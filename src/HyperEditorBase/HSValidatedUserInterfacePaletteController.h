#import "HyperEditorBasePrefix.h"
#import "HSPaletteController.h"


@interface HSValidatedUserInterfacePaletteController : HSPaletteController
{
}
- (void)validateUserInterface;
- (void)windowDidUpdate:(id)aUpdate;
- (void)willShowWindow;
- (void)validatePaletteItem:(id)aItem;
- (id)findValidatorForAction:(SEL)aAction target:(id)aTarget from:(id)aFrom;
@end

