#import "HSTransitionEffect.h"
// The base of transition effects: no renderers; a new frame only at the
// end. Effects of one class are equal.
@implementation HSTransitionEffect
- (BOOL)isExternal
{
    return NO;
}
- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat
{
    return nil;
}
- (id)createQuartzRendererForSize:(CGSize)aSize
{
    return nil;
}
- (BOOL)hasOpenGLRenderer
{
    return NO;
}
- (BOOL)hasQuartzRenderer
{
    return NO;
}
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2
{
    if (aTime == 1.0)
        return aTime2 < 1.0;
    return aTime2 == 1.0;
}
- (BOOL)isSlow
{
    return NO;
}
- (NSUInteger)hash
{
    return (NSUInteger)[self class];
}
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSTransitionEffect class]])
        return NO;
    Class class = [self class];
    // A subclass instance decides for itself.
    if (![aEqual isMemberOfClass:class] && [aEqual isKindOfClass:class])
        return [aEqual isEqual:self];
    return YES;
}
@end
