#import "HSWindowMovingAnimation.h"
@implementation HSWindowMovingAnimation
// Moves the source window to the destination rect in half a second (ease in,
// blocking), ignoring the mouse meanwhile.
- (void)startAnimation
{
    NSDictionary *animation = [[NSDictionary alloc] initWithObjectsAndKeys:
        _sourceWindow, NSViewAnimationTargetKey,
        [NSValue valueWithRect:[_sourceWindow frame]], NSViewAnimationStartFrameKey,
        [NSValue valueWithRect:_destinationRect], NSViewAnimationEndFrameKey,
        nil];
    if (animation == nil)
        return;
    NSArray *animations = [[NSArray alloc] initWithObjects:animation, nil];
    [animation release];
    if (animations == nil)
        return;
    [_sourceWindow setIgnoresMouseEvents:YES];
    [self setViewAnimations:animations];
    [animations release];
    [self setDuration:0.5];
    [self setAnimationCurve:NSAnimationEaseIn];
    [self setAnimationBlockingMode:NSAnimationBlocking];
    [super startAnimation];
}
- (void)dealloc
{
    [_sourceWindow release];
    [super dealloc];
}
- (id)initWithWindow:(id)aWindow destinationRect:(NSRect)aRect
{
    self = [super init];
    if (self != nil) {
        _sourceWindow = [aWindow retain];
        _destinationRect = aRect;
    }
    return self;
}
// Not available: use -initWithWindow:destinationRect:.
- (id)initWithViewAnimations:(id)aAnimations
{
    [self release];
    return nil;
}
- (id)init
{
    [self release];
    return nil;
}
@end
