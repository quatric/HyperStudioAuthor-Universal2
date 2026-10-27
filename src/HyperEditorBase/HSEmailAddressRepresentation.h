#import "HyperEditorBasePrefix.h"


@interface HSEmailAddressRepresentation : NSObject <NSCoding>
{
    ABPerson *_person;
    NSString *_emailAddress;
}
+ (id)personForEmailAddress:(id)aAddress;
+ (id)emailAddressForPerson:(id)aPerson;
+ (id)emailAddressRepresentationWithEmailAddress:(id)aAddress;
+ (id)emailAddressRepresentationWithPerson:(id)aPerson;
- (id)description;
- (id)emailAddress;
- (id)person;
- (id)displayName;
- (void)dealloc;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (BOOL)isEqual:(id)aEqual;
- (NSUInteger)hash;
- (id)initWithEmailAddress:(id)aAddress;
- (id)initWithPerson:(id)aPerson;
@end

@interface HSAddressBookEmailTokenFieldController : NSObject <NSTokenFieldDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    NSTokenField *_tokenField;
}
- (id)nameForEmailAddress:(id)aAddress;
- (id)tokenField:(id)aField representedObjectForEditingString:(id)aString;
- (id)tokenField:(id)aField editingStringForRepresentedObject:(id)aObject;
- (id)tokenField:(id)aField displayStringForRepresentedObject:(id)aObject;
- (id)tokenField:(id)aField completionsForSubstring:(id)aSubstring indexOfToken:(NSInteger)aToken indexOfSelectedItem:(int *)aItem;
- (BOOL)control:(id)aControl textShouldBeginEditing:(id)aEditing;
- (id)emailAddresses;
- (void)awakeFromNib;
@end

