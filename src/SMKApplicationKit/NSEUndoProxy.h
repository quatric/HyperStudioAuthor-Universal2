#import "SMKApplicationKitPrefix.h"


@interface NSEUndoProxy : NSObject
{
    NSUndoManager *_undoManager;
    id _undoTarget;
}
- (id)prepareUndoInManager:(id)aManager withInvocationTarget:(id)aTarget;
- (void)registerUndoInManager:(id)aManager withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)NSEUndoProxy_performUndoActionWithInvocation:(id)aInvocation target:(void *)aTarget;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
@end

