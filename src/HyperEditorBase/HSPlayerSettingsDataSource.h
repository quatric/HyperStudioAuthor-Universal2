#import "HyperEditorBasePrefix.h"


@interface HSPlayerSettingsDataSource : NSObject
{
    BOOL _isFullScreen;
    BOOL _isTitlebarDisabled;
    BOOL _isMenuShown;
    BOOL _isCoverDesktopEnabled;
    id<HSGraphics> _backgroundGraphics;
    id _backgroundRenderer;
}
- (void)desktopBackgroundDidChange:(id)aChange;
- (void)preferencesSettingsDidChange:(id)aChange;
- (void)setBackgroundRendererWithGraphics:(id)aGraphics;
- (void)setBackgroundGraphics:(id)aGraphics;
- (void)setIsCoverDesktopEnabled:(BOOL)aEnabled;
- (void)setIsMenuShown:(BOOL)aShown;
- (void)setIsTitlebarDisabled:(BOOL)aDisabled;
- (void)setIsFullScreen:(BOOL)aScreen;
- (id)backgroundRenderer;
- (id)backgroundGraphics;
- (BOOL)isCoverDesktopEnabled;
- (BOOL)isMenuShown;
- (BOOL)isTitlebarDisabled;
- (BOOL)isFullScreen;
- (void)dealloc;
- (id)initPreferencesSettingsDataSource;
@end

