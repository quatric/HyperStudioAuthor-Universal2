#import "HyperStudioPrefix.h"


@interface HSEffectsDialogController : HSGenericModalController
{
    id _object;
    NSMutableDictionary *_controllersByIdentifier;
    NSTabView *_tabView;
    HSEffectController *_currentEffectController;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)showHelp:(id)aHelp;
- (void)revertSettingsToDefault:(id)aDefault;
- (void)willCloseWindow;
- (void)applyChanges;
- (void)willShowWindow;
- (void)tabView:(id)aView willSelectTabViewItem:(id)aItem;
- (void)mountEffectControllerWithIdentifier:(id)aIdentifier intoView:(id)aView;
- (id)controllerForIdentifier:(id)aIdentifier;
- (id)nibName;
- (void)setObject:(id)aObject;
- (id)initWithObject:(id)aObject;
- (void)dealloc;
@end

