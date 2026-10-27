#import "HSPauseAction.h"
// "Pause": waits for a duration (0.1 s by default) before the next action.
@implementation HSPauseAction
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setPauseDuration:[[[aRepresentation attributeForName:@"pauseDuration"] stringValue] doubleValue]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"pauseDuration" stringValue:[NSString stringWithFormat:@"%.2f", [self pauseDuration]]]];
    return element;
}
- (id)XMLElementName
{
    return @"actPause";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (void)setPauseDuration:(double)aDuration
{
    if (_pauseDuration == aDuration)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Pause Duration" value:@"" table:@"UndoManager"]];
    [(HSPauseAction *)[[self undoManager] prepareWithInvocationTarget:self] setPauseDuration:[self pauseDuration]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPauseDurationAttribute) ofObject:self withUserInfo:nil];
    _pauseDuration = aDuration;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPauseDurationAttribute) ofObject:self withUserInfo:nil];
}
- (double)pauseDuration
{
    return _pauseDuration;
}
// (The timer's callback: it fires once.)
- (void)pauseTimerInvalidated:(id)aInvalidated
{
    [self notifyDidFinish];
    [_pauseTimer release];
    _pauseTimer = nil;
}
- (void)startInContext:(id)aContext
{
    [aContext setCurrentPauseAction:self];
    _pauseTimer = [[NSTimer timerWithTimeInterval:[self pauseDuration] target:self selector:@selector(pauseTimerInvalidated:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:_pauseTimer forMode:NSDefaultRunLoopMode];
}
- (void)stop:(id)aStop
{
    [_pauseTimer invalidate];
    [_pauseTimer release];
    _pauseTimer = nil;
    [super stop:aStop];
    [self notifyDidFinish];
}
- (BOOL)canBeStopped
{
    return YES;
}
- (BOOL)isSynchronous
{
    return YES;
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObject:@"pauseDuration"]];
}
- (void)dealloc
{
    [_pauseTimer release];
    [super dealloc];
}
- (id)initWithDuration:(double)aDuration
{
    self = [super init];
    if (self != nil)
        [self setPauseDuration:aDuration];
    return self;
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _pauseDuration = 0.1;
    return self;
}
@end
