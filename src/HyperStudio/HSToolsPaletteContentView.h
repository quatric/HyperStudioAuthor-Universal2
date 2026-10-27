#import "HyperStudioPrefix.h"


@interface HSToolsPaletteContentView : NSView
{
    HSTexturedView *_mainView;
    HSTexturedView *_drawerView;
    HSTexturedView *_knobView;
    BOOL _drawerIsOpen;
    NSView *_drawerContentView;
}
- (void)resizeDrawerBy:(CGFloat)aBy withAutoresizingMask:(NSUInteger)aMask;
- (void)hideDrawer:(id)aDrawer;
- (void)showDrawer:(id)aDrawer;
- (BOOL)drawerIsOpen;
- (void)setDrawerContentView:(id)aView;
- (void)addDrawerContentViewToDrawerView;
- (void)setNewWindowFrame:(NSRect)aFrame;
- (void)awakeFromNib;
- (void)updateImagesForDrawerState:(BOOL)aState;
- (void)setImagesForClosedDrawer;
- (void)setImagesForOpenedDrawer;
- (void)dealloc;
@end

