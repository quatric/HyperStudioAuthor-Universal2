#import "HyperStudioPrefix.h"
#import "HSColorPicker.h"


@interface HSGradientPicker : HSColorPicker
{
    HSWheelColorViewController *_startColorController;
    HSWheelColorViewController *_endColorController;
    NSColor *_gradientStartColor;
    NSColor *_gradientEndColor;
    NSTextField *_topColorTextFiled;
    NSTextField *_bottomColorTextFiled;
    NSMatrix *_matrix;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedGradienPicker;
- (void)gradientTypeChanged:(id)aChanged;
- (void)switchColors:(id)aColors;
- (void)setGradientKindFromInterface:(id)aInterface;
- (NSSize)minContentSize;
- (NSSize)maxContentSize;
- (void)colorDidChange:(id)aChange;
- (void)didLoadNib;
- (void)setColor:(id)aColor;
- (id)gradientEndColor;
- (void)setGradientEndColor:(id)aColor;
- (id)gradientStartColor;
- (void)setGradientStartColor:(id)aColor;
- (id)nibName;
- (id)imageName;
- (NSInteger)currentMode;
- (BOOL)supportsMode:(NSInteger)aMode;
- (id)buttonToolTip;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

