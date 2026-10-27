#import "HyperStudioPrefix.h"


@interface HSMediaStripFilmCanAnimator : NSObject <NSAnimationDelegate, NSObject>
{
    HSMediaStripAnimatingFilmCan *_animatingView;
    NSView *_containerView;
    NSScrollView *_enclosingScrollView;
    NSAnimation *_filmCanAnimation;
    float _windowWidthDelta;
}
+ (id)synchronousAnimatorWithFilmCanView:(id)aView containerView:(id)aView2 enclosingScrollView:(id)aView3 windowWidthDelta:(CGFloat)aDelta;
- (void)closeAndAnimate:(BOOL)aAnimate;
- (void)openAndAnimate:(BOOL)aAnimate;
- (void)mediaStripFilmCanAnimation:(id)aAnimation didChangeProgressTo:(CGFloat)aTo;
- (void)performFilmCanOpening:(BOOL)aOpening;
- (void)resizeContainerViewToWidth:(CGFloat)aWidth windowToWidth:(CGFloat)aWidth2 forceWindowUpdate:(BOOL)aUpdate;
- (void)animateFilmCanForOpening:(BOOL)aOpening;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (BOOL)animationShouldStart:(id)aStart;
- (void)discardAnimation:(id)aAnimation;
- (void)setFilmCanAnimation:(id)aAnimation;
- (id)filmCanAnimation;
- (void)dealloc;
- (id)initWithFilmCanView:(id)aView containerView:(id)aView2 enclosingScrollView:(id)aView3 windowWidthDelta:(CGFloat)aDelta;
@end

