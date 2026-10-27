#import "HyperStudioPrefix.h"


@interface HSAssistantPaneApplier : NSObject
{
    id _delegate;
    id<HyperInterface> _object;
}
- (BOOL)canRegisterUndo;
- (void)revertChanges;
- (void)applyChanges;
- (void)restoreIfNotApplied;
- (void)updateObject;
- (void)enableNotifications;
- (void)disableNotifications;
- (void)enableUndo;
- (void)disableUndo;
- (id)undoManager;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)object;
- (id)initWithObject:(id)aObject;
- (id)init;
@end

