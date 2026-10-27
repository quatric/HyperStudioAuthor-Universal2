#import "HyperPlayerBasePrefix.h"


@interface HSRunTimeEditorUndoManager : NSUndoManager
{
    id<HSRunTimeEditorUndoManagerDelegate> _delegate;
}
- (void)registerUndoWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
- (id)prepareWithInvocationTarget:(id)aTarget;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
@end

