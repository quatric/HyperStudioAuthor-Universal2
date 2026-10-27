#import "HSZipWrapper.h"
#import "HSZipDirectoryWrapper.h"
#import "HSZipFileWrapper.h"
#import "HSMediaFileWrapper.h"
#import "HSTemporaryFilesManager.h"
#import "NSFileManager+HSExtensions.h"
#import "NSString+NSStringLinkRecognitionHSExtensions.h"
#import <zlib.h>

// A directory file wrapper read from and written as a ZIP archive (stored or
// deflated entries, no data descriptors). The first local header of a stack
// archive carries the signature "HS\3\4" instead of "PK\3\4". Reading uses
// the central directory, or scans the local headers one after the other when
// the directory is damaged; entries larger than 10 MB are extracted to
// temporary files.
@implementation HSZipWrapper

enum {
    HSZipLocalHeaderSignature = 0x04034b50,         // "PK\3\4"
    HSZipFirstLocalHeaderSignature = 0x04035348,    // "HS\3\4"
    HSZipCentralHeaderSignature = 0x02014b50,
    HSZipEndOfCentralDirectorySignature = 0x06054b50,
    HSZipLocalHeaderSize = 30,
    HSZipCentralHeaderSize = 46,
    HSZipEndOfCentralDirectorySize = 22,
    HSZipLargeEntrySize = 0xa00000,
};

static unsigned int HSZipDataOffset(HSZipWrapper *self, struct SZipFileInfo anEntry, BOOL *aValid)
{
    // f0 local header offset, f1 data offset (0 until known), f2 compression
    // method, f3 compressed size, f4 uncompressed size.
    if (anEntry.f1 != 0)
        return anEntry.f1;
    NSData *data = [self subdataWithRange:NSMakeRange(anEntry.f0, HSZipLocalHeaderSize)];
    if (data == nil) {
        if (aValid)
            *aValid = NO;
        return 0;
    }
    struct SLocalFileHeader header;
    HSReadSLocalFileHeader(&header, [data bytes]);
    return anEntry.f0 + HSZipLocalHeaderSize + header.FilenameLength + header.ExtraFieldLength;
}

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError
{
    return NO;
}

// Raw deflate; nil when the output would not be smaller than the input.
- (id)compressedData:(id)aData withCompressionLevel:(NSUInteger)aLevel
{
    z_stream stream;
    memset(&stream, 0, sizeof(stream));
    deflateInit2(&stream, (int)aLevel, Z_DEFLATED, -MAX_WBITS, 9, Z_DEFAULT_STRATEGY);
    stream.avail_in = (uInt)[aData length];
    stream.next_in = (Bytef *)[aData bytes];
    NSMutableData *result = [[NSMutableData alloc] initWithLength:[aData length]];
    stream.avail_out = (uInt)[result length];
    stream.next_out = [result mutableBytes];
    int status = deflate(&stream, Z_FINISH);
    NSUInteger length = [result length] - stream.avail_out;
    deflateEnd(&stream);
    if (status != Z_STREAM_END) {
        [result release];
        return nil;
    }
    [result setLength:length];
    return [result autorelease];
}

// Reads the entries listed in the central directory.
- (BOOL)scanLocalHeader
{
    if (_stackSize < HSZipEndOfCentralDirectorySize)
        return NO;
    BOOL result = NO;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    unsigned char end[HSZipEndOfCentralDirectorySize];
    id offset = [NSNumber numberWithLongLong:_stackSize - HSZipEndOfCentralDirectorySize];
    if (offset != nil && [_inputStream setProperty:offset forKey:NSStreamFileCurrentOffsetKey] &&
        [_inputStream read:end maxLength:HSZipEndOfCentralDirectorySize] == HSZipEndOfCentralDirectorySize) {
        unsigned int signature = end[0] | end[1] << 8 | end[2] << 16 | (unsigned int)end[3] << 24;
        unsigned short entriesOnDisk = end[8] | end[9] << 8;
        unsigned short entries = end[10] | end[11] << 8;
        unsigned int directoryOffset = end[16] | end[17] << 8 | end[18] << 16 | (unsigned int)end[19] << 24;
        if (signature == HSZipEndOfCentralDirectorySignature && entries == entriesOnDisk && directoryOffset <= _stackSize) {
            NSData *directory = [self subdataWithRange:NSMakeRange(directoryOffset, _stackSize - directoryOffset)];
            if (directory != nil) {
                const unsigned char *bytes = [directory bytes];
                const unsigned char *limit = bytes + [directory length];
                size_t position = 0;
                unsigned short i;
                for (i = 0; i < entries; i++) {
                    struct SFileHeader header;
                    if (limit < bytes + position + HSZipCentralHeaderSize)
                        goto damaged;
                    HSReadSFileHeader(&header, bytes + position);
                    if (header.Signature != HSZipCentralHeaderSignature)
                        goto damaged;
                    position += HSZipCentralHeaderSize;
                    if (limit < bytes + position + header.FilenameLength)
                        goto damaged;
                    NSString *path = [self createStringFromFilenameRecord:(void *)(bytes + position) count:header.FilenameLength];
                    struct SZipFileInfo entry = { header.LocalHeaderOffset, 0, header.CompressionMethod,
                                                  header.DataDescriptor.CompressedSize, header.DataDescriptor.UncompressedSize };
                    // The original released the path a second time when the
                    // entry was rejected.
                    [self addFileWrapperForPath:path withEntry:entry];
                    position += header.FilenameLength + header.ExtraFieldLength + header.CommentLength;
                    [path release];
                }
                result = YES;
                goto done;
            damaged:
                [self scanZipFileInConsecutiveOrderWithDeclaredEntriesCount:entries searchEndPosition:directoryOffset];
                result = YES;
            }
        }
    }
done:
    [pool release];
    return result;
}

// Fallback for a damaged directory: walks the local headers, searching for
// the next signature where the expected one is missing.
- (void)scanZipFileInConsecutiveOrderWithDeclaredEntriesCount:(NSUInteger)aCount searchEndPosition:(NSUInteger)aPosition
{
    NSUInteger position = 0;
    NSUInteger found = 0;
    while (position != NSNotFound) {
        struct SLocalFileHeader header;
        NSData *data = [self subdataWithRange:NSMakeRange(position, HSZipLocalHeaderSize)];
        if (data != nil)
            HSReadSLocalFileHeader(&header, [data bytes]);
        unsigned int signature = found == 0 ? HSZipFirstLocalHeaderSignature : HSZipLocalHeaderSignature;
        if (data == nil || header.Signature != signature) {
            unsigned char pattern[4] = { signature & 0xff, (signature >> 8) & 0xff, (signature >> 16) & 0xff, signature >> 24 };
            position = [self rangeOfData:[NSData dataWithBytes:pattern length:4] options:0 range:NSMakeRange(position, 0)].location;
            if (position == NSNotFound)
                return;
            data = [self subdataWithRange:NSMakeRange(position, HSZipLocalHeaderSize)];
            if (data == nil)
                return;
            HSReadSLocalFileHeader(&header, [data bytes]);
        }
        BOOL added = NO;
        if (header.VersionToExtract == 10) {
            NSUInteger nameOffset = position + HSZipLocalHeaderSize;
            NSData *nameData = [self subdataWithRange:NSMakeRange(nameOffset, header.FilenameLength)];
            if (nameData != nil) {
                NSString *path = [self createStringFromFilenameRecord:(void *)[nameData bytes] count:header.FilenameLength];
                // The original leaked the path when its length did not match.
                if ([path length] == header.FilenameLength) {
                    struct SZipFileInfo entry = { (unsigned int)position,
                                                  (unsigned int)(nameOffset + header.FilenameLength + header.ExtraFieldLength),
                                                  header.CompressionMethod, header.DataDescriptor.CompressedSize,
                                                  header.DataDescriptor.UncompressedSize };
                    if ([self addFileWrapperForPath:path withEntry:entry]) {
                        position = entry.f1 + entry.f3;
                        found++;
                        added = YES;
                    }
                }
                [path release];
            }
        }
        if (!added)
            position++;
        if (position > aPosition)
            return;
    }
}

// Adds the entry at its path, creating intermediate directories. Paths ending
// in "/" or "\" are directories; empty files are skipped.
- (BOOL)addFileWrapperForPath:(id)aPath withEntry:(struct SZipFileInfo)aEntry
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id wrapper = nil;
    if ([aPath hasSuffix:@"\\"] || [aPath hasSuffix:@"/"]) {
        wrapper = [[HSZipDirectoryWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
        aPath = [aPath substringToIndex:[aPath length] - 1];
    } else if (aEntry.f4 != 0) {
        if (aEntry.f4 > HSZipLargeEntrySize) {
            NSString *path = [HSTemporaryFilesManager generatedTempFilePathWithExtension:[[aPath lastPathComponent] pathExtension]];
            [HSTemporaryFilesManager registerTempFileAtPath:path];
            NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
            if (stream != nil) {
                [stream open];
                if ([stream streamStatus] == NSStreamStatusOpen && [self writeEntry:aEntry toStream:stream]) {
                    [stream close];
                    wrapper = [[HSZipFileWrapper alloc] initWithPath:path];
                }
            }
            [HSTemporaryFilesManager unregisterTempFileAtPath:path];
        }
        if (wrapper == nil) {
            NSData *data = [self dataForEntry:aEntry];
            if (data != nil)
                wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        }
    }
    BOOL result = NO;
    if (wrapper != nil) {
        NSArray *components = [aPath pathComponents];
        NSUInteger count = [components count];
        id parent = self;
        NSUInteger i;
        for (i = 0; count > 1 && i < count - 1; i++) {
            NSString *component = [components objectAtIndex:i];
            if (i == 0 && [component length] == 0)
                continue;
            id child = [[parent fileWrappers] objectForKey:component];
            if (child == nil) {
                child = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
                [child setPreferredFilename:component];
                [parent addFileWrapper:child];
                [child release];
            }
            parent = child;
        }
        NSString *name = [components lastObject];
        [wrapper setPreferredFilename:name];
        id existing = [[parent fileWrappers] objectForKey:name];
        if (existing != nil)
            [parent removeFileWrapper:existing];
        NSString *key = [parent addFileWrapper:wrapper];
        if (![key isEqualToString:name] && _delegate != nil &&
            [_delegate respondsToSelector:@selector(zipWrapper:didChangeFileNameFrom:toName:)])
            [_delegate zipWrapper:self didChangeFileNameFrom:name toName:key];
        [wrapper release];
        result = YES;
    }
    [pool release];
    return result;
}

- (id)dataForEntry:(struct SZipFileInfo)aEntry
{
    BOOL valid = YES;
    aEntry.f1 = HSZipDataOffset(self, aEntry, &valid);
    if (!valid)
        return nil;
    if (aEntry.f2 == 0)
        return [self subdataWithRange:NSMakeRange(aEntry.f1, aEntry.f4)];
    if (aEntry.f2 > 10)
        return nil;
    NSData *compressed = [self subdataWithRange:NSMakeRange(aEntry.f1, aEntry.f3)];
    z_stream stream;
    memset(&stream, 0, sizeof(stream));
    if (inflateInit2(&stream, -MAX_WBITS) != Z_OK)
        return nil;
    stream.avail_in = aEntry.f3;
    stream.next_in = (Bytef *)[compressed bytes];
    NSMutableData *output = [[NSMutableData alloc] initWithLength:aEntry.f4];
    stream.avail_out = aEntry.f4;
    stream.next_out = [output mutableBytes];
    int status = inflate(&stream, Z_FINISH);
    if (status == Z_BUF_ERROR) {
        // The declared size was too small: one more buffer of the same size.
        NSMutableData *more = [[NSMutableData alloc] initWithLength:aEntry.f4];
        stream.avail_out = (uInt)[more length];
        stream.next_out = [more mutableBytes];
        status = inflate(&stream, Z_FINISH);
        if (status == Z_STREAM_END) {
            // The original appended the whole second buffer.
            [more setLength:[more length] - stream.avail_out];
            [output appendData:more];
        }
        [more release];
    }
    id result = nil;
    if (status == Z_STREAM_END)
        result = [NSData dataWithData:output];
    // The original skipped inflateEnd on failure.
    inflateEnd(&stream);
    [output release];
    return result;
}

// Copies the (uncompressed) entry to the stream; stored entries are copied in
// 4 KB pieces without loading them.
- (BOOL)writeEntry:(struct SZipFileInfo)aEntry toStream:(id)aStream
{
    aEntry.f1 = HSZipDataOffset(self, aEntry, NULL);
    if (aEntry.f2 != 0) {
        NSData *data = [self dataForEntry:aEntry];
        return [aStream write:[data bytes] maxLength:[data length]] == (NSInteger)[data length];
    }
    BOOL result = YES;
    uint8_t *buffer = malloc(0x1000);
    NSRange entry = NSMakeRange(aEntry.f1, aEntry.f4);
    NSRange piece = NSIntersectionRange(entry, NSMakeRange(aEntry.f1, 0x1000));
    [_inputStream setProperty:[NSNumber numberWithLongLong:aEntry.f1] forKey:NSStreamFileCurrentOffsetKey];
    while (piece.length != 0) {
        NSInteger read = [_inputStream read:buffer maxLength:piece.length];
        // The original looped forever on a short archive (read of 0 or -1).
        if (read <= 0 || [aStream write:buffer maxLength:read] != read) {
            result = NO;
            break;
        }
        piece = NSIntersectionRange(entry, NSMakeRange(piece.location + read, 0x1000));
    }
    free(buffer);
    return result;
}

// Entry names are UTF-8 (at most 4095 bytes); the per-byte stream conversion
// runs without keys, so it leaves them unchanged. Returns a retained string.
- (id)createStringFromFilenameRecord:(void *)aRecord count:(NSInteger)aCount
{
    if (aRecord == NULL || aCount < 1 || aCount > 0xfff)
        return nil;
    char buffer[0x1000];
    memcpy(buffer, aRecord, aCount);
    buffer[aCount] = 0;
    NSInteger i;
    for (i = 0; i < aCount; i++)
        buffer[i] = (char)SHIFER_streamConvert((unsigned char)buffer[i], (unsigned int)i, nil, nil);
    return [[NSString alloc] initWithUTF8String:buffer];
}

// Finds the bytes in the archive, reading pieces of aRange.length (100 times
// the pattern length when 0) that overlap by the pattern length. The original
// matched through ASCII strings and lost the last, partial piece (it searched
// an already released string); this searches the bytes and includes it.
- (NSRange)rangeOfData:(id)aData options:(NSUInteger)aOptions range:(NSRange)aRange
{
    NSUInteger patternLength = [aData length];
    NSUInteger pieceLength = aRange.length != 0 ? aRange.length : patternLength * 100;
    NSUInteger position = aRange.location;
    if (patternLength == 0 || pieceLength <= patternLength)
        return NSMakeRange(NSNotFound, 0);
    while (position < _stackSize) {
        NSUInteger length = MIN(pieceLength, _stackSize - position);
        NSData *piece = [self subdataWithRange:NSMakeRange(position, length)];
        if (piece == nil)
            break;
        const void *match = memmem([piece bytes], length, [aData bytes], patternLength);
        if (match != NULL)
            return NSMakeRange(position + ((const char *)match - (const char *)[piece bytes]), patternLength);
        if (length < pieceLength)
            break;
        position += pieceLength - patternLength;
    }
    return NSMakeRange(NSNotFound, 0);
}

- (id)subdataWithRange:(NSRange)aRange
{
    NSMutableData *data = [NSMutableData dataWithLength:aRange.length];
    void *bytes = [data mutableBytes];
    id offset = [NSNumber numberWithLongLong:aRange.location];
    if (data == nil || bytes == NULL || offset == nil ||
        ![_inputStream setProperty:offset forKey:NSStreamFileCurrentOffsetKey] ||
        [_inputStream read:bytes maxLength:aRange.length] != (NSInteger)aRange.length)
        return nil;
    return data;
}

- (NSUInteger)writeFileWrapper:(id)aWrapper parentFileWrapper:(id)aWrapper2 parentPath:(id)aPath outStream:(id)aStream
{
    unsigned int written = 0;
    [self writeFileWrapper:aWrapper parentFileWrapper:aWrapper2 parentPath:aPath outStream:aStream byteWritten:&written error:NULL];
    return written;
}

// Writes the local header, name and data of one entry and records its central
// header (directories, media and non-empty files). Media wrappers write
// themselves; afterwards their CRC and sizes are patched into the local
// header, or, when they ask to (2), the entry is written again in retrying
// mode.
- (BOOL)writeFileWrapper:(id)aWrapper parentFileWrapper:(id)aWrapper2 parentPath:(id)aPath outStream:(id)aStream byteWritten:(unsigned int *)aWritten error:(id *)aError
{
    NSString *offsetKey = NSStreamFileCurrentOffsetKey;
    NSAutoreleasePool *pool = nil;
    BOOL retrying = NO;
    BOOL result = NO;
    for (;;) {
        [pool release];
        pool = [[NSAutoreleasePool alloc] init];
        NSString *name = [aWrapper2 keyForFileWrapper:aWrapper];
        if (name == nil)
            goto done;
        if (aPath != nil && (name = [aPath stringByAppendingPathComponent:name]) == nil)
            goto done;
        BOOL isDirectory = [aWrapper isDirectory];
        if (isDirectory && (name = [name stringByAppendingString:@"/"]) == nil)
            goto done;
        NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger nameLength = [nameData length];
        if (nameLength == 0)
            goto done;

        struct SLocalFileHeader local;
        memset(&local, 0, sizeof(local));
        local.Signature = HSZipLocalHeaderSignature;
        local.VersionToExtract = 10;
        local.FilenameLength = (unsigned short)nameLength;
        struct SFileHeader central;
        memset(&central, 0, sizeof(central));
        central.Signature = HSZipCentralHeaderSignature;
        central.VersionPacked = 0x317;      // Unix, 2.3
        central.VersionToExtract = 10;
        central.FilenameLength = (unsigned short)nameLength;
        central.ExternalFileAttr = 0x41ed0000;      // drwxr-xr-x

        long long headerOffset = [[aStream propertyForKey:offsetKey] longLongValue];
        if (headerOffset >= 0xffffffffLL)
            goto done;
        central.LocalHeaderOffset = (unsigned int)headerOffset;
        BOOL isMedia = [aWrapper isKindOfClass:[HSMediaFileWrapper class]];

        NSData *contents = nil;
        NSString *contentsPath = nil;
        unsigned int size = 0;
        if (!isDirectory) {
            central.ExternalFileAttr = 0x81a40000;  // -rw-r--r--
            if (!isMedia) {
                NSFileManager *manager = [NSFileManager defaultManager];
                contentsPath = [aWrapper hyperContentFilePath];
                uLong crc;
                if (contentsPath != nil && [manager hyperIsFileReadableAtPath:contentsPath]) {
                    // Streamed from the file instead of loaded.
                    size = (unsigned int)[[manager attributesOfItemAtPath:[contentsPath stringByResolvingSymlinksInPath] error:NULL] fileSize];
                    local.DataDescriptor.UncompressedSize = size;
                    crc = crc32(0, NULL, 0);
                    NSInputStream *input = [[NSInputStream alloc] initWithFileAtPath:contentsPath];
                    [input open];
                    if ([input streamStatus] == NSStreamStatusOpen) {
                        uint8_t *buffer = malloc(0x1000);
                        if (buffer != NULL) {
                            NSInteger read;
                            while ((read = [input read:buffer maxLength:0x1000]) > 0)
                                crc = crc32(crc, buffer, (uInt)read);
                            free(buffer);
                        }
                    } else if ([input streamStatus] == NSStreamStatusError) {
                        NSLog(@"%@", [[input streamError] localizedDescription]);
                    }
                    [input close];
                    [input release];
                } else {
                    contents = [aWrapper regularFileContents];
                    if (contents == nil)
                        goto done;
                    size = (unsigned int)[contents length];
                    local.DataDescriptor.UncompressedSize = size;
                    crc = crc32(crc32(0, NULL, 0), [contents bytes], (uInt)[contents length]);
                }
                local.DataDescriptor.CRC32 = (unsigned int)crc;
                if ([_delegate respondsToSelector:@selector(compressLevelForFileWrapper:zipWrapper:)]) {
                    NSUInteger level = [_delegate compressLevelForFileWrapper:aWrapper zipWrapper:self];
                    if (level != 0) {
                        if (contents == nil) {
                            contents = [NSData dataWithContentsOfFile:contentsPath];
                            if (contents != nil)
                                contentsPath = nil;
                        }
                        NSData *compressed = contents != nil ? [self compressedData:contents withCompressionLevel:level] : nil;
                        if (compressed != nil) {
                            local.CompressionMethod = Z_DEFLATED;
                            contents = compressed;
                            size = (unsigned int)[compressed length];
                        }
                    }
                }
                local.DataDescriptor.CompressedSize = size;
            }
        }
        if ([_fileHeaders count] == 0)
            local.Signature = HSZipFirstLocalHeaderSignature;
        if (HSWriteSLocalFileHeader(local, aStream) != HSZipLocalHeaderSize)
            goto done;
        *aWritten += HSZipLocalHeaderSize;
        if ([nameData bytes] == NULL || [aStream write:[nameData bytes] maxLength:nameLength] != (NSInteger)nameLength)
            goto done;
        *aWritten += (unsigned int)nameLength;

        if (isMedia) {
            unsigned int crc = 0, length = 0;
            NSInteger status = [aWrapper writeToStream:aStream retrying:retrying CRC32:&crc writtenLength:&length error:aError];
            if (status == 0)
                goto done;
            if (status == 2) {
                // Rewind over the header and write the entry again.
                id rewind = [NSNumber numberWithLongLong:headerOffset];
                if (rewind == nil || ![aStream setProperty:rewind forKey:offsetKey])
                    goto done;
                *aWritten -= HSZipLocalHeaderSize + (unsigned int)nameLength;
                retrying = YES;
                if (aError)
                    *aError = nil;
                continue;
            }
            local.DataDescriptor.CRC32 = crc;
            local.DataDescriptor.CompressedSize = length;
            local.DataDescriptor.UncompressedSize = length;
            id current = [aStream propertyForKey:offsetKey];
            if (current == nil)
                goto done;
            id patch = [NSNumber numberWithLongLong:headerOffset + 14];
            if (patch == nil || ![aStream setProperty:patch forKey:offsetKey])
                goto done;
            uint8_t descriptor[12];
            unsigned int values[3] = { crc, length, length };
            int k;
            for (k = 0; k < 12; k++)
                descriptor[k] = (values[k / 4] >> (8 * (k % 4))) & 0xff;
            if ([aStream write:descriptor maxLength:4] != 4 || [aStream write:descriptor + 4 maxLength:4] != 4 ||
                [aStream write:descriptor + 8 maxLength:4] != 4)
                goto done;
            if (![aStream setProperty:current forKey:offsetKey])
                goto done;
            *aWritten += length;
        }

        central.DataDescriptor = local.DataDescriptor;
        central.CompressionMethod = local.CompressionMethod;
        if (isMedia || isDirectory || size != 0) {
            HSFileHeader *header = [[HSFileHeader alloc] initWithFileHeader:central fileNameData:nameData];
            if (header == nil)
                goto done;
            [_fileHeaders addObject:header];
            [header release];
        }
        if (!isMedia) {
            if (isDirectory) {
                id children = [aWrapper fileWrappers];
                if (children != nil &&
                    ![self writeFileWrappers:children parentFileWrapper:aWrapper parentPath:name outStream:aStream byteWritten:aWritten error:aError])
                    goto done;
            } else if (size != 0) {
                if (contents != nil) {
                    if ([aStream write:[contents bytes] maxLength:size] != (NSInteger)size)
                        goto done;
                } else if (![self writeDataFromFile:contentsPath toStream:aStream]) {
                    goto done;
                }
                *aWritten += size;
            }
        }
        result = YES;
        break;
    }
done:
    if (aError) {
        [*aError retain];
        [pool release];
        [*aError autorelease];
    } else {
        [pool release];
    }
    return result;
}

- (NSUInteger)writeFileWrappers:(id)aWrappers parentFileWrapper:(id)aWrapper parentPath:(id)aPath outStream:(id)aStream
{
    unsigned int written = 0;
    [self writeFileWrappers:aWrappers parentFileWrapper:aWrapper parentPath:aPath outStream:aStream byteWritten:&written error:NULL];
    return written;
}

// A "quicklook" directory goes last.
- (BOOL)writeFileWrappers:(id)aWrappers parentFileWrapper:(id)aWrapper parentPath:(id)aPath outStream:(id)aStream byteWritten:(unsigned int *)aWritten error:(id *)aError
{
    NSEnumerator *enumerator = [[aWrappers allValues] objectEnumerator];
    id quickLook = nil;
    BOOL result = YES;
    id wrapper;
    while ((wrapper = [enumerator nextObject]) != nil) {
        if (quickLook == nil && [wrapper isDirectory] && [[wrapper preferredFilename] isEqualToString:@"quicklook"]) {
            // The original also wrote it here, then a second time at the end.
            quickLook = [wrapper retain];
            continue;
        }
        result = [self writeFileWrapper:wrapper parentFileWrapper:aWrapper parentPath:aPath outStream:aStream byteWritten:aWritten error:aError];
        if (!result)
            break;
    }
    if (result && quickLook != nil)
        result = [self writeFileWrapper:quickLook parentFileWrapper:aWrapper parentPath:aPath outStream:aStream byteWritten:aWritten error:aError];
    [quickLook release];
    return result;
}

- (BOOL)writeDataFromFile:(id)aFile toStream:(id)aStream
{
    NSInputStream *input = [[NSInputStream alloc] initWithFileAtPath:aFile];
    if (input == nil)
        return NO;
    [input open];
    BOOL result = NO;
    if ([input streamStatus] == NSStreamStatusOpen) {
        result = [self writeDataFromStream:input toStream:aStream];
        [input close];
    }
    // The original leaked the stream when it did not open.
    [input release];
    return result;
}

- (BOOL)writeDataFromStream:(id)aStream toStream:(id)aStream2
{
    uint8_t *buffer = malloc(0x1000);
    BOOL result;
    for (;;) {
        NSInteger read = [aStream read:buffer maxLength:0x1000];
        if (read == 0) {
            result = YES;
            break;
        }
        // A read error (-1) is a failure; the original passed it on to write.
        if (read < 0 || [aStream2 write:buffer maxLength:read] != read) {
            result = NO;
            break;
        }
    }
    free(buffer);
    return result;
}

- (BOOL)updateFromPath:(id)aPath
{
    return NO;
}

- (id)serializedRepresentation
{
    return nil;
}

- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames
{
    NSURL *URL = [NSURL fileURLWithPath:aFile];
    if (URL == nil)
        return NO;
    return [self hyperWriteToURL:URL atomically:aAtomically updateFilenames:aFilenames error:NULL];
}

// Writes the entries, then the central directory, and truncates the file
// after it. Atomic writes go to a temporary file that is copied over the
// destination.
- (BOOL)hyperWriteToURL:(id)aURL atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames error:(id *)aError
{
    NSString *path = [aURL path];
    if (path == nil)
        return NO;
    NSString *temporaryPath = nil;
    if (aAtomically)
        temporaryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString hyperUIDString]];
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:aAtomically ? temporaryPath : path append:NO];
    [stream open];
    if ([stream streamStatus] != NSStreamStatusOpen) {
        // The original leaked the stream on its failure paths.
        [stream release];
        return NO;
    }
    [_fileHeaders release];
    _fileHeaders = [NSMutableArray new];
    unsigned int written = 0;
    if (![self writeFileWrappers:[self fileWrappers] parentFileWrapper:self parentPath:nil outStream:stream byteWritten:&written error:aError]) {
        [stream close];
        [stream release];
        return NO;
    }
    struct SZipDirectory directory;
    memset(&directory, 0, sizeof(directory));
    directory.Signature = HSZipEndOfCentralDirectorySignature;
    directory.CentralDirectoryOffset = written;
    directory.EntriesInCentralDirectory = directory.EntriesInCentralDirectoryOnThisDisk = (unsigned short)[_fileHeaders count];
    unsigned int directorySize = 0;
    NSEnumerator *enumerator = [_fileHeaders objectEnumerator];
    HSFileHeader *header;
    while ((header = [enumerator nextObject]) != nil) {
        directorySize += HSWriteSFileHeader([header fileHeader], stream);
        NSData *nameData = [header fileNameData];
        directorySize += (unsigned int)[stream write:[nameData bytes] maxLength:[nameData length]];
    }
    directory.CentralDirectorySize = directorySize;
    HSWriteSDirectory(directory, stream);
    [_fileHeaders release];
    _fileHeaders = nil;
    long long length = [[stream propertyForKey:NSStreamFileCurrentOffsetKey] longLongValue];
    [stream close];
    [stream release];

    const char *fileSystemPath = [aAtomically ? temporaryPath : path fileSystemRepresentation];
    if (fileSystemPath == NULL || truncate(fileSystemPath, length) == -1)
        return NO;
    if (!aAtomically)
        return YES;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path] && ![manager removeItemAtPath:path error:NULL])
        return NO;
    BOOL result = [manager copyItemAtPath:temporaryPath toPath:path error:NULL];
    [manager removeItemAtPath:temporaryPath error:NULL];
    return result;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)initSymbolicLinkWithDestination:(id)aDestination
{
    return [self initSymbolicLinkWithDestination:aDestination withDelegate:nil];
}

// Quirk kept: opens the destination as an archive.
- (id)initSymbolicLinkWithDestination:(id)aDestination withDelegate:(id)aDelegate
{
    return [self initWithPath:aDestination withDelegate:aDelegate];
}

- (id)initWithPath:(id)aPath
{
    return [self initWithPath:aPath withDelegate:nil];
}

// Archives of 4 GB or more are refused.
- (id)initWithPath:(id)aPath withDelegate:(id)aDelegate
{
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:[aPath stringByResolvingSymlinksInPath] error:NULL] fileSize];
    if (size >> 32) {
        [self release];
        return nil;
    }
    _stackSize = (unsigned int)size;
    return [self initWithInputStream:[NSInputStream inputStreamWithFileAtPath:aPath] withDelegate:aDelegate];
}

- (id)initRegularFileWithContents:(id)aContents
{
    return [self initRegularFileWithContents:aContents withDelegate:nil];
}

- (id)initRegularFileWithContents:(id)aContents withDelegate:(id)aDelegate
{
    _stackSize = (unsigned int)[aContents length];
    return [self initWithInputStream:[NSInputStream inputStreamWithData:aContents] withDelegate:aDelegate];
}

// Reads the whole archive now; the stream is closed afterwards.
- (id)initWithInputStream:(id)aStream withDelegate:(id)aDelegate
{
    self = [super initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    if (self != nil) {
        _inputStream = [aStream retain];
        [_inputStream open];
        if ([_inputStream streamStatus] != NSStreamStatusOpen) {
            [self release];
            return nil;
        }
        _delegate = aDelegate;
        [self scanLocalHeader];
        [_inputStream close];
        [_inputStream release];
        _inputStream = nil;
    }
    return self;
}

- (void)dealloc
{
    [_inputStream close];
    [_inputStream release];
    [super dealloc];
}

@end

@implementation HSFileHeader

- (id)fileNameData
{
    return _fileNameData;
}

- (struct SFileHeader)fileHeader
{
    return _fileHeader;
}

- (void)dealloc
{
    [_fileNameData release];
    [super dealloc];
}

- (id)initWithFileHeader:(struct SFileHeader)aHeader fileNameData:(id)aData
{
    self = [super init];
    if (self != nil) {
        _fileNameData = [aData retain];
        _fileHeader = aHeader;
    }
    return self;
}

@end
