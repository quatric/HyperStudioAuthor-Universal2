#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSForwardAction : HSChangeCardAction <HSForwardActionAttributes, HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute>
{
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)canRunInContext:(id)aContext;
- (void)willConcludeNavigationOperation:(id)aOperation;
- (void)willStartNavigationOperation:(id)aOperation;
- (id)createNavigationOperation;
@end

