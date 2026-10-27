#import "HSGhostWriterActionPerformer.h"
#import "HSGhostWriterAction.h"
#import "HSGhostWriterTypeTextCommand.h"

static HSGhostWriterActionPerformer *sSharedGhostWriterActionPerformer = nil;

// Runs Ghost Writer actions one at a time, in the order they were queued.
// Each command of the current action runs after a timer delay; a type text
// command types one character per tick into the target text object (or the
// active text field).
@implementation HSGhostWriterActionPerformer

// Quirk kept: a second allocation returns nil.
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedGhostWriterActionPerformer == nil) {
            sSharedGhostWriterActionPerformer = [super allocWithZone:aZone];
            return sSharedGhostWriterActionPerformer;
        }
    }
    return nil;
}

+ (id)sharedGhostWriterActionPerformer
{
    @synchronized(self) {
        if (sSharedGhostWriterActionPerformer == nil)
            [[self alloc] init];
    }
    return sSharedGhostWriterActionPerformer;
}

- (void)startAction
{
    [self setupInitialSettings];
    [self runNextCommandIfNeeded];
}

- (void)currentActionDidFinish
{
    [[_actionsQueue objectAtIndex:0] didFinishInActionPerfromer];
}

- (id)commands
{
    return [[self action] commands];
}

- (id)card
{
    return [[self action] card];
}

- (id)stack
{
    return [[self action] stack];
}

// Changes only by more than 0.0005 of the larger magnitude (compared as
// floats).
- (void)setTimeInterval:(double)aInterval
{
    float oldInterval = _timeInterval;
    float newInterval = aInterval;
    float magnitude = MAX(oldInterval != 0.0f ? fabsf(oldInterval) : 1.0f, newInterval != 0.0f ? fabsf(newInterval) : 1.0f);
    if (magnitude * 0.0005f < fabsf(oldInterval - newInterval))
        _timeInterval = aInterval;
}

- (double)timeInterval
{
    return _timeInterval;
}

- (void)setupInitialSettings
{
    [self setTimeInterval:0.2];
    _commandsCounter = 0;
    _charactersCounter = 0;
}

// The timer holds a weak proxy, so it doesn't retain the performer.
- (void)createTimerWithFireSelector:(SEL)aSelector
{
    [self invalidateTimer];
    _timer = [[NSTimer timerWithTimeInterval:[self timeInterval] target:[[self NSE_newWeakProxy] autorelease] selector:aSelector userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSEventTrackingRunLoopMode];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
}

// Types the next character. The tick after the last character moves on to
// the next command.
- (void)fireTimer:(id)aTimer
{
    id command = [[self commands] objectAtIndex:_commandsCounter];
    if ([command queryHyperInterface:@protocol(HSGhostWriterTypeTextCommandInterface)] == nil) {
        [self runCommand:command];
        return;
    }
    if (_charactersCounter < [[self textToType] length]) {
        id target = [self textObjectWithUID:_targetObjectUID];
        if (target == nil) {
            target = [[[[self action] document] cardView] activeTextField];
            if (target != nil && ![HSGhostWriterAction canUseObject:target])
                target = nil;
        }
        NSString *character = [[self textToType] substringWithRange:NSMakeRange(_charactersCounter, 1)];
        [[self action] insertText:character toNode:[target queryHyperInterface:@protocol(HSNodeAttributes)]];
    }
    if ((_targetObjectUID == nil || [self textObjectWithUID:_targetObjectUID] == nil) && [[[[self action] document] cardView] activeTextField] == nil)
        return;
    _charactersCounter++;
    if (_charactersCounter <= [[self textToType] length])
        return;
    _commandsCounter++;
    [self runNextCommandIfNeeded];
}

- (id)textObjectWithUID:(id)aUID
{
    return [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
}

- (void)runCommand:(id)aCommand
{
    [aCommand executeWithActionPerformer:self];
    if ([[[aCommand class] commandType] isEqualToString:[HSGhostWriterTypeTextCommand commandType]]) {
        _charactersCounter = 0;
        [self createTimerWithFireSelector:@selector(fireTimer:)];
        [self fireTimer:nil];
    } else {
        _commandsCounter++;
        [self invalidateTimer];
        [self runNextCommandIfNeeded];
    }
}

// A command whose target is hidden stops the action. Some commands run
// straight after the previous one; the others wait for a tick.
- (void)runNextCommandIfNeeded
{
    if (_commandsCounter >= [[self commands] count]) {
        [self currentActionDidFinish];
        return;
    }
    id command = [[self commands] objectAtIndex:_commandsCounter];
    id target = [self textObjectWithUID:[[command queryHyperInterface:@protocol(HSGhostWriterTargetCommandInterface)] targetObjectUID]];
    if ([[target queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)] isHiddenInPlayer])
        return;
    if (_commandsCounter != 0 && [command shouldRunWithoutDelayAfterCommand:[[self commands] objectAtIndex:_commandsCounter - 1]])
        [self runCommand:command];
    else
        [self createTimerWithFireSelector:@selector(delayDidFinish:)];
}

- (void)delayDidFinish:(id)aFinish
{
    [self runCommand:[[self commands] objectAtIndex:_commandsCounter]];
}

- (id)action
{
    return [_actionsQueue objectAtIndex:0];
}

- (void)actionDidStop:(id)aStop
{
    [self invalidateTimer];
    [_actionsQueue removeObjectIdenticalTo:aStop];
    [_targetObjectUID release];
    _targetObjectUID = nil;
    if ([_actionsQueue count] != 0)
        [self startAction];
}

// The same action queued again behind itself just finishes the running one.
- (void)performAction:(id)aAction
{
    if (_actionsQueue == nil)
        _actionsQueue = [NSMutableArray new];
    [_actionsQueue addObject:aAction];
    if ([_actionsQueue count] == 2 && [[_actionsQueue objectAtIndex:0] isEqual:aAction])
        [self currentActionDidFinish];
    else if ([_actionsQueue count] == 1)
        [self startAction];
}

- (void)moveRight
{
    [self doCommandBySelector:@selector(moveRight:)];
}

- (void)moveLeft
{
    [self doCommandBySelector:@selector(moveLeft:)];
}

- (void)backspace
{
    [self doCommandBySelector:@selector(deleteBackward:)];
}

- (void)erase
{
    [self doCommandBySelector:@selector(erase:)];
}

- (void)doCommandBySelector:(SEL)aSelector
{
    [[self action] doCommandBySelector:aSelector forNode:[self textObjectWithUID:_targetObjectUID]];
}

- (id)targetObjectUID
{
    return _targetObjectUID;
}

// Only an object Ghost Writer can type into becomes the target.
- (void)setTargetObjectUID:(id)aUID
{
    id object = [self textObjectWithUID:aUID];
    if ([_targetObjectUID isEqual:aUID] || ![HSGhostWriterAction canUseObject:object])
        return;
    [_targetObjectUID release];
    _targetObjectUID = [aUID retain];   // the original left the old pointer when aUID was nil
    if (aUID != nil)
        [[self action] insertText:nil toNode:[self textObjectWithUID:_targetObjectUID]];
}

// Speeds 1 (fastest) to 7 (slowest); others are ignored.
- (void)setTypingSpeed:(NSInteger)aSpeed
{
    switch (aSpeed) {
    case 1: [self setTimeInterval:0]; break;
    case 2: [self setTimeInterval:0.05]; break;
    case 3: [self setTimeInterval:0.1]; break;
    case 4: [self setTimeInterval:0.2]; break;
    case 5: [self setTimeInterval:0.5]; break;
    case 6: [self setTimeInterval:1]; break;
    case 7: [self setTimeInterval:3]; break;
    default: break;
    }
}

- (NSInteger)typingSpeed
{
    return 0;
}

- (void)setTextToType:(id)aType
{
    if ([_textToType isEqual:aType])
        return;
    [_textToType release];
    _textToType = [aType retain];
}

- (id)textToType
{
    return _textToType;
}

- (void)dealloc
{
    [_actionsQueue release];
    [_textToType release];
    [_timer invalidate];
    [_timer release];
    [_targetObjectUID release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
