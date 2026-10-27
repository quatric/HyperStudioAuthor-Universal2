#import "HSOldFormatDocument+HSResourceRecreation.h"
static inline uint32_t HSReadBigEndian32(const uint8_t *aBytes)
{
    uint32_t value;
    memcpy(&value, aBytes, sizeof(value));
    return CFSwapInt32BigToHost(value);
}

// Resources of an old stack recreated while it's parsed: cursors, icons,
// fonts, sounds and the offsets of actions and hyperlinks.
@implementation HSOldFormatDocument (HSResourceRecreation)
// A cursor blob: a 0x1c byte header (type, hot spot) and then either one
// icon (type 0x100) or the frames of an animated cursor (type 0x200): at
// 0x20 the frame count n, at 0x40 n delays (in ticks), n frame indices and
// n frame sizes, then the frames' icon data.
- (void)processBy_blobBody_cursor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSUInteger length = [aValue length];
    if (length < 0x1c)
        return;
    const uint8_t *bytes = [aValue bytes];
    uint16_t type, hotSpotX, hotSpotY;
    memcpy(&type, bytes, 2);
    memcpy(&hotSpotX, bytes + 6, 2);
    memcpy(&hotSpotY, bytes + 8, 2);
    NSPoint hotSpot = NSMakePoint(CFSwapInt16BigToHost(hotSpotX), CFSwapInt16BigToHost(hotSpotY));
    id cursor;
    // (The type is compared as stored, in the host's order.)
    if (type == 0x200) {
        // Bounds checks added: the original trusted the counts and sizes.
        if (length < 0x40)
            return;
        uint32_t count = HSReadBigEndian32(bytes + 0x20);
        if (count > (length - 0x40) / 12)
            return;
        NSMutableArray *delays = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:count];
        const uint8_t *frameData = bytes + 0x40 + count * 12;
        for (uint32_t i = 0; i < count; i++) {
            uint32_t delay = HSReadBigEndian32(bytes + 0x40 + i * 4);
            // The index is used as stored (the original didn't swap it).
            uint32_t index;
            memcpy(&index, bytes + 0x40 + count * 4 + i * 4, 4);
            uint32_t size = HSReadBigEndian32(bytes + 0x40 + count * 8 + i * 4);
            if ((NSUInteger)(frameData - bytes) + size > length)
                break;
            id image = [[self graphicsImport] imageFromIconData:[NSData dataWithBytes:frameData length:size]];
            if (image != nil && index <= [frames count]) {
                [frames insertObject:image atIndex:index];
                [delays insertObject:[NSNumber numberWithFloat:(float)delay / 60.0f] atIndex:index];
            }
            frameData += size;
        }
        cursor = [HSCursor cursorWithFrames:frames changeDelays:delays hotSpot:hotSpot];
    } else if (type == 0x100) {
        id image = [[self graphicsImport] imageFromIconData:[aValue subdataWithRange:NSMakeRange(0x1c, length - 0x1c)]];
        cursor = image != nil ? [[[HSCursor alloc] initWithImage:image hotSpot:hotSpot] autorelease] : nil;
    } else
        return;
    NSInteger identifier = [[self parser] intEvaluate:@"blobHeader.type.id"];
    [[self parser] setValuesBufferObject:cursor forKey:[NSString stringWithFormat:@"CursorID_%d", (int)identifier]];
}
- (void)processBy_blobBody_icon_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id image = [[self graphicsImport] imageFromIconData:aValue];
    int identifier = (int)[[self parser] intEvaluate:@"blobHeader.type.id"];
    [[self parser] setValuesBufferObject:image forKey:[NSString stringWithFormat:@"IconID_%d", identifier]];
    if ([self debugFlag]) {
        NSString *name = [NSString stringWithFormat:@"icon%d.tiff", identifier];
        NSData *tiff = [image TIFFRepresentation];
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/ico" withIntermediateDirectories:NO attributes:nil error:NULL];
        [tiff writeToFile:[@"/tmp/ico/" stringByAppendingString:name] atomically:YES];
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/dat" withIntermediateDirectories:NO attributes:nil error:NULL];
        [aValue writeToFile:[@"/tmp/dat/" stringByAppendingString:name] atomically:YES];
    }
}
- (void)processBy_oneFont_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id fontName = [[self parser] valuesBufferObjectForKey:@"oneFont.type.fontName"];
    [[self parser] setValuesBufferObject:fontName forKey:[NSString stringWithFormat:@"~fontByID_%d", [aValue unsignedIntValue]]];
}
// The sound by id, its name by id and the sound by name.
- (void)HSResourceRecreation_registerSound:(id)aMedia name:(id)aName identifier:(int)aIdentifier
{
    [[self stack] setUserInfo:aName forKey:[NSString stringWithFormat:@"~soundNameByID_%d", aIdentifier]];
    [[self stack] setUserInfo:aMedia forKey:[NSString stringWithFormat:@"~soundByID_%d", aIdentifier]];
    [[self stack] setUserInfo:aMedia forKey:[NSString stringWithFormat:@"~soundByName_%@", aName]];
}
- (void)processBy_blobBody_midi_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int identifier = (int)[[self parser] intEvaluate:@"blobHeader.type.id"];
    id name = [[self parser] valuesBufferObjectForKey:@"blobHeader.type.name"];
    id media = [HSNewMedia mediaWithData:aValue name:name type:@"mid"];
    [self HSResourceRecreation_registerSound:media name:name identifier:identifier];
    if ([self debugFlag]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/stk" withIntermediateDirectories:NO attributes:nil error:NULL];
        [aValue writeToFile:[@"/tmp/stk/" stringByAppendingFormat:@"%d-%@.mid", identifier, name] atomically:YES];
    }
}
// The sampled sound of a button, made a WAV file. Sounds with a modifier
// (or none) become two bytes of silence; channels other than 1 or 2 count
// as 1 and a sample rate out of 1...65536 Hz as 44100.
- (void)processBy_blobBody_buttonItemSoundData_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSData *samples = aValue;
    uint32_t size = ([[self parser] intEvaluate:@"buttonSoundHeader1.type.modInit"] & 0x700) == 0 ? (uint32_t)[aValue length] : 0;
    if (size == 0) {
        uint16_t silence = 0;
        samples = [NSData dataWithBytes:&silence length:2];
        size = 2;
    }
#pragma pack(push, 2)
    struct {
        uint32_t riff, riffSize, wave, fmt, fmtSize;
        uint16_t format, channels;
        uint32_t sampleRate, byteRate;
        uint16_t blockAlign, bitsPerSample;
        uint32_t data, dataSize;
    } header;
#pragma pack(pop)
    header.riff = 0x46464952;
    header.riffSize = (uint32_t)[self longSwapped:size + 0x24];
    header.wave = 0x45564157;
    header.fmt = 0x20746d66;
    header.fmtSize = (uint32_t)[self longSwapped:0x10];
    header.format = (uint16_t)[self shortSwapped:1];
    short channels = (short)[[self parser] longEvaluate:@"buttonSoundHeaderLastPart.type.numChannels"];
    if ((unsigned short)(channels - 1) > 1)
        channels = 1;
    header.channels = (uint16_t)[self shortSwapped:channels];
    uint32_t sampleRate = (uint32_t)[[self parser] longEvaluate:@"buttonSoundHeaderLastPart.type.sampleRate"] >> 16;
    if (sampleRate - 1 > 0xffff)
        sampleRate = 44100;
    header.sampleRate = (uint32_t)[self longSwapped:sampleRate];
    short sampleSize = (short)[[self parser] longEvaluate:@"buttonSoundHeaderLastPart.type.sampleSize"];
    header.bitsPerSample = (uint16_t)[self shortSwapped:sampleSize];
    int blockAlign = (short)((sampleSize >> 3) * channels);
    header.blockAlign = (uint16_t)[self shortSwapped:blockAlign];
    header.byteRate = (uint32_t)[self longSwapped:sampleRate * blockAlign];
    header.data = 0x61746164;
    header.dataSize = (uint32_t)[self longSwapped:size];
    NSMutableData *wav = [NSMutableData dataWithBytes:&header length:0x2c];
    [wav appendData:samples];
    int identifier = (int)[[self parser] intEvaluate:@"blobHeader.type.id"];
    id name = [[self parser] valuesBufferObjectForKey:@"blobHeader.type.name"];
    if ([self debugFlag]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/stk" withIntermediateDirectories:NO attributes:nil error:NULL];
        [wav writeToFile:[@"/tmp/stk/" stringByAppendingFormat:@"%d-%@.wav", identifier, name] atomically:YES];
    }
    id media = [HSNewMedia mediaWithData:wav name:name type:@"wav"];
    [self HSResourceRecreation_registerSound:media name:name identifier:identifier];
}
// The offset an action ('Actn') or hyperlink ('Hlnk') blob was found at,
// by its id.
- (void)processBy_blobHeader_id_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int type = [[[self parser] valuesBufferObjectForKey:@"blobHeader.type.typeLong"] intValue];
    id offset;
    NSString *key;
    if (type == 0x4163746e) {
        offset = [[self parser] valuesBufferObjectForKey:@"~ActionOffset"];
        key = [NSString stringWithFormat:@"~actionOffsetByID_%d", [aValue intValue]];
    } else if (type == 0x486c6e6b) {
        offset = [[self parser] valuesBufferObjectForKey:@"~HyperlinkOffset"];
        key = [NSString stringWithFormat:@"~hyperlinkOffsetByID_%d", [aValue intValue]];
    } else
        return;
    [[self parser] setValuesBufferObject:offset forKey:key];
}
- (void)processBy_blobHeader_typeLong_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *key;
    if ([aValue intValue] == 0x4163746e)
        key = @"~ActionOffset";
    else if ([aValue intValue] == 0x486c6e6b)
        key = @"~HyperlinkOffset";
    else
        return;
    [[self parser] setValuesBufferObject:[aParameters objectForKey:@"offsetParameter"] forKey:key];
}
@end
