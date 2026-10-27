#import "HyperPlayerBasePrefix.h"


@interface HSVisualizationAuxiliaryView : NSView
{
    BOOL _isHyperFlipped;
}
- (BOOL)isOpaque;
- (BOOL)isFlipped;
- (void)setHyperFlipped:(BOOL)aFlipped;
@end

