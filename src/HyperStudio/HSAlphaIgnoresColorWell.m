#import "HSAlphaIgnoresColorWell.h"

@implementation HSAlphaIgnoresColorWell

- (void)setShowsAlphaForPanel:(BOOL)aPanel
{
    _alphaIgnoresColorWellFlags.hidesAlphaForPanel = !aPanel;
}

- (BOOL)showsAlphaForPanel
{
    return !_alphaIgnoresColorWellFlags.hidesAlphaForPanel;
}

// Restores the shared color panel's alpha setting changed by -activate:.
- (void)deactivate
{
    [super deactivate];
    if (_alphaIgnoresColorWellFlags.isCustomSettingsApplied) {
        [[NSColorPanel sharedColorPanel] setShowsAlpha:_alphaIgnoresColorWellFlags.previousShowsAlphaForPanel != 0];
        _alphaIgnoresColorWellFlags.isCustomSettingsApplied = 0;
    }
}

- (void)activate:(BOOL)aActivate
{
    [super activate:aActivate];
    if (_alphaIgnoresColorWellFlags.hidesAlphaForPanel) {
        _alphaIgnoresColorWellFlags.previousShowsAlphaForPanel = [[NSColorPanel sharedColorPanel] showsAlpha];
        [[NSColorPanel sharedColorPanel] setShowsAlpha:NO];
        _alphaIgnoresColorWellFlags.isCustomSettingsApplied = 1;
    }
}

@end
