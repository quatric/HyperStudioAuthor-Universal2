#import "HyperPlayerBasePrefix.h"
#import "HSControllerCell.h"


@interface HSQTVRMovieControllerCell : HSControllerCell
{
}
+ (id)disabledQTVREmptyBarImage;
+ (id)disabledQTVRControlsImage;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (CGFloat)controllerHeight;
- (CGFloat)minControllerWidth;
@end

