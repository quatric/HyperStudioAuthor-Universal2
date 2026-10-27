#import "HSOldFormatParser+HSOldFormatParserItemType.h"

// The parsed type for a button sub-item type number, or nil.
static NSString *HSOldFormatButtonItemType(int aType)
{
    switch (aType) {
    case 0xc: return @"ButtonItem_NUM_BTN_TYPES";
    case 0x33: return @"ButtonItem_NBA_ITEM";
    case 0x35: return @"ButtonItem_ACTION_ITEM";
    case 0x38: return @"ButtonItem_ANIM_STK_ITEM";
    case 0x3b: return @"ButtonItem_CONN_APPL_ITEM";
    case 0x3c: return @"ButtonItem_CONN_STK_ITEM";
    case 0x3d: return @"ButtonItem_CONN_URL_ITEM";
    case 0x40: return @"ButtonItem_SCRIPT_ITEM";
    case 0x50: return @"ButtonItem_SND_STK_ITEM";
    case 0x52: return @"ButtonItem_SND_DSK_ITEM";
    case 0x53: return @"ButtonItem_SND_RES_ITEM";
    case 0x58: return @"ButtonItem_QT_RES_ITEM";
    case 0x59: return @"ButtonItem_QT_DSK_ITEM";
    case 0x77: return @"ButtonItem_BTN_VIDEO_ITEM";
    case 0x81: return @"ButtonItem_BTN_RGN_ITEM";
    case 0x82: return @"ButtonItem_BTN_NEW_RGN_ITEM";
    default: return nil;
    }
}

// The parsed type for a stack item type number (not a button sub-item), or nil.
static NSString *HSOldFormatStackItemType(int aType)
{
    switch (aType) {
    case 0x0: return @"Item_kStkItmNone";
    case 0x8: return @"Item_kStkItmBackground";
    case 0x10: return @"Item_kStkItmGraphic";
    case 0x30: return @"Item_kStkItmButton";
    case 0x5a: return @"Item_kStkItmCardQuickTime";
    case 0x60: return @"Item_kStkItmTextStack";
    case 0x63: return @"Item_kStkItmTextChars";
    case 0x78: return @"Item_kStkItmCardVideo";
    case 0xf0: return @"Item_kStkItmCard";
    default: return nil;
    }
}

// Item bodies: the bytes (or text) after an item's record, sized by the item
// header less the record; a flag bit 0x200 marks a pad byte at the end.
@implementation HSOldFormatParser (HSOldFormatParserItemType)

// A Pascal string at the offset, as the original read it into a 256-byte buffer.
- (NSString *)HSOldFormatParserItemType_pascalStringAtOffset:(NSInteger)aOffset
{
    unsigned char string[256];
    unsigned char length;
    [_data getBytes:&length range:NSMakeRange(aOffset, 1)];
    [_data getBytes:string range:NSMakeRange(aOffset, length + 1)];
    p2cstrcpyMy(string, string);
    return [NSString stringWithCString:(const char *)string encoding:NSMacOSRomanStringEncoding];
}

- (id)HSOldFormatParserItemType_body:(id)aType tree:(id)aTree offset:(NSInteger)aOffset length:(NSInteger)aLength size:(NSInteger)aSize
{
    return [self parametersDictionaryWithValue:[_data subdataWithRange:NSMakeRange(aOffset, aLength)] name:[aTree objectForKey:@"name"] type:aType size:[NSNumber numberWithLong:aSize]];
}

- (id)parseType_vButton_BTN_RGN_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemHeader.type.size"] - [self longEvaluate:@"ItemRecord.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size size:size];
}

- (id)parseType_vButton_BTN_NEW_RGN_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemHeader.type.size"] - [self longEvaluate:@"BitMapRefs.size"] - [self longEvaluate:@"ItemRecord.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size size:size];
}

// The movie's file name.
- (id)parseType_vButton_QT_DSK_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    [self intEvaluate:@"buttonItem_QT_DSK_ITEM_header.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"buttonItem_QT_DSK_ITEM_header.type.size"] - [self longEvaluate:@"ItemRecord.size"];
    return [self parametersDictionaryWithValue:[self HSOldFormatParserItemType_pascalStringAtOffset:aOffset] name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

// Sprite animations ("Sprt") are kept as data; older ones are parsed.
- (id)parseType_vButtonItem_ANIM_STK_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger flags = [self intEvaluate:@"buttonItem_ANIM_STK_ITEM_itemHeader.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"buttonItem_ANIM_STK_ITEM_itemHeader.type.size"] - [self longEvaluate:@"ItemRecord.size"];
    unsigned int tag;
    [_data getBytes:&tag range:NSMakeRange(aOffset, 4)];
    id value;
    if (CFSwapInt32LittleToHost(tag) == 0x74727053)
        value = [_data subdataWithRange:NSMakeRange(aOffset, size - ((flags >> 9) & 1))];
    else
        value = [self valueForType:@"_AnimOldStyle" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

// Text in ASCII, returns as newlines.
- (id)parseType_vTBText:(id)aText atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"tbTextHeader.type.TBtextsize"];
    NSMutableString *text = [[[NSMutableString alloc] initWithData:[_data subdataWithRange:NSMakeRange(aOffset, size)] encoding:NSASCIIStringEncoding] autorelease];
    [text replaceOccurrencesOfString:@"\r" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [text length])];
    return [self parametersDictionaryWithValue:text name:[aTree objectForKey:@"name"] type:aText size:[NSNumber numberWithLong:size]];
}

- (id)parseType_vTBItems:(id)aItems atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger end = [self intEvaluate:@"itemTextStack.offset"] - 1 + [self intEvaluate:@"itemTextStackHeader.type.size"];
    if (aOffset < end)
        return [self valueForType:@"_TBItemsIterate" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    return [self parseType_none:@"none" atDefinedTree:aTree parent:aParent atOffset:aOffset];
}

- (id)parseType_vAnimFrameBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger flags = [self intEvaluate:@"oneAnimFrameHeader.type.flags"];
    NSInteger size = [self longEvaluate:@"oneAnimFrameHeader.type.framelen"] - [self longEvaluate:@"AnimFrame.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size - ((flags >> 9) & 1) size:size];
}

// The video's name, in ASCII.
- (id)parseType_vButton_BTN_VIDEO_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger flags = [self intEvaluate:@"buttonItem_BTN_VIDEO_ITEM_header.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"buttonItem_BTN_VIDEO_ITEM_header.type.size"] - [self longEvaluate:@"ItemRecord.size"];
    NSData *data = [_data subdataWithRange:NSMakeRange(aOffset, size - ((flags >> 9) & 1))];
    NSString *name = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    return [self parametersDictionaryWithValue:name name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

- (id)parseType_vButton_NBA_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger flags = [self intEvaluate:@"buttonItem_NBA_ITEM_header.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"buttonItem_NBA_ITEM_header.type.size"] - [self longEvaluate:@"ItemRecord.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size - ((flags >> 9) & 1) size:size];
}

// The samples up to the end of the blob; 16-bit samples are big-endian and
// swapped to native order.
- (id)parseType_vButtonItemSoundData:(id)aData atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger length = [self longEvaluate:@"BlobTag.size"] + ([self longEvaluate:@"blob.offset"] - aOffset) + [self longEvaluate:@"blobHeader.type.size"];
    if (length < 0)
        length = 0;
    NSData *samples = [_data subdataWithRange:NSMakeRange(aOffset, length)];
    short sampleSize = (short)[self longEvaluate:@"buttonSoundHeaderLastPart.type.sampleSize"];
    if (samples && [samples length] && sampleSize > 8) {
        NSUInteger byteCount = [samples length];
        unsigned short *words = malloc(byteCount);
        [samples getBytes:words];
        for (NSUInteger i = 0; i < byteCount / 2; i++)
            words[i] = CFSwapInt16(words[i]);
        samples = [NSData dataWithBytes:words length:byteCount];
        free(words);
    }
    return [self parametersDictionaryWithValue:samples name:[aTree objectForKey:@"name"] type:aData size:[NSNumber numberWithLong:length]];
}

// The sound header, extended (encode -1) or compressed (encode -2) when so
// marked; mono 8-bit until the header says otherwise.
- (id)parseType_vButtonSoundHeaderLastPart:(id)aPart atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    [self setValuesBufferObject:[NSNumber numberWithShort:1] forKey:@"buttonSoundHeaderLastPart.type.numChannels"];
    [self setValuesBufferObject:[NSNumber numberWithShort:8] forKey:@"buttonSoundHeaderLastPart.type.sampleSize"];
    id value = [self valueForType:@"SoundHeader" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    char encode = (char)[self intEvaluate:@"buttonSoundHeaderLastPart.type.encode"];
    if (encode == -1)
        return [self valueForType:@"ExtSoundHeader" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    if (encode == -2)
        return [self valueForType:@"CmpSoundHeader" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    return value;
}

- (id)parseType_vButton_SND_RES_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger flags = [self intEvaluate:@"buttonItem_SND_RES_ITEM_header.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"buttonItem_SND_RES_ITEM_header.type.size"] - [self longEvaluate:@"BSoundItem.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size - ((flags >> 9) & 1) size:size];
}

// The sound's file name.
- (id)parseType_vButton_SND_DSK_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    [self intEvaluate:@"buttonItem_SND_DSK_ITEM_header.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"buttonItem_SND_DSK_ITEM_header.type.size"] - [self longEvaluate:@"BSoundItem.size"];
    return [self parametersDictionaryWithValue:[self HSOldFormatParserItemType_pascalStringAtOffset:aOffset] name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

// The stack's file name.
- (id)parseType_vButton_CONN_STK_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemHeader.type.size"] - [self longEvaluate:@"LaunchItemRecord.size"];
    return [self parametersDictionaryWithValue:[self HSOldFormatParserItemType_pascalStringAtOffset:aOffset] name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

// The application and document names, one per line.
- (id)parseType_vButton_CONN_APPL_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemHeader.type.size"] - [self longEvaluate:@"LaunchItemRecord.size"];
    NSString *application = [self HSOldFormatParserItemType_pascalStringAtOffset:aOffset];
    NSInteger documentOffset = [self longEvaluate:@"buttonItem_CONN_APPL_ITEM_header.type.docPathSize"];
    NSString *document = [self HSOldFormatParserItemType_pascalStringAtOffset:aOffset + documentOffset];
    NSString *value = [[NSArray arrayWithObjects:application, document, nil] componentsJoinedByString:@"\n"];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

// The URL, in ASCII.
- (id)parseType_vLaunchURLItemBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger flags = [self intEvaluate:@"itemHeader.type.itemstatflags"];
    NSInteger size = [self longEvaluate:@"itemHeader.type.size"] - [self longEvaluate:@"LaunchURLItemRecord.size"];
    NSData *data = [_data subdataWithRange:NSMakeRange(aOffset, size - ((flags >> 9) & 1))];
    NSString *url = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    return [self parametersDictionaryWithValue:url name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

- (id)parseType_vItemTextStackBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemTextStackHeader.type.size"] - [self longEvaluate:@"FieldItem.size"];
    id items = [self valueForType:@"_TBItems" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    return [self parametersDictionaryWithValue:items name:[aTree objectForKey:@"name"] type:aBody size:[NSNumber numberWithLong:size]];
}

- (id)parseType_vButton_SCRIPT_ITEM_body:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"buttonItem_SCRIPT_ITEM_header.type.size"] - [self longEvaluate:@"ItemRecord.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size size:size];
}

- (id)parseType_vItemGraphicBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemGraphicHeader.type.size"] - [self longEvaluate:@"GraphicItem.size"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size size:size];
}

// The whole graphic item from its header, without moving the offset on.
- (id)parseType_vItemGraphicWhole:(id)aWhole atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    return [self HSOldFormatParserItemType_body:aWhole tree:aTree offset:aOffset length:[self longEvaluate:@"itemHeader.type.size"] size:0];
}

- (id)parseType_vItemBackgroundBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:@"itemBackgroundHeader.type.size"] - [self longEvaluate:@"BkgdHeader.size"];
    NSInteger flags = [self intEvaluate:@"itemBackgroundHeader.type.flags"];
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:size - ((flags >> 9) & 1) size:size];
}

- (id)parseType_vZeroItemBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    return [self HSOldFormatParserItemType_body:aBody tree:aTree offset:aOffset length:0 size:0];
}

// Items go on to the end of the button (inside a button) or of the card (of a
// card with a type), stopping a record short of the end of the data.
- (id)parseType_vItems:(id)aItems atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger recordSize = [self longEvaluate:@"ItemRecord.size"];
    NSInteger end;
    BOOL hasItems;
    if (![[self valuesBufferObjectForKey:@"ButtonItems"] isEqualToString:@"NO"]) {
        end = [self intEvaluate:@"itemButton.offset"] + [self intEvaluate:@"itemButtonHeader.type.size"];
        hasItems = YES;
    } else {
        end = [self intEvaluate:@"card.offset"] - 2 + [self intEvaluate:@"cardHeader.type.length"];
        hasItems = [self intEvaluate:@"cardHeader.type.type"] != 0;
    }
    NSInteger limit = MIN(end, [self dataLength] - 1 - recordSize);
    id value;
    if (hasItems && aOffset < limit)
        value = [self valueForType:@"_ItemsIterate" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    else
        value = [self parseType_none:@"none" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    [self setValuesBufferObject:@"NO" forKey:@"ButtonItems"];
    return value;
}

// The card's items, one after another while they have a size; progress goes
// to the delegate by offset.
- (id)parseType_vItemsNew:(id)aNew atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    [self setValuesBufferObject:@"NO" forKey:@"ButtonItems"];
    [self valueForType:@"ItemRecord" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    NSInteger recordSize = [self longEvaluate:@"ItemRecord.size"];
    NSInteger length = [self intEvaluate:@"cardHeader.type.length"];
    NSInteger headerSize = [self intEvaluate:@"CardHeader.size"];
    NSInteger cardOffset = [self intEvaluate:@"card.offset"];
    NSInteger type = [self intEvaluate:@"cardHeader.type.type"];
    NSInteger itemSize = [self intEvaluate:@"item.type.size"];
    NSMutableArray *items = [NSMutableArray new];
    NSInteger offset = aOffset;
    if (type) {
        itemSize -= 2;
        while (offset <= -2 - recordSize + length + cardOffset && itemSize > 0) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            id item = [self valueForType:@"_Item" atDefinedTree:aTree parent:aParent atOffset:offset];
            [items addObject:item];
            itemSize = [[item objectForKey:@"size"] intValue];
            offset += itemSize;
            if ([_delegate respondsToSelector:@selector(oldFormatParser:progressForParseOperationDidChange:)])
                [_delegate oldFormatParser:self progressForParseOperationDidChange:(double)offset];
            [pool release];
        }
    }
    [items autorelease];
    [self setValuesBufferObject:@"NO" forKey:@"ButtonItems"];
    return [self parametersDictionaryWithValue:items name:@"Items" type:aNew size:[NSNumber numberWithLong:length - headerSize]];
}

// The button's sub-items, one after another while they have a size.
- (id)parseType_vButtonItems:(id)aItems atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger buttonOffset = [self intEvaluate:@"itemButton.offset"];
    [self valueForType:@"ItemRecord" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    NSInteger recordSize = [self longEvaluate:@"ItemRecord.size"];
    NSInteger headerSize = [self intEvaluate:@"itemButtonHeader.type.size"];
    NSInteger buttonItemSize = [self intEvaluate:@"ButtonItem.size"];
    NSInteger type = [self longEvaluate:@"itemButtonHeader.type.type"];
    NSInteger itemSize = [self intEvaluate:@"itemButtonHeader.type.size"];
    NSMutableArray *items = [NSMutableArray new];
    NSInteger offset = aOffset;
    if (type) {
        while (offset <= buttonOffset - recordSize + headerSize && itemSize > 0) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            id item = [self valueForType:@"_Item" atDefinedTree:aTree parent:aParent atOffset:offset];
            [items addObject:item];
            itemSize = [[item objectForKey:@"size"] intValue];
            offset += itemSize;
            [pool release];
        }
    }
    [items autorelease];
    [self setValuesBufferObject:@"NO" forKey:@"ButtonItems"];
    return [self parametersDictionaryWithValue:items name:@"Items" type:aItems size:[NSNumber numberWithLong:headerSize - buttonItemSize]];
}

// A button sub-item by its type; unknown types are zero items, which end the
// button's items.
- (id)parseType_vButtonItemHeader:(id)aHeader atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSString *type = HSOldFormatButtonItemType([[self valuesBufferObjectForKey:@"itemButtonSubItems.type.type"] intValue]);
    if (type) {
        [self setValuesBufferObject:@"YES" forKey:@"ButtonItems"];
    } else {
        [self setValuesBufferObject:@"NO" forKey:@"ButtonItems"];
        type = @"_ZeroItem";
    }
    return [self valueForType:type atDefinedTree:[[self typesTree] objectForKey:type] parent:aTree atOffset:aOffset];
}

// An item by its type: button sub-items mark the items as a button's, stack
// items (and unknown types, as zero items) as a card's.
- (id)parseType_vItemHeader:(id)aHeader atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    [self valueForType:@"ItemRecord" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    int number = [[self valuesBufferObjectForKey:@"itemHeader.type.type"] intValue];
    NSString *type = HSOldFormatButtonItemType(number);
    if (type) {
        [self setValuesBufferObject:@"YES" forKey:@"ButtonItems"];
    } else {
        type = HSOldFormatStackItemType(number);
        if (!type)
            type = @"_ZeroItem";
        [self setValuesBufferObject:@"NO" forKey:@"ButtonItems"];
    }
    return [self valueForType:type atDefinedTree:[[self typesTree] objectForKey:type] parent:aTree atOffset:aOffset];
}

@end
