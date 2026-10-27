#import "HSTigerEmailTextFieldController.h"

@implementation HSTigerEmailTextFieldController

- (void)setEmailAddresses:(id)aAddresses
{
    NSMutableArray *representations = [NSMutableArray array];
    NSEnumerator *enumerator = [aAddresses objectEnumerator];
    id address;
    while ((address = [enumerator nextObject]))
        [representations addObject:[[[HSEmailAddressRepresentation alloc] initWithEmailAddress:address] autorelease]];
    [_tokenField setObjectValue:representations];
}

- (id)emailAddresses
{
    return [_addresBookEmailTokenFieldController emailAddresses];
}

- (void)awakeFromNib
{
    [[_tokenField cell] setPlaceholderString:@"name@host.com"];
}

@end
