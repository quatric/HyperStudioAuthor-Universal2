#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSendMailAction : HSToDoAction <HSSendMailActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSEmailAddressesAttribute, HSURLAttribute, HSEmailSubjectAttribute, HSMutableURLAttributes>
{
    NSURL *_URL;
    HSError *_error;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)isValid;
- (id)URLStringForEmailAddresses:(id)aAddresses;
- (id)URLAddressStringForEmailAddresses:(id)aAddresses;
- (BOOL)isEmailAddressValid:(id)aValid;
- (id)hyperInvalidEmailAddressError;
- (void)setHyperEmailSubject:(id)aSubject;
- (id)hyperEmailSubject;
- (void)setHyperEmailAddresses:(id)aAddresses;
- (void)setHyperEmailAddress:(id)aAddress;
- (id)hyperEmailAddresses;
- (id)hyperEmailAddress;
- (void)startInContext:(id)aContext;
- (id)error;
- (void)setEmailSubject:(id)aSubject;
- (id)emailSubject;
- (void)setEmailAddress:(id)aAddress;
- (void)setEmailAddresses:(id)aAddresses;
- (id)emailAddress;
- (id)emailAddresses;
- (void)setURL:(id)aURL;
- (id)URL;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

