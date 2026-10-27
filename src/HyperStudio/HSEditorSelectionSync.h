#import "HyperStudioPrefix.h"
#import "HSAbstractSelectionSync.h"


@interface HSEditorSelectionSync : HSAbstractSelectionSync <HSDocumentSelectionHolderInterface, NSObject, HSPrimitiveSelectionHost>
{
    id<HSSelectionHost> _stackSelectionHost;
    id<HSSelectionHost> _thisCardSelectionHost;
    id<HSSelectionHost> _cardObjectsSelectionHost;
    id<HSSelectionHost> _cardObjectsSecondarySelectionHost;
    NSWindow *_notifyingWindow;
}
+ (BOOL)isEnabledByDefault;
- (void)windowWillClose:(id)aClose;
- (void)windowDidBecomeMain:(id)aMain;
- (void)setWindowController:(id)aController;
- (void)setNotifyingWindow:(id)aWindow;
- (void)noteWindowControllerWillClose;
- (void)noteWindowControllerWillResignMain;
- (void)noteWindowControllerDidBecomeMain;
- (void)setObjectBrowser:(id)aBrowser;
- (void)setCardView:(id)aView;
- (void)setThisCardSelectionHost:(id)aHost;
- (void)setStackSelectionHost:(id)aHost;
- (void)selectionHostDidChangeSelectedObject:(id)aObject;
- (void)makeCurrentSelectionHost:(id)aHost;
- (BOOL)isRegisteredSelectionHost:(id)aHost;
- (id)ownSelectedObject;
- (id)currentSelectionHost;
- (void)notifySelectionDidChange;
- (void)updateOtherSelectionHostsWithChangedSelectionHost:(id)aHost;
- (void)updateSelectionHost:(id)aHost withChangedSelectionHost:(id)aHost2;
- (void)dealloc;
@end

