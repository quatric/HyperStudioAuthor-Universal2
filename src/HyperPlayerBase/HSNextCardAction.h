#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSNextCardAction : HSChangeCardAction <HSNextCardActionAttributes, HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute>
{
}
+ (id)nextCardActionWithFadeTransition;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)canRunInContext:(id)aContext;
- (BOOL)canGoToHyperDestinationCard;
- (id)createNavigationOperation;
- (NSUInteger)destinationCardIndex;
@end

