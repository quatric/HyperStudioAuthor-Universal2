#import "HSGraphicComposition.h"
// A composition with no renderers (an abstract base); compositions of the
// same class are equal.
@implementation HSGraphicComposition
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
    return NO;
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
    if (![aEqual isKindOfClass:[HSGraphicComposition class]])
        return NO;
    Class class = [self class];
    if (![aEqual isMemberOfClass:class] && [aEqual isKindOfClass:class])
        return [aEqual isEqual:self];
    return YES;
}
@end
