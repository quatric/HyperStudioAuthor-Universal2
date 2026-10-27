#import "SMKApplicationKitPrefix.h"


@interface __NSEUndoAutogroupBreaker : NSObject
{
    NSUndoManager *_undoManager;
}
- (void)__NSEUndoAutogroupBreaker_undoMangerWillCloseUndoGroupNotification:(id)aNotification;
- (void)dealloc;
- (id)initWithUndoManger:(id)aManger;
- (id)init;
@end

@interface __NSEUndoAutogroupNamer : NSObject
{
    NSUndoManager *_undoManager;
    NSString *_actionName;
    struct __CFRunLoopObserver *_closeGroupingObserver;
}
- (void)__NSEUndoAutogroupNamer_undoMangerDidOpenUndoGroupNotification:(id)aNotification;
- (void)updateRunLoopModesFrom:(id)aFrom;
- (void)setActionName:(id)aName;
- (id)actionName;
- (void)dealloc;
- (id)initWithUndoManger:(id)aManger;
- (id)init;
- (struct __CFRunLoopObserver *)__NSEUndoAutogroupNamer_newCloseGroupingObserver;
@end

@interface NSUndoManager (NSEUndoManager)
- (void)NSE_endUndoAutogroup;
- (void)NSE_setActionNameIfNeeded:(id)aNeeded;
- (id)NSE_pendingActionName;
@end

