#import "HSOldFormatImportProblemsChecker+Text.h"
// Problems of an old stack's text items: fonts, cursors, actions and text
// read from files.
@implementation HSOldFormatImportProblemsChecker (Text)
// Text from a file (flag 0x40): the path follows a length byte.
- (void)processBy_tbItem_tbTextText_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (([aParser intEvaluate:@"itemTextStackHeader.type.itemstatflags"] & 0x40) == 0)
        return;
    NSString *path = [self actionObjectPathForApplePath:[aValue substringFromIndex:1]];
    if (path != nil && [[NSFileManager defaultManager] isReadableFileAtPath:path])
        return;
    [self addImportingProblemForCode:0x4e2c point:@"009" info:path];
}
- (void)processBy_itemTextStackHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addCursorImportingProblemIfNeededForOldCursorID:[aValue intValue]];
}
// A font without the style's traits is reported once (per run).
- (void)processBy_tbAttributes_scrpColor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    static BOOL reported = NO;
    id font = [aParser valuesBufferObjectForKey:@"~TextViewFont"];
    NSInteger traits = [aParser intEvaluate:@"~HTextViewAttributesTraitMask"];
    if ([[NSFontManager sharedFontManager] convertFont:font toHaveTrait:traits] == nil && !reported) {
        [self addImportingProblemForCode:0x4e28 point:@"004" info:[self descriptionForFontTraitMask:traits]];
        reported = YES;
    }
}
// The font by id (Arial for none), else Arial, else the system font.
- (void)processBy_tbAttributes_scrpFont_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *fontName = [aParser valuesBufferObjectForKey:[NSString stringWithFormat:@"~fontByID_%d", [aValue unsignedIntValue]]];
    if (fontName == nil || [fontName isEqualToString:@""])
        fontName = @"Arial";
    float size = [[aParser valuesBufferObjectForKey:@"~TextViewFontSize"] floatValue];
    NSFont *font = [NSFont fontWithName:fontName size:size];
    if (font == nil) {
        font = [NSFont fontWithName:@"Arial" size:size];
        [self addImportingProblemForCode:0x4e28 point:@"001" info:fontName];
    }
    if (font == nil) {
        font = [NSFont systemFontOfSize:12.0];
        [self addImportingProblemForCode:0x4e28 point:@"002" info:@"Arial"];
    }
    if (font == nil)
        [self addImportingProblemForCode:0x4e28 point:@"003" info:@"(wrong system font size 12)"];
    [aParser setValuesBufferObject:font forKey:@"~TextViewFont"];
}
- (void)processBy_tbAttributes_scrpFace_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self fontTraitMaskForFaceStyle:[aValue intValue]];
}
- (void)processBy_tbAttributes_scrpAscent_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [aParser setValuesBufferObject:aValue forKey:@"~TextViewFontSize1"];
}
- (void)processBy_tbAttributes_scrpHeight_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [aParser setValuesBufferObject:aValue forKey:@"~TextViewFontSize"];
}
- (void)processBy_itemTextStackHeader_actionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
@end
