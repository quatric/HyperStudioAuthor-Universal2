#import "HSOldFormatImportProblemsChecker+Tools.h"
@implementation HSOldFormatImportProblemsChecker (Tools)
// Parses the button item of an action, when it has an offset.
- (void)checkActionForId:(NSInteger)aId
{
    NSString *key = [NSString stringWithFormat:@"~actionOffsetByID_%d", (int)aId];
    NSInteger offset = [[self parser] intEvaluate:key];
    if (offset > 0) {
        [[self parser] setValuesBufferObject:@"YES" forKey:@"ButtonItems"];
        id tree = [[[self parser] typesTree] objectForKey:@"Item_kStkItmButton"];
        [[self parser] valueForType:@"Item_kStkItmButton" atDefinedTree:tree parent:nil atOffset:offset + 0x44];
    }
}
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle
{
    return [self fontTraitMaskForFaceStyle:aStyle applyToObject:nil];
}
// The font traits of a Mac face style (bold, italic, underline, outline,
// shadow, condense, extend), set on the object if any; the underline,
// outline and shadow are also left in the parser's buffer.
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle applyToObject:(id)aObject
{
    id attributes = aObject != nil ? [aObject queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)] : nil;
    NSUInteger mask = 0;
    if (aStyle & 1) {
        mask |= NSBoldFontMask;
        [attributes setHyperBold:YES];
    }
    if (aStyle & 2) {
        mask |= NSItalicFontMask;
        [attributes setHyperItalic:YES];
    }
    NSString *underline = @"NO";
    if (aStyle & 4) {
        underline = @"YES";
        [attributes setHyperUnderlined:YES];
    }
    NSString *outline = @"NO";
    if (aStyle & 8) {
        outline = @"YES";
        [attributes setHyperOutlineEnabled:YES];
    }
    NSString *shadow = @"NO";
    if (aStyle & 0x10) {
        shadow = @"YES";
        [attributes setHyperShadowEnabled:YES];
    }
    if (aStyle & 0x20) {
        mask |= NSCondensedFontMask;
        [attributes setHyperCondensed:YES];
    }
    if (aStyle & 0x40) {
        mask |= NSExpandedFontMask;
        [attributes setHyperExpanded:YES];
    }
    [[self parser] setValuesBufferObject:[NSNumber numberWithInt:(int)mask] forKey:@"~HTextViewAttributesTraitMask"];
    [[self parser] setValuesBufferObject:underline forKey:@"~HTextViewAttributesUnderlineStyle"];
    [[self parser] setValuesBufferObject:outline forKey:@"~HTextViewAttributesOutlineStyle"];
    [[self parser] setValuesBufferObject:shadow forKey:@"~HTextViewAttributesShadowStyle"];
    return mask;
}
- (id)actionObjectPathForApplePath:(id)aPath
{
    return [self actionObjectPathForPath:[self pathForApplePath:aPath]];
}
- (id)actionObjectPathForPath:(id)aPath
{
    return [HSNavigationController findFile:aPath base:[[[self oldFormatDocument] fileName] stringByDeletingLastPathComponent]];
}
// "Disk:Folder:File" → "/Volumes/Disk/Folder/File".
- (id)pathForApplePath:(id)aPath
{
    NSMutableArray *components = [NSMutableArray arrayWithArray:[aPath componentsSeparatedByString:@":"]];
    [components insertObject:@"Volumes" atIndex:0];
    return [@"/" stringByAppendingString:[components componentsJoinedByString:@"/"]];
}
// At most 255 bytes of Mac Roman text.
- (id)stringForImportedData:(id)aData
{
    if (aData == nil || [aData length] == 0)
        return nil;
    if ([aData length] > 0x100)
        aData = [aData subdataWithRange:NSMakeRange(0, 0xff)];
    // The original copied all of a 256-byte string into 255 bytes and
    // terminated it one byte too late; the copy is bounded here.
    char buffer[0x100];
    NSUInteger length = MIN([aData length], (NSUInteger)0xff);
    [aData getBytes:buffer length:length];
    buffer[length] = 0;
    return [NSString stringWithCString:buffer encoding:NSMacOSRomanStringEncoding];
}
@end
