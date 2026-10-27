#import "NSTextContainer+HSExtensions.h"
@implementation NSTextContainer (HSExtensions)
+ (CGFloat)hyperDefaultLineFragmentPadding
{
    static BOOL known;
    static float padding;
    if (!known) {
        NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        padding = [container lineFragmentPadding];
        [container release];
        known = YES;
    }
    return padding;
}
// sizes within 0.05% of each other count as equal
static BOOL HSTextContainerSizesDiffer(float a, float b)
{
    float scale = fmaxf(a != 0 ? fabsf(a) : 1.0f, b != 0 ? fabsf(b) : 1.0f);
    return scale * 0.0005f < fabsf(a - b);
}
- (void)hyperResizeToContainerHeight:(CGFloat)aHeight
{
    NSSize size = [self containerSize];
    if (HSTextContainerSizesDiffer(aHeight, size.height))
        [self setContainerSize:NSMakeSize(size.width, aHeight)];
}
- (void)hyperResizeToContainerWidth:(CGFloat)aWidth
{
    NSSize size = [self containerSize];
    if (HSTextContainerSizesDiffer(aWidth, size.width))
        [self setContainerSize:NSMakeSize(aWidth, size.height)];
}
@end
