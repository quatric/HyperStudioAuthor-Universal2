#import "HyperEditorBasePrefix.h"


@interface HSControlAnimator : NSObject <NSAnimationDelegate, NSObject>
{
    NSMutableArray *_animationProperties;
    HSControlAnimation *_animation;
    BOOL _acceptsAnimations;
}
+ (id)sharedControlAnimator;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (void)animateObject:(id)aObject key:(id)aKey toValue:(id)aValue;
- (void)startAnimations:(id)aAnimations;
- (BOOL)acceptsAnimations;
- (void)closeAnimationGroup;
- (void)openAnimationGroup;
- (id)animationProperties;
- (id)mutableAnimationProperties;
- (void)dealloc;
@end

@interface NSColorWell (HSControlAnimator)
- (void)setHyperColor:(id)aColor animate:(BOOL)aAnimate;
@end

@interface NSControl (HSControlAnimator)
- (void)setHyperIntValue:(NSInteger)aValue animate:(BOOL)aAnimate;
- (void)setHyperFloatValue:(CGFloat)aValue animate:(BOOL)aAnimate;
- (void)setHyperObjectValue:(id)aValue animate:(BOOL)aAnimate;
@end

