#import "HSOldFormatImportProblemsChecker+Button.h"
// Problems of an old stack's buttons: fonts, cursors, add-ons (NBAs),
// scripts and the files their actions use.
@implementation HSOldFormatImportProblemsChecker (Button)
- (void)processBy_itemButtonHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addCursorImportingProblemIfNeededForOldCursorID:[aValue intValue]];
}
// A known add-on is checked by its own method (process<Name>NBAWithData:).
- (void)processBy_buttonNbaItem_buttonItem_NBA_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int identifier = (int)[aParser intEvaluate:@"buttonItem_NBA_ITEM_header.type.itemvar1"];
    id name = [[[self oldFormatDocument] nbaById] objectForKey:[NSString stringWithFormat:@"%d", identifier]];
    if (name == nil) {
        // (The original's choice was inverted: "Unknown NBA" for a known
        // name, nil for an unknown one.)
        id nbaName = [self nbaNameById:identifier];
        NSString *info = [NSString stringWithFormat:@"%@ (id=%d)", nbaName != nil ? nbaName : @"Unknown NBA", identifier];
        [self addImportingProblemForCode:0x4e27 point:@"011" info:info];
        return;
    }
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"process%@NBAWithData:", name]);
    if ([self respondsToSelector:selector])
        [self performSelector:selector withObject:aValue];
}
- (void)processBy_buttonScriptItem_buttonItem_SCRIPT_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addImportingProblemForCode:0x4e26 point:@"010" info:@"(HyperLogo)"];
}
// A movie file: found and readable, with sound and video QuickTime opens.
- (void)processBy_buttonQtDskItem_buttonItem_QT_DSK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *path = [self actionObjectPathForApplePath:aValue];
    if (path == nil || ![[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:NO error:NULL]) {
        [self addImportingProblemForCode:0x4e2c point:@"008" info:aValue];
        return;
    }
    if (![HSMovie canInitAsSoundOnlyWithURL:[NSURL fileURLWithPath:path] error:NULL])
        [self addImportingProblemForCode:0x4e29 point:@"009" info:[NSString stringWithFormat:@"Movie with sound, path: %@", aValue]];
    if (![HSMovie canInitAsVideoWithURL:[NSURL fileURLWithPath:path] error:NULL])
        [self addImportingProblemForCode:0x4e29 point:@"009a" info:[NSString stringWithFormat:@"Movie importing problem, path: %@", aValue]];
}
- (void)processBy_buttonSndDskItem_buttonItem_SND_DSK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *path = [self actionObjectPathForApplePath:aValue];
    if (path == nil) {
        [self addImportingProblemForCode:0x4e2c point:@"006" info:aValue];
        return;
    }
    if ([HSNewMedia mediaWithData:[NSData dataWithContentsOfFile:path] name:[path lastPathComponent] type:@"wav"] == nil)
        [self addImportingProblemForCode:0x4e2b point:@"007" info:@"(wrong type)"];
}
// "Application path\nDocument path": both must be found.
- (void)processBy_buttonConnApplItem_buttonItem_CONN_APPL_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSArray *paths = [aValue componentsSeparatedByString:@"\n"];
    NSString *application = nil, *document = nil;
    if (paths != nil && [paths count] == 2) {
        application = [paths objectAtIndex:0];
        document = [paths objectAtIndex:1];
    }
    if (application == nil || [application isEqualToString:@""] || [self actionObjectPathForApplePath:application] == nil)
        [self addImportingProblemForCode:0x4e2c point:@"004" info:application];
    if (document == nil || [document isEqualToString:@""] || [self actionObjectPathForApplePath:document] == nil)
        [self addImportingProblemForCode:0x4e2c point:@"005" info:document];
}
- (void)processBy_buttonConnStkItem_buttonItem_CONN_STK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *path = [self pathForApplePath:aValue];
    if (path != nil && [self actionObjectPathForPath:path] == nil)
        [self addImportingProblemForCode:0x4e2c point:@"003" info:aValue];
}
// The font of a named button (of the kinds with text): its font by id, or
// Charcoal in its place.
- (void)processBy_itemButtonHeader_textFace_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    unsigned short kind = (unsigned short)[aParser intEvaluate:@"itemButtonHeader.type.kind"];
    NSInteger type = [aParser intEvaluate:@"itemButtonHeader.type.type"];
    NSString *name = [[[self parser] valuesBufferObjectForKey:@"itemButtonHeader.type.name"]
                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (kind > 7 || type == 0x35 || name == nil || [name isEqualToString:@""])
        return;
    int fontID = (short)[aParser intEvaluate:@"itemButtonHeader.type.textFont"];
    short size = (short)[aParser intEvaluate:@"itemButtonHeader.type.textSize"];
    NSString *fontName = [aParser valuesBufferObjectForKey:[NSString stringWithFormat:@"~fontByID_%d", fontID]];
    NSFont *font = nil;
    if (fontName != nil && ![fontName isEqualToString:@""])
        font = [NSFont fontWithName:fontName size:size];
    else
        fontName = [NSString stringWithFormat:@"wrong font for id: %d", fontID];
    if (font == nil) {
        [self addImportingProblemForCode:0x4e28 point:@"001" info:fontName];
        font = [NSFont fontWithName:@"Charcoal" size:size < 1 ? 12.0 : size];
    }
    if (font == nil)
        [self addImportingProblemForCode:0x4e28 point:@"002" info:@"Charcoal"];
}
@end
