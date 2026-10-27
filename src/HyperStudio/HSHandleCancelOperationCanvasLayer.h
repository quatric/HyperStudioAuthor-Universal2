#import "HyperStudioPrefix.h"


@interface HSHandleCancelOperationCanvasLayer : HSSimpleCanvasSublayer
{
    id _owner;
}
- (void)cancelOperation:(id)aOperation;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (id)initWithOwner:(id)aOwner;
@end

