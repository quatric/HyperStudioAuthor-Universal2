#import "HyperEditorBasePrefix.h"


@interface HSControlslImageProvider : NSObject
{
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedImageProvider;
- (id)popUpButtonEditableFillPressedImage;
- (id)popUpButtonEditableRightCapPressedImage;
- (id)popUpButtonEditableLeftCapPressedImage;
- (id)popUpButtonEditableFillImage;
- (id)popUpButtonEditableRightCapImage;
- (id)popUpButtonEditableLeftCapImage;
- (id)popUpButtonFillDisabledImage;
- (id)popUpButtonRightCapDisabledImage;
- (id)popUpButtonLeftCapDisabledImage;
- (id)popUpButtonFillPressedImage;
- (id)popUpButtonRightCapPressedImage;
- (id)popUpButtonLeftCapPressedImage;
- (id)popUpButtonFillImage;
- (id)popUpButtonRightCapImage;
- (id)popUpButtonLeftCapImage;
- (id)stepperNoPressedDisabledImage;
- (id)stepperDownPressedImage;
- (id)stepperUpPressedImage;
- (id)stepperNoPressedImage;
- (id)sliderBlueCirclePressedImage;
- (id)sliderBlueCircleImage;
- (id)sliderAboveBlueTrianglePressedImage;
- (id)sliderAboveBlueTriangleImage;
- (id)sliderBelowBlueTrianglePressedImage;
- (id)sliderBelowBlueTriangleImage;
- (id)sliderPressedWithMarksImage;
- (id)sliderWithMarksImage;
- (id)sliderPressedWithoutMarksImage;
- (id)sliderWithoutMarksImage;
- (id)verticalScrollerBottomKnobImage;
- (id)verticalScrollerMiddleKnobImage;
- (id)verticalScrollerTopKnobImage;
- (id)verticalScrollerMiddleImage;
- (id)verticalScrollerTopImage;
- (id)verticalScrollerTogetherUpPressedImage;
- (id)verticalScrollerTogetherUpImage;
- (id)verticalScrollerUpPressedImage;
- (id)verticalScrollerUpImage;
- (id)verticalScrollerTogetherDownPressedImage;
- (id)verticalScrollerTogetherDownImage;
- (id)verticalScrollerDownPressedImage;
- (id)verticalScrollerDownImage;
- (id)radioButtonDisabledPushedImage;
- (id)radioButtonDisabledImage;
- (id)radioButtonPushedImage;
- (id)radioButtonImage;
- (id)checkBoxDisabledPushedImage;
- (id)checkBoxDisabledImage;
- (id)checkBoxPushedImage;
- (id)checkBoxImage;
- (id)buttonFillDisabledImage;
- (id)buttonRightCapDisabledImage;
- (id)buttonLeftCapDisabledImage;
- (id)buttonFillPressedImage;
- (id)buttonRightCapPressedImage;
- (id)buttonLeftCapPressedImage;
- (id)buttonFillImage;
- (id)buttonRightCapImage;
- (id)buttonLeftCapImage;
- (id)imageWithName:(id)aName;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

