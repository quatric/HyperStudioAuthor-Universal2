#import "HSValidatedUserInterfacePaletteController.h"

// A palette whose items are validated like menu items, against the
// responder chain, whenever its window updates.

@implementation HSValidatedUserInterfacePaletteController

- (void)validateUserInterface
{
}

- (void)windowDidUpdate:(id)aUpdate
{
    [self validateUserInterface];
}

- (void)willShowWindow
{
    [super willShowWindow];
    [self validateUserInterface];
}

// Disabled without a validator that handles the action; left as it is when
// the validator can't validate.
- (void)validatePaletteItem:(id)aItem
{
    NSControl *item = aItem;
    id validator = [self findValidatorForAction:[item action] target:[item target] from:aItem];
    if (validator == nil || ![validator respondsToSelector:[item action]]) {
        [aItem setEnabled:NO];
        return;
    }
    if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)])
        [aItem setEnabled:[validator validateUserInterfaceItem:aItem]];
}

// Nothing validates while the document window has a sheet.
- (id)findValidatorForAction:(SEL)aAction target:(id)aTarget from:(id)aFrom
{
    if ([[[[[HSApplicationController sharedDocumentController] currentDocument] currentWindowController] window] attachedSheet] != nil)
        return nil;
    return [NSApp targetForAction:aAction to:aTarget from:aFrom];
}

@end
