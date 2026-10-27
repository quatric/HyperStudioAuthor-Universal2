#import "HSPaletteController.h"

// The base of the palettes: one instance per class, a panel from a nib
// shown again on launch if it was visible, and kept on screen.

@implementation HSPaletteController

+ (id)visibilityKeyForDefaults
{
    return [NSString stringWithFormat:@"%@Visible", NSStringFromClass([self class])];
}

// Moved into the main screen's visible frame, if not in it.
+ (NSRect)adjustFrameToFitVisibleScreenFrame:(NSRect)aFrame
{
    NSRect visible = [[NSScreen mainScreen] visibleFrame];
    NSRect frame = aFrame;
    if (!NSContainsRect(visible, frame)) {
        if (frame.origin.x < visible.origin.x)
            frame.origin.x = visible.origin.x;
        if (frame.origin.y < visible.origin.y)
            frame.origin.y = visible.origin.y;
        if (NSMaxX(visible) < frame.origin.x + frame.size.width)
            frame.origin.x = NSMaxX(visible) - frame.size.width;
        if (NSMaxY(visible) < frame.origin.y + frame.size.height)
            frame.origin.y = NSMaxY(visible) - frame.size.height;
    }
    return frame;
}

+ (id)frameAutosaveName
{
    return [NSString stringWithFormat:@"%@Frame", NSStringFromClass([self class])];
}

+ (id)sharedInstance
{
    id instance = [self cachedSharedInstance];
    if (instance == nil) {
        instance = [self new];
        [self registerSharedInstanceIfNeeded:instance];
        [instance release];
    }
    return instance;
}

+ (void)registerSharedInstanceIfNeeded:(id)aNeeded
{
    if ([self cachedSharedInstance] == nil && [aNeeded class] == self)
        [[self sharedInstancesByClass] setObject:aNeeded forKey:(id<NSCopying>)self];
}

+ (id)cachedSharedInstance
{
    return [[self sharedInstancesByClass] objectForKey:self];
}

+ (id)sharedInstancesByClass
{
    static NSMutableDictionary *sharedInstancesByClass;
    if (sharedInstancesByClass == nil)
        sharedInstancesByClass = [NSMutableDictionary new];
    return sharedInstancesByClass;
}

// The panel's top left point is saved (its size comes from the nib).
- (void)panel:(id)aPanel saveFrameUsingName:(id)aName
{
    NSRect frame = [(NSWindow *)aPanel frame];
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromPoint(NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height)) forKey:aName];
}

- (BOOL)panel:(id)aPanel setFrameUsingName:(id)aName
{
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:aName];
    if (string != nil) {
        NSPoint point = NSPointFromString(string);
        NSRect frame = [(NSWindow *)aPanel frame];
        NSRect onscreenFrame = [HSAutoOriginedWindow onscreenFrameUsingFrame:NSMakeRect(point.x, point.y - frame.size.height, frame.size.width, frame.size.height)];
        [(NSWindow *)aPanel setFrame:onscreenFrame display:NO];
    }
    return string != nil;
}

- (void)windowDidShowRespectingLastVisibilityState:(id)aState
{
    [self didShowWindow];
}

- (void)windowWillShowRespectingLastVisibilityState:(id)aState
{
    [self willShowWindow];
}

// The visibility saved when the palettes were hidden (as a stack).
- (BOOL)windowShouldOrderFrontRespectingLastVisibilityState:(id)aState
{
    NSMutableArray *states = [self storedVisibilityStates];
    if ([states count] == 0)
        return NO;
    BOOL visible = [[states lastObject] boolValue];
    [states removeObjectAtIndex:[states count] - 1];
    return visible;
}

- (void)windowWillHideWithSavingVisibilityState:(id)aState
{
    [[self storedVisibilityStates] addObject:[NSNumber numberWithBool:[self isPaletteVisible]]];
}

- (id)storedVisibilityStates
{
    if (_storedVisibilityStates == nil)
        _storedVisibilityStates = [NSMutableArray new];
    return _storedVisibilityStates;
}

- (void)togglePalette
{
    if ([self isPaletteVisible])
        [self hidePalette];
    else
        [self showPalette];
}

- (void)setHyperPaletteLocked:(BOOL)aLocked
{
    _paletteLocked = aLocked;
}

- (BOOL)isHyperPaletteLocked
{
    return _paletteLocked;
}

- (BOOL)validateTogglePaletteUserInterfaceItem:(id)aItem
{
    if ([aItem isKindOfClass:[NSMenuItem class]])
        [(NSMenuItem *)aItem setState:[self isPaletteVisible] ? NSControlStateValueOn : NSControlStateValueOff];
    return YES;
}

- (void)loadNibIfNeeded
{
    if (_window == nil && [NSBundle loadNibNamed:[self nibName] owner:self])
        [self didLoadNib];
}

- (void)willCloseWindow
{
}

- (void)didShowWindow
{
}

- (void)willShowWindow
{
}

- (void)didLoadNib
{
    [_window setFrameAutosaveName:[[self class] frameAutosaveName]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentWindowDidBecomeMain:) name:HSDocumentWindowDidBecomeMainNotification object:nil];
}

- (id)nibName
{
    return nil;
}

// The current editor's undo manager.
- (id)windowWillReturnUndoManager:(id)aManager
{
    return [[[[[NSDocumentController sharedDocumentController] currentDocument] currentWindowController] queryHyperInterface:@protocol(HSPreferedUndoManagerOwner)] preferedUndoManager];
}

- (id)window
{
    return _window;
}

- (void)createWindowIfNeeded
{
    if (_window == nil) {
        [self loadNibIfNeeded];
        [_window setDelegate:self];
        [_window setBecomesKeyOnlyIfNeeded:[self paletteShouldBecomeKeyOnlyWhenNeeded]];
    }
}

- (BOOL)paletteShouldBecomeKeyOnlyWhenNeeded
{
    return YES;
}

- (BOOL)windowShouldClose:(id)aClose
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[[self class] visibilityKeyForDefaults]];
    return YES;
}

- (BOOL)isPaletteVisible
{
    return _window != nil && [[self window] isVisible];
}

- (BOOL)isWindowLoaded
{
    return _window != nil;
}

- (void)windowWillClose:(id)aClose
{
    [self willCloseWindow];
}

- (void)hidePalette
{
    [self hidePaletteWithSaveToDefaults:YES];
}

// Shown if it was visible last time (or only marked to be, when the
// palettes come back with their saved visibility).
- (void)showPaletteIfNeededByDefault:(BOOL)aDefault
{
    BOOL visible = [[NSUserDefaults standardUserDefaults] boolForKey:[[self class] visibilityKeyForDefaults]];
    if (!visible)
        return;
    if (aDefault)
        [self showPalette];
    else {
        [self createWindowIfNeeded];
        [[self storedVisibilityStates] addObject:[NSNumber numberWithBool:visible]];
    }
}

- (void)showPalette
{
    if ([self isPaletteVisible])
        return;
    [self createWindowIfNeeded];
    [self willShowWindow];
    [self orderFrontPaletteWindow:[self window]];
    [self adjustWindowPositionIfNeeded];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[self class] visibilityKeyForDefaults]];
    [self didShowWindow];
}

- (void)adjustWindowPositionIfNeeded
{
    NSRect frame = [[self window] frame];
    NSRect adjusted = [[self class] adjustFrameToFitVisibleScreenFrame:frame];
    if (!NSEqualRects(frame, adjusted))
        [[self window] setFrame:adjusted display:YES animate:NO];
}

- (void)orderFrontPaletteWindow:(id)aWindow
{
    [aWindow orderFront:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_window setDelegate:nil];
    [_window release];
    [_storedVisibilityStates release];
    [super dealloc];
}

// One instance per class: another init gives the existing one.
- (id)init
{
    id instance = [[self class] cachedSharedInstance];
    if (instance != nil) {
        [super dealloc];
        // Fix: the shared instance was returned without the retain
        // the caller's init owns.
        return [instance retain];
    }
    if ((self = [super init]))
        [[self class] registerSharedInstanceIfNeeded:self];
    return self;
}

- (void)hidePaletteWithSaveToDefaults:(BOOL)aSave
{
    if (_window != nil && [self isPaletteVisible]) {
        [_window close];
        if (aSave)
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[[self class] visibilityKeyForDefaults]];
    }
}

- (void)documentWindowDidBecomeMain:(id)aNotification
{
    BOOL protected = [[[[NSDocumentController sharedDocumentController] currentDocument] stack] isStackProtected];
    if (protected)
        [self hidePaletteWithSaveToDefaults:NO];
    else
        [self showPaletteIfNeededByDefault:YES];
}

@end
