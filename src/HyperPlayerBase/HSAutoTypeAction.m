#import "HSAutoTypeAction.h"

@implementation HSAutoTypeAction
// "text[command]text..." -> commands; text runs become type 9.
+ (id)parseStringToCommands:(id)aCommands
{
    NSMutableArray *commands = [NSMutableArray array];
    NSArray *parts = [aCommands componentsSeparatedByString:HSAutoTypeActionOpenBracket];
    NSUInteger i;
    for (i = 0; i < [parts count]; i++) {
        NSArray *pieces = [[parts objectAtIndex:i] componentsSeparatedByString:HSAutoTypeActionCloseBracket];
        if ([pieces count] == 1 && [[pieces objectAtIndex:0] length]) {
            HSAutoTypeCommand *command = [[HSAutoTypeCommand alloc] initWithCommandType:9 command:[pieces objectAtIndex:0]];
            [commands addObject:command];
            [command release];
        } else if ([pieces count] == 2) {
            NSString *name = [pieces objectAtIndex:0];
            NSInteger type = [self commandTypeForString:name];
            if ([name length]) {
                HSAutoTypeCommand *command = [[HSAutoTypeCommand alloc] initWithCommandType:type command:name];
                [commands addObject:command];
                [command release];
            }
            NSString *text = [pieces objectAtIndex:1];
            if ([text length]) {
                HSAutoTypeCommand *command = [[HSAutoTypeCommand alloc] initWithCommandType:9 command:text];
                [commands addObject:command];
                [command release];
            }
        }
    }
    return [[commands copy] autorelease];
}
// Speeds 0-6, 8 erase; anything else (7) names a text object.
+ (NSInteger)commandTypeForString:(id)aString
{
    if ([aString isEqualToString:HSAutoTypeActionFastestCommand])
        return 0;
    if ([aString isEqualToString:HSAutoTypeActionFasterCommand])
        return 1;
    if ([aString isEqualToString:HSAutoTypeActionFastCommand])
        return 2;
    if ([aString isEqualToString:HSAutoTypeActionDefaultCommand])
        return 3;
    if ([aString isEqualToString:HSAutoTypeActionSlowCommand])
        return 4;
    if ([aString isEqualToString:HSAutoTypeActionSlowerCommand])
        return 5;
    if ([aString isEqualToString:HSAutoTypeActionSlowestCommand])
        return 6;
    return [aString isEqualToString:HSAutoTypeActionEraseCommand] ? 8 : 7;
}
// Brackets must balance and not nest.
+ (BOOL)validateStringToType:(id)aType
{
    NSInteger opened = 0, closed = 0;
    NSUInteger i;
    for (i = 0; i < [aType length]; i++) {
        NSString *character = [aType substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:HSAutoTypeActionOpenBracket]) {
            if (opened != closed)
                return NO;
            opened++;
        }
        if ([character isEqualToString:HSAutoTypeActionCloseBracket]) {
            closed++;
            if (closed != opened)
                return NO;
        }
    }
    return opened == closed;
}
- (void)setCommands:(id)aCommands
{
    if (![_commands isEqualToArray:aCommands]) {
        [_commands release];
        _commands = [aCommands retain];
    }
}
- (id)commands
{
    return _commands;
}
- (void)setTimeInterval:(CGFloat)aInterval
{
    float interval = (float)aInterval;
    float current = _timeInterval != 0.0f ? fabsf(_timeInterval) : 1.0f;
    float magnitude = interval != 0.0f ? fabsf(interval) : 1.0f;
    if (magnitude <= current)
        magnitude = current;
    if (magnitude * 0.0005f < fabsf(_timeInterval - interval))
        _timeInterval = interval;
}
- (CGFloat)timeInterval
{
    return _timeInterval;
}
- (void)setTextToType:(id)aType
{
    if ([_textToType isEqual:aType])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text To Type" value:@"" table:@"UndoManager"]];
    [(HSAutoTypeAction *)[[self undoManager] prepareWithInvocationTarget:self] setTextToType:[self textToType]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoTypeTextToTypeAttribute) ofObject:self withUserInfo:nil];
    [_textToType release];
    _textToType = [aType retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoTypeTextToTypeAttribute) ofObject:self withUserInfo:nil];
}
- (id)textToType
{
    return _textToType;
}
// Types one character into every target text object.
- (void)fireTimer:(id)aTimer
{
    NSEnumerator *enumerator = [[self textViewUIDs] objectEnumerator];
    id uid;
    while ((uid = [enumerator nextObject])) {
        id object = [self textObjectWithUID:uid];
        NSAttributedString *character = [[self textToType] attributedSubstringFromRange:NSMakeRange(_charactersCounter, 1)];
        [_context insertText:[character string] toNode:[object queryHyperInterface:@protocol(HSNodeAttributes)]];
    }
    _charactersCounter++;
    if ([[[self textToType] string] length] <= _charactersCounter) {
        [self invalidateTimer];
        [self runNextCommandIfNeeded];
    }
}
- (id)textObjectWithUID:(id)aUID
{
    return [[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:aUID];
}
- (void)runCommand:(NSUInteger)aCommand
{
    NSArray *commands = [self commands];
    if ([commands count] <= aCommand)
        return;
    HSAutoTypeCommand *command = [commands objectAtIndex:aCommand];
    NSString *argument = [command command];
    static const float sIntervals[7] = {0.0f, 0.025f, 0.05f, 0.1f, 0.25f, 0.5f, 1.5f};
    NSInteger type = [command commandType];
    switch (type) {
    case 0: case 1: case 2: case 3: case 4: case 5: case 6:
        [self setTimeInterval:sIntervals[type]];
        [self runNextCommandIfNeeded];
        break;
    case 7:
        [self setTextViewUIDs:[NSArray arrayWithObject:[[[self textViewWithTitle:argument] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID]]];
        [self runNextCommandIfNeeded];
        break;
    case 8: {
        NSEnumerator *enumerator = [[self textViewUIDs] objectEnumerator];
        id uid;
        while ((uid = [enumerator nextObject])) {
            NSAttributedString *empty = [[NSAttributedString alloc] initWithString:@""];
            [[self textViewWithUID:uid] setHyperText:empty];
            [empty release];
        }
        [self runNextCommandIfNeeded];
        break;
    }
    case 9: {
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:argument];
        [self setTextToType:text];
        [text release];
        _charactersCounter = 0;
        _timer = [[NSTimer timerWithTimeInterval:[self timeInterval] target:[[self NSE_newWeakProxy] autorelease] selector:@selector(fireTimer:) userInfo:nil repeats:YES] retain];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        break;
    }
    }
}
- (void)runNextCommandIfNeeded
{
    _commandsCounter++;
    if (_commandsCounter < [[self commands] count])
        [self runCommand:_commandsCounter];
    else
        [self notifyDidFinish];
}
- (void)stop:(id)aStop
{
    [self invalidateTimer];
    [self setContext:nil];
    [super stop:aStop];
}
- (BOOL)canBeStopped
{
    return YES;
}
// The text view processing superclass drives the commands.
- (void)startInContext:(id)aContext
{
}
- (void)setContext:(id)aContext
{
    if (_context != aContext) {
        [_context release];
        _context = [aContext retain];
    }
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:[@"textToType" extraKeyForMultiRepresentations]];
}
- (void)dealloc
{
    [_textToType release];
    [_context release];
    [self invalidateTimer];
    [super dealloc];
}
- (void)invalidateTimer
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
}
@end
