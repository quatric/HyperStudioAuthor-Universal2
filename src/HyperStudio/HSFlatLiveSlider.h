#import "HyperStudioPrefix.h"


@interface HSFlatLiveSlider : NSControl <NSValidatedUserInterfaceItem, NSAnimationDelegate, NSObject>
{
    float _progress;
    double _changeDuration;
    double _cancelDuration;
    HSFlatLiveSliderAnimation *_sliderAnimation;
    NSMutableDictionary *_texturesCache;
    int _state;
    BOOL _isTrackingMouse;
}
+ (Class)cellClass;
- (NSInteger)tag;
- (SEL)action;
- (void)setCancelDuration:(double)aDuration;
- (double)cancelDuration;
- (void)setChangeDuration:(double)aDuration;
- (double)changeDuration;
- (void)animationDidEnd:(id)aEnd;
- (void)drawBackground;
- (void)drawSlider;
- (void)drawRect:(NSRect)aRect;
- (id)liveSliderImage;
- (id)flatSliderImage;
- (id)liveBackgroundImage;
- (id)flatBackgroundImage;
- (void)invalidateAnimation;
- (CGFloat)progress;
- (void)setProgress:(CGFloat)aProgress;
- (BOOL)isAnimationInProgress;
- (void)animateWithProgress:(CGFloat)aProgress;
- (void)mouseDown:(id)aDown;
- (void)mouseUp:(id)aUp;
- (CGFloat)xForProgress:(CGFloat)aProgress;
- (CGFloat)progressForX:(CGFloat)aX;
- (CGFloat)progressForState:(NSInteger)aState;
- (CGFloat)knobWidth;
- (NSInteger)invertedState;
- (NSInteger)state;
- (void)setState:(NSInteger)aState animate:(BOOL)aAnimate;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)dealloc;
@end

@interface HSFlatLiveSlider (Accessibility)
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityAttributeNames;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
@end

