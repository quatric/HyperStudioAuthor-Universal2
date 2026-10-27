#import "HyperStudioPrefix.h"
#import "HSColorWell.h"


@interface HSAlphaIgnoresColorWell : HSColorWell
{
    struct HyperStudio_anon6 _alphaIgnoresColorWellFlags;
}
- (void)setShowsAlphaForPanel:(BOOL)aPanel;
- (BOOL)showsAlphaForPanel;
- (void)deactivate;
- (void)activate:(BOOL)aActivate;
@end

