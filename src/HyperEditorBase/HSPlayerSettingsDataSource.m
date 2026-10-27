#import "HSPlayerSettingsDataSource.h"

// The player mode settings from the preferences (full screen, title bar,
// cover desktop and its background), kept current.

@implementation HSPlayerSettingsDataSource

- (void)desktopBackgroundDidChange:(id)aChange
{
    [self setBackgroundGraphics:[[HSUI sharedUI] backgroundGraphics]];
}

- (void)preferencesSettingsDidChange:(id)aChange
{
    HSUI *ui = [HSUI sharedUI];
    [self setIsFullScreen:[[ui settingsForKey:HSUIModeIsFullScreenEnabled mode:1] boolValue]];
    [self setIsTitlebarDisabled:[[ui settingsForKey:HSUIModeIsTitlebarDisabled mode:1] boolValue]];
    [self setIsCoverDesktopEnabled:[[ui settingsForKey:HSUIModeIsCoverDesktopEnabled mode:1] boolValue]];
}

- (void)setBackgroundRendererWithGraphics:(id)aGraphics
{
    [[[self backgroundRenderer] queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] setBackgroundGraphics:aGraphics];
}

- (void)setBackgroundGraphics:(id)aGraphics
{
    if (_backgroundGraphics != aGraphics) {
        [_backgroundGraphics release];
        _backgroundGraphics = [aGraphics retain];
        [self setBackgroundRendererWithGraphics:_backgroundGraphics];
    }
}

- (void)setIsCoverDesktopEnabled:(BOOL)aEnabled
{
    _isCoverDesktopEnabled = aEnabled;
}

- (void)setIsMenuShown:(BOOL)aShown
{
    _isMenuShown = aShown;
}

- (void)setIsTitlebarDisabled:(BOOL)aDisabled
{
    _isTitlebarDisabled = aDisabled;
}

- (void)setIsFullScreen:(BOOL)aScreen
{
    _isFullScreen = aScreen;
}

- (id)backgroundRenderer
{
    if (_backgroundRenderer == nil)
        _backgroundRenderer = [HSBackgroundViewRenderer new];
    return _backgroundRenderer;
}

- (id)backgroundGraphics
{
    return _backgroundGraphics;
}

- (BOOL)isCoverDesktopEnabled
{
    return _isCoverDesktopEnabled;
}

- (BOOL)isMenuShown
{
    return _isMenuShown;
}

- (BOOL)isTitlebarDisabled
{
    return _isTitlebarDisabled;
}

- (BOOL)isFullScreen
{
    return _isFullScreen;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_backgroundGraphics release];
    [_backgroundRenderer release];
    [super dealloc];
}

- (id)initPreferencesSettingsDataSource
{
    if ((self = [super init])) {
        [self preferencesSettingsDidChange:nil];
        [self setBackgroundGraphics:[[HSUI sharedUI] backgroundGraphics]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesSettingsDidChange:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(desktopBackgroundDidChange:) name:HSUICoverDesktopBackgroundDidChangeNotification object:[HSUI sharedUI]];
    }
    return self;
}

@end
