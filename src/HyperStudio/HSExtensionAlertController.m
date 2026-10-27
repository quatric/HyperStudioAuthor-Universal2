#import "HSExtensionAlertController.h"

@implementation HSExtensionAlertController

static HSExtensionAlertController *sSharedExtensionAlertController = nil;

+ (id)sharedInstance
{
    if (sSharedExtensionAlertController == nil)
        sSharedExtensionAlertController = [[self alloc] HSExtensionAlertController_init];
    return sSharedExtensionAlertController;
}

- (void)orderInfoPressed:(id)aPressed
{
    NSString *url = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSOrderHyperStudioURL" value:@"" table:@"HyperPlayerBase"];
    [HSDocument openURL:url versionString:nil addPlatformInfo:NO addProductName:NO];
    [NSApp stopModalWithCode:0];
}

- (void)OKPressed:(id)aPressed
{
    [NSApp stopModalWithCode:1];
}

- (void)linkButtonPressed:(id)aPressed
{
    NSString *url = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSHyperStudioURL" value:@"" table:@"HyperPlayerBase"];
    [HSDocument openURL:url versionString:nil addPlatformInfo:NO addProductName:NO];
}

- (NSInteger)runModalForMode:(NSInteger)aMode
{
    [[self window] center];
    [self setAlertTextForExtensionMode:aMode];
    BOOL isFirstExtension = aMode == 0;
    [_orderInfoButton setEnabled:!isFirstExtension];
    [_orderInfoButton setHidden:isFirstExtension];
    [_OKButton setKeyEquivalent:isFirstExtension ? @"\r" : @""];
    NSInteger result = [NSApp runModalForWindow:[self window]];
    [self close];
    return result;
}

- (void)setAlertTextForExtensionMode:(NSInteger)aMode
{
    NSString *message = aMode == 0 ? @"The trial period has been extended" : @"This is your LAST extension";
    NSString *explanation = aMode == 0 ? @"You now have an additional 15 days to try HyperStudio on a single computer. To purchase a non-expiring license for yourself or for a classroom, please visit" : @"You now have 5 more days to try HyperStudio on a single computer. To purchase a non-expiring license for yourself or for a classroom, please visit";
    [_message setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:message value:@"" table:@"Alerts"]];
    [_explanation setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:explanation value:@"" table:@"Alerts"]];
}

- (void)windowDidLoad
{
    [self configureLinkButton];
}

- (void)configureLinkButton
{
    NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] initWithAttributedString:[_linkButton attributedTitle]] autorelease];
    NSUInteger length = [title length];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, [NSColor blueColor], NSForegroundColorAttributeName, nil];
    [title addAttributes:attributes range:NSMakeRange(0, length)];
    [title setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [title length])];
    [_linkButton setAttributedTitle:title];

    NSDictionary *alternateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, [NSColor brownColor], NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *alternateTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:[_linkButton attributedTitle]] autorelease];
    [alternateTitle addAttributes:alternateAttributes range:NSMakeRange(0, [alternateTitle length])];
    [alternateTitle setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [alternateTitle length])];
    [_linkButton setAttributedAlternateTitle:alternateTitle];
    [_linkButton setFocusRingType:NSFocusRingTypeNone];
}

- (id)init
{
    [super release];
    return nil;
}

- (id)HSExtensionAlertController_init
{
    return [super initWithWindowNibName:@"ExtensionAlert"];
}

@end
