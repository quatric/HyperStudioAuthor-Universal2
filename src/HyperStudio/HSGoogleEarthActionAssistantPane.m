#import "HSGoogleEarthActionAssistantPane.h"

@implementation HSGoogleEarthActionAssistantPane

/* i386 ivar offsets: _documentNameField=0x88, _documentIconView=0x8c, _quitAfterLaunchSwitch=0x90, _launchInForegroundSwitch=0x94 */

- (void)launchInForeground:(id)aForeground
{
    [[self googleEarthActionAssistantPaneApplier] setLaunchInForeground:[aForeground intValue]];
}

- (void)quitFromPlayer:(id)aPlayer
{
    [[self googleEarthActionAssistantPaneApplier] setQuitAfterLaunch:[aPlayer intValue]];
}

- (void)chooseLocation:(id)aLocation
{
    id pvVar1_2;
    NSURL *pvVar2_2;

    pvVar1_2 = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSGoogleEarthFileType];
    if (pvVar1_2 != nil) {
        pvVar2_2 = [NSURL fileURLWithPath:pvVar1_2];
        [[self googleEarthActionAssistantPaneApplier] setURL:pvVar2_2];
    }
    [self validateUI];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return [[self actionAttributes] URL] != nil;
}

- (BOOL)canApplyCurrentSettingsForObjectAssistant:(id)aAssistant
{
    return YES;
}

- (void)validateUI
{
    NSString *pvVar2;
    NSWorkspace *self_00;
    id pvVar1_3;
    id pvVar1_4;
    id pvVar1_5;
    NSImage *pvVar2_3;

    pvVar1_3 = [[[self actionAttributes] URL] path];
    pvVar2 = [pvVar1_3 stringByReplacingPercentEscapesUsingEncoding:4];
    self_00 = [NSWorkspace sharedWorkspace];
    pvVar1_4 = _documentNameField;
    if (pvVar2 == nil) {
        [pvVar1_4 setStringValue:[NSString string]];
        pvVar1_5 = _documentIconView;
        pvVar2_3 = nil;
    }
    else {
        [pvVar1_4 setStringValue:[pvVar2 lastPathComponent]];
        pvVar1_5 = _documentIconView;
        pvVar2_3 = [self_00 iconForFileType:[pvVar2 pathExtension]];
    }
    [pvVar1_5 setImage:pvVar2_3];
    [_quitAfterLaunchSwitch setState:(unsigned int)([[self actionAttributes] quitAfterLaunch])];
    [_launchInForegroundSwitch setState:(unsigned int)([[self actionAttributes] launchInForeground])];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (id)helpTopicKey
{
    return @"HSGoogleEarthAction";
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSGoogleEarthActionAttributes);
}

- (id)actionAttributes
{
    return [[self googleEarthActionAssistantPaneApplier] googleEarthActionAttributes];
}

- (id)actionType
{
    return [HSGoogleEarthAction actionType];
}

- (id)googleEarthActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSGoogleEarthActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"GoogleEarthAssistantPane"];
    return self;
}

@end

@implementation HSGoogleEarthActionAssistantPaneApplier

/* i386 ivar offsets: _quitFromPlayer=0x30, _launchInForeground=0x31, _URL=0x34, _initialQuitFromPlayer=0x38, _initialLaunchInForeground=0x39, _initialURL=0x3c */

- (void)setLaunchInForeground:(BOOL)aForeground
{
    if (_launchInForeground != aForeground) {
        _launchInForeground = aForeground;
        [self disableUndo];
        [[self googleEarthActionAttributes] setLaunchInForeground:_launchInForeground];
        [self enableUndo];
    }
}

- (void)setQuitAfterLaunch:(BOOL)aLaunch
{
    if (_quitFromPlayer != aLaunch) {
        _quitFromPlayer = aLaunch;
        [self disableUndo];
        [[self googleEarthActionAttributes] setQuitAfterLaunch:_quitFromPlayer];
        [self enableUndo];
    }
}

- (void)setURL:(id)aURL
{
    if (![_URL isEqual:aURL]) {
        [_URL release];
        _URL = [aURL retain];
        [self disableUndo];
        [[self googleEarthActionAttributes] setURL:_URL];
        [self enableUndo];
    }
}

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    pvVar1 = [super areSettingsEqual];
    if (((!pvVar1) || (_quitFromPlayer != _initialQuitFromPlayer)) || (_launchInForeground != _initialLaunchInForeground)) {
        bVar2 = NO;
    }
    else if (_URL == nil && _initialURL == nil) {
        bVar2 = YES;
    }
    else {
        pvVar1 = [_URL isEqual:_initialURL];
        bVar2 = pvVar1;
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    id pvVar2;

    [super makeCurrentEqualToInitial];
    pvVar2 = _URL;
    if (![_initialURL isEqual:pvVar2]) {
        [_URL release];
        pvVar2 = [_initialURL retain];
        _URL = pvVar2;
    }
    _quitFromPlayer = _initialQuitFromPlayer;
    _launchInForeground = _initialLaunchInForeground;
}

- (void)makeInitialEqualToCurrent
{
    id pvVar2;

    [super makeInitialEqualToCurrent];
    pvVar2 = _URL;
    if (![_initialURL isEqual:pvVar2]) {
        [_initialURL release];
        pvVar2 = [_URL retain];
        _initialURL = pvVar2;
    }
    _initialQuitFromPlayer = _quitFromPlayer;
    _initialLaunchInForeground = _launchInForeground;
}

- (void)setInitialSettingsToObject
{
    id self_00;

    self_00 = [self googleEarthActionAttributes];
    [self_00 setURL:_initialURL];
    [self_00 setQuitAfterLaunch:_initialQuitFromPlayer];
    [self_00 setLaunchInForeground:_initialLaunchInForeground];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    id self_00;

    [super setCurrentSettingsToObject];
    self_00 = [self googleEarthActionAttributes];
    [self_00 setURL:_URL];
    [self_00 setQuitAfterLaunch:_quitFromPlayer];
    [self_00 setLaunchInForeground:_launchInForeground];
}

- (void)setUpInitialSettings
{
    id pvVar1;
    BOOL pvVar2;
    id pvVar1_3;
    BOOL pvVar2_2;

    pvVar1 = [self googleEarthActionAttributes];
    pvVar2 = [pvVar1 quitAfterLaunch];
    _quitFromPlayer = (BOOL)pvVar2;
    _initialQuitFromPlayer = (BOOL)pvVar2;
    pvVar2_2 = [pvVar1 launchInForeground];
    _launchInForeground = (BOOL)pvVar2_2;
    _initialLaunchInForeground = (BOOL)pvVar2_2;
    pvVar1_3 = [[pvVar1 URL] retain];
    _initialURL = pvVar1_3;
    _URL = [pvVar1_3 retain];
}

- (id)googleEarthActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSGoogleEarthActionAttributes)];
}

- (void)dealloc
{
    [_initialURL release];
    [_URL release];
    [super dealloc];
}

@end

