#import "HSSendMailAction.h"

// "Send mail" action: keeps a mailto: URL (addresses and subject are parsed
// from / encoded into it) and opens it with the default mail client.
@implementation HSSendMailAction
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    id subject = [self hyperEmailSubject];
    if (subject)
        [dictionary setObject:subject forKey:@"subject"];
    NSMutableArray *addresses = [NSMutableArray new];
    for (id address in [self hyperEmailAddresses]) {
        NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:address, @"email", nil];
        [addresses addObject:entry];
        [entry release];
    }
    [dictionary setObject:addresses forKey:@"addresses"];
    [addresses release];
    return dictionary;
}
- (BOOL)isValid
{
    return [[self hyperEmailAddress] length] != 0;
}
- (id)URLStringForEmailAddresses:(id)aAddresses
{
    NSString *result = [NSString string];
    NSString *addressString = [self URLAddressStringForEmailAddresses:aAddresses];
    if (addressString) {
        NSString *subject = [[self hyperEmailSubject] length]
            ? [NSString stringWithFormat:@"%@%@", @"?subject=", [self hyperEmailSubject]] : @"";
        result = [[NSString stringWithFormat:@"%@%@", addressString, subject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return result;
}
- (id)URLAddressStringForEmailAddresses:(id)aAddresses
{
    NSMutableString *string = [NSMutableString string];
    int count = (int)[aAddresses count];
    for (int i = 0; i < count; i++) {
        [string appendString:[aAddresses objectAtIndex:i]];
        if (i < count - 1)
            [string appendString:@", "];
    }
    return [NSString stringWithFormat:@"%@%@", @"mailto:", string];
}
- (BOOL)isEmailAddressValid:(id)aValid
{
    NSString *string = [self URLStringForEmailAddresses:[NSArray arrayWithObject:aValid]];
    if (string == nil)
        return YES;
    NSURL *URL = [NSURL URLWithString:string];
    if (URL == nil || [[URL absoluteString] length] == 0)
        return NO;
    return [string length] != 0;
}
- (id)hyperInvalidEmailAddressError
{
    return [self error];
}
- (void)setHyperEmailSubject:(id)aSubject
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Email Subject" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEmailSubject:[self emailSubject]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSEmailSubjectAttribute) ofObject:self withUserInfo:nil];
    [self setEmailSubject:aSubject];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSEmailSubjectAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)hyperEmailSubject
{
    return [self emailSubject];
}
- (void)setHyperEmailAddresses:(id)aAddresses
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Email Addresses" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEmailAddresses:[self emailAddresses]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSEmailAddressesAttribute) ofObject:self withUserInfo:nil];
    [self setEmailAddresses:aAddresses];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSEmailAddressesAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    _error = nil;
}
- (void)setHyperEmailAddress:(id)aAddress
{
    if (![self isEmailAddressValid:aAddress]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aAddress forKey:HSAdditionalInfo1ErrorKey];
        _error = [HSError errorWithDomain:HSSpecificErrorDomain code:20004 userInfo:userInfo]; // Not retained, as in the original.
        return;
    }
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Email Address" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEmailAddresses:[self emailAddresses]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSEmailAddressesAttribute) ofObject:self withUserInfo:nil];
    [self setEmailAddress:aAddress];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSEmailAddressesAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    _error = nil;
}
- (id)hyperEmailAddresses
{
    return [self emailAddresses];
}
- (id)hyperEmailAddress
{
    return [self emailAddress];
}
- (void)startInContext:(id)aContext
{
    [[NSWorkspace sharedWorkspace] openURL:[self URL]];
    [self notifyDidFinish];
}
- (id)error
{
    return _error;
}
- (void)setEmailSubject:(id)aSubject
{
    if ([aSubject isEqual:[self hyperEmailSubject]])
        return;
    NSString *addressString = [self URLAddressStringForEmailAddresses:[self emailAddresses]];
    NSString *subject = @"";
    if ([aSubject length])
        subject = [NSString stringWithFormat:@"%@%@", @"?subject=", aSubject];
    NSString *string = [[NSString stringWithFormat:@"%@%@", addressString, subject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self setURL:[NSURL URLWithString:string]];
}
- (id)emailSubject
{
    NSString *subject = @"";
    NSURL *URL = [self URL];
    if (URL) {
        NSString *string = [URL absoluteString];
        NSRange range = [string rangeOfString:@"?subject=" options:NSCaseInsensitiveSearch];
        if (range.length)
            subject = [string substringFromIndex:NSMaxRange(range)];
    }
    return [subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setEmailAddress:(id)aAddress
{
    [self setEmailAddresses:[NSArray arrayWithObject:aAddress]];
}
- (void)setEmailAddresses:(id)aAddresses
{
    if (![aAddresses isEqual:[self emailAddresses]])
        [self setURL:[NSURL URLWithString:[self URLStringForEmailAddresses:aAddresses]]];
}
- (id)emailAddress
{
    NSString *address = @"";
    NSArray *addresses = [self emailAddresses];
    if ([addresses count])
        address = [addresses objectAtIndex:0];
    return address;
}
- (id)emailAddresses
{
    NSArray *addresses = [NSArray array];
    NSURL *URL = [self URL];
    if (URL) {
        NSString *string = [URL absoluteString];
        NSString *addressString = [string hasPrefix:@"mailto:"] ? [string substringFromIndex:[@"mailto:" length]] : @"";
        NSRange range = [addressString rangeOfString:@"?subject=" options:NSCaseInsensitiveSearch];
        if (range.length)
            addressString = [addressString substringToIndex:range.location];
        addresses = [[addressString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@", "];
    }
    return addresses;
}
- (void)setURL:(id)aURL
{
    if ([_URL isEqual:aURL])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Action URL" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setURL:[self URL]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [_URL release];
    _URL = [aURL retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
}
- (id)URL
{
    return _URL;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObject:[@"URL" extraKeyForMultiRepresentations]]];
}
- (void)dealloc
{
    [_URL release];
    [super dealloc];
}
@end
