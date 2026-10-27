#import "HyperStudioPrefix.h"


@interface HSExtraModalController : HSGenericModalController
{
    HSEditObjectDialogContext *_context;
}
- (id)document;
- (id)stack;
- (id)card;
- (void)dealloc;
- (id)initWithContext:(id)aContext;
@end

