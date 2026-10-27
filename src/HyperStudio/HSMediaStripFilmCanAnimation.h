#import "HyperStudioPrefix.h"


@interface HSMediaStripFilmCanAnimation : NSAnimation
{
    unsigned int _countOfFrames;
    float _originalWindowWidth;
    float _windowWidthDelta;
    NSRect _originalContainerFrameInWindowCoordinates;
    NSView *_containerView;
    BOOL _invertResizingProgress;
    BOOL _isCurrentResizingProgressValid;
    float _currentResizingProgress;
    BOOL _isCurrentFrameValid;
    unsigned int _currentFrameIndex;
}
+ (id)animationWithView:(id)aView containerView:(id)aView2 windowWidthDelta:(CGFloat)aDelta duration:(CGFloat)aDuration invertResizingProgress:(BOOL)aProgress;
- (CGFloat)currentValueForContainerViewWidth;
- (CGFloat)currentValueForWindowWidth;
- (CGFloat)currentResizingProgress;
- (BOOL)getCurrentFilmCanAnimationFrame:(unsigned int *)aFrame;
- (NSUInteger)countOfFrames;
- (void)setCurrentProgress:(CGFloat)aProgress;
- (void)stopAnimation;
- (void)startAnimation;
- (void)dealloc;
- (id)initWithView:(id)aView containerView:(id)aView2 windowWidthDelta:(CGFloat)aDelta duration:(CGFloat)aDuration invertResizingProgress:(BOOL)aProgress;
@end

