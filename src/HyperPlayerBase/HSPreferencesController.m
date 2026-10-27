#import "HSPreferencesController.h"

// The preferences window: one toolbar item per .hsprefPane bundle in the
// application's PreferencePanes folder, ordered by PrefPanesOrder.plist.

static HSPreferencesController *sSharedPreferencesController = nil;
static NSArray *sOrderedPanes = nil;

// Listed panes first in list order, unlisted ones after, by identifier.
static NSInteger HSComparePaneIdentifiers(id aIdentifier, id aIdentifier2, void *aContext)
{
    NSUInteger index = [sOrderedPanes indexOfObject:aIdentifier];
    NSUInteger index2 = [sOrderedPanes indexOfObject:aIdentifier2];
    if (index == index2) {
        if (index == NSNotFound)
            return [aIdentifier compare:aIdentifier2 options:0];
        return NSOrderedSame;
    }
    if (index == NSNotFound)
        return NSOrderedDescending;
    if (index2 == NSNotFound || index < index2)
        return NSOrderedAscending;
    return index > index2 ? NSOrderedDescending : NSOrderedSame;
}

@implementation HSPreferencesController

+ (id)sharedPreferencesController
{
    if (sSharedPreferencesController == nil)
        sSharedPreferencesController = [[self alloc] init];
    return sSharedPreferencesController;
}

- (BOOL)windowShouldClose:(id)aClose
{
    if (_indexOfPaneToSwitch == 0xffffffff)
        [self deselectPaneForSwitchingToPaneWithBundle:nil];
    return YES;
}

- (id)toolbarSelectableItemIdentifiers:(id)aIdentifiers
{
    return _registeredPaneIdentifiers;
}

- (id)toolbarAllowedItemIdentifiers:(id)aIdentifiers
{
    return _registeredPaneIdentifiers;
}

- (id)toolbarDefaultItemIdentifiers:(id)aIdentifiers
{
    return _registeredPaneIdentifiers;
}

- (id)toolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:aIdentifier];
    if (bundle == nil)
        return nil;
    NSString *label = [self labelForPaneFromBundle:bundle];
    NSImage *icon = [self iconForPaneFromBundle:bundle];
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:aIdentifier];
    [item setLabel:label];
    [item setPaletteLabel:label];
    [item setToolTip:label];
    [item setImage:icon];
    [item setTarget:self];
    [item setAction:@selector(switchPane:)];
    return [item autorelease];
}

- (id)iconForPaneFromBundle:(id)aBundle
{
    NSDictionary *info = [aBundle infoDictionary];
    NSString *iconFile = [info objectForKey:@"NSPrefPaneIconFile"];
    if (iconFile == nil)
        iconFile = [info objectForKey:@"CFBundleIconFile"];
    return [[[NSImage alloc] initWithContentsOfFile:[aBundle pathForImageResource:iconFile]] autorelease];
}

- (void)updateWindowTitle
{
    [[self window] setTitle:[self localizedWindowTitle]];
}

// The application's PrefPaneNames table wins over the pane's own label.
- (id)labelForPaneFromBundle:(id)aBundle
{
    NSString *identifier = [aBundle bundleIdentifier];
    NSString *label = [[NSBundle mainBundle] localizedStringForKey:identifier value:@"" table:[self localizedPreferencePaneNamesTable]];
    if ([label isEqualToString:identifier]) {
        NSDictionary *info = [aBundle infoDictionary];
        label = [info objectForKey:@"NSPrefPaneIconLabel"];
        if (label == nil)
            label = [info objectForKey:@"CFBundleName"];
    }
    return label;
}

- (void)preferencePaneCancelUnselect:(id)aUnselect
{
    _indexOfPaneToSwitch = 0xffffffff;
    _waitingForClose = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Note: the original cleared the pending index before reading it, which
// raised a range exception; it is read first here.
- (void)preferencePaneDoUnselect:(id)aUnselect
{
    unsigned int index = _indexOfPaneToSwitch;
    _indexOfPaneToSwitch = 0xffffffff;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_waitingForClose) {
        [[self window] performClose:self];
        _waitingForClose = NO;
    } else if (index != 0xffffffff) {
        [self switchToPaneWithIdentifier:[_registeredPaneIdentifiers objectAtIndex:index]];
    }
}

- (void)showPreferencePaneHelp:(id)aHelp
{
}

- (void)switchPane:(id)aPane
{
    [self switchToPaneWithIdentifier:[aPane itemIdentifier]];
}

- (void)showWindow:(id)aWindow
{
    if (_selectedPane == nil && _lastSelectedPaneIdentifier != nil)
        [self switchToPaneWithIdentifier:_lastSelectedPaneIdentifier];
    [[self window] makeKeyAndOrderFront:nil];
}

- (void)orderFront:(id)aFront
{
    [[self window] orderFront:nil];
}

- (void)loadUI
{
    if (![NSBundle loadNibNamed:[self windowNibName] owner:self])
        return;
    [self registerPreferencePanes];
    [self setupUI];
    if ([_registeredPaneIdentifiers count] != 0)
        [self switchToPaneWithIdentifier:[_registeredPaneIdentifiers objectAtIndex:0]];
}

- (void)setupUI
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:[self toolbarIdentifier]];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDelegate:self];
    [[self window] setToolbar:toolbar];
    [toolbar release];
}

- (void)switchToPaneWithIdentifier:(id)aIdentifier
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:aIdentifier];
    if (_indexOfPaneToSwitch != 0xffffffff)
        return;
    if (![self deselectPaneForSwitchingToPaneWithBundle:bundle])
        return;
    Class paneClass = [bundle principalClass];
    if (paneClass == Nil)
        return;
    [self selectAndMountPreferencePane:[[paneClass alloc] initWithBundle:bundle]];
    [_lastSelectedPaneIdentifier release];
    _lastSelectedPaneIdentifier = [aIdentifier copy];
    if ([[[self window] toolbar] respondsToSelector:@selector(setSelectedItemIdentifier:)])
        [[[self window] toolbar] setSelectedItemIdentifier:_lastSelectedPaneIdentifier];
    [self updateWindowTitle];
}

// A pane answering NSUnselectLater is switched away from (or the window
// closed) once it posts its do/cancel unselect notification.
- (BOOL)deselectPaneForSwitchingToPaneWithBundle:(id)aBundle
{
    if (_selectedPane == nil)
        return YES;
    NSPreferencePaneUnselectReply reply = [_selectedPane shouldUnselect];
    if (reply == NSUnselectLater) {
        _indexOfPaneToSwitch = aBundle != nil ? (unsigned int)[_registeredPaneIdentifiers indexOfObject:[aBundle bundleIdentifier]] : 0xffffffff;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencePaneDoUnselect:)
                                                     name:NSPreferencePaneDoUnselectNotification object:_selectedPane];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencePaneCancelUnselect:)
                                                     name:NSPreferencePaneCancelUnselectNotification object:_selectedPane];
        return NO;
    }
    if (reply == NSUnselectCancel)
        return NO;
    [_selectedPane willUnselect];
    [[_selectedPane mainView] removeFromSuperview];
    [_selectedPane didUnselect];
    [_selectedPane release];
    _selectedPane = nil;
    return YES;
}

// The pane view is widened to the window's content and the window resized
// to the pane's height, keeping its top edge.
- (void)selectAndMountPreferencePane:(id)aPane
{
    if ([aPane loadMainView] == nil)
        return;
    NSRect contentBounds = NSZeroRect;
    NSRect paneFrame = NSZeroRect;
    [aPane willSelect];
    contentBounds = [[self contentView] bounds];
    paneFrame = [[aPane mainView] frame];
    if (contentBounds.size.width > paneFrame.size.width) {
        paneFrame.origin.x = contentBounds.origin.x;
        paneFrame.size.width = contentBounds.size.width;
    }
    if (paneFrame.size.height != contentBounds.size.height) {
        NSRect windowFrame = [[self window] frame];
        CGFloat delta = paneFrame.size.height - contentBounds.size.height;
        windowFrame.size.height += delta;
        windowFrame.origin.y -= delta;
        if (!NSEqualRects(windowFrame, [[self window] frame])) {
            if ([[self window] isVisible])
                [[self window] setFrame:windowFrame display:YES animate:YES];
            else
                [[self window] setFrame:windowFrame display:YES];
        }
        paneFrame.origin.y = 0.0;
    }
    [[aPane mainView] setFrame:paneFrame];
    [[self contentView] addSubview:[aPane mainView]];
    [[self window] recalculateKeyViewLoop];
    _selectedPane = aPane;
    [aPane didSelect];
    [[self window] makeFirstResponder:[aPane initialKeyView]];
}

- (id)preferencesControllerWindow
{
    return _window;
}

- (id)contentView
{
    return [[self window] contentView];
}

- (id)window
{
    if (_window == nil) {
        [self loadUI];
        [self updateWindowTitle];
        [_window center];
    }
    return _window;
}

- (void)registerPreferencePanes
{
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:[self preferencePaneExtension] inDirectory:[self preferencePaneResourceFolder]];
    int count = (int)[paths count];
    NSMutableArray *identifiers = [[NSMutableArray alloc] initWithCapacity:count];
    [self orderedPanes];
    for (int i = 0; i < count; i++)
        [identifiers addObject:[[NSBundle bundleWithPath:[paths objectAtIndex:i]] bundleIdentifier]];
    [identifiers sortUsingFunction:HSComparePaneIdentifiers context:NULL];
    _registeredPaneIdentifiers = [identifiers copy];
    [identifiers release];
}

- (id)orderedPanes
{
    if (sOrderedPanes == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[self nameForPreferencePanesOrderResource] ofType:@"plist"];
        sOrderedPanes = [[NSArray alloc] initWithContentsOfFile:path];
        if (sOrderedPanes == nil)
            sOrderedPanes = [NSArray new];
    }
    return sOrderedPanes;
}

- (id)preferencePaneResourceFolder
{
    return @"PreferencePanes";
}

- (id)preferencePaneExtension
{
    return @"hsprefPane";
}

- (id)toolbarIdentifier
{
    return [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".preferences.toolbar"];
}

- (id)windowNibName
{
    return @"Preferences";
}

- (id)localizedWindowTitle
{
    return [self labelForPaneFromBundle:[NSBundle bundleWithIdentifier:_lastSelectedPaneIdentifier]];
}

- (id)localizedPreferencePaneNamesTable
{
    return @"PrefPaneNames";
}

- (id)nameForPreferencePanesOrderResource
{
    return @"PrefPanesOrder";
}

- (void)dealloc
{
    [_registeredPaneIdentifiers release];
    [[_window toolbar] setDelegate:nil];
    [_window release];
    if (sSharedPreferencesController == self)
        sSharedPreferencesController = nil;
    [super dealloc];
}

// A second instance gives way to the shared one.
- (id)init
{
    if (sSharedPreferencesController != nil) {
        [super dealloc];
        return [sSharedPreferencesController retain];
    }
    if (self != nil) {
        sSharedPreferencesController = self;
        _indexOfPaneToSwitch = 0xffffffff;
    }
    return self;
}

- (NSInteger)getStartupPreferencesOption
{
    if (_firstTimeApplicationStartup) {
        return 0;
    }
    NSNumber *firstTime = [[NSUserDefaults standardUserDefaults] objectForKey:HSFirstTimeApplicationStartupKey];
    if (firstTime == nil) {
        _firstTimeApplicationStartup = YES;
    } else {
        _firstTimeApplicationStartup = [firstTime boolValue];
        if (!_firstTimeApplicationStartup) {
            goto option;
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:HSFirstTimeApplicationStartupKey];
option:
    if (!_firstTimeApplicationStartup) {
        NSInteger option = [[NSUserDefaults standardUserDefaults] integerForKey:HSStartupActionKey];
        if (option == 3) {
            option = [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"NSQuitAlwaysKeepsWindows"] boolValue] ? 2 : 0;
        }
        return option;
    }
    return 0;
}

@end
