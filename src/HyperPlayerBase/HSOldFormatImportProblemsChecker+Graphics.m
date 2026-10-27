#import "HSOldFormatImportProblemsChecker+Graphics.h"
@implementation HSOldFormatImportProblemsChecker (Graphics)
- (void)processBy_itemGraphicHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addCursorImportingProblemIfNeededForOldCursorID:[aValue intValue]];
}
- (void)processBy_oneAnimFrameHeader_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addImportingProblemForCode:20010 point:@"002" info:@"(old style animation)"];
}
// A button's animation item: anything but a 'strp' (film strip) animation is
// an old style one. For a version 3 item the animation file's Apple path (a
// Pascal string in Mac Roman) must resolve. Offsets are into the big-endian
// HyperStudio 4 records: the item header is 600 bytes, its long at 0x1c8 is
// the body's offset; the body's word at 0x20 is its version and its long at
// 0xaa the path's offset past header and body (0x3c2 bytes).
- (void)processBy_buttonAnimStkItem_buttonItem_ANIM_STK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    uint32_t kind = 0;
    [aValue getBytes:&kind length:4];
    if (CFSwapInt32BigToHost(kind) != 'strp')
        [self addImportingProblemForCode:20010 point:@"002" info:@"(old style animation)"];
    unsigned char header[600];
    [aValue getBytes:header length:sizeof(header)];
    uint32_t bodyOffset = OSReadBigInt32(header, 0x1c8);
    unsigned char body[0x16a];
    [aValue getBytes:body range:NSMakeRange(bodyOffset + 600, sizeof(body))];
    if (OSReadBigInt16(body, 0x20) != 3)
        return;
    NSData *pathData = [aValue subdataWithRange:NSMakeRange(bodyOffset + 0x3c2, OSReadBigInt32(body, 0xaa))];
    unsigned char length = 0;
    [pathData getBytes:&length length:1];
    NSString *applePath = [[[NSString alloc] initWithData:[pathData subdataWithRange:NSMakeRange(1, length)]
                                                 encoding:NSMacOSRomanStringEncoding] autorelease];
    if ([[self oldFormatDocument] actionObjectPathForApplePath:applePath] == nil)
        [self addImportingProblemForCode:20012 point:@"003" info:nil];
}
- (void)processBy_itemGraphicHeader_actionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
// Graphic items with item status flag 0x40 hold an action object path
// (a Pascal string) that must resolve.
- (void)processBy_itemGraphic_itemGraphicBody_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (([aParser intEvaluate:@"itemGraphicHeader.type.itemstatflags"] & 0x40) == 0)
        return;
    unsigned char length = 0;
    [aValue getBytes:&length length:1];
    NSString *applePath = [NSString hyperStringWithASCIIData:[aValue subdataWithRange:NSMakeRange(1, length)]];
    if ([self actionObjectPathForApplePath:applePath] == nil)
        [self addImportingProblemForCode:20012 point:@"001" info:applePath];
}
@end
