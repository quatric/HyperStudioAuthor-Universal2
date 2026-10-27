#import "HyperPlayerBasePrefix.h"


@interface HSAutoTypeCommand : NSObject
{
    int _commandType;
    NSString *_command;
}
- (void)setCommand:(id)aCommand;
- (id)command;
- (void)setCommandType:(NSInteger)aType;
- (NSInteger)commandType;
- (void)dealloc;
- (id)init;
- (id)initWithCommandType:(NSInteger)aType command:(id)aCommand;
@end

