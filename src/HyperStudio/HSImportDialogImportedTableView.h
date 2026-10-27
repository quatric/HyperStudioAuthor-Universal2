#import "HyperStudioPrefix.h"


@interface HSImportDialogImportedTableView : NSTableView
{
}
- (void)dragImage:(id)aImage at:(NSPoint)aAt offset:(NSSize)aOffset event:(id)aEvent pasteboard:(id)aPasteboard source:(id)aSource slideBack:(BOOL)aBack;
- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation;
- (void)poofAnimationEffectDidEnd:(void *)aEnd;
- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal;
@end

