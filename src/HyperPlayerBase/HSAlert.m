#import "HSAlert.h"
#import "EXBundleID.h"
#import "HSAlertView.h"
#import "HSExecutableResourceProvider.h"

static NSImage *HSAlertInformationalIcon;
static NSImage *HSAlertCriticalIcon;
static NSImage *HSAlertWarningIcon;
static NSImage *HSAlertMascotIcon;

// An NSAlert lookalike loaded from the "HSAlert" nib: up to three buttons
// (return codes 1000, 1001, 1002) and a help button, run as a modal window
// or a sheet. Style 0 warning, 1 informational, 2 critical, 3 mascot,
// 5 application icon (the default).
@implementation HSAlert

+ (id)applicationIcon
{
    return [NSImage imageNamed:@"NSApplicationIcon"];
}

+ (id)informationalIcon
{
    if (HSAlertInformationalIcon == nil)
        HSAlertInformationalIcon = [[self iconForKey:@"HSInformationalAlertStyle"] retain];
    return HSAlertInformationalIcon;
}

+ (id)criticalIcon
{
    if (HSAlertCriticalIcon == nil)
        HSAlertCriticalIcon = [[self iconForKey:@"HSCriticalAlertStyle"] retain];
    return HSAlertCriticalIcon;
}

+ (id)warningIcon
{
    if (HSAlertWarningIcon == nil)
        HSAlertWarningIcon = [[self iconForKey:@"HSWarningAlertStyle"] retain];
    return HSAlertWarningIcon;
}

// The image data in the "HSAlertMascotImage" default, or the bundled one.
// Quirk kept: it is made again each time.
+ (id)mascotIcon
{
    NSImage *image = [[[NSImage alloc] initWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSAlertMascotImage"]] autorelease];
    if (HSAlertMascotIcon != image || HSAlertMascotIcon == nil) {
        if (image == nil)
            image = [self iconForKey:@"HSMascotAlertStyle"];
        // Fixed: the previous icon leaked.
        [HSAlertMascotIcon release];
        HSAlertMascotIcon = [image retain];
    }
    return HSAlertMascotIcon;
}

// The file named for the key in HSAlertIcons.plist, from this bundle or the
// main one.
+ (id)iconForKey:(id)aKey
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *iconsPath = [bundle pathForResource:@"HSAlertIcons" ofType:@"plist"];
    if (iconsPath == nil)
        return nil;
    NSDictionary *icons = [[NSDictionary alloc] initWithContentsOfFile:iconsPath];
    NSString *file = [icons objectForKey:aKey];
    NSString *path = [bundle pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
    if (path == nil)
        path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
    NSImage *icon = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
    [icons release];
    return icon;
}

+ (id)iconForAlertStyle:(NSInteger)aStyle
{
    switch (aStyle) {
    case 0:
        return [[self class] warningIcon];
    case 1:
        return [[self class] informationalIcon];
    case 2:
        return [[self class] criticalIcon];
    case 3:
        return [[self class] mascotIcon];
    case 5:
        return [[self class] applicationIcon];
    default:
        return nil;
    }
}

+ (NSInteger)defaultAlertStyle
{
    return 5;
}

// Later buttons only after earlier ones.
+ (id)alertWithMessageText:(id)aText defaultButton:(id)aButton alternateButton:(id)aButton2 otherButton:(id)aButton3 informativeText:(id)aText2
{
    HSAlert *alert = [[[HSAlert alloc] init] autorelease];
    [alert setMessageText:aText];
    [alert setInformativeText:aText2];
    if (aButton != nil) {
        [alert addButtonWithTitle:aButton];
        if (aButton2 != nil) {
            [alert addButtonWithTitle:aButton2];
            if (aButton3 != nil)
                [alert addButtonWithTitle:aButton3];
        }
    }
    return alert;
}

- (void)closeWindow
{
    [_window close];
    if ([_window delegate] == (id)self)
        [_window setDelegate:nil];
    [_window release];
    _window = nil;
}

- (id)window
{
    [self initOnce];
    return _window;
}

// Ends the modal session, or the sheet (then the did-end invocation gets the
// code).
- (void)closeWithCode:(NSInteger)aCode
{
    if (_window == nil || !_canClose)
        return;
    if (_modal) {
        [NSApp stopModalWithCode:aCode];
        _modal = NO;
    } else if (_sheet) {
        NSWindow *window = [self window];
        [[window sheetParent] endSheet:window returnCode:aCode];
        _sheet = NO;
        // Balances the retain in beginSheetModalForWindow:.
        [self autorelease];
        [self closeWindow];
        if (_alertDidEndSheetInvocation != nil) {
            [_alertDidEndSheetInvocation setArgument:&aCode atIndex:3];
            [_alertDidEndSheetInvocation invoke];
            [_alertDidEndSheetInvocation autorelease];
            _alertDidEndSheetInvocation = nil;
        }
    }
}

- (void)close
{
    [self closeWithCode:NSAlertFirstButtonReturn];
}

- (id)anchor
{
    return _helpAnchor;
}

- (void)setHelpAnchor:(id)aAnchor
{
    if (_helpAnchor == aAnchor)
        return;
    [_helpAnchor release];
    _helpAnchor = [aAnchor retain];
}

- (BOOL)showsHelp
{
    if (_helpButton == nil)
        return NO;
    return ![_helpButton isHidden];
}

- (void)setShowsHelp:(BOOL)aHelp
{
    [self initOnce];
    [_helpButton setHidden:!aHelp];
}

- (id)buttons
{
    return [NSArray arrayWithObjects:_firstButton, _secondButton, _thirdButton, _helpButton, nil];
}

- (void)addButtonWithTitle:(id)aTitle
{
    [self initOnce];
    NSButton *button;
    if (_addButtonNumber == 0)
        button = _firstButton;
    else if (_addButtonNumber == 1)
        button = _secondButton;
    else if (_addButtonNumber == 2)
        button = _thirdButton;
    else
        return;
    [self setupButton:button withTitle:aTitle];
}

// At least the minimum width (the nib's second button width).
- (void)setupButton:(id)aButton withTitle:(id)aTitle
{
    [aButton setTitle:aTitle];
    [aButton sizeToFit];
    NSRect frame = [aButton frame];
    [aButton setFrameSize:NSMakeSize(MAX(_minButtonWidth, frame.size.width + 12.0), frame.size.height)];
    [aButton setHidden:NO];
    _addButtonNumber++;
    [self layout];
}

// Widens the window to fit the buttons, then right-aligns the first two.
- (void)layout
{
    NSWindow *window = [self window];
    NSRect windowFrame = [window frame];
    CGFloat available = windowFrame.size.width - 24.0 - 104.0;
    CGFloat needed;
    if (_addButtonNumber == 3)
        needed = [_firstButton frame].size.width + 12.0 + [_secondButton frame].size.width + 24.0 + [_thirdButton frame].size.width - 48.0;
    else
        needed = [_firstButton frame].size.width + 12.0 + [_secondButton frame].size.width - 32.0;
    if (needed > available) {
        windowFrame.size.width += needed - available;
        [[self window] setFrame:windowFrame display:YES];
        [_alertView layoutAll];
    }
    CGFloat y = [_firstButton frame].origin.y;
    CGFloat x = windowFrame.size.width - 24.0 - [_firstButton frame].size.width + 8.0;
    [_firstButton setFrameOrigin:NSMakePoint(x, y)];
    x = x - 12.0 - [_secondButton frame].size.width + 16.0;
    [_secondButton setFrameOrigin:NSMakePoint(x, y)];
}

- (void)setIcon:(id)aIcon
{
    [self initOnce];
    [_imageView setImage:aIcon];
}

- (id)icon
{
    return [_imageView image];
}

- (void)setDoNotShowAgainPreferenceKey:(id)aKey
{
    [self initOnce];
    [_alertView setDoNotShowAgainPreferenceKey:aKey];
}

- (id)doNotShowAgainPreferenceKey
{
    return [_alertView doNotShowAgainPreferenceKey];
}

- (void)setCustomView:(id)aView
{
    [self initOnce];
    [_alertView setCustomView:aView];
}

- (id)customView
{
    return [_alertView customView];
}

- (void)setBottomInformativeText:(id)aText
{
    [self initOnce];
    [_alertView setBottomInformativeText:aText];
}

- (id)bottomInformativeText
{
    return [_alertView bottomInformativeText];
}

- (void)setInformativeText:(id)aText
{
    [self initOnce];
    [_alertView setInformativeText:aText];
}

- (id)informativeText
{
    return [_alertView informativeText];
}

- (void)setMessageText:(id)aText
{
    [self initOnce];
    [_alertView setMessageText:aText];
}

- (id)messageText
{
    return [_alertView messageText];
}

- (void)setCanClose:(BOOL)aClose
{
    _canClose = aClose;
}

- (BOOL)canClose
{
    return _canClose;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

// An "OK" button without buttons. The did-end selector is
// alertDidEnd:returnCode:contextInfo:-shaped; the alert keeps itself alive
// until closed.
- (void)beginSheetModalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    HSAlert *alert = self;
    void *contextInfo = aInfo;
    _sheet = YES;
    if (_addButtonNumber == 0)
        [self addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    if (aSelector != NULL) {
        NSMethodSignature *signature = [aDelegate methodSignatureForSelector:aSelector];
        if (signature != nil) {
            _alertDidEndSheetInvocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
            [_alertDidEndSheetInvocation setTarget:aDelegate];
            [_alertDidEndSheetInvocation setSelector:aSelector];
            [_alertDidEndSheetInvocation setArgument:&alert atIndex:2];
            [_alertDidEndSheetInvocation setArgument:&contextInfo atIndex:4];
            [_alertDidEndSheetInvocation retainArguments];
        }
    }
    [self retain];
    [aWindow beginSheet:[self window] completionHandler:nil];
}

- (NSInteger)runModal
{
    _modal = YES;
    if (_addButtonNumber == 0)
        [self addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    NSInteger code = [NSApp runModalForWindow:[self window]];
    [self closeWindow];
    return code;
}

- (NSInteger)alertStyle
{
    return _style;
}

- (void)setAlertStyle:(NSInteger)aStyle
{
    if (_style == aStyle)
        return;
    [self initOnce];
    _style = (int)aStyle;
    [_imageView setImage:[[self class] iconForAlertStyle:_style]];
}

- (void)dealloc
{
    [_helpAnchor release];
    if ([_window delegate] == (id)self)
        [_window setDelegate:nil];
    [_window release];
    // Fixed: an unfinished sheet's invocation leaked.
    [_alertDidEndSheetInvocation release];
    [super dealloc];
}

- (void)initOnce
{
    if (_inited)
        return;
    [EXBundleID loadNibNamed:[self nibName] owner:self];
    _inited = YES;
    _minButtonWidth = [_secondButton frame].size.width;
    _canClose = YES;
}

- (id)init
{
    self = [super init];
    if (self != nil)
        [self setAlertStyle:[[self class] defaultAlertStyle]];
    return self;
}

- (id)nibName
{
    return @"HSAlert";
}

@end

@implementation HSAlert (IBActions)

- (void)help:(id)aHelp
{
    if ([_delegate respondsToSelector:@selector(hyperAlertShowHelp:)])
        [_delegate hyperAlertShowHelp:self];
}

- (void)thirdButtonPressed:(id)aPressed
{
    [self closeWithCode:NSAlertThirdButtonReturn];
}

- (void)secondButtonPressed:(id)aPressed
{
    [self closeWithCode:NSAlertSecondButtonReturn];
}

- (void)firstButtonPressed:(id)aPressed
{
    [self closeWithCode:NSAlertFirstButtonReturn];
}

@end
