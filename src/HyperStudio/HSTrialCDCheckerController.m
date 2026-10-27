#import "HSTrialCDCheckerController.h"

@implementation HSTrialCDCheckerController

static HSTrialCDCheckerController *sSharedTrialCDCheckerController = nil;

+ (id)sharedInstance
{
    if (sSharedTrialCDCheckerController == nil)
        sSharedTrialCDCheckerController = [[self alloc] HSTrialCDCheckerController_init];
    return sSharedTrialCDCheckerController;
}

- (void)purchaseOnline:(id)aOnline
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.mackiev.com/mc_reg.html"]];
    [NSApp stopModalWithCode:0];
}

- (void)enterRegistrationKey:(id)aKey
{
    [NSApp stopModalWithCode:1];
}

- (void)continueWorking:(id)aWorking
{
    [NSApp stopModalWithCode:2];
}

- (void)learnMoreButtonPressed:(id)aPressed
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.hyperstudio.com/testdrive"]];
}

- (void)linkButtonPressed:(id)aPressed
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:education@mackiev.com"]];
}

- (NSInteger)runModal
{
    NSInteger result = [NSApp runModalForWindow:[self window]];
    [[self window] orderOut:nil];
    return result;
}

- (void)windowDidLoad
{
    NSMutableAttributedString *linkTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:[_linkButton attributedTitle]] autorelease];
    NSUInteger length = [linkTitle length];
    [linkTitle addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, [NSColor blueColor], NSForegroundColorAttributeName, nil]
                       range:NSMakeRange(0, length)];
    [linkTitle setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [linkTitle length])];
    [_linkButton setAttributedTitle:linkTitle];

    NSMutableAttributedString *learnMoreTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:[_learnMoreButton attributedTitle]] autorelease];
    length = [learnMoreTitle length];
    [learnMoreTitle addAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:NSUnderlineStyleAttributeName] range:NSMakeRange(0, length)];
    [learnMoreTitle setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [learnMoreTitle length])];
    [_learnMoreButton setAttributedTitle:learnMoreTitle];

    NSDictionary *alternateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, [NSColor brownColor], NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *linkAlternate = [[[NSMutableAttributedString alloc] initWithAttributedString:[_linkButton attributedTitle]] autorelease];
    [linkAlternate addAttributes:alternateAttributes range:NSMakeRange(0, [linkAlternate length])];
    [linkAlternate setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [linkAlternate length])];
    [_linkButton setAttributedAlternateTitle:linkAlternate];
    NSMutableAttributedString *learnMoreAlternate = [[[NSMutableAttributedString alloc] initWithAttributedString:[_learnMoreButton attributedTitle]] autorelease];
    [learnMoreAlternate addAttributes:alternateAttributes range:NSMakeRange(0, [learnMoreAlternate length])];
    [learnMoreAlternate setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [learnMoreAlternate length])];
    [_learnMoreButton setAttributedAlternateTitle:learnMoreAlternate];

    [_linkButton setFocusRingType:NSFocusRingTypeNone];
    [_learnMoreButton setFocusRingType:NSFocusRingTypeNone];
    [[self window] center];
}

- (id)init
{
    [super release];
    return nil;
}

- (id)HSTrialCDCheckerController_init
{
    return [super initWithWindowNibName:@"TrialCDAlertPanel"];
}

@end
