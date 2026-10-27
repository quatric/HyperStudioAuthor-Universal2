#import "NSParagraphStyle+HSExtensions.h"
// Paragraph styles changed one attribute at a time; unchanged (within
// 0.05%) styles come back as they are.
static BOOL HSParagraphValuesAreClose(float a, float b)
{
    float scale = MAX(a != 0 ? fabsf(a) : 1.0f, b != 0 ? fabsf(b) : 1.0f);
    return fabsf(a - b) <= scale * 0.0005f;
}

@implementation NSParagraphStyle (HSExtensions)
+ (id)hyperParagraphStyleWithAlignment:(NSUInteger)aAlignment lineBreakMode:(NSUInteger)aMode
{
    NSParagraphStyle *style = [NSParagraphStyle defaultParagraphStyle];
    if ((NSUInteger)[style alignment] == aAlignment)
        return [style hyperParagraphStyleByChangingLineBreakMode:aMode];
    if ((NSUInteger)[style lineBreakMode] == aMode)
        return [style hyperParagraphStyleByChangingAlignment:aAlignment];
    NSMutableParagraphStyle *changed = [style mutableCopy];
    [changed setAlignment:aAlignment];
    [changed setLineBreakMode:aMode];
    NSParagraphStyle *result = [[changed copy] autorelease];
    [changed release];
    return result;
}
+ (id)hyperParagraphStyleWithCombinedHeadIndent:(CGFloat)aIndent
{
    return [[NSParagraphStyle defaultParagraphStyle] hyperParagraphStyleByChangingCombinedHeadIndent:aIndent];
}
+ (id)hyperParagraphStyleWithLineBreakMode:(NSUInteger)aMode
{
    return [[NSParagraphStyle defaultParagraphStyle] hyperParagraphStyleByChangingLineBreakMode:aMode];
}
+ (id)hyperParagraphStyleWithAlignment:(NSUInteger)aAlignment
{
    return [[NSParagraphStyle defaultParagraphStyle] hyperParagraphStyleByChangingAlignment:aAlignment];
}
- (id)hyperParagraphStyleByChangingMinimumLineHeight:(CGFloat)aHeight
{
    if (!HSParagraphValuesAreClose(aHeight, [self minimumLineHeight])) {
        NSMutableParagraphStyle *changed = [self mutableCopy];
        [changed setMinimumLineHeight:aHeight];
        NSParagraphStyle *result = [[changed copy] autorelease];
        [changed release];
        if (result != nil)
            return result;
    }
    return [[self retain] autorelease];
}
// The head indent of every line, the first included.
- (id)hyperParagraphStyleByChangingCombinedHeadIndent:(CGFloat)aIndent
{
    if (!HSParagraphValuesAreClose(aIndent, [self headIndent]) || !HSParagraphValuesAreClose(aIndent, [self firstLineHeadIndent])) {
        NSMutableParagraphStyle *changed = [self mutableCopy];
        [changed setHeadIndent:aIndent];
        [changed setFirstLineHeadIndent:aIndent];
        NSParagraphStyle *result = [[changed copy] autorelease];
        [changed release];
        if (result != nil)
            return result;
    }
    return [[self retain] autorelease];
}
- (id)hyperParagraphStyleByChangingLineBreakMode:(NSUInteger)aMode
{
    if ((NSUInteger)[self lineBreakMode] != aMode) {
        NSMutableParagraphStyle *changed = [self mutableCopy];
        [changed setLineBreakMode:aMode];
        NSParagraphStyle *result = [[changed copy] autorelease];
        [changed release];
        if (result != nil)
            return result;
    }
    return [[self retain] autorelease];
}
- (id)hyperParagraphStyleByChangingAlignment:(NSUInteger)aAlignment
{
    if ((NSUInteger)[self alignment] != aAlignment) {
        NSMutableParagraphStyle *changed = [self mutableCopy];
        [changed setAlignment:aAlignment];
        NSParagraphStyle *result = [[changed copy] autorelease];
        [changed release];
        if (result != nil)
            return result;
    }
    return [[self retain] autorelease];
}
@end
