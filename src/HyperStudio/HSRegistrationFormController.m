#import "HSRegistrationFormController.h"
#import <Carbon/Carbon.h>

@implementation HSRegistrationFormController

+ (id)registrationInfoWithSerialNumber:(id)aSerial settingsType:(id)aType
{
    if (![HSRegistrationUserDefaults isRegistrationCompleted])
        return nil;
    id stored = [HSRegistrationUserDefaults registrationUserInfo];
    if (stored == nil)
        return nil;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:stored];
    [info removeFalseBooleanValues];
    [info removeNotSupportedValuesForSettingsType:aType];
    if (![info containsAllRequiredValuesForSettingsType:aType])
        return nil;
    if ([aSerial length] != 0)
        [info setObject:aSerial forKey:@"serial"];
    NSString *build = [[NSBundle mainBundle] HS_buildVersion];
    if ([build length] != 0)
        [info setObject:build forKey:@"build number"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([version length] != 0)
        [info setObject:version forKey:@"short version"];
    if ([info objectForKey:kHSUsersDefaultsRegistrationMacsTypeKey] == nil) {
        static SInt32 sArchitecture;
        if (sArchitecture == 0)
            Gestalt(gestaltSysArchitecture, &sArchitecture);
        [info setObject:sArchitecture == gestaltIntel ? @"Only Intel Macs" : @"Only older Macs" forKey:kHSUsersDefaultsRegistrationMacsTypeKey];
    }
    return info;
}

- (id)initWithRegistrationType:(id)aType settings:(id)aSettings
{
    if (aType == nil || aSettings == nil) {
        [super dealloc];
        return nil;
    }
    self = [super initWithWindowNibName:@"RegistrationForm"];
    if (self != nil) {
        _registrationType = [aType retain];
        _settingsType = [aSettings retain];
    }
    return self;
}

- (id)init
{
    return [self initWithRegistrationType:@"HSRegistrationFormSettingsSerial" settings:@"HSRegistrationTypeOptional"];
}

- (void)dealloc
{
    [_settingsType release];
    [_registrationType release];
    [_registrationFormMap release];
    [_buttonsViewMap release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self registrationForm] windowDidLoad];
    [self setupWindow:[self window]];
    id info = [HSRegistrationUserDefaults registrationUserInfo];
    if ([info count] == 0)
        info = [HSRegistrationUserDefaults HS50registrationUserInfo];
    if (info != nil)
        [[self registrationForm] setValuesFromDictionaryRepresentation:info];
}

// The window takes the height of the form of the settings and the buttons of the registration type.
- (void)setupWindow:(id)aWindow
{
    NSView *container = _buttonsView;
    NSView *buttons = [self buttonsView];
    NSArray *subviews = [container subviews];
    if ([subviews count] == 0) {
        [container addSubview:buttons];
    } else {
        NSView *current = [subviews objectAtIndex:0];
        if (current != buttons) {
            [current removeFromSuperviewWithoutNeedingDisplay];
            [container addSubview:buttons];
        }
    }
    NSRect oldFrame = _settingsView != nil ? [_settingsView frame] : NSZeroRect;
    NSView *newView = [self settingsView];
    NSRect newFrame = newView != nil ? [newView frame] : NSZeroRect;
    CGFloat delta = newFrame.size.height - oldFrame.size.height;
    NSView *placeholder = _settingsView;
    [placeholder setFrameSize:NSMakeSize(oldFrame.size.width, oldFrame.size.height + delta)];
    NSArray *placeholderSubviews = [placeholder subviews];
    if ([placeholderSubviews count] != 0) {
        NSView *last = [placeholderSubviews objectAtIndex:[placeholderSubviews count] - 1];
        if (last != newView) {
            [last removeFromSuperviewWithoutNeedingDisplay];
            [placeholder addSubview:newView];
        }
    } else {
        [placeholder addSubview:newView];
    }
    NSRect windowFrame = aWindow != nil ? [aWindow frame] : NSZeroRect;
    windowFrame.size.height += delta;
    [aWindow setFrame:windowFrame display:NO];
}

- (NSInteger)runModal
{
    NSInteger result = [NSApp runModalForWindow:[self window]];
    [[self window] orderOut:nil];
    if (result != 2) {
        [HSRegistrationUserDefaults setRegistrationUserInfo:[[self registrationForm] dictionaryRepresentation]];
        [self writeRegistrationTypeToUserDefaults];
    }
    [self writeRegistrationChoiceToUserDefaultsForModalResult:(int)result];
    return result;
}

- (id)buttonsView
{
    if (_buttonsViewMap == nil)
        _buttonsViewMap = [[NSDictionary alloc] initWithObjectsAndKeys:buttonsViewRegistrationOptional, @"HSRegistrationTypeOptional", buttonsViewRegistrationForcedWithGoBack, @"HSRegistrationTypeForcedWithGoBack", buttonsViewRegistrationForcedWithQuit, @"HSRegistrationTypeForcedWithQuit", nil];
    return [_buttonsViewMap objectForKey:[self registrationType]];
}

- (id)registrationForm
{
    if (_registrationFormMap == nil)
        _registrationFormMap = [[NSDictionary alloc] initWithObjectsAndKeys:registrationFormTrial, @"HSRegistrationFormSettingsTrial", registrationFormTrialReduced, @"HSRegistrationFormSettingsTrialReduced", registrationFormSerial, @"HSRegistrationFormSettingsSerial", nil];
    return [_registrationFormMap objectForKey:[self settingsType]];
}

- (id)settingsView
{
    return [[self registrationForm] settingsView];
}

- (id)settingsType
{
    return _settingsType;
}

- (id)registrationType
{
    return _registrationType;
}

- (void)defaultButtonClick:(id)aSender
{
    NSError *error = nil;
    if (![[self registrationForm] validateValuesWithError:&error] && error != nil) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    } else {
        [NSApp stopModalWithCode:0];
    }
}

- (void)alternateButtonClick:(id)aSender
{
    [NSApp stopModalWithCode:1];
}

- (void)otherButtonClick:(id)aSender
{
    [NSApp stopModalWithCode:2];
}

- (void)otherAlternateButtonClick:(id)aSender
{
    [NSApp stopModalWithCode:3];
}

- (void)alertSheetDidEnd:(id)aAlert returnCode:(int)aCode contextInfo:(void *)aInfo
{
    [[aAlert window] orderOut:nil];
}

- (void)sheetDidEnd:(id)aSheet returnCode:(int)aCode contextInfo:(void *)aInfo
{
    [aSheet orderOut:nil];
}

- (void)showPrivacyStatement:(id)aSender
{
    [NSApp beginSheet:_privacyStatementWindow modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)privacyStatementWindowOK:(id)aSender
{
    [NSApp endSheet:_privacyStatementWindow returnCode:1];
}

- (void)cut:(id)aSender
{
    if ([[[self window] firstResponder] respondsToSelector:_cmd])
        [[[self window] firstResponder] performSelector:_cmd withObject:aSender];
}

- (void)copy:(id)aSender
{
    if ([[[self window] firstResponder] respondsToSelector:_cmd])
        [[[self window] firstResponder] performSelector:_cmd withObject:aSender];
}

- (void)paste:(id)aSender
{
    if ([[[self window] firstResponder] respondsToSelector:_cmd])
        [[[self window] firstResponder] performSelector:_cmd withObject:aSender];
}

- (void)writeRegistrationChoiceToUserDefaultsForModalResult:(int)aResult
{
    switch (aResult) {
    case 0:
        [HSRegistrationUserDefaults setRegistrationCompleted];
        break;
    case 1:
    case 3:
        [HSRegistrationUserDefaults setRegistrationPostponed];
        break;
    case 2:
        [HSRegistrationUserDefaults setRegistrationRefused];
        break;
    }
}

- (void)writeRegistrationTypeToUserDefaults
{
    if ([[self settingsType] isEqualToString:HSRegistrationFormSettingsTrial] || [[self settingsType] isEqualToString:HSRegistrationFormSettingsTrialReduced])
        [HSRegistrationUserDefaults setRegistrationTypeTrial];
    else
        [HSRegistrationUserDefaults setRegistrationTypeSerial];
}

@end
