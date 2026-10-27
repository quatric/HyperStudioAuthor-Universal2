#import "HSAutoTypeCommand.h"
@implementation HSAutoTypeCommand
- (void)setCommand:(id)aCommand
{
    if (![_command isEqualToString:aCommand]) {
        [_command release];
        _command = [aCommand retain];
    }
}
- (id)command
{
    return _command;
}
- (void)setCommandType:(NSInteger)aType
{
    if (_commandType != aType)
        _commandType = (int)aType;
}
- (NSInteger)commandType
{
    return _commandType;
}
- (void)dealloc
{
    [_command release];
    [super dealloc];
}
- (id)init
{
    return [self initWithCommandType:9 command:@""];
}
- (id)initWithCommandType:(NSInteger)aType command:(id)aCommand
{
    self = [super init];
    if (self != nil) {
        [self setCommandType:aType];
        [self setCommand:aCommand];
    }
    return self;
}
@end
