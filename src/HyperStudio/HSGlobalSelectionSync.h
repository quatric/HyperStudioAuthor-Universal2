#import "HyperStudioPrefix.h"
#import "HSAbstractSelectionSync.h"


@interface HSGlobalSelectionSync : HSAbstractSelectionSync
{
}
+ (id)globalSelectionSync;
- (void)notifySelectionDidChange;
- (BOOL)isRegisteredSelectionHost:(id)aHost;
- (void)editorSelectionSyncDidChangeSelection:(id)aSelection;
- (void)editorSelectionSyncWillResignActive:(id)aActive;
- (void)editorSelectionSyncDidBecomeActive:(id)aActive;
- (void)dealloc;
- (id)init;
@end

