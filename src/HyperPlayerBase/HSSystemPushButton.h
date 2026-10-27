#import "HyperPlayerBasePrefix.h"
#import "HSSystemButton.h"


@interface HSSystemPushButton : HSSystemButton <HSSystemPushButtonAttributes, HSSystemButtonAttributes, HSAttributes, HyperInterface, NSObject, HSTitleMutableAttributes, HSTitleAttributes, HSTitleStringAttribute, HSTitleAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSTitleFontAttribute, HSTitleRectAttribute, HSSystemControlSizeAttribute, HSSystemButtonBorderAttribute, HSSystemTransparencyAttribute, HSSystemButtonContinuousAttribute, HSSystemEnabledAttribute, HSResizingBehaviorSubattributes, HSDefaultSizeSubattributes>
{
    unsigned int _previousControlSize;
}
+ (Class)nodeDataClass;
- (id)hyperSizeMaxValue;
- (id)hyperSizeMinValue;
- (NSSize)defaultSize;
- (BOOL)canResizeVertically;
- (BOOL)canResizeHorizontally;
- (BOOL)canBreakSizeAspectRatio;
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically;
- (void)controlSizeDidChange;
- (void)controlSizeWillChange;
- (void)HSSystemPushButton_controlSizeDidChange:(id)aChange;
- (void)HSSystemPushButton_controlSizeWillChange:(id)aChange;
- (CGFloat)adjustingWidthForControlSize:(NSUInteger)aSize;
- (void)didCreateSystemView;
- (void)dealloc;
- (id)init;
@end

