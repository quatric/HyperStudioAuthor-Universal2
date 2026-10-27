#import "HyperStudioPrefix.h"


@interface HSSegmentRulerView : NSView
{
    HSSegmentView *_segmentView;
    NSSlider *_currentValueSlider;
    NSButton *_leftPlusMinusButton;
    NSButton *_rightPlusMinusButton;
}
+ (id)minusImage;
+ (id)plusImage;
- (void)refreshPlusMinus;
- (NSRect)rightPlusMinusFrame;
- (NSRect)leftPlusMinusFrame;
- (BOOL)arePlusMinusVisible;
- (void)createPlusMinusButton:(id *)aButton image:(id)aImage action:(SEL)aAction;
- (void)drawRect:(NSRect)aRect;
- (id)textAttributes;
- (void)refreshCurrentValue;
- (void)refresh;
- (void)setupSlider;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame segmentView:(id)aView;
@end

