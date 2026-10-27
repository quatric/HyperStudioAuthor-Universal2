#import "HSControlAnimator.h"

// Animates control values: changes asked for between openAnimationGroup
// and closeAnimationGroup are collected, then run together in 0.3 seconds
// by startAnimations:.

static HSControlAnimator *sSharedAnimator;

@implementation HSControlAnimator

+ (id)sharedControlAnimator
{
    if (sSharedAnimator == nil)
        sSharedAnimator = [HSControlAnimator new];
    return [[sSharedAnimator retain] autorelease];
}

- (void)animationDidEnd:(id)aEnd
{
    [[self mutableAnimationProperties] removeAllObjects];
    [_animation release];
    _animation = nil;
}

- (void)animationDidStop:(id)aStop
{
    [_animation finishAnimation];
    [[self mutableAnimationProperties] removeAllObjects];
    [_animation release];
    _animation = nil;
}

- (void)animateObject:(id)aObject key:(id)aKey toValue:(id)aValue
{
    if (![self acceptsAnimations])
        return;
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:aObject, HSControlAnimatorTargetKey, aKey, HSControlAnimatorPropertyKey,
        [aObject valueForKey:aKey], HSControlAnimatorStartValueKey, aValue, HSControlAnimatorEndValueKey, nil];
    [[self mutableAnimationProperties] addObject:properties];
}

- (void)startAnimations:(id)aAnimations
{
    [_animation stopAnimation];
    // (A stopped animation was released by animationDidStop:.)
    _animation = [[HSControlAnimation alloc] initWithAnimationProperties:[self animationProperties]];
    [_animation setDuration:0.3];
    [_animation setDelegate:self];
    [_animation startAnimation];
}

- (BOOL)acceptsAnimations
{
    return _acceptsAnimations;
}

- (void)closeAnimationGroup
{
    _acceptsAnimations = NO;
}

- (void)openAnimationGroup
{
    _acceptsAnimations = YES;
}

- (id)animationProperties
{
    return [self mutableAnimationProperties];
}

- (id)mutableAnimationProperties
{
    if (_animationProperties == nil)
        _animationProperties = [NSMutableArray new];
    return _animationProperties;
}

- (void)dealloc
{
    [_animationProperties release];
    [super dealloc];
}

@end

@implementation NSColorWell (HSControlAnimator)

- (void)setHyperColor:(id)aColor animate:(BOOL)aAnimate
{
    if (aAnimate)
        [[HSControlAnimator sharedControlAnimator] animateObject:self key:@"color" toValue:aColor];
    else
        [self setColor:aColor];
}

@end

@implementation NSControl (HSControlAnimator)

- (void)setHyperIntValue:(NSInteger)aValue animate:(BOOL)aAnimate
{
    [self setHyperObjectValue:[NSNumber numberWithInteger:aValue] animate:aAnimate];
}

- (void)setHyperFloatValue:(CGFloat)aValue animate:(BOOL)aAnimate
{
    [self setHyperObjectValue:[NSNumber numberWithFloat:aValue] animate:aAnimate];
}

- (void)setHyperObjectValue:(id)aValue animate:(BOOL)aAnimate
{
    if (aAnimate)
        [[HSControlAnimator sharedControlAnimator] animateObject:self key:@"objectValue" toValue:aValue];
    else
        [self setObjectValue:aValue];
}

@end
