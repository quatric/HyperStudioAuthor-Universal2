#import "HyperStudioPrefix.h"


@interface HSShortcutsPaletteController : HSValidatedUserInterfacePaletteController
{
    NSView *_containerView;
    NSMutableArray *_toolbarItems;
    BOOL _firstTimeLaunch;
}
- (void)rebuildShortcutsIfNeeded;
- (BOOL)needUpdateToolbarItems:(id)aItems withItems:(id)aItems2;
- (id)filteredToolbarItems:(id)aItems;
- (NSRect)frameForItemIndex:(NSInteger)aIndex origin:(NSPoint)aOrigin;
- (NSRect)viewFrameForButtonsCount:(NSInteger)aCount;
- (id)toolbarItems;
- (void)validateView:(id)aView;
- (void)validateToolbarItems;
- (void)validateUserInterface;
- (void)willShowWindow;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

