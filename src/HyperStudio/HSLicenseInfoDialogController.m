#import "HSLicenseInfoDialogController.h"

@implementation HSLicenseInfoDialogController

- (void)actionCloseDialog:(id)aDialog
{
    if (_isModalSession)
        [NSApp stopModalWithCode:0];
    else
        [[self window] close];
}

- (void)actionGetRegistrationNumber:(id)aNumber
{
    NSURL *url = [NSURL URLWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSLicenseGetRegNumberURL" value:@"" table:@"LicenseInfoLocalized"]];
    if (url != nil && ![[NSWorkspace sharedWorkspace] openURL:url]) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *ok = [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        NSString *message = [provider localizedStringForKey:@"BrowserNotFound_message" value:@"" table:@"Alerts"];
        NSString *title = [provider localizedStringForKey:@"BrowserNotFound_title" value:@"" table:@"Alerts"];
        NSRunAlertPanel(title, @"%@", ok, nil, nil, message);
    }
    if (_isModalSession)
        [NSApp stopModalWithCode:0];
    else
        [[self window] close];
}

- (void)run
{
    if (_needsUpdate) {
        [self HSLicenseInfoDialogController_updateWindow];
        _needsUpdate = 0;
    }
    NSWindow *window = [self window];
    [window center];
    [window makeKeyAndOrderFront:self];
}

- (NSInteger)runModal
{
    if (_needsUpdate) {
        [self HSLicenseInfoDialogController_updateWindow];
        _needsUpdate = 0;
    }
    [[self window] center];
    _isModalSession = 1;
    NSInteger result = [NSApp runModalForWindow:[self window]];
    _isModalSession = 0;
    [self close];
    return result;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self HSLicenseInfoDialogController_updateWindow];
    _needsUpdate = 0;
}

- (id)licenseInfo
{
    return _information;
}

- (void)setLicenseInfo:(id)aInfo
{
    if (_information != aInfo) {
        [_information release];
        _information = [aInfo retain];
        if ([[self window] isVisible])
            [self HSLicenseInfoDialogController_updateWindow];
        else
            _needsUpdate = 1;
    }
}

- (void)HSLicenseInfoDialogController_updateWindow
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSString *type = [_information objectForKey:LULicenseInfoType];
    [_typeField setStringValue:type != nil ? [provider localizedStringForKey:type value:@"" table:@"LicenseInfoLocalized"] : @""];
    NSString *identifier = [_information objectForKey:LULicenseInfoIdentifier];
    [_identifierField setStringValue:identifier != nil ? identifier : @""];
    id creationDate = [_information objectForKey:LULicenseInfoCreationDate];
    if (creationDate == nil)
        creationDate = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"undefined" value:@"" table:@"LicenseInfoLocalized"];
    [_creationDateField setStringValue:creationDate];
    id expirationDate = [_information objectForKey:LULicenseInfoExpirationDate];
    if (expirationDate == nil)
        expirationDate = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"undefined" value:@"" table:@"LicenseInfoLocalized"];
    [_expirationDateField setStringValue:expirationDate];
    id copiesCount = [_information objectForKey:LULicenseInfoCopiesCount];
    if (copiesCount == nil)
        copiesCount = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"unlimited" value:@"" table:@"LicenseInfoLocalized"];
    [_copiesCountField setStringValue:copiesCount];
}

- (void)dealloc
{
    [_information release];
    [super dealloc];
}

- (id)initWithInfo:(id)aInfo
{
    self = [super initWithWindowNibName:@"LicenseInfo"];
    if (self != nil)
        _information = [aInfo retain];
    return self;
}

- (id)init
{
    [super release];
    return nil;
}

@end
