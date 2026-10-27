#import "HSOldFormatParser+HSOldFormatParserBlobType.h"
@implementation HSOldFormatParser (HSOldFormatParserBlobType)
// A link with an action carries a button item right after it.
- (id)parseType_vLinkActionBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    if ([self intEvaluate:@"linkHeader.type.hasAction"] == 1) {
        [self setValuesBufferObject:@"YES" forKey:@"ButtonItems"];
        [self valueForType:@"Item_kStkItmButton" atDefinedTree:[[self typesTree] objectForKey:@"Item_kStkItmButton"] parent:nil atOffset:aOffset];
    }
    return [self parametersDictionaryWithValue:@"dummy" name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:0]];
}
// The link text (ASCII) starts one byte before the offset.
- (id)parseType_vLinkTextBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger padCount = [self intEvaluate:@"linkHeader.type.padCount"];
    NSInteger textLength = [self intEvaluate:@"linkHeader.type.textLen"];
    NSData *data = [_data subdataWithRange:NSMakeRange(aOffset - 1, textLength)];
    NSString *text = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    return [self parametersDictionaryWithValue:text name:[aTree objectForKey:@"name"] type:aBody
                                          size:[NSNumber numberWithLong:padCount + textLength]];
}
- (id)parseType_vIconBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self intEvaluate:@"blobHeader.type.size"];
    NSData *data = [_data subdataWithRange:NSMakeRange(aOffset, size)];
    return [self parametersDictionaryWithValue:data name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}
- (id)parseType_vMidiBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self intEvaluate:@"blobHeader.type.size"];
    NSData *data = [_data subdataWithRange:NSMakeRange(aOffset, size)];
    return [self parametersDictionaryWithValue:data name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}
- (id)parseType_vFontListCount:(id)aCount atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    int next = (int)[self intEvaluate:@"blobHeader.type.next"];
    int mapSize = (int)[self intEvaluate:@"FontMap.size"];
    return [self parametersDictionaryWithValue:[NSNumber numberWithInt:next / mapSize] name:[aTree objectForKey:@"name"]
                                          type:aCount size:[NSNumber numberWithLong:0]];
}
// Known blob types are parsed as their own types; a QuickTime effect blob
// ('QTFX') also leaves its effect data in the values buffer as
// HSTransitionEffect_<number>. Anything else is kept as raw data.
- (id)parseType_vBlobBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger next = [self intEvaluate:@"blobHeader.type.next"];
    NSInteger size = [self intEvaluate:@"blobHeader.type.size"];
    long type = [self longEvaluate:@"blobHeader.type.typeLong"];
    NSString *blobType = nil;
    switch (type) {
    case 'Crsr': blobType = @"Blob_BT_CURSOR"; break;
    case 'FntL': blobType = @"Blob_BT_FONTLIST"; break;
    case 'Icon': blobType = @"Blob_BT_ICON"; break;
    case 'Midi': blobType = @"Blob_BT_MIDI"; break;
    case 'Snd ': blobType = @"Blob_BT_SOUND"; break;
    }
    id value;
    if (blobType != nil)
        value = [self valueForType:blobType atDefinedTree:aTree parent:aParent atOffset:aOffset];
    else {
        if (type == 'QTFX') {
            const uint8_t *bytes = [[_data subdataWithRange:NSMakeRange(aOffset, size)] bytes];
            short effect = (short)OSReadBigInt16(bytes, 4);
            uint32_t length = OSReadBigInt32(bytes, 0x6c);
            if (aOffset + 0x70 + length < [_data length]) {
                NSData *effectData = [_data subdataWithRange:NSMakeRange(aOffset + 0x70, length)];
                BOOL saved = [self isDataSavedToValuesBuffer];
                [self setDataSavedToValuesBuffer:YES];
                [self setValuesBufferObject:effectData forKey:[NSString stringWithFormat:@"HSTransitionEffect_%d", effect]];
                [self setDataSavedToValuesBuffer:saved];
            }
        }
        value = [_data subdataWithRange:NSMakeRange(aOffset, size)];
    }
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:next]];
}
@end
