#import "HyperStudioPrefix.h"


@interface NSObject (HSSelectionHolder)
- (void)getSelectedHyperObject:(id *)aObject orObjects:(id *)aObjects;
- (void)notifyHyperSelectionHolderWantsToResign;
- (void)notifyHyperSelectionHolderReactivate;
- (void)notifyHyperSelectionDidChangeAndActivate:(BOOL)aActivate;
@end

