#import "HSWebAuthenticationPanel.h"
// Asks for a name and password for a web page or proxy (WebKit's panel);
// the callback gets the challenge and the credential (nil if cancelled).
@implementation HSWebAuthenticationPanel
- (void)runAsModalDialogWithChallenge:(id)aChallenge
{
    [self setUpForChallenge:aChallenge];
    NSURLCredential *credential = nil;
    if ([NSApp runModalForWindow:_panel] == 0)
        credential = [NSURLCredential credentialWithUser:[_username stringValue] password:[_password stringValue]
                                             persistence:[_remember state] == NSControlStateValueOn ? NSURLCredentialPersistencePermanent : NSURLCredentialPersistenceForSession];
    [_callback performSelector:_selector withObject:aChallenge withObject:credential];
}
- (void)setUpForChallenge:(id)aChallenge
{
    [self loadNib];
    NSURLProtectionSpace *space = [aChallenge protectionSpace];
    NSString *host = [space port] != 0 ? [NSString stringWithFormat:@"%@:%u", [space host], (unsigned int)[space port]] : [space host];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *format, *area;
    if ([aChallenge previousFailureCount] == 0) {
        if ([space isProxy]) {
            area = [space proxyType];
            format = [bundle localizedStringForKey:@"To view this page, you need to log in to the %@ proxy server %@." value:@"" table:@"HyperPlayerBase"];
        } else {
            area = [space realm];
            format = [bundle localizedStringForKey:@"To view this page, you need to log in to area \"%@\" on %@." value:@"" table:@"HyperPlayerBase"];
        }
    } else {
        if ([space isProxy]) {
            area = [space proxyType];
            format = [bundle localizedStringForKey:@"The name or password entered for the %@ proxy server %@ was incorrect. Please try again." value:@"" table:@"HyperPlayerBase"];
        } else {
            area = [space realm];
            format = [bundle localizedStringForKey:@"The name or password entered for area \"%@\" on %@ was incorrect. Please try again." value:@"" table:@"HyperPlayerBase"];
        }
    }
    [_mainLabel setStringValue:[NSString stringWithFormat:format, area, host]];
    [_mainLabel sizeToFitAndAdjustWindowHeight];
    if ([space receivesCredentialSecurely])
        [_smallLabel setStringValue:[bundle localizedStringForKey:@"Your log-in information will be sent securely." value:@"" table:@"HyperPlayerBase"]];
    else
        [_smallLabel setStringValue:[bundle localizedStringForKey:@"Your password will be sent in the clear." value:@"" table:@"HyperPlayerBase"]];
    NSString *user = [[aChallenge proposedCredential] user];
    if (user != nil) {
        [_username setStringValue:user];
        [_panel setInitialFirstResponder:_password];
    } else {
        [_username setStringValue:@""];
        [_password setStringValue:@""];
        [_panel setInitialFirstResponder:_username];
    }
}
- (BOOL)loadNib
{
    if (_nibLoaded)
        return YES;
    if (![NSBundle loadNibNamed:@"WebAuthenticationPanel" owner:self])
        return NO;
    _nibLoaded = YES;
    [_imageView setImage:[NSImage imageNamed:@"NSApplicationIcon"]];
    return YES;
}
- (void)logIn:(id)aIn
{
    [[_panel retain] autorelease];
    [_panel close];
    [NSApp stopModalWithCode:0];
}
- (void)cancel:(id)aCancel
{
    [[_panel retain] autorelease];
    [[self retain] autorelease];
    [_panel close];
    [NSApp stopModalWithCode:1];
}
- (void)dealloc
{
    [_panel release];
    [_callback release];
    [super dealloc];
}
- (id)initWithCallback:(id)aCallback selector:(SEL)aSelector
{
    self = [self init];
    if (self != nil) {
        _callback = [aCallback retain];
        _selector = aSelector;
    }
    return self;
}
@end

@implementation NSControl (HSWebExtras)
// Grows (or shrinks) to fit its text downwards, and the window with it.
- (void)sizeToFitAndAdjustWindowHeight
{
    NSRect frame = [self frame];
    NSSize size = [[self cell] cellSizeForBounds:NSMakeRect(0, 0, frame.size.width, 10000.0)];
    CGFloat delta = size.height - frame.size.height;
    frame.size.height += delta;
    frame.origin.y -= delta;
    [self setFrame:frame];
    NSRect windowFrame = [[self window] frame];
    windowFrame.size.height += delta;
    [[self window] setFrame:windowFrame display:NO];
}
@end
