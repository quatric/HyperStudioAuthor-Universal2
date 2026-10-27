#import "HyperStudioPrefix.h"


@interface HSToolSettingsViewController : NSObject
{
    NSView *_toolSettingsView;
    id<HSToolSettingsViewControllerParent> _parent;
}
- (void)validateUserInterface;
- (void)updateUI;
- (void)willUnMount;
- (void)didMount;
- (void)willMount;
- (void)didLoadNib;
- (id)backgroundColorForPreviewColor:(id)aColor;
- (void)setParent:(id)aParent;
- (id)parent;
- (NSInteger)toolTag;
- (id)toolView;
- (id)toolSettingsView;
- (id)nibName;
- (void)dealloc;
@end

