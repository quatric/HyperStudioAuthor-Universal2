#import "HSBackgroundWindowController.h"
#import "HSApplicationController.h"
#import "HSBackgroundRendererView.h"
#import "HSBackgroundViewRenderer.h"
#import "HSBackgroundWindow.h"
#import "HSDocument.h"
#import "HSLinkButton.h"
#import "HSPreferencesController.h"
#import "HSStack.h"
#import "HSUI.h"

// Implemented by the editor's document and mode switcher.
@interface NSObject (HSBackgroundWindowControllerModeSwitching)
- (id)modeSwitcher;
- (id)activeModeController;
@end

// _isActive is bit 0 and _updateWindowsOrderInProcess bit 1 of the shared flags byte.
static BOOL sBackgroundWindowControllerAllocated;
static HSBackgroundWindowController *sBackgroundWindowController;

@implementation HSBackgroundWindowController
// Only one instance is ever allocated, and only when the application supports document presentation settings.
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sBackgroundWindowControllerAllocated)
            return nil;
        sBackgroundWindowControllerAllocated = YES;
        if ([[NSDocumentController sharedDocumentController] respondsToSelector:@selector(areDocumentSpecificPresentationSettingsActive)])
            sBackgroundWindowController = [super allocWithZone:aZone];
        return sBackgroundWindowController;
    }
}
+ (id)backgroundWindowController
{
    @synchronized (self) {
        if (!sBackgroundWindowControllerAllocated)
            [[self alloc] init];
    }
    return sBackgroundWindowController;
}
- (void)UIModeSettingsDidChangeNotification:(id)aNotification
{
    [self validateAndDisplay:[[(NSNotification *)aNotification name] isEqualToString:HSUICoverDesktopBackgroundDidChangeNotification]];
}
- (void)screenParametersDidChange:(id)aChange
{
    // The original constrains the window frame and drops the result.
    [[self window] constrainFrameRect:NSZeroRect toScreen:[[self window] screen]];
}
- (void)HSBackgroundWindowController_validateAndDisplay
{
    [self validateAndDisplay:YES];
}
- (void)applicationDidBecomeActive:(id)aActive
{
    // The original performs -validateAndDisplay: with self as the BOOL argument (non-zero).
    [self performSelectorOnMainThread:@selector(HSBackgroundWindowController_validateAndDisplay) withObject:nil waitUntilDone:NO];
}
- (void)applicationWillResignActive:(id)aActive
{
    [self deactivate];
}
// In presentation or pure player mode with per-document settings the stack supplies the background.
- (void)verifyBackgroundRendererState
{
    HSApplicationController *controller = [HSApplicationController sharedDocumentController];
    id source = [HSUI sharedUI];
    if ([controller areDocumentSpecificPresentationSettingsActive]) {
        HSDocument *document = [controller currentDocument];
        if ([document isInPresentationMode] || [document isInPurePlayerMode])
            source = [(HSDocument *)[controller currentDocument] stack];
    }
    id graphics = [source backgroundGraphics];
    if (graphics != [_backgroundRenderer backgroundGraphics])
        [_backgroundRenderer setBackgroundGraphics:graphics];
}
- (BOOL)isActive
{
    return _isActive;
}
- (void)validateAndDisplay:(BOOL)aDisplay onScreen:(id)aScreen
{
    if (![self shouldBeActive]) {
        [self deactivate];
        return;
    }
    if (aScreen != nil) {
        NSWindow *window = [self window];
        NSRect screenFrame = [(NSScreen *)aScreen frame];
        NSRect frame = [window frame];
        if (screenFrame.size.width < frame.size.width)
            frame.size.width = screenFrame.size.width;
        if (screenFrame.size.height < frame.size.height)
            frame.size.height = screenFrame.size.height;
        frame.origin.x = ((screenFrame.size.width * 0.5 + screenFrame.origin.x) - (frame.size.width * 0.5 + screenFrame.origin.x)) + screenFrame.origin.x;
        frame.origin.y = ((screenFrame.size.height * 0.5 + screenFrame.origin.y) - (frame.size.height * 0.5 + screenFrame.origin.y)) + screenFrame.origin.y;
        [window setFrame:frame display:YES];
    }
    [self activate];
    if (aDisplay)
        [[_backgroundRenderer backgroundView] setNeedsDisplay:YES];
}
- (void)validateAndDisplay:(BOOL)aDisplay
{
    [self validateAndDisplay:aDisplay onScreen:nil];
}
- (void)deactivate
{
    _isActive = 0;
    NSWindow *window = [self window];
    if ([window isVisible])
        [window orderOut:nil];
}
- (void)activate
{
    if (![self shouldBeActive])
        return;
    [self verifyBackgroundRendererState];
    _isActive = 1;
    [self updateWindowsOrder];
}
// Restacks the application windows front to back with the background window last.
- (void)updateWindowsOrder
{
    if (!_isActive || _updateWindowsOrderInProcess)
        return;
    _updateWindowsOrderInProcess = 1;
    NSArray *windows = [self applicationWindowsInOrder];
    NSUInteger count = [windows count];
    [[windows objectAtIndex:0] orderFront:self];
    NSUInteger i;
    for (i = 1; i < count; i++)
        [[windows objectAtIndex:i] orderWindow:NSWindowBelow relativeTo:[[windows objectAtIndex:i - 1] windowNumber]];
    _updateWindowsOrderInProcess = 0;
}
- (id)applicationWindowsInOrder
{
    NSMutableArray *ordered = [NSMutableArray array];
    NSArray *windows = [self applicationWindows];
    // Before AppKit 1038 the original listed the window numbers with NSCountWindows/NSWindowList.
    NSArray *numbers = [NSWindow windowNumbersWithOptions:0];
    for (NSNumber *number in numbers) {
        NSInteger windowNumber = [number integerValue];
        for (NSWindow *window in windows) {
            if ([window windowNumber] == windowNumber && window != nil)
                [ordered addObject:window];
        }
    }
    [ordered addObject:[self window]];
    return ordered;
}
- (id)applicationWindows
{
    NSMutableArray *windows = [NSMutableArray array];
    for (NSDocument *document in [[NSDocumentController sharedDocumentController] documents]) {
        NSWindow *window = [[[document modeSwitcher] activeModeController] window];
        if (window != nil)
            [windows addObject:window];
    }
    NSWindow *preferencesWindow = [[HSPreferencesController sharedPreferencesController] preferencesControllerWindow];
    if ([preferencesWindow isVisible])
        [windows addObject:preferencesWindow];
    NSWindow *aboutWindow = [[HSAboutBoxController sharedInstance] window];
    if ([aboutWindow isVisible])
        [windows addObject:aboutWindow];
    return windows;
}
- (BOOL)shouldBeActive
{
    HSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
    if (![document isInPresentationMode] && ![document isInPurePlayerMode])
        return [[[HSUI sharedUI] settingsForKey:HSUIModeIsCoverDesktopEnabled] boolValue];
    if ([(HSApplicationController *)[NSDocumentController sharedDocumentController] areDocumentSpecificPresentationSettingsActive]) {
        HSStack *stack = [document stack];
        if ([stack isPresentationCoveringDesktopMode])
            return [stack backgroundGraphics] != nil;
    }
    return NO;
}
- (void)subscribeToNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:NSApp];
    [center addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    [center addObserver:self selector:@selector(screenParametersDidChange:) name:NSApplicationDidChangeScreenParametersNotification object:NSApp];
    [center addObserver:self selector:@selector(UIModeSettingsDidChangeNotification:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
    [center addObserver:self selector:@selector(UIModeSettingsDidChangeNotification:) name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
    [center addObserver:self selector:@selector(UIModeSettingsDidChangeNotification:) name:HSUICoverDesktopBackgroundDidChangeNotification object:[HSUI sharedUI]];
}
- (id)windowNibName
{
    return @"";
}
- (void)dealloc
{
    [[self window] setDelegate:nil];
    if ([_backgroundRenderer delegate] == self)
        [_backgroundRenderer setDelegate:nil];
    [_backgroundRenderer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (id)init
{
    NSScreen *screen = [NSScreen mainScreen];
    // Style mask 0x80 is NSWindowStyleMaskNonactivatingPanel.
    HSBackgroundWindow *window = [[HSBackgroundWindow alloc] initWithContentRect:[screen frame]
                                                                      styleMask:NSWindowStyleMaskNonactivatingPanel
                                                                        backing:NSBackingStoreBuffered
                                                                          defer:YES
                                                                         screen:screen];
    // The original also calls -useOptimizedDrawing:YES, a no-op on current AppKit.
    [window setBackgroundColor:[NSColor blackColor]];
    [window setOpaque:YES];
    [window setReleasedWhenClosed:NO];
    [window setHasShadow:NO];
    self = [super initWithWindow:[window autorelease]];
    if (self != nil) {
        HSBackgroundRendererView *view = [[[HSBackgroundRendererView alloc] initWithFrame:[screen frame]] autorelease];
        _backgroundRenderer = [[HSBackgroundViewRenderer alloc] initWithBackgroundView:view];
        [_backgroundRenderer setDelegate:self];
        [view setBackgroundRenderer:_backgroundRenderer];
        [window setContentView:view];
        [self subscribeToNotifications];
        [[self window] setDelegate:self];
        if (NSAppKitVersionNumber >= 949.0)
            [[self window] setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    return self;
}
- (id)autorelease
{
    return self;
}
- (void)release
{
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (id)retain
{
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}
@end
