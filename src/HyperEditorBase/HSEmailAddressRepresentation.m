#import "HSEmailAddressRepresentation.h"

// An email address (a token of the email fields), and the address book
// person with it as the primary address.

// The primary email address of the person.
static NSString *HSPrimaryEmailAddress(ABPerson *aPerson)
{
    ABMultiValue *emails = [aPerson valueForProperty:kABEmailProperty];
    return [emails valueAtIndex:[emails indexForIdentifier:[emails primaryIdentifier]]];
}

@implementation HSEmailAddressRepresentation

+ (id)personForEmailAddress:(id)aAddress
{
    for (ABPerson *person in [[ABAddressBook sharedAddressBook] people]) {
        if ([HSPrimaryEmailAddress(person) isEqual:aAddress])
            return person;
    }
    return nil;
}

+ (id)emailAddressForPerson:(id)aPerson
{
    return HSPrimaryEmailAddress(aPerson);
}

+ (id)emailAddressRepresentationWithEmailAddress:(id)aAddress
{
    return [[[self alloc] initWithEmailAddress:aAddress] autorelease];
}

+ (id)emailAddressRepresentationWithPerson:(id)aPerson
{
    return [[[self alloc] initWithPerson:aPerson] autorelease];
}

- (id)description
{
    return [self displayName];
}

- (id)emailAddress
{
    if (_emailAddress == nil && _person != nil)
        _emailAddress = [[HSEmailAddressRepresentation emailAddressForPerson:_person] retain];
    return _emailAddress;
}

- (id)person
{
    if (_person == nil && _emailAddress != nil)
        _person = [[HSEmailAddressRepresentation personForEmailAddress:_emailAddress] retain];
    return _person;
}

// The person's name, else the address.
- (id)displayName
{
    if ([self person] == nil)
        return [[self emailAddress] stringByRemovingPercentEncoding];
    // Original quirk kept: last name first.
    return [NSString stringWithFormat:@"%@ %@", [[self person] valueForProperty:kABLastNameProperty], [[self person] valueForProperty:kABFirstNameProperty]];
}

- (void)dealloc
{
    [_person release];
    [_emailAddress release];
    [super dealloc];
}

- (void)encodeWithCoder:(id)aCoder
{
    if ([aCoder allowsKeyedCoding]) {
        if (_person != nil)
            [aCoder encodeObject:_person forKey:@"person"];
        [aCoder encodeObject:[self emailAddress] forKey:@"emailAddress"];
    } else {
        [aCoder encodeObject:[self emailAddress]];
        [aCoder encodeObject:[_person uniqueId]];
    }
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super init])) {
        if ([aCoder allowsKeyedCoding]) {
            _person = [[aCoder decodeObjectForKey:@"person"] retain];
            _emailAddress = [[aCoder decodeObjectForKey:@"emailAddress"] retain];
        } else {
            _emailAddress = [[aCoder decodeObject] retain];
            NSString *uniqueId = [aCoder decodeObject];
            if (uniqueId != nil)
                _person = [(ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:uniqueId] retain];
        }
    }
    return self;
}

// Original quirk kept: never equal, even to itself.
- (BOOL)isEqual:(id)aEqual
{
    return NO;
}

- (NSUInteger)hash
{
    return [[self emailAddress] hash];
}

- (id)initWithEmailAddress:(id)aAddress
{
    if ((self = [super init]))
        _emailAddress = [aAddress retain];
    return self;
}

- (id)initWithPerson:(id)aPerson
{
    if ((self = [super init]))
        _person = [aPerson retain];
    return self;
}

@end

// The token field of email addresses, completing from the address book.

@implementation HSAddressBookEmailTokenFieldController

- (id)nameForEmailAddress:(id)aAddress
{
    ABPerson *person = [HSEmailAddressRepresentation personForEmailAddress:aAddress];
    if (person == nil)
        return nil;
    return [NSString stringWithFormat:@"%@ %@", [person valueForProperty:kABFirstNameProperty], [person valueForProperty:kABLastNameProperty]];
}

- (id)tokenField:(id)aField representedObjectForEditingString:(id)aString
{
    return [[[HSEmailAddressRepresentation alloc] initWithEmailAddress:aString] autorelease];
}

- (id)tokenField:(id)aField editingStringForRepresentedObject:(id)aObject
{
    return [aObject emailAddress];
}

- (id)tokenField:(id)aField displayStringForRepresentedObject:(id)aObject
{
    if ([aObject isKindOfClass:[HSEmailAddressRepresentation class]])
        return [aObject displayName];
    return aObject;
}

// The primary addresses starting with the (lowercased) text.
- (id)tokenField:(id)aField completionsForSubstring:(id)aSubstring indexOfToken:(NSInteger)aToken indexOfSelectedItem:(int *)aItem
{
    NSMutableSet *completions = [NSMutableSet set];
    NSString *prefix = [aSubstring lowercaseString];
    for (ABPerson *person in [[ABAddressBook sharedAddressBook] people]) {
        NSString *address = HSPrimaryEmailAddress(person);
        if ([address hasPrefix:prefix])
            [completions addObject:address];
    }
    return [completions allObjects];
}

- (BOOL)control:(id)aControl textShouldBeginEditing:(id)aEditing
{
    [(NSText *)aEditing setUsesFontPanel:NO];
    return YES;
}

- (id)emailAddresses
{
    NSMutableArray *addresses = [NSMutableArray array];
    for (id token in [_tokenField objectValue])
        [addresses addObject:[token respondsToSelector:@selector(emailAddress)] ? [token emailAddress] : token];
    return addresses;
}

- (void)awakeFromNib
{
    [_tokenField setDelegate:self];
}

@end
