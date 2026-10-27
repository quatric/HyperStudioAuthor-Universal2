#import "HSMainWindowController.h"
#import "EXToolbarController.h"
#import "HSActionEvent.h"
#import "HSAlert.h"
#import "HSApplicationController.h"
#import "HSBackgroundWindowController.h"
#import "HSDocument.h"
#import "HSExecutableResourceProvider.h"
#import "HSFunctions.h"
#import "HSHomeStackController.h"
#import "HSNextCardAction.h"
#import "HSSystem.h"
#import "HSTintedView.h"
#import "HSUI.h"
#import "NSEView.h"
#import "NSEWindow.h"

// Implemented by the editor's document, mode switcher, mode controllers and
// minimal window applier.
@interface NSObject (HSMainWindowControllerEditor)
- (BOOL)isInStoryboardMode;
- (void)exitPurePlayerModeWithAnimation:(BOOL)aAnimation;
- (BOOL)isInHyperCastingMode;
- (void)stopExport;
- (void)switchToEditor;
- (void)detachToolView;
- (BOOL)switchesAllWindows;
- (id)previousModeController;
- (id)modeSwitcherCardView:(id)aSwitcher;
- (void)replaceCardView:(id)aView;
- (void)setSupportsMinimalWindowMode:(BOOL)aMode;
@end

// The scale of a tolerance for comparing two edges.
static CGFloat HSMainWindowControllerScale(CGFloat aValue1, CGFloat aValue2)
{
    CGFloat scale1 = aValue1 != 0 ? fabs(aValue1) : 1;
    CGFloat scale2 = aValue2 != 0 ? fabs(aValue2) : 1;
    return MAX(scale1, scale2);
}

static NSString *HSMainWindowControllerAlertString(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Alerts"];
}

// The base of the document windows showing a stack: the card view (made by the
// subclasses), its frame and the window frame for the card size, the window
// title, and the minimal window mode of the mode switcher.
@implementation HSMainWindowController

// Grows the window to the new minimum size, keeping its top.
- (void)updateContentMinSize:(NSSize)aSize forWindow:(id)aWindow animated:(BOOL)aAnimated
{
    [aWindow setContentMinSize:aSize];
    NSSize minSize = [aWindow minSize];
    NSRect frame = [aWindow frame];
    if (minSize.width > frame.size.width)
        frame.size.width = minSize.width;
    if (minSize.height > frame.size.height) {
        frame.origin.y += frame.size.height - minSize.height;
        frame.size.height = minSize.height;
    }
    [aWindow setFrame:frame display:aAnimated animate:aAnimated];
}

- (NSSize)mainWindowMinCardAreaSize
{
    return NSMakeSize([self isBottomToolbarVisible] ? 640 : 150, 100);
}

- (void)setBottomToolbarVisible:(BOOL)aVisible
{
    if ([self isBottomToolbarVisible] != aVisible)
        _isBottomToolbarVisible = aVisible;
}

- (BOOL)isBottomToolbarVisible
{
    return _isBottomToolbarVisible;
}

- (id)currentActiveStack
{
    return [[self document] stack];
}

- (id)currentActiveCard
{
    return [self activeCard];
}

- (void)saveEditingState
{
}

- (void)runMakeEveryCardNextCardExtra:(id)aExtra
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:HSMainWindowControllerAlertString(@"MakeEveryCardNextCardAlertMessageText")];
    [alert setInformativeText:HSMainWindowControllerAlertString(@"MakeEveryCardNextCardAlertInfomativeText")];
    [alert setAlertStyle:5];
    [alert addButtonWithTitle:HSMainWindowControllerAlertString(@"MakeEveryCardNextCardOKButton")];
    [alert addButtonWithTitle:HSMainWindowControllerAlertString(@"Cancel")];
    [alert beginSheetModalForWindow:[[[self document] currentWindowController] window] modalDelegate:self didEndSelector:@selector(alertOnMakeEveryCardNextCardExtraDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

// Gives every card a next card action on click.
- (void)alertOnMakeEveryCardNextCardExtraDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == NSAlertFirstButtonReturn) {
        id cards = [[[self document] stack] queryHyperInterface:@protocol(HSNodeContainer)];
        NSUInteger count = [cards hyperCount];
        NSString *eventType = kHSClickActionEventType;
        for (NSUInteger index = 0; index < count; index++) {
            id actor = [[cards hyperChildAtIndex:index] queryHyperInterface:@protocol(HSActor)];
            [actor addHyperAction:[HSNextCardAction action] forEvent:[HSActionEvent actionEventOfType:eventType]];
        }
    }
    [aEnd release];
}

// Moves the current card (the active one in storyboard mode) to the start.
- (void)titleCard:(id)aCard
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:HSMainWindowControllerAlertString(@"TitleCardAlertMessageText")];
    [alert setInformativeText:HSMainWindowControllerAlertString(@"TitleCardAlertInfomativeText")];
    [alert setAlertStyle:5];
    [alert addButtonWithTitle:HSMainWindowControllerAlertString(@"Make Title Card")];
    [alert addButtonWithTitle:HSMainWindowControllerAlertString(@"Cancel")];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        id document = [self document];
        id card = [[self document] isInStoryboardMode] ? [self activeCard] : [document currentCard];
        [[card queryHyperInterface:@protocol(HSNodeChild)] moveToHyperBegin];
        [document setCurrentCard:card];
    }
    [alert release];
}

- (void)documentDidCreateMinimalWindowApplier
{
    [self applyMinimalWindowModeAttributeIfNeeded];
}

- (void)applyMinimalWindowModeAttributeIfNeeded
{
}

- (id)minimalWindowApplier
{
    return [[self document] minimalWindowApplier];
}

- (BOOL)supportsMinimalWindowMode
{
    return NO;
}

- (void)windowControllerDidBindToWindowInModeSwitcher:(id)aSwitcher
{
}

- (BOOL)shouldDisableAnimationInModeSwitcher:(id)aSwitcher
{
    return [aSwitcher switchesAllWindows];
}

- (void)didBecomeNonWorkingInModeSwitcher:(id)aSwitcher
{
    [[self cardView] hibernate];
}

// Hands the card view to the minimal window applier when this mode supports
// the minimal window, and refreshes the support when the switch changed it.
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    BOOL refresh = _pendingRequestToRefreshMinimalWindowModeSupport;
    _pendingRequestToRefreshMinimalWindowModeSupport = NO;
    if ([self minimalWindowApplier]) {
        BOOL supports = [self modeControllerSupportsMinimalWindowMode:self withModeSwitcher:aSwitcher];
        [[self minimalWindowApplier] replaceCardView:supports ? [self cardView] : nil];
        if (refresh)
            [[self minimalWindowApplier] setSupportsMinimalWindowMode:supports];
    }
    [[self cardView] dehibernate];
    [[self cardView] setNeedsDisplayOpenGLSurface:YES];
    [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
}

- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    BOOL supports = [self modeControllerSupportsMinimalWindowMode:self withModeSwitcher:aSwitcher];
    BOOL previousSupports = [self modeControllerSupportsMinimalWindowMode:[aSwitcher previousModeController] withModeSwitcher:aSwitcher];
    if (previousSupports != supports)
        _pendingRequestToRefreshMinimalWindowModeSupport = YES;
}

- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher
{
    [[self document] detachToolView];
}

- (BOOL)modeControllerSupportsMinimalWindowMode:(id)aMode withModeSwitcher:(id)aSwitcher
{
    if ([aMode respondsToSelector:@selector(supportsMinimalWindowMode)] && [aMode respondsToSelector:@selector(modeSwitcherCardView:)] && [aMode modeSwitcherCardView:aSwitcher])
        return [aMode supportsMinimalWindowMode];
    return NO;
}

- (id)secondaryModeSwitcherWindows:(id)aWindows
{
    return [NSArray array];
}

- (id)mainModeSwitcherWindow:(id)aWindow
{
    return [self window];
}

- (id)sheetWindow
{
    return [[self window] attachedSheet];
}

- (BOOL)isSheetRunning
{
    return [[self window] attachedSheet] != nil;
}

// The window fitted to the card, keeping its top, within the screen. The
// original also shifted the frame back from the screen's far edges, but into
// the unused current frame, so only the near edges count.
- (NSRect)windowWillUseStandardFrame:(id)aFrame defaultFrame:(NSRect)aFrame2
{
    NSRect frame = [[self window] frame];
    NSRect standardFrame;
    standardFrame.size = [self windowFrameSizeAdjustedToCurrentContent];
    standardFrame.origin.x = frame.origin.x;
    standardFrame.origin.y = (frame.origin.y + frame.size.height) - standardFrame.size.height;
    NSScreen *screen = [[self window] screen];
    standardFrame = [self constrainSizeOfWindowFrame:standardFrame forScreen:screen];
    NSRect visibleFrame = [screen visibleFrame];
    if (visibleFrame.origin.x > standardFrame.origin.x)
        standardFrame.origin.x = visibleFrame.origin.x;
    if (visibleFrame.origin.y > standardFrame.origin.y)
        standardFrame.origin.y = visibleFrame.origin.y;
    standardFrame.origin.x = roundf((float)standardFrame.origin.x);
    standardFrame.origin.y = roundf((float)standardFrame.origin.y);
    return standardFrame;
}

// The card size, at least the minimum card area, plus the card view's offset
// in the window.
- (NSSize)windowFrameSizeAdjustedToCurrentContent
{
    NSSize cardSize = [(id<HSSizeAttributes>)[[[self document] currentCard] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSSize minSize = [self mainWindowMinCardAreaSize];
    NSRect contentRect = NSZeroRect;
    contentRect.size.width = MAX(minSize.width, cardSize.width);
    contentRect.size.height = MAX(minSize.height, cardSize.height);
    NSScrollView *scrollView = [[self cardView] enclosingScrollView];
    NSRect bounds = [scrollView bounds];
    NSPoint origin = bounds.origin;
    if ([scrollView isFlipped])
        origin.y += bounds.size.height;
    NSPoint offset = [scrollView convertPoint:origin toView:nil];
    contentRect.size.width += offset.x;
    contentRect.size.height += offset.y;
    return [[self window] frameRectForContentRect:contentRect].size;
}

- (void)windowWillClose:(id)aClose
{
    if ([self window] != nil) {
        id state = [self documentWindowStateDictionary];
        [[self document] storeDocumentWindowState:state];
        [self commitToDocumentWindowStatesDictionary:state];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self notifyWillClose:aClose];
}

// Remembers the window frame for the document.
// With several documents, the other unprotected documents leave the player
// and casting modes for the editor.
- (void)windowDidBecomeMain:(id)aMain
{
    if ([[HSApplicationController sharedDocumentController] isMultiDocument]) {
        for (id document in [[NSDocumentController sharedDocumentController] documents]) {
            if ([self document] == document || [document isStackProtected])
                continue;
            if ([document isInPlayerMode]) {
                if ([document isInPurePlayerMode] || [document isInPresentationMode])
                    [document exitPurePlayerModeWithAnimation:NO];
            } else if ([document isInHyperCastingMode]) {
                [document stopExport];
            } else {
                continue;
            }
            [document switchToEditor];
        }
    }
    [self notifyDidBecomeMain:aMain];
}

// Posted for the window of the last document.
- (void)notifyWillClose:(id)aClose
{
    NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
    NSUInteger count = [documents count];
    if (count != 0) {
        if (count != 1)
            return;
        if ([[[NSDocumentController sharedDocumentController] documents] lastObject] != [[[aClose object] windowController] document])
            return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSLastDocumentWindowWillCloseNotification" object:[aClose object]];
}

- (void)notifyDidBecomeMain:(id)aMain
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentWindowDidBecomeMainNotification" object:[aMain object]];
}

- (void)documentCurrentStackDidChange:(id)aChange
{
    [self attachToStackAndUpdateView];
}

- (void)documentCurrentStackWillChange:(id)aChange
{
    [self detachFromStack];
}

- (void)setDocument:(id)aDocument
{
    if ([self document] == aDocument)
        return;
    if ([self document]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentWillChangeCurrentStack object:[self document]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentDidChangeCurrentStack object:[self document]];
        [self detachFromStack];
    }
    [super setDocument:aDocument];
    if (!aDocument)
        return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentCurrentStackWillChange:) name:HSDocumentWillChangeCurrentStack object:[self document]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentCurrentStackDidChange:) name:HSDocumentDidChangeCurrentStack object:[self document]];
    [self attachToStackAndUpdateView];
    [self stackDidChangeAttributes:nil];
}

- (void)attachToStackAndUpdateView
{
    [self attachToStack];
}

- (void)attachToStack
{
    [[[self document] stack] addObserver:self selector:@selector(stackDidChangeAttributes:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSStackAttributes) withPriority:-0.25];
}

- (void)detachFromStack
{
    [[[self document] stack] removeObserver:self selector:@selector(stackDidChangeAttributes:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSStackAttributes)];
}

- (id)cardViewContainer
{
    return nil;
}

// Fits the frame's size within the screen and the window's size limits, and
// moves it into the screen when it sticks out.
- (NSRect)constrainSizeOfWindowFrame:(NSRect)aFrame forScreen:(id)aScreen
{
    NSRect visibleFrame = [aScreen visibleFrame];
    NSSize minSize = [[self window] minSize];
    NSSize maxSize = [[self window] maxSize];
    CGFloat height = MIN(MAX(MIN(aFrame.size.height, visibleFrame.size.height), minSize.height), maxSize.height);
    CGFloat width = MIN(MAX(MIN(aFrame.size.width, visibleFrame.size.width), minSize.width), maxSize.width);
    NSPoint origin = aFrame.origin;
    CGFloat toleranceX = HSMainWindowControllerScale(fabs(visibleFrame.origin.x) + visibleFrame.size.width, fabs(aFrame.origin.x) + width) * 0.0005;
    CGFloat toleranceY = HSMainWindowControllerScale(fabs(visibleFrame.origin.y) + visibleFrame.size.height, fabs(aFrame.origin.y) + height) * 0.0005;
    if (aFrame.origin.x < visibleFrame.origin.x - toleranceX || NSMaxX(visibleFrame) + toleranceX < aFrame.origin.x + width || aFrame.origin.y < visibleFrame.origin.y - toleranceY || NSMaxY(visibleFrame) + toleranceY < aFrame.origin.y + height) {
        origin.x = MAX(visibleFrame.origin.x, aFrame.origin.x);
        if (NSMaxX(visibleFrame) < origin.x + width)
            origin.x = NSMaxX(visibleFrame) - width;
        origin.y = MAX(visibleFrame.origin.y, aFrame.origin.y);
        if (NSMaxY(visibleFrame) < origin.y + height)
            origin.y = NSMaxY(visibleFrame) - height;
    }
    return NSMakeRect(origin.x, origin.y, width, height);
}

- (void)adjustWindowFrame
{
}

- (NSRect)bestWindowFrameForCurrentStack
{
    [self doesNotRecognizeSelector:_cmd];
    return NSZeroRect;
}

- (void)didEndModalWindow:(id)aWindow
{
    [self updateAlternateGoToHomeMenuItemToTemporaryKeyEquivalent:NO];
}

- (void)willRunModalWindow:(id)aWindow
{
    [self updateAlternateGoToHomeMenuItemToTemporaryKeyEquivalent:YES];
}

- (void)windowDidEndSheet:(id)aSheet
{
    [self updateAlternateGoToHomeMenuItemToTemporaryKeyEquivalent:NO];
}

- (void)windowWillBeginSheet:(id)aSheet
{
    [self updateAlternateGoToHomeMenuItemToTemporaryKeyEquivalent:YES];
}

// The alternate Go To Home item is Command-Shift-H, or Option-H while a modal
// window or sheet runs.
- (void)updateAlternateGoToHomeMenuItemToTemporaryKeyEquivalent:(BOOL)aEquivalent
{
    NSMenuItem *item = [[[[NSApp mainMenu] itemWithTag:4] submenu] itemWithTag:4];
    if (aEquivalent) {
        [item setKeyEquivalent:@"h"];
        [item setKeyEquivalentModifierMask:NSEventModifierFlagOption];
    } else {
        [item setKeyEquivalent:@"H"];
        [item setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    }
}

- (BOOL)cancelOperation
{
    return NO;
}

- (id)playerSettingsDataSource
{
    return nil;
}

// The home stack goes without its extension; the stack title preference adds
// the card number (bit 0) and title (bit 1).
- (id)windowTitleForDocumentDisplayName:(id)aName
{
    NSURL *homeStackURL = [[HSHomeStackController sharedHomeStackController] defaultHomeStackURL];
    NSString *name = aName;
    if ([homeStackURL isEqual:[[self document] fileURL]] && [[[homeStackURL path] lastPathComponent] isEqualToString:aName])
        name = [aName stringByDeletingPathExtension];
    NSInteger options = [[[NSUserDefaults standardUserDefaults] objectForKey:HSStackTitleKey] integerValue];
    if (!options)
        return name;
    id card = [self activeCard];
    BOOL showsNumber = (options & 1) != 0;
    BOOL showsTitle = (options & 2) != 0;
    if (showsNumber && showsTitle) {
        NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"%@ - %@ (%u of %u)" value:@"" table:nil];
        unsigned int number = (unsigned int)[card hyperIndex] + 1;
        unsigned int count = (unsigned int)[[[[self document] stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperCount];
        return [NSString stringWithFormat:format, name, [card hyperTitle], number, count];
    }
    if (showsNumber) {
        NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"%@ - Card %u" value:@"" table:nil];
        return [NSString stringWithFormat:format, name, (unsigned int)[card hyperIndex] + 1];
    }
    if (showsTitle) {
        NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"%@ - %@" value:@"" table:nil];
        return [NSString stringWithFormat:format, name, [card hyperTitle]];
    }
    return name;
}

- (void)synchronizeWindowTitleWithDocumentName
{
    if (![self activeCard])
        return;
    [super synchronizeWindowTitleWithDocumentName];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentTitleHasChangedNotification" object:[[self document] stack]];
}

- (void)activateOnLoad
{
    [[self cardView] activate];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setCollectionBehavior:0x80];
    [self willBindToModelOnLoad];
    [self bindToModelOnLoad];
    [self didBindToModelOnLoad];
}

- (void)loadWindow
{
    if (_isNibLoaded)
        return;
    [super loadWindow];
    _isNibLoaded = YES;
}

// Converts the old version attributes of the actions of the stack, its cards
// and their objects.
- (void)didBindToModelOnLoad
{
    [self activateOnLoad];
}

- (void)bindToModelOnLoad
{
}

// With OpenGL the window is transparent, with an opaque shape shadow.
- (void)willBindToModelOnLoad
{
    NSWindow *window = [self window];
    if (window) {
        [window setPreferredBackingLocation:NSWindowBackingLocationMainMemory];
        [self setShouldCascadeWindows:YES];
        [_toolbarController setupToolbar];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentWindowDidLoadNotification" object:[self window]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRunModalWindow:) name:HSWillRunModalWindowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndModalWindow:) name:HSDidEndModalWindowNotification object:nil];
    [self stackDidChangeAttributes:nil];
}

- (void)stackDidChangeAttributes:(id)aAttributes
{
    id stack = [[[self document] stack] queryHyperInterface:@protocol(HSStackAttributes)];
    if (!stack)
        return;
    NSRect frame = [[self cardViewContainer] frame];
    frame.size = [stack hyperCardSize];
    [self setCardViewFrame:frame];
}

- (BOOL)needsHelpCoachingHintForObject:(id)aObject
{
    return [[aObject queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)] isDropOffTarget];
}

- (void)nodeContainer:(id)aContainer didRemoveChildren:(id)aChildren
{
    [self nodeContentsDidChange:aContainer affectedChildren:aChildren];
}

- (void)nodeContainer:(id)aContainer didAddChild:(id)aChild
{
    [self nodeContentsDidChange:aContainer affectedChildren:[NSArray arrayWithObject:aChild]];
}

- (void)nodeContentsDidChange:(id)aChange affectedChildren:(id)aChildren
{
}

// The container's frame adds its border around the card.
- (void)setCardViewFrame:(NSRect)aFrame
{
    id container = [self cardViewContainer];
    float border = (float)[container borderThickness];
    float thickness = border + border;
    [container setFrame:NSMakeRect(aFrame.origin.x, aFrame.origin.y, aFrame.size.width + thickness, aFrame.size.height + thickness)];
    [container setNeedsDisplay:YES];
}

- (void)setActiveCard:(id)aCard
{
    [self window];
    [[self cardView] setCard:aCard];
}

- (id)activeCard
{
    return [[self cardView] card];
}

- (id)cardView
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// stackView is implemented by the HSSelectionHolderDelegate category.

- (id)preferedUndoManager
{
    id undoManager = _preferedUndoManager;
    if (!undoManager && [self respondsToSelector:@selector(windowWillReturnUndoManager:)])
        undoManager = [self performSelector:@selector(windowWillReturnUndoManager:) withObject:[self window]];
    return undoManager;
}

- (void)setPreferedUndoManager:(id)aManager
{
    if (_preferedUndoManager == aManager)
        return;
    [_preferedUndoManager release];
    _preferedUndoManager = [aManager retain];
}

- (id)windowNibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// Marks the nib loaded so that asking for the window here loads nothing.
- (void)dealloc
{
    _isNibLoaded = YES;
    if ([[self window] delegate] == (id)self)
        [[self window] setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_preferedUndoManager release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self setupBottomToolbar];
}

- (id)init
{
    return [self initWithWindowNibName:[self windowNibName]];
}

// Shown unless turned off in the settings.
- (void)setupBottomToolbar
{
    id setting = [[HSUI sharedUI] settingsForKey:HSUIModeIsBottomToolbarShown];
    if (!setting) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:YES] forKey:HSUIModeIsBottomToolbarShown];
        _isBottomToolbarVisible = YES;
    } else {
        _isBottomToolbarVisible = [setting boolValue];
    }
}

- (void)setToolbarController:(id)aController
{
    if (_toolbarController != aController)
        _toolbarController = aController;
}

- (id)toolbarController
{
    return _toolbarController;
}

- (void)commitToDocumentWindowStatesDictionary:(id)aDictionary
{
    NSMutableDictionary *states = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSDocumentWindowStates"]];
    if (states == nil) {
        states = [NSMutableDictionary dictionary];
    }
    NSString *key = [[[[self document] fileURL] path] retain];
    if (key == nil) {
        key = [[[[[self document] stack] UID] stringValue] retain];
        if (key == nil) {
            return;
        }
    }
    [states setObject:aDictionary forKey:key];
    [key release];
    [[NSUserDefaults standardUserDefaults] setObject:states forKey:@"HSDocumentWindowStates"];
}

- (id)documentWindowStateDictionary
{
    NSMutableDictionary *states = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSDocumentWindowStates"]];
    NSString *key = [[[self document] fileURL] path];
    if (key == nil) {
        key = [[[[self document] stack] UID] stringValue];
    }
    NSMutableDictionary *state = [NSMutableDictionary dictionaryWithDictionary:[states objectForKey:key]];
    if (state == nil) {
        state = [NSMutableDictionary dictionary];
    }
    return state;
}

- (void)fitWindowToCardSizeAnimated:(BOOL)aAnimated
{
    CGFloat zoomFactor = [[self cardView] zoomFactor];
    NSSize cardSize = [[[self document] cardView] cardSize];
    id documentCardView = [[self document] cardView];
    NSSize targetSize = NSMakeSize(ceilf(cardSize.width * zoomFactor), ceilf(cardSize.height * zoomFactor));
    NSScrollView *scrollView = [documentCardView enclosingScrollView];
    NSRect visibleRect = scrollView != nil ? [scrollView visibleRect] : NSZeroRect;
    if (!NSEqualSizes(targetSize, visibleRect.size)) {
        NSWindow *window = [self window];
        NSSize minSize = [window contentMinSize];
        CGFloat width = MAX(minSize.width, targetSize.width);
        CGFloat height = MAX(minSize.height, targetSize.height);
        NSRect frame = window != nil ? [window frame] : NSZeroRect;
        NSRect newFrame = NSMakeRect(frame.origin.x - floorf((width - visibleRect.size.width) * 0.5), frame.origin.y - floorf((height - visibleRect.size.height) * 0.5), frame.size.width + (width - visibleRect.size.width), frame.size.height + (height - visibleRect.size.height));
        [window setFrame:newFrame display:YES animate:aAnimated];
    }
}

- (void)hideAllPalettesAndToolbars
{
    [self hideFloatingPalettes];
    [self hideFixedToolbars];
}

- (void)hideFixedToolbars
{
}

- (void)hideFloatingPalettes
{
}

- (void)restoreAllPalettesAndToolbars
{
    [self restoreFloatingPalettes];
    [self restoreFixedToolbars];
}

- (void)restoreFixedToolbars
{
}

- (void)restoreFloatingPalettes
{
}

- (void)notifyDidEnterVersionBrowser:(id)aBrowser
{
}

- (void)notifyDidExitVersionBrowser:(id)aBrowser
{
}

- (void)notifyWillEnterVersionBrowser:(id)aBrowser
{
}

- (void)notifyWillExitVersionBrowser:(id)aBrowser
{
}

- (void)storeDocumentWindowState:(id)aState
{
    [aState setValue:[NSNumber numberWithBool:[[self document] isInPresentationMode]] forKey:@"HSDocumentInPresenationModeKey"];
    [aState setValue:[[self window] stringWithSavedFrame] forKey:@"HSMainWindowFrameAsStringKey"];
    [aState setValue:[NSNumber numberWithBool:[[[self toolbarController] toolbar] isVisible]] forKey:@"HSToolbarVisibleKey"];
    [aState setValue:[NSNumber numberWithBool:[self isBottomToolbarVisible]] forKey:@"HSBottomToolbarVisibleKey"];
    [aState setValue:[NSNumber numberWithBool:![[self document] isInPlayerMode]] forKey:@"HSDocumentInEditModeKey"];
    [aState setValue:[NSNumber numberWithFloat:[[self cardView] zoomFactor]] forKey:@"HSCardViewZoomFactorKey"];
    [aState setValue:[NSNumber numberWithInt:[[self cardView] zoomMode]] forKey:@"HSCardViewZoomModeKey"];
}

- (void)window:(id)aWindow willEncodeRestorableState:(id)aState
{
    NSString *homePath = [[[HSHomeStackController sharedHomeStackController] defaultHomeStackURL] path];
    if ([[HSPreferencesController sharedPreferencesController] getStartupPreferencesOption] == 2 || [[self document] fileURL] == nil) {
        if (![homePath isEqualToString:[[[self document] fileURL] path]]) {
            return;
        }
    }
    [[self window] setRestorable:NO];
}

- (NSSize)window:(id)aWindow willResizeForVersionBrowserWithMaxPreferredSize:(NSSize)aPreferred maxAllowedSize:(NSSize)aAllowed
{
    NSSize frameSize = aWindow != nil ? [aWindow frame].size : NSZeroSize;
    return NSMakeSize(MIN(aPreferred.width, frameSize.width), MIN(aPreferred.height, frameSize.height));
}

- (NSSize)window:(id)aWindow willUseFullScreenContentSize:(NSSize)aSize
{
    return aSize;
}

- (void)windowDidEnterFullScreen:(id)aScreen
{
    [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
}

- (void)windowDidExitFullScreen:(id)aScreen
{
    [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
}

- (void)windowDidEnterVersionBrowser:(id)aBrowser
{
    [[[self document] editorWindowController] notifyDidEnterVersionBrowser:aBrowser];
}

- (void)windowDidExitVersionBrowser:(id)aBrowser
{
    [[[self document] editorWindowController] notifyDidExitVersionBrowser:aBrowser];
}

- (void)windowWillEnterVersionBrowser:(id)aBrowser
{
    id document = [self document];
    if ([document isInStoryboardMode]) {
        [document switchToStandardMode:nil];
    } else if ([document isInPlayerMode]) {
        [document switchToEditor];
    }
    [[document editorWindowController] notifyWillEnterVersionBrowser:aBrowser];
}

- (void)windowWillExitVersionBrowser:(id)aBrowser
{
    [[[self document] editorWindowController] notifyWillExitVersionBrowser:aBrowser];
}

@end

@implementation HSMainWindowController (HSSelectionHolderDelegate)

- (id)stackView
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)cardView:(id)aView :(id)aArg
{
}

@end

@implementation HSMainWindowController (HSMainWindowControllerCreation)

+ (id)mainWindowController
{
    return [[self new] autorelease];
}

@end

@implementation HSMainWindowController (IBActions)

- (void)toggleContinuousSpellChecking:(id)aChecking
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[aChecking state] == 0] forKey:HSTextViewContinuousSpellCheckingKeyString];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSTextViewContinuousSpellCheckingNotification object:nil userInfo:nil];
}

- (void)customizeToolbar:(id)aToolbar
{
    [[[self toolbarController] toolbar] runCustomizationPalette:aToolbar];
}

- (void)hideShowToolbar:(id)aToolbar
{
    BOOL visible = [[[self toolbarController] toolbar] isVisible];
    [[[self toolbarController] toolbar] setVisible:!visible];
}

// Nothing is enabled while a sheet or modal session runs or the document
// closes, except the toolbar toggle and the spell checking toggle.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(NSMenuItem *)aItem action];
    BOOL enabled = ![self isSheetRunning] && ![[self document] isDocumentClosing] && ![[self document] isModalSessionPresent];
    if (action == @selector(hideShowToolbar:)) {
        if (![[self toolbarController] toolbar])
            return enabled;
        if ([aItem respondsToSelector:@selector(setState:)])
            [(NSMenuItem *)aItem setState:[[[self toolbarController] toolbar] isVisible]];
        return YES;
    }
    if (action == @selector(customizeToolbar:)) {
        if (!enabled || [[[self toolbarController] toolbar] customizationPaletteIsRunning])
            return NO;
        return [[self toolbarController] toolbar] != nil;
    }
    if (action == @selector(toggleContinuousSpellChecking:)) {
        if ([aItem respondsToSelector:@selector(setState:)])
            [(NSMenuItem *)aItem setState:[[[NSUserDefaults standardUserDefaults] objectForKey:HSTextViewContinuousSpellCheckingKeyString] boolValue]];
        return YES;
    }
    if (action == @selector(runMakeEveryCardNextCardExtra:))
        return ![[self document] isStackProtected] && ![[self document] isInPresentationMode];
    if (action == @selector(titleCard:)) {
        if ([[self document] isStackProtected] || [[self document] isInPresentationMode])
            return NO;
        return [[[[self document] currentCard] queryHyperInterface:@protocol(HSNodeChild)] hyperIndex] != 0;
    }
    return enabled;
}

- (id)navigationController
{
    return [[self document] navigationController];
}

@end

@implementation NSWindow (NSWindowPrivate)

- (void)hyperMakeNonTransparent
{
    [self setAlphaValue:1.0];
}

- (void)hyperMakeTransparent
{
    [self setAlphaValue:0.0];
}

@end
