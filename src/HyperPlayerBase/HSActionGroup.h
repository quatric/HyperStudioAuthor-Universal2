#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSActionGroup : HSAction <HSActionOwner>
{
    id _callingObject;
    NSMutableArray *_subActions;
    HSActionSynchronizer *_actionSynchronizer;
}
- (void)actionSynchronizerDidFinishPerformActions:(id)aActions;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (id)hyperObjectForAction:(id)aAction;
- (void)removeSubAction:(id)aAction;
- (void)addSubActions:(id)aActions;
- (void)addSubAction:(id)aAction;
- (void)insertSubAction:(id)aAction atIndex:(NSUInteger)aIndex;
- (BOOL)supportedInWebPlayer;
- (BOOL)isKindOfType:(id)aType;
- (id)subActions;
- (id)mutableSubActions;
- (void)dealloc;
- (id)initWithCallingObject:(id)aObject;
@end

