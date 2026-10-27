#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSGoToURLAction : HSToDoAction <HSGoToURLActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSGoToURLActionTypeAttribute, HSActionOwner>
{
    id _currentAction;
    HSOpenWebPageAction *_openWebPageAction;
    HSSendMailAction *_sendMailAction;
}
+ (id)actionWithURL:(id)aURL;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)isValid;
- (void)validateActionWithNotification:(id)aNotification;
- (id)hyperObjectForAction:(id)aAction;
- (id)openWebPageActionAttributes;
- (id)sendMailActionAttributes;
- (void)setURLType:(NSInteger)aType;
- (NSInteger)URLType;
- (void)startInContext:(id)aContext;
- (void)setCurrentAction:(id)aAction;
- (id)currentAction;
- (id)sendMailAction;
- (id)openWebPageAction;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

