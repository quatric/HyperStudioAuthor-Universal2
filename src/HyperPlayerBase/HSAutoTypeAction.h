#import "HyperPlayerBasePrefix.h"
#import "HSTextViewProcessingAction.h"


@interface HSAutoTypeAction : HSTextViewProcessingAction <HSAutoTypeActionAttributes, HSTextViewProcessingActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTextViewUIDsAttribute, HSTextViewNamesAttribute, HSAutoTypeTextToTypeAttribute>
{
    NSAttributedString *_textToType;
    HSActionExecutionContext *_context;
    NSTimer *_timer;
    unsigned int _charactersCounter;
    unsigned int _commandsCounter;
    NSArray *_commands;
    float _timeInterval;
}
+ (id)parseStringToCommands:(id)aCommands;
+ (NSInteger)commandTypeForString:(id)aString;
+ (BOOL)validateStringToType:(id)aType;
- (void)setCommands:(id)aCommands;
- (id)commands;
- (void)setTimeInterval:(CGFloat)aInterval;
- (CGFloat)timeInterval;
- (void)setTextToType:(id)aType;
- (id)textToType;
- (void)fireTimer:(id)aTimer;
- (id)textObjectWithUID:(id)aUID;
- (void)runCommand:(NSUInteger)aCommand;
- (void)runNextCommandIfNeeded;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (void)setContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (void)invalidateTimer;
@end

