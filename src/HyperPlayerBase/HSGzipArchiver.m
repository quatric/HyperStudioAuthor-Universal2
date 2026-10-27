#import "HSGzipArchiver.h"
#import <zlib.h>
// Unpacks gzip data (concatenated members too) or Unix compress (LZW .Z)
// data from inputData into outputData. This is zlib's "gun" example (its
// gunpipe and lunpipe) reading from NSData instead of file descriptors;
// errors become errorString with "-" as the file name.

#define HSGzipBufferSize 32768U
#define HSGzipPieceSize 16384U

// (The original keeps these buffers in static storage, so unpacking is
// not reentrant; here each unpack allocates its own.)
struct HSGzipBuffers {
    unsigned char input[HSGzipBufferSize];
    unsigned char output[HSGzipBufferSize];
    unsigned short prefix[65536];
    unsigned char suffix[65536];
    unsigned char match[65280 + 2];
};

struct HSGzipInput {
    HSGzipArchiver *archiver;
    unsigned char *buffer;
};

struct HSGzipOutput {
    BOOL write;
    BOOL check;
    unsigned long crc;
    unsigned long total;
    HSGzipArchiver *archiver;
};

// Reads up to 32K of input into the input buffer, 16K at a time.
static unsigned HSGzipArchiverIn(void *aDescriptor, unsigned char **aBuffer)
{
    struct HSGzipInput *input = aDescriptor;
    NSData *data = [input->archiver inputData];
    unsigned char *next = input->buffer;
    unsigned have = 0;
    *aBuffer = next;
    do {
        NSInteger position = [input->archiver currentPosition];
        NSInteger length = HSGzipBufferSize - have;
        if (length > HSGzipPieceSize)
            length = HSGzipPieceSize;
        if ((NSInteger)[data length] - position < length)
            length = (NSInteger)[data length] - position;
        if (length <= 0)
            break;
        [data getBytes:next range:NSMakeRange(position, length)];
        have += length;
        [input->archiver setCurrentPosition:position + length];
        next += length;
    } while (have < HSGzipBufferSize);
    return have;
}

// Appends output, keeping the CRC and length when checking a gzip member.
static int HSGzipArchiverOut(void *aDescriptor, unsigned char *aBytes, unsigned aLength)
{
    struct HSGzipOutput *output = aDescriptor;
    if (output->check) {
        output->crc = crc32(output->crc, aBytes, aLength);
        output->total += aLength;
    }
    if (output->write)
        [[output->archiver outputData] appendBytes:aBytes length:aLength];
    return 0;
}

// Next input byte into last, or -1 at the end of the input.
#define NEXT() (have ? 0 : (have = HSGzipArchiverIn(input, &next)), \
                last = have ? (have--, (int)(*next++)) : -1)

// Skips the rest of the current chunk of codes when the code size changes.
#define FLUSHCODE() \
    do { \
        left = 0; \
        rem = 0; \
        if (chunk > have) { \
            chunk -= have; \
            have = 0; \
            if (NEXT() == -1) \
                break; \
            chunk--; \
            if (chunk > have) { \
                chunk = have = 0; \
                break; \
            } \
        } \
        have -= chunk; \
        next += chunk; \
        chunk = 0; \
    } while (0)

// Decodes the rest of a compress (LZW) stream after its two magic bytes.
static int HSGzipArchiverLZWUnpack(unsigned have, unsigned char *next, struct HSGzipInput *input, HSGzipArchiver *anArchiver, z_stream *aStream, struct HSGzipBuffers *buffers)
{
    int last;
    unsigned chunk;
    int left;
    unsigned rem;
    int bits;
    unsigned code;
    unsigned mask;
    int max;
    unsigned flags;
    unsigned end;
    unsigned temp;
    unsigned prev;
    unsigned final;
    unsigned stack;
    unsigned outcnt;
    struct HSGzipOutput output = {YES, NO, 0, 0, anArchiver};
    unsigned char *outbuf = buffers->output;
    unsigned char *match = buffers->match;
    unsigned char *p;

    flags = NEXT();
    if (last == -1)
        return Z_BUF_ERROR;
    if (flags & 0x60) {
        aStream->msg = (char *)"unknown lzw flags set";
        return Z_DATA_ERROR;
    }
    max = flags & 0x1f;
    if (max < 9 || max > 16) {
        aStream->msg = (char *)"lzw bits out of range";
        return Z_DATA_ERROR;
    }
    if (max == 9)
        max = 10;
    flags &= 0x80;

    bits = 9;
    mask = 0x1ff;
    end = flags ? 256 : 255;

    // The first 9-bit code is the first byte; no table entry until the next.
    if (NEXT() == -1)
        return Z_OK;
    final = prev = (unsigned)last;
    if (NEXT() == -1)
        return Z_BUF_ERROR;
    if (last & 1) {
        aStream->msg = (char *)"invalid lzw code";
        return Z_DATA_ERROR;
    }
    rem = (unsigned)last >> 1;
    left = 7;
    chunk = bits - 2;
    outbuf[0] = (unsigned char)final;
    outcnt = 1;

    stack = 0;
    for (;;) {
        if (end >= mask && bits < max) {
            FLUSHCODE();
            bits++;
            mask <<= 1;
            mask++;
        }

        if (chunk == 0)
            chunk = bits;
        code = rem;
        if (NEXT() == -1) {
            if (outcnt && HSGzipArchiverOut(&output, outbuf, outcnt)) {
                aStream->next_in = outbuf;
                return Z_BUF_ERROR;
            }
            return Z_OK;
        }
        code += (unsigned)last << left;
        left += 8;
        chunk--;
        if (bits > left) {
            if (NEXT() == -1)
                return Z_BUF_ERROR;
            code += (unsigned)last << left;
            left += 8;
            chunk--;
        }
        code &= mask;
        left -= bits;
        rem = (unsigned)last >> (8 - left);

        // Clear code.
        if (code == 256 && flags) {
            FLUSHCODE();
            bits = 9;
            mask = 0x1ff;
            end = 255;
            continue;
        }

        // The code being defined reuses the last match.
        temp = code;
        if (code > end) {
            if (code != end + 1 || prev > end) {
                aStream->msg = (char *)"invalid lzw code";
                return Z_DATA_ERROR;
            }
            match[stack++] = (unsigned char)final;
            code = prev;
        }

        p = match + stack;
        while (code >= 256) {
            *p++ = buffers->suffix[code];
            code = buffers->prefix[code];
        }
        stack = (unsigned)(p - match);
        match[stack++] = (unsigned char)code;
        final = code;

        if (end < mask) {
            end++;
            buffers->prefix[end] = (unsigned short)prev;
            buffers->suffix[end] = (unsigned char)final;
        }

        prev = temp;

        while (stack > HSGzipBufferSize - outcnt) {
            while (outcnt < HSGzipBufferSize)
                outbuf[outcnt++] = match[--stack];
            if (HSGzipArchiverOut(&output, outbuf, outcnt)) {
                aStream->next_in = outbuf;
                return Z_BUF_ERROR;
            }
            outcnt = 0;
        }
        p = match + stack;
        do {
            outbuf[outcnt++] = *--p;
        } while (p > match);
        stack = 0;
    }
}

// Decodes concatenated gzip members (or one compress stream).
static int HSGzipArchiverUnpackStreams(z_stream *aStream, HSGzipArchiver *anArchiver, struct HSGzipBuffers *buffers)
{
    int ret, first, last;
    unsigned have, flags, len;
    unsigned char *next = NULL;
    struct HSGzipInput inputDescriptor = {anArchiver, buffers->input};
    struct HSGzipInput *input = &inputDescriptor;
    struct HSGzipOutput output;

    have = 0;
    first = 1;
    aStream->next_in = Z_NULL;
    for (;;) {
        if (NEXT() == -1) {
            ret = Z_OK;
            break;
        }
        if (last != 31 || (NEXT() != 139 && last != 157)) {
            aStream->msg = (char *)"incorrect header check";
            ret = first ? Z_DATA_ERROR : Z_ERRNO;
            break;
        }
        first = 0;

        if (last == 157) {
            ret = HSGzipArchiverLZWUnpack(have, next, input, anArchiver, aStream, buffers);
            break;
        }

        ret = Z_BUF_ERROR;
        if (NEXT() != 8) {
            if (last == -1)
                break;
            aStream->msg = (char *)"unknown compression method";
            ret = Z_DATA_ERROR;
            break;
        }
        flags = NEXT();
        NEXT();
        NEXT();
        NEXT();
        NEXT();
        NEXT();
        NEXT();
        if (last == -1)
            break;
        if (flags & 0xe0) {
            aStream->msg = (char *)"unknown header flags set";
            ret = Z_DATA_ERROR;
            break;
        }
        if (flags & 4) {
            len = NEXT();
            len += (unsigned)(NEXT()) << 8;
            if (last == -1)
                break;
            while (len > have) {
                len -= have;
                have = 0;
                if (NEXT() == -1)
                    break;
                len--;
            }
            if (last == -1)
                break;
            have -= len;
            next += len;
        }
        if (flags & 8)
            while (NEXT() != 0 && last != -1)
                ;
        if (flags & 16)
            while (NEXT() != 0 && last != -1)
                ;
        if (flags & 2) {
            NEXT();
            NEXT();
        }
        if (last == -1)
            break;

        output.write = YES;
        output.check = YES;
        output.crc = crc32(0L, Z_NULL, 0);
        output.total = 0;
        output.archiver = anArchiver;

        aStream->next_in = next;
        aStream->avail_in = have;
        ret = inflateBack(aStream, HSGzipArchiverIn, input, HSGzipArchiverOut, &output);
        if (ret != Z_STREAM_END)
            break;
        next = aStream->next_in;
        have = aStream->avail_in;
        aStream->next_in = Z_NULL;

        ret = Z_BUF_ERROR;
        if (NEXT() != (int)(output.crc & 0xff)
            || NEXT() != (int)((output.crc >> 8) & 0xff)
            || NEXT() != (int)((output.crc >> 16) & 0xff)
            || NEXT() != (int)((output.crc >> 24) & 0xff)) {
            if (last != -1) {
                aStream->msg = (char *)"incorrect data check";
                ret = Z_DATA_ERROR;
            }
            break;
        }
        if (NEXT() != (int)(output.total & 0xff)
            || NEXT() != (int)((output.total >> 8) & 0xff)
            || NEXT() != (int)((output.total >> 16) & 0xff)
            || NEXT() != (int)((output.total >> 24) & 0xff)) {
            if (last != -1) {
                aStream->msg = (char *)"incorrect length check";
                ret = Z_DATA_ERROR;
            }
            break;
        }
    }
    return ret;
}

#undef NEXT
#undef FLUSHCODE

@implementation HSGzipArchiver

// Returns 0 on success (or trailing garbage, which only sets a warning),
// 1 on an error.
- (NSInteger)unpack
{
    struct HSGzipBuffers *buffers = malloc(sizeof(struct HSGzipBuffers));
    if (!buffers) {
        [self setOutputData:nil];
        [self setErrorString:@"out of memory error--aborting\n"];
        return 1;
    }
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    if (inflateBackInit(&stream, 15, buffers->match) != Z_OK) {
        [self setOutputData:nil];
        free(buffers);
        return 1;
    }

    errno = 0;
    int ret = HSGzipArchiverUnpackStreams(&stream, self, buffers);
    NSInteger result = 1;
    switch (ret) {
    case Z_OK:
        result = 0;
        break;
    case Z_ERRNO:
        [self setErrorString:[NSString stringWithFormat:@"warning: trailing garbage ignored in %s\n", "-"]];
        result = 0;
        break;
    case Z_DATA_ERROR:
        [self setErrorString:[NSString stringWithFormat:@"data error on %s: %s\n", "-", stream.msg ? stream.msg : ""]];
        break;
    case Z_BUF_ERROR:
        if (stream.next_in != Z_NULL)
            [self setErrorString:[NSString stringWithFormat:@"write error on %s: %s\n", "-", strerror(errno)]];
        else if (errno)
            [self setErrorString:[NSString stringWithFormat:@"read error on %s: %s\n", "-", strerror(errno)]];
        else
            [self setErrorString:[NSString stringWithFormat:@"unexpected end of file on %s\n", "-"]];
        break;
    case Z_MEM_ERROR:
        [self setErrorString:@"out of memory error--aborting\n"];
        break;
    default:
        [self setErrorString:@"internal error--aborting\n"];
        break;
    }
    inflateBackEnd(&stream);
    free(buffers);
    return result;
}

- (void)setErrorString:(id)aString
{
    if (_errorString != aString) {
        [_errorString release];
        _errorString = [aString retain];
    }
}

- (id)errorString
{
    return _errorString;
}

- (void)setError:(NSInteger)aError
{
    if (_error != aError)
        _error = (int)aError;
}

- (NSInteger)error
{
    return _error;
}

- (void)setOutputData:(id)aData
{
    if (_outputData != aData) {
        [_outputData release];
        _outputData = [aData retain];
    }
}

- (id)outputData
{
    if (!_outputData)
        _outputData = [NSMutableData new];
    return _outputData;
}

- (void)setCurrentPosition:(NSInteger)aPosition
{
    if (_currentPosition != aPosition)
        _currentPosition = (int)aPosition;
}

- (NSInteger)currentPosition
{
    return _currentPosition;
}

- (void)setInputData:(id)aData
{
    if (_inputData != aData) {
        _currentPosition = 0;
        [_inputData release];
        _inputData = [aData retain];
    }
}

- (id)inputData
{
    return _inputData;
}

- (void)dealloc
{
    [_inputData release];
    [_outputData release];
    [_errorString release];
    [super dealloc];
}

- (id)init
{
    return [super init];
}

@end

@implementation NSData (HSGzipExtensions)

// Gzip-compresses the data at level 9. (The original sizes the output as
// length + length/1000 + 13, which can be too small for the gzip wrapper
// on incompressible data, ignores deflate's result and leaks the buffer
// on failure; this uses deflateBound and checks for the stream end.)
- (id)hyperDataWithGzipPack
{
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.next_in = (Bytef *)[self bytes];
    stream.avail_in = (uInt)[self length];
    NSMutableData *result = nil;
    if (deflateInit2(&stream, 9, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        uLong size = deflateBound(&stream, [self length]);
        Bytef *buffer = malloc(size);
        if (buffer) {
            stream.next_out = buffer;
            stream.avail_out = (uInt)size;
            int status = deflate(&stream, Z_FINISH);
            if (deflateEnd(&stream) == Z_OK && status == Z_STREAM_END && stream.total_out)
                result = [NSMutableData dataWithBytes:buffer length:stream.total_out];
            free(buffer);
        } else {
            deflateEnd(&stream);
        }
    }
    return result ? [NSData dataWithData:result] : [NSData data];
}

- (id)hyperDataWithGzipUnpack
{
    HSGzipArchiver *archiver = [HSGzipArchiver new];
    [archiver setInputData:self];
    [archiver unpack];
    id data = [[archiver outputData] retain];
    [archiver release];
    return [data autorelease];
}

@end
