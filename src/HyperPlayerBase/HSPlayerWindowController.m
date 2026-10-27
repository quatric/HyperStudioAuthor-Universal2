#import "HSPlayerWindowController.h"
#import "HSBackgroundWindowController.h"
#import "HSBorderlessAttributes.h"
#import "HSFullScreenBorderlessWindow.h"
#import "HSCardView.h"
#import "HSPlayerView.h"
#import "HSSlideshowAttributes.h"
#import "HSSlideshowDialogController.h"
#import "HSStack.h"
#import "HSSystemUI.h"
#import "EXToolbarController.h"

@implementation HSPlayerWindowController

/* i386 ivar offsets: _playerView=0x34, _borderlessAttributes=0x38, _oldWindow=0x3c, _oldLevel=0x40, _borderlessWindow=0x44, _bitmapLayerView=0x48, _sessionSlideshowAttributes=0x4c, _lastSlideShowOptions=0x50, _lastCardViewMouseDownEventNumbers=0x54, _modifiedAttributesSet=0x58, _isFullScreenMode=0x5c, _isBorderlessWindowMode=0x5c, _isMarkerActive=0x5c, _inResizeMainWindow=0x5c, _miniaturizeWhenSlideShow=0x5c, _beginSheetWhenSlideShow=0x5c, _isSlideShowAttributesObserverInited=0x5c */

- (BOOL)isBackgroundGraphics
{
    return [[[self document] stack] backgroundGraphics] != nil;
}

- (BOOL)isMenuShown
{
    return [[[self document] stack] isPresentationMenuVisible];
}

- (BOOL)isTitlebarDisabled
{
    return [[[self document] stack] isPresentationPlaysWithoutTitleBar];
}

- (BOOL)isFullScreen
{
    return [[[self document] stack] shouldPlayInFullScreen];
}

// Remembers which default slideshow settings were changed while a custom set
// from the last live slideshow is held, so the dialog can merge them in.
- (void)HSPlayerWindowController_defaultSlideshowAttributesDidChange:(id)aChange
{
    if (_lastSlideShowOptions == nil)
        return;
    NSArray *modified = [[aChange userInfo] objectForKey:@"HSSlideshowAttributesNotificationModifiedSetting"];
    if (modified == nil)
        return;
    if (_modifiedAttributesSet == nil)
        _modifiedAttributesSet = [[NSMutableSet alloc] initWithArray:modified];
    else
        [_modifiedAttributesSet addObjectsFromArray:modified];
}

// Toggles the slideshow. A plain slideshow starts with the session defaults;
// a live one asks for its settings first. Stopping a live slideshow keeps its
// settings for the next dialog.
- (void)HSPlayerWindowController_startSlideShow:(id)aShow isLive:(BOOL)aLive
{
    if (!_isSlideShowAttributesObserverInited) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSPlayerWindowController_defaultSlideshowAttributesDidChange:)
                                                     name:@"HSSlideshowDidChangeAttributesNotification" object:nil];
        _isSlideShowAttributesObserverInited = 1;
    }
    BOOL isSlideshow = [[self playerView] isSlideshow];
    if (!aLive) {
        if (isSlideshow) {
            [[self playerView] stopSlideshow];
        } else {
            [_sessionSlideshowAttributes autorelease];
            _sessionSlideshowAttributes = nil;
            [[self playerView] startSlideshow];
        }
    } else if (!isSlideshow) {
        id attributes = [self slideshowAttributesFromDialog];
        if (attributes != nil)
            [self startSlideShowWithAttributes:attributes];
    } else {
        [_lastSlideShowOptions release];
        _lastSlideShowOptions = nil;
        if ([[self playerView] isSlideshow])
            _lastSlideShowOptions = [[[self playerView] slideshowAttributes] retain];
        [[self playerView] stopSlideshow];
    }
}

- (void)HSPlayerWindowController_defaultBorderlessAttributesDidChange:(id)aChange
{
    [self HSPlayerWindowController_setBorderlessAttributes:
          [HSBorderlessAttributes objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSBorderlessAttributesKeyString"]]];
    if (_isBorderlessWindowMode) {
        [[self window] setLevel:[_borderlessAttributes isOnTop] ? CGWindowLevelForKey(kCGFloatingWindowLevelKey) : _oldLevel];
        [[self window] setHasShadow:[_borderlessAttributes needShadow]];
        [[self window] invalidateShadow];
    }
}

- (void)HSPlayerWindowController_setBorderlessAttributes:(id)aAttributes
{
    if (_borderlessAttributes != aAttributes) {
        [_borderlessAttributes release];
        _borderlessAttributes = [aAttributes retain];
    }
}

- (void)activeCardDidChange:(id)aChange
{
    [self synchronizeWindowTitleWithDocumentName];
}

- (void)stackTitleDidChanged:(id)aChanged
{
    [self synchronizeWindowTitleWithDocumentName];
}

- (void)insertNewline:(id)aNewline
{
    if ([[self playerView] isTransitionPlaying])
        [[self playerView] stopTransition];
}

- (void)insertBacktab:(id)aBacktab
{
    if ([[self playerView] isTransitionPlaying])
        [[self playerView] stopTransition];
}

- (void)insertTab:(id)aTab
{
    if ([[self playerView] isTransitionPlaying])
        [[self playerView] stopTransition];
}

- (void)cancelOperation:(id)aOperation
{
    [[[self playerView] cardView] cancelOperation:aOperation];
}

- (BOOL)cancelOperation
{
    if ([[self playerView] isTransitionPlaying])
        [[self playerView] stopTransition];
    if (![[self playerView] isSlideshow])
        return [super cancelOperation];
    [self slideshow:nil];
    return YES;
}

- (void)keyDown:(id)aDown
{
    if (![[self playerView] handleKeyDownEvent:aDown])
        [super keyDown:aDown];
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    BOOL result = [super validateUserInterfaceItem:aItem];
    if (action == @selector(borderlessWindowMode:)) {
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            NSString *key = _isBorderlessWindowMode ? @"Exit Borderless Window" : @"Borderless Window";
            [aItem setTitle:[[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil]];
        }
        return !_isFullScreenMode;
    }
    if (action == @selector(slideshow:) || action == @selector(liveSlideShow:)) {
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:[[self playerView] isSlideshow] ? NSControlStateValueOn : NSControlStateValueOff];
        } else if ([aItem isKindOfClass:[NSToolbarItem class]]) {
            BOOL isSlideshow = [[self playerView] isSlideshow];
            [aItem setLabel:[[NSBundle mainBundle] localizedStringForKey:isSlideshow ? @"HSToolBarSlideshowAlternateLabelKey" : @"HSToolBarSlideshowLabelKey"
                                                                   value:@"" table:nil]];
            [aItem setToolTip:[[NSBundle mainBundle] localizedStringForKey:isSlideshow ? @"HSToolBarSlideshowAlternateToolTipKey" : @"HSToolBarSlideshowToolTipKey"
                                                                     value:@"" table:nil]];
        }
        return [[self playerView] canDoSlideshow] && ![[self document] isModalSessionPresent];
    }
    if (action == @selector(changeFontTrait:)) {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFontTraitMask traits = [fontManager traitsOfFont:[fontManager selectedFont]];
        if ([aItem tag] == NSBoldFontMask)
            [aItem setState:(traits >> 1) & 1];
        else if ([aItem tag] == NSItalicFontMask)
            [aItem setState:traits & 1];
        return [[self cardView] activeTextField] != nil;
    }
    return result;
}

- (void)liveSlideShow:(id)aShow
{
    if ([[self playerView] isSlideshow])
        [[[self document] playerView] stopSlideshow];
    else
        [self HSPlayerWindowController_startSlideShow:aShow isLive:YES];
}

- (id)sessionSlideshowAttributes
{
    if (_sessionSlideshowAttributes == nil)
        _sessionSlideshowAttributes = [[HSSlideshowAttributes defaultSlideshowAttributes] retain];
    return _sessionSlideshowAttributes;
}

- (void)changeFontTrait:(id)aTrait
{
    if ([aTrait state] == NSControlStateValueOn)
        [[NSFontManager sharedFontManager] removeFontTrait:aTrait];
    else
        [[NSFontManager sharedFontManager] addFontTrait:aTrait];
}

- (void)slideshow:(id)aSlideshow
{
    [self HSPlayerWindowController_startSlideShow:aSlideshow isLive:NO];
}

- (void)borderlessWindowMode:(id)aMode
{
    if (_isBorderlessWindowMode)
        [self exitBorderlessModeIfNeeded];
    else
        [self makeWindowBorderlessWithFullScreen:NO];
}

- (void)saveEditingState
{
    [[self cardView] saveEditingState];
}

- (void)navigationOperationDidFinishInPlayerView:(id)aView
{
    [[_toolbarController toolbar] validateVisibleItems];
    [[[[NSApp mainMenu] itemAtIndex:4] submenu] update];
    if ([self hasPlayerMode]) {
        [self verifyCardViewZoomFactor];
        [[self playerView] adjustCardViewSize];
        [[self playerView] centrateCardView];
    }
}

- (id)windowScreen
{
    return [[self window] screen];
}

- (BOOL)hasPlayerMode
{
    return YES;
}

- (id)navigationControllerForPlayerView:(id)aView
{
    return [[self document] navigationController];
}

- (BOOL)needRunArrivingActions
{
    return YES;
}

- (void)runAutomaticTimersAndArrivingActions
{
    [[[[self document] navigationController] presentationSync] runAutomaticTimersAndArrivingActions];
}

// Attributes chosen for a fresh live slideshow become the session's.
- (void)startSlideShowWithAttributes:(id)aAttributes
{
    if (aAttributes == nil)
        return;
    if (_lastSlideShowOptions == nil) {
        [_sessionSlideshowAttributes autorelease];
        _sessionSlideshowAttributes = [aAttributes retain];
    }
    [[self playerView] startSlideshowWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:aAttributes, HSCustomSlideshowAttributesKey, nil]];
}

// Runs the slideshow dialog, seeded either from the session settings or, after
// a live slideshow was stopped, from its settings with any defaults changed
// meanwhile merged in.
- (id)slideshowAttributesFromDialog
{
    HSSlideshowDialogController *dialog = [HSSlideshowDialogController new];
    HSSlideshowAttributes *defaults = [HSSlideshowAttributes defaultSlideshowAttributes];
    id result = nil;
    if (_lastSlideShowOptions == nil) {
        HSSlideshowAttributes *session = [self sessionSlideshowAttributes];
        [defaults setStartsNextSlideAutomatically:[session startsNextSlideAutomatically]];
        [defaults setUseKeystrokeOnExitCard:[session useKeystrokeOnExitCard:nil]];
        [defaults setDurationBetweenSlides:[session durationBetweenSlides]];
        [defaults setStopsAfterEnd:[session stopsAfterEnd]];
        [dialog setDefaultSlideshowAttributesToBeCustomized:defaults];
    } else {
        if (defaults != nil && _modifiedAttributesSet != nil) {
            NSArray *keys = [_modifiedAttributesSet allObjects];
            [_modifiedAttributesSet release];
            _modifiedAttributesSet = nil;
            for (NSUInteger i = 0; i < [keys count]; i++) {
                id key = [keys objectAtIndex:i];
                [_lastSlideShowOptions setValue:[defaults valueForKey:key] forKey:key];
            }
            [_lastSlideShowOptions setTransition:[defaults transition]];
        }
        [dialog setDefaultSlideshowAttributesToBeCustomized:_lastSlideShowOptions];
    }
    if ([dialog runModal] == 1)
        result = [[[dialog slideshowAttributes] retain] autorelease];
    [dialog release];
    return result;
}

- (BOOL)isFullScreenMode
{
    return _isFullScreenMode ? YES : NO;
}

- (void)revertUIMode
{
    [[HSSystemUI sharedSystemUI] revertChanges];
}

- (void)setupUIMode
{
    if ([[self document] currentWindowController] != self)
        return;
    BOOL menuShown = [self isMenuShown];
    [[HSSystemUI sharedSystemUI] setupWithMode:menuShown ? 0 : 3 options:!menuShown];
}

- (void)mouseMoved:(id)aMoved
{
    [[self cardView] handleMouseMoved:aMoved];
    Class editorApplication = NSClassFromString(@"HSAEditorApplication");
    if (editorApplication != Nil)
        [[editorApplication sharedHyperApplication] noteMainWindowDidHandleMouseMovedEvent];
}

// Moves the content back into the original window.
- (void)exitBorderlessModeIfNeeded
{
    if (!_isFullScreenMode && !_isBorderlessWindowMode)
        return;
    [[self playerView] presentationWillInterrupt];
    _isFullScreenMode = 0;
    _isBorderlessWindowMode = 0;
    NSWindow *borderless = [[self window] retain];
    [self setWindow:_oldWindow];
    NSView *content = [[borderless contentView] retain];
    [borderless setContentView:nil];
    [_oldWindow setContentView:content];
    [content release];
    [[self playerView] exitBorderlesMode];
    [_oldWindow makeKeyAndOrderFront:self];
    [borderless close];
    [borderless release];
    NSString *path = [[[self document] fileURL] path];
    if (path != nil)
        [_oldWindow setTitleWithRepresentedFilename:path];
    [self setOldWindow:nil];
}

// Moves the content into a borderless window, either covering the screen or
// sized to the card where the old window was.
- (void)makeWindowBorderlessWithFullScreen:(BOOL)aScreen
{
    if (_isFullScreenMode && aScreen)
        return;
    if (_isBorderlessWindowMode && !aScreen)
        return;
    _isFullScreenMode = aScreen ? 1 : 0;
    _isBorderlessWindowMode = aScreen ? 0 : 1;
    [[self playerView] makeBorderlessWithFullScreen:aScreen];
    NSRect frame = [[self window] frame];
    float x = frame.origin.x, y = frame.origin.y;
    NSSize cardSize = [self adjustedCardSize];
    if ([[self playerView] containerView] == [[self playerView] enclosingScrollView]) {
        NSRect visible = [[[self playerView] containerView] documentVisibleRect];
        if (visible.size.height > cardSize.height)
            y += (visible.size.height - cardSize.height) * 0.5f;
        if (visible.size.width > cardSize.width)
            x += (visible.size.width - cardSize.width) * 0.5f;
        if (cardSize.height > visible.size.height)
            y -= cardSize.height - visible.size.height;
    }
    [self setOldWindow:[self window]];
    NSScreen *screen = [_oldWindow screen];
    if (screen == nil)
        screen = [NSScreen mainScreen];
    if (_borderlessWindow == nil)
        _borderlessWindow = [[HSBorderlessWindow alloc] initWithContentRect:NSMakeRect(x, y + 20.0f, cardSize.width, cardSize.height)
                                                                  styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO screen:screen];
    if ([self window] != _borderlessWindow) {
        id responder = [_oldWindow firstResponder];
        if (responder == _oldWindow)
            responder = _borderlessWindow;
        NSView *content = [_oldWindow contentView];
        [_oldWindow setContentView:nil];
        [content setFrameSize:cardSize];
        [_borderlessWindow setContentView:content];
        [_borderlessWindow setBackgroundColor:[NSColor blackColor]];
        NSString *path = [[[self document] fileURL] path];
        if (path != nil) {
            [_borderlessWindow setTitleWithRepresentedFilename:path];
        } else {
            NSString *title = [_oldWindow title];
            if (title != nil)
                [_borderlessWindow setTitle:title];
        }
        [NSApp addWindowsItem:_borderlessWindow title:[_borderlessWindow title] filename:NO];
        [_borderlessWindow setHasShadow:[_borderlessAttributes needShadow]];
        [_borderlessWindow setWindowController:[_oldWindow windowController]];
        [_borderlessWindow setDelegate:[_oldWindow delegate]];
        [[_oldWindow windowController] setWindow:_borderlessWindow];
        [_borderlessWindow makeFirstResponder:responder];
    }
    if (aScreen) {
        NSView *content = [[self window] contentView];
        [[self window] setFrame:[screen frame] display:NO];
        NSRect contentFrame = [content frame];
        NSRect cardFrame = [[self cardView] frame];
        cardFrame.origin.x = ((contentFrame.size.width * 0.5f + contentFrame.origin.x) - (cardFrame.size.width * 0.5f + cardFrame.origin.x)) + cardFrame.origin.x;
        cardFrame.origin.y = ((contentFrame.size.height * 0.5f + contentFrame.origin.y) - (cardFrame.size.height * 0.5f + cardFrame.origin.y)) + cardFrame.origin.y;
        [[self cardView] setFrame:cardFrame];
        _oldLevel = (int)[[self window] level];
    } else {
        _oldLevel = (int)[[self window] level];
        if ([_borderlessAttributes isOnTop])
            [[self window] setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
    }
    [[self playerView] setNeedsDisplay:YES];
    [_borderlessWindow makeKeyAndOrderFront:self];
    [_borderlessWindow makeMainWindow];
    [_oldWindow close];
    [self setupUIMode];
}

- (void)setOldWindow:(id)aWindow
{
    if (_oldWindow != aWindow) {
        [_oldWindow release];
        _oldWindow = [aWindow retain];
    }
}

// A full-screen window is kept pinned to the origin.
- (void)windowDidMove:(id)aMove
{
    if (_inResizeMainWindow)
        return;
    _inResizeMainWindow = 1;
    if (_isFullScreenMode)
        [[self window] setFrameOrigin:NSZeroPoint];
    _inResizeMainWindow = 0;
}

- (NSRect)bestWindowFrameForCurrentStack
{
    NSRect frame = [[self window] frame];
    NSSize contentSize = [[self playerView] frameSizeForStackSize:[self adjustedCardSize] withScrollView:YES];
    NSRect best = [[self window] frameRectForContentRect:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    return NSMakeRect(frame.origin.x, frame.origin.y, best.size.width, best.size.height);
}

- (void)verifyWindowMode
{
    [self setupRoundedCornersIfNeeded];
    if ([self isTitlebarDisabled])
        [self makeWindowBorderlessWithFullScreen:[self isFullScreen]];
    else
        [self exitBorderlessModeIfNeeded];
}

// Resizes the window around its centre to fit the card.
- (void)adjustWindowFrame
{
    if ([[self playerView] stack] == nil)
        return;
    [self verifyCardViewZoomFactor];
    HSPlayerView *playerView = [self playerView];
    [playerView adjustCardViewSize];
    [playerView centrateCardView];
    [self verifyWindowMode];
    if ([self isFullScreenMode]) {
        [playerView makeBorderlessWithFullScreen:YES];
        [playerView setNeedsDisplay:YES];
        return;
    }
    NSRect frame = [[self window] frame];
    NSRect best = [self bestWindowFrameForCurrentStack];
    float x = ((frame.size.width * 0.5f + frame.origin.x) - (best.size.width * 0.5f + best.origin.x)) + best.origin.x;
    float y = ((frame.size.height * 0.5f + frame.origin.y) - (best.size.height * 0.5f + best.origin.y)) + best.origin.y;
    best.origin.x = roundf(x);
    best.origin.y = roundf(y);
    best = [self constrainSizeOfWindowFrame:best forScreen:[[self window] screen]];
    if (!NSEqualSizes(frame.size, best.size))
        [[self window] setFrame:best display:YES animate:NO];
    [[self cardView] adjustCardFrame];
}

- (void)centerWindowFrame
{
    if ([self window] == nil)
        return;
    NSRect visible = [[[self window] screen] visibleFrame];
    NSRect frame = [[self window] frame];
    frame.origin.x = ((visible.size.width * 0.5f + visible.origin.x) - (frame.size.width * 0.5f + frame.origin.x)) + frame.origin.x;
    frame.origin.y = ((visible.size.height * 0.5f + visible.origin.y) - (frame.size.height * 0.5f + frame.origin.y)) + frame.origin.y;
    [[self window] setFrame:frame display:YES animate:NO];
}

- (void)verifyCardViewZoomFactor
{
    if (![self isFullScreen]) {
        [[self cardView] setZoomFactor:1.0];
        return;
    }
    NSSize cardSize = [[[self document] stack] hyperCardSize];
    [[self cardView] setZoomFactor:[[[self cardView] class] zoomFactorForFullScreen:cardSize forScreen:[[self window] screen]]];
}

- (NSSize)adjustedCardSize
{
    HSStack *stack = [[self document] stack];
    if (stack == nil)
        return NSZeroSize;
    NSSize size = [stack hyperCardSize];
    return [[self cardView] viewBoundingRectForUserRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height)].size;
}

- (void)attachToStackAndUpdateView
{
    [super attachToStackAndUpdateView];
    [[self playerView] setStack:[[self document] stack]];
}

- (void)didBindToModelOnLoad
{
    [self activateOnLoad];
    if ([self window] != nil) {
        [self adjustWindowFrame];
        [self centerWindowFrame];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(HSPlayerWindowController_applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    [center addObserver:self selector:@selector(HSPlayerWindowController_defaultBorderlessAttributesDidChange:) name:@"HSBorderlessDidChangeAttributesNotification" object:nil];
    [center addObserver:self selector:@selector(stackTitleDidChanged:) name:HSStackTitleDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(activeCardDidChange:) name:HSCurrentCardInCardViewDidChange object:[self cardView]];
    [center addObserver:self selector:@selector(HSPlayerWindowController_screenParametersDidChange:) name:NSApplicationDidChangeScreenParametersNotification object:NSApp];
    [self HSPlayerWindowController_defaultBorderlessAttributesDidChange:nil];
    [self synchronizeWindowTitleWithDocumentName];
}

- (void)bindToModelOnLoad
{
    [[self playerView] setStack:[[self document] stack]];
}

- (void)stackDidChangeAttributes:(id)aAttributes
{
    if ([self isWindowLoaded] && [[self window] isVisible]) {
        [super stackDidChangeAttributes:aAttributes];
        [self setupRoundedCornersIfNeeded];
        [[self cardView] adjustCardFrame];
    }
    if ([self hasPlayerMode]) {
        [self setupUIMode];
        if ([self isTitlebarDisabled])
            [self adjustWindowFrame];
        else
            [self verifyWindowMode];
        [self coverDesktopAttributesDidChange];
    }
}

- (void)coverDesktopAttributesDidChange
{
    if (![[[self document] stack] arePresentationNotificationsSuspended])
        [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:NO onScreen:[self windowScreen]];
}

- (void)setupRoundedCornersIfNeeded
{
    BOOL rounds = [[self document] isInPresentationMode] || [[self document] isInPurePlayerMode] ||
                  ([[self document] isInPlayerMode] && [[self document] isStackProtected]);
    [[self cardView] setRoundsCardCorners:rounds];
}

- (void)HSPlayerWindowController_screenParametersDidChange:(id)aChange
{
    if (!_isFullScreenMode)
        return;
    NSScreen *screen = [_borderlessWindow screen];
    if (screen == nil)
        screen = [NSScreen mainScreen];
    if (screen != nil)
        [_borderlessWindow setFrame:[screen frame] display:[_borderlessWindow isVisible]];
    [self adjustWindowFrame];
}

- (void)HSPlayerWindowController_applicationDidBecomeActive:(id)aActive
{
    if ([self isFullScreenMode])
        [[self window] makeKeyAndOrderFront:self];
}

// Loads the window first when needed.
- (id)playerView
{
    if (_playerView == nil)
        [self window];
    return _playerView;
}

- (id)cardViewContainer
{
    return [[self playerView] cardContainerView];
}

- (id)cardView
{
    return [[self playerView] cardView];
}

// Mouse events over a visible pixel of the card view's front window layer are
// sent straight to the card view (returning NO so the window does not handle
// them). Up and drag events go through only when their down event did, which
// is tracked per button.
- (BOOL)hyperWindow:(id)aWindow shouldSendLocationEvent:(id)aEvent
{
    id cardView = [self cardView];
    if (cardView == nil)
        return YES;
    NSArray *layers = [cardView windowLayers];
    if ([layers count] == 0)
        return YES;
    NSWindow *eventWindow = [aEvent window];
    NSWindow *layer = [layers objectAtIndex:0];
    NSPoint location = [aEvent locationInWindow];
    if (eventWindow != layer) {
        if (eventWindow != nil)
            location = [eventWindow convertPointToScreen:location];
        location = [layer convertPointFromScreen:location];
    }
    if (location.x < 0.0 || location.y < 0.0)
        return YES;
    NSRect layerFrame = [layer frame];
    if (!(location.x < layerFrame.size.width && location.y < layerFrame.size.height))
        return YES;
    NSEventType type = [(NSEvent *)aEvent type];
    if (type < 0x1c) {
        if ((0xc0000d4U >> type) & 1) {
            // Mouse up / dragged: only when the down event went to the card view.
            if (_lastCardViewMouseDownEventNumbers == NULL)
                return YES;
            if ((const void *)[aEvent eventNumber] != CFDictionaryGetValue(_lastCardViewMouseDownEventNumbers, (const void *)[aEvent buttonNumber]))
                return YES;
        } else if ((0x200000aU >> type) & 1) {
            // Mouse down: remember it per button.
            if (_lastCardViewMouseDownEventNumbers == NULL) {
                _lastCardViewMouseDownEventNumbers = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEIntegerDictionaryKeyCallBacks,
                                                                               &kCFEIntegerDictionaryValueCallBacks);
                if (_lastCardViewMouseDownEventNumbers == NULL)
                    return YES;
            }
            CFDictionarySetValue(_lastCardViewMouseDownEventNumbers, (const void *)[aEvent buttonNumber], (const void *)[aEvent eventNumber]);
        }
    }
    // The original read the pixel back through an NSCachedImageRep of the layer
    // window; window backing stores are no longer readable, so the layer's
    // content view is drawn into the one-pixel bitmap instead.
    unsigned char pixel[4] = { 0, 0, 0, 0 };
    unsigned char *planes = pixel;
    NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&planes pixelsWide:1 pixelsHigh:1 bitsPerSample:8 samplesPerPixel:4
                                                                          hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace
                                                                      bitmapFormat:0 bytesPerRow:4 bitsPerPixel:32] autorelease];
    if (bitmap == nil)
        return YES;
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    if (context == nil)
        return YES;
    NSView *layerContent = [layer contentView];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:-location.x yBy:-location.y];
    [transform concat];
    [layerContent displayRectIgnoringOpacity:NSMakeRect(location.x, location.y, 1.0, 1.0) inContext:context];
    [NSGraphicsContext restoreGraphicsState];
    if (pixel[3] == 0)
        return YES;
    SEL action;
    switch (type) {
    case NSEventTypeLeftMouseDown:
        if (![NSApp isActive]) {
            if (![cardView acceptsFirstMouse:aEvent])
                return YES;
            [NSApp activateIgnoringOtherApps:YES];
            [[self window] makeKeyAndOrderFront:self];
        }
        action = @selector(mouseDown:);
        break;
    case NSEventTypeLeftMouseUp:
        action = @selector(mouseUp:);
        break;
    case NSEventTypeRightMouseDown:
        action = @selector(rightMouseDown:);
        break;
    case NSEventTypeRightMouseUp:
        action = @selector(rightMouseUp:);
        break;
    case NSEventTypeMouseMoved:
        action = @selector(mouseMoved:);
        break;
    case NSEventTypeLeftMouseDragged:
        action = @selector(mouseDragged:);
        break;
    case NSEventTypeRightMouseDragged:
        action = @selector(rightMouseDragged:);
        break;
    case NSEventTypeMouseEntered:
        action = @selector(mouseEntered:);
        break;
    case NSEventTypeMouseExited:
        action = @selector(mouseExited:);
        break;
    case NSEventTypeCursorUpdate:
        action = @selector(updateCursorWithMouseEvent:);
        break;
    case NSEventTypeScrollWheel:
        action = @selector(scrollWheel:);
        break;
    case NSEventTypeTabletPoint:
        action = @selector(tabletPoint:);
        break;
    case NSEventTypeOtherMouseDown:
        action = @selector(otherMouseDown:);
        break;
    case NSEventTypeOtherMouseUp:
        action = @selector(otherMouseUp:);
        break;
    case NSEventTypeOtherMouseDragged:
        action = @selector(otherMouseDragged:);
        break;
    default:
        return NO;
    }
    [cardView performSelector:action withObject:aEvent];
    return NO;
}

- (void)didEndModalWindow:(id)aWindow
{
    [super didEndModalWindow:aWindow];
    [[self cardView] restorePreviosCursorVisabilityState];
}

- (void)willRunModalWindow:(id)aWindow
{
    [super willRunModalWindow:aWindow];
    [[self cardView] showCursor];
}

- (void)windowDidEndSheet:(id)aSheet
{
    [super windowDidEndSheet:aSheet];
    [self restoreSlideShow:_beginSheetWhenSlideShow ? YES : NO];
    _beginSheetWhenSlideShow = 0;
    [[self cardView] restorePreviosCursorVisabilityState];
}

- (void)windowWillBeginSheet:(id)aSheet
{
    [super windowWillBeginSheet:aSheet];
    _beginSheetWhenSlideShow = [self stopSlideShow] ? 1 : 0;
    [[self cardView] showCursor];
}

- (void)windowDidDeminiaturize:(id)aDeminiaturize
{
    [self restoreSlideShow:_miniaturizeWhenSlideShow ? YES : NO];
    _miniaturizeWhenSlideShow = 0;
}

- (void)windowWillMiniaturize:(id)aMiniaturize
{
    _miniaturizeWhenSlideShow = [self stopSlideShow] ? 1 : 0;
}

- (void)restoreSlideShow:(BOOL)aShow
{
    if (!aShow)
        return;
    if ([[self playerView] isPictureShow]) {
        [[self playerView] resumePictureShow];
        return;
    }
    id options = nil;
    if (_sessionSlideshowAttributes != nil)
        options = [NSDictionary dictionaryWithObjectsAndKeys:_sessionSlideshowAttributes, HSCustomSlideshowAttributesKey, nil];
    [[self playerView] startSlideshowWithOptions:options];
}

// Picture shows are only paused so they can resume where they were.
- (BOOL)stopSlideShow
{
    if (![[self playerView] isSlideshow])
        return NO;
    if ([[self playerView] isPictureShow])
        [[self playerView] pausePictureShow];
    else
        [[self playerView] stopSlideshow];
    return YES;
}

- (void)windowWillClose:(id)aClose
{
    [[self playerView] presentationWillInterrupt];
    [super windowWillClose:aClose];
}

- (void)setWindow:(id)aWindow
{
    [super setWindow:aWindow];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayerDidChangeWindowNotification" object:self];
}

- (void)awakeFromNib
{
    [[self playerView] setDelegate:self];
}

- (id)presentationSync
{
    return [[[self document] navigationController] presentationSync];
}

- (void)handleWindowDidLoad
{
    if ([self isTitlebarDisabled] && [self isFullScreen])
        [[self window] setHidesOnDeactivate:YES];
    [self setupUIMode];
    if ([[NSDocumentController sharedDocumentController] isKindOfClass:NSClassFromString(@"HSStackToGoController")] && [self needRunArrivingActions])
        [self runAutomaticTimersAndArrivingActions];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self handleWindowDidLoad];
}

- (id)windowNibName
{
    return @"PlayerWindow";
}

- (void)dealloc
{
    if (_lastCardViewMouseDownEventNumbers != NULL)
        CFRelease(_lastCardViewMouseDownEventNumbers);
    [_oldWindow release];
    [_borderlessWindow release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_borderlessAttributes release];
    [_playerView setDelegate:nil];
    [_playerView setStack:nil];
    [_bitmapLayerView release];
    [_sessionSlideshowAttributes release];
    [_lastSlideShowOptions release];
    [_modifiedAttributesSet release];
    [super dealloc];
}

- (Class)navigationControllerClass
{
    return [HSPlayerNavigationController class];
}

@end
