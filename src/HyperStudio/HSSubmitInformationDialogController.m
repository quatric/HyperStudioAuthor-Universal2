#import "HSSubmitInformationDialogController.h"

@implementation HSSubmitInformationDialogController

- (void)mountContentView:(id)aView animated:(BOOL)aAnimated
{
    NSRect windowFrame = [[self window] frame];
    NSRect viewFrame = [aView frame];
    NSRect containerFrame = [_containerView frame];
    windowFrame.size.height += viewFrame.size.height - containerFrame.size.height;
    windowFrame.origin.y -= floorf(viewFrame.size.height - containerFrame.size.height);
    windowFrame.size.width += viewFrame.size.width - containerFrame.size.width;
    windowFrame.origin.x -= floorf((viewFrame.size.width - containerFrame.size.width) * 0.5f);
    [[[_containerView subviews] lastObject] removeFromSuperview];
    [[self window] setFrame:windowFrame display:YES animate:aAnimated];
    [_containerView addSubview:aView];
}

- (void)submitInformationErrorAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    [NSApp stopModalWithCode:(aCode == 1000 && _trialLicenseState != 3) ? 3 : 2];
}

- (void)requestAssistance:(id)aAssistance
{
    NSString *serial = [_infoToSend objectForKey:@"serial"];
    if (serial == nil)
        return;
    NSString *string = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRequestAssistanceHyperStudioURL" value:@"" table:@"Alerts"], serial];
    if (string == nil)
        return;
    NSURL *url = [NSURL URLWithString:string];
    if (url == nil)
        return;
    if (![[NSWorkspace sharedWorkspace] openURL:url]) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *ok = [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        NSString *message = [provider localizedStringForKey:@"BrowserNotFound_message" value:@"" table:@"Alerts"];
        NSString *title = [provider localizedStringForKey:@"BrowserNotFound_title" value:@"" table:@"Alerts"];
        NSRunAlertPanel(title, @"%@", ok, nil, nil, message);
    }
}

- (void)submitInfoDidEndWithResult:(NSInteger)aResult
{
    if (aResult == 0) {
        [self mountContentView:_succeededView animated:YES];
        return;
    }
    [_progressIndicator setIndeterminate:NO];
    [_progressIndicator setDoubleValue:[_progressIndicator maxValue]];
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSInteger state = _trialLicenseState;
    if (aResult == 2) {
        NSUInteger assistanceIndex;
        if (state == 1) {
            [alert setMessageText:[provider localizedStringForKey:@"HSSubmitInformationNotConfirmedTrialAvailableAlertTitle" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[provider localizedStringForKey:@"HSSubmitInformationNotConfirmedTrialAvailableAlertText" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Request Assistance" value:@"" table:@"Alerts"]];
            assistanceIndex = 2;
        } else if (state == 2) {
            [alert setMessageText:[provider localizedStringForKey:@"HSSubmitInformationNotConfirmedTrialUsedAlertTitle" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[provider localizedStringForKey:@"HSSubmitInformationNotConfirmedTrialUsedAlertText" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Request Assistance" value:@"" table:@"Alerts"]];
            assistanceIndex = 1;
        } else {
            [alert setMessageText:[provider localizedStringForKey:@"HSSubmitInformationNotConfirmedTrialExpiredAlertTitle" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[provider localizedStringForKey:@"HSSubmitInformationNotConfirmedTrialExpiredAlertText" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Request Assistance" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"]];
            assistanceIndex = 0;
        }
        NSButton *assistanceButton = [[alert buttons] objectAtIndex:assistanceIndex];
        [assistanceButton setTarget:self];
        [assistanceButton setAction:@selector(requestAssistance:)];
    } else if (state == 1) {
        [alert setMessageText:[provider localizedStringForKey:@"HSSubmitInformationConnectionFailedTrialAvailableAlertTitle" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[provider localizedStringForKey:@"HSSubmitInformationConnectionFailedTrialAvailableAlertText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"]];
    } else if (state == 2) {
        [alert setMessageText:[provider localizedStringForKey:@"HSSubmitInformationConnectionFailedTrialUsedAlertTitle" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[provider localizedStringForKey:@"HSSubmitInformationConnectionFailedTrialUsedAlertText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    } else {
        [alert setMessageText:[provider localizedStringForKey:@"HSSubmitInformationConnectionFailedTrialExpiredAlertTitle" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[provider localizedStringForKey:@"HSSubmitInformationConnectionFailedTrialExpiredAlertText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"]];
    }
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(submitInformationErrorAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)continueButtonPressed:(id)aPressed
{
    [NSApp stopModalWithCode:0];
}

- (void)cancelButtonPressed:(id)aPressed
{
    [NSApp stopModalWithCode:1];
}

- (NSInteger)runModalWithInformationDictionary:(id)aDictionary applicationRegistrationIdentifier:(id)aIdentifier
{
    NSMutableDictionary *info = [aDictionary mutableCopy];
    [info setObject:aIdentifier forKey:@"mac_identifier"];
    [_infoToSend release];
    _infoToSend = info;
    [[HSSubmitRequest sharedInstance] submitInformationDictionary:_infoToSend delegate:self didEndSelector:@selector(submitInfoDidEndWithResult:)];
    [self window];
    [self mountContentView:_waitingView animated:NO];
    [_progressIndicator setHidden:NO];
    [_progressIndicator setIndeterminate:YES];
    [_progressIndicator startAnimation:self];
    NSInteger result = [NSApp runModalForWindow:[self window]];
    [[HSSubmitRequest sharedInstance] removeSubmitInformationStatusDelegate:self];
    [self close];
    return result;
}

- (void)setTrialLicenseState:(NSInteger)aState
{
    _trialLicenseState = (int)aState;
    [self window];
    [_cancelButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:_trialLicenseState == 2 ? @"Cancel" : @"Quit" value:@"" table:@"Alerts"]];
}

- (NSInteger)trialLicenseState
{
    return _trialLicenseState;
}

- (void)dealloc
{
    [_infoToSend release];
    [super dealloc];
}

@end
