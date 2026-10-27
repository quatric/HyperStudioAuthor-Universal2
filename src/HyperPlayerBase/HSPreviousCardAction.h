#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSPreviousCardAction : HSChangeCardAction <HSPreviousCardActionAttributes, HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute>
{
}
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)canRunInContext:(id)aContext;
- (BOOL)canGoToHyperDestinationCard;
- (id)createNavigationOperation;
- (NSUInteger)destinationCardIndex;
@end

