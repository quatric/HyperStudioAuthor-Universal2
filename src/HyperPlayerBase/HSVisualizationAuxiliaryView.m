#import "HSVisualizationAuxiliaryView.h"
@implementation HSVisualizationAuxiliaryView
- (BOOL)isOpaque
{
    return NO;
}
- (BOOL)isFlipped
{
    return _isHyperFlipped;
}
- (void)setHyperFlipped:(BOOL)aFlipped
{
    _isHyperFlipped = aFlipped;
    [self setNeedsDisplay:YES];
}
@end
