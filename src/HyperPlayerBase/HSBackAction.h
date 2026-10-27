#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSBackAction : HSChangeCardAction <HSBackActionAttributes, HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute>
{
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementName;
- (BOOL)canRunInContext:(id)aContext;
- (void)willConcludeNavigationOperation:(id)aOperation;
- (void)willStartNavigationOperation:(id)aOperation;
- (id)createNavigationOperation;
- (BOOL)canGoToHyperDestinationCard;
- (id)cantChangeCardAlertMessage;
- (id)cantChangeCardAlertTitle;
@end

