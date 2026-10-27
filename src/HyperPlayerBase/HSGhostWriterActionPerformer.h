#import "HyperPlayerBasePrefix.h"


@interface HSGhostWriterActionPerformer : NSObject
{
    NSMutableArray *_actionsQueue;
    NSString *_textToType;
    NSTimer *_timer;
    unsigned int _charactersCounter;
    unsigned int _commandsCounter;
    HSUID *_targetObjectUID;
    double _timeInterval;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedGhostWriterActionPerformer;
- (void)startAction;
- (void)currentActionDidFinish;
- (id)commands;
- (id)card;
- (id)stack;
- (void)setTimeInterval:(double)aInterval;
- (double)timeInterval;
- (void)setupInitialSettings;
- (void)createTimerWithFireSelector:(SEL)aSelector;
- (void)invalidateTimer;
- (void)fireTimer:(id)aTimer;
- (id)textObjectWithUID:(id)aUID;
- (void)runCommand:(id)aCommand;
- (void)runNextCommandIfNeeded;
- (void)delayDidFinish:(id)aFinish;
- (id)action;
- (void)actionDidStop:(id)aStop;
- (void)performAction:(id)aAction;
- (void)moveRight;
- (void)moveLeft;
- (void)backspace;
- (void)erase;
- (void)doCommandBySelector:(SEL)aSelector;
- (id)targetObjectUID;
- (void)setTargetObjectUID:(id)aUID;
- (void)setTypingSpeed:(NSInteger)aSpeed;
- (NSInteger)typingSpeed;
- (void)setTextToType:(id)aType;
- (id)textToType;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
- (void)pause;
- (void)resume;
@end

