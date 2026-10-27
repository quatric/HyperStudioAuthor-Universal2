#import "HSDontShowAgainAlert.h"

@implementation HSDontShowAgainAlert

- (void)setShowAlertKey:(id)aKey
{
    if (![_showAlertKey isEqualToString:aKey]) {
        [_showAlertKey release];
        _showAlertKey = [aKey retain];
    }
}

- (id)showAlertKey
{
    return _showAlertKey;
}

// Original quirk kept: _showAlertKey is not released.
- (void)dealloc
{
    [_showAgain release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _showAgain = [[NSButton alloc] initWithFrame:NSZeroRect];
        [_showAgain setButtonType:NSButtonTypeSwitch];
        [_showAgain setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSDontShowAgainCheckBoxTitle" value:@"" table:@"Alerts"]];
        [self setCustomView:_showAgain];
    }
    return self;
}

@end

@implementation HSDontShowAgainAlert (IBActions)

- (void)firstButtonPressed:(id)aPressed
{
    if ([_showAgain state] != NSControlStateValueOff)
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:[self showAlertKey]];
    [super firstButtonPressed:aPressed];
}

@end
