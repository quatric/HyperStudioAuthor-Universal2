#import "HSLockedKnob.h"

@implementation HSLockedKnob

+ (id)normalStateImage
{
    static NSImage *sImage = nil;
    if (sImage == nil)
        sImage = [[NSImage imageNamed:@"hLocked"] retain];
    return sImage;
}

- (id)affectingAttributes
{
    return [_originalKnob affectingAttributes];
}

static BOOL HSLockedKnobApproximatelyEqual(float a, float b)
{
    float scaleA = a != 0.0f ? fabsf(a) : 1.0f;
    float scaleB = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(scaleA, scaleB) * 0.0005f;
}

- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    NSRect originalFrame = [_originalKnob calculateFrameForOwner:aOwner inView:aView];
    NSRect frame = [super calculateFrameForOwner:aOwner inView:aView];
    if (HSLockedKnobApproximatelyEqual(frame.size.width, originalFrame.size.width)
        && HSLockedKnobApproximatelyEqual(frame.size.height, originalFrame.size.height))
        return originalFrame;
    frame.origin.x = ((originalFrame.size.width * 0.5 + originalFrame.origin.x) - (frame.size.width * 0.5 + frame.origin.x)) + frame.origin.x;
    frame.origin.y = ((originalFrame.size.height * 0.5 + originalFrame.origin.y) - (frame.size.height * 0.5 + frame.origin.y)) + frame.origin.y;
    return NSIntegralRect(frame);
}

- (BOOL)hitTest:(NSPoint)aTest forOwner:(id)aOwner inView:(id)aView
{
    return NO;
}

- (id)querySelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return nil;
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return nil;
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NO;
}

- (void)dealloc
{
    [_originalKnob release];
    [super dealloc];
}

- (id)init
{
    return [self initWithOriginalKnob:nil];
}

- (id)initWithOriginalKnob:(id)aKnob
{
    self = [super init];
    if (self != nil)
        _originalKnob = [aKnob retain];
    return self;
}

@end
