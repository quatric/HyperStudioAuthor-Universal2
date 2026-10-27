#import "HSHandleCancelOperationCanvasLayer.h"

@implementation HSHandleCancelOperationCanvasLayer

- (void)cancelOperation:(id)aSender
{
    if ([_owner respondsToSelector:@selector(handleCancelOperationFromCanvasLayer:)])
        [_owner handleCancelOperationFromCanvasLayer:self];
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (id)initWithOwner:(id)aOwner
{
    self = [super init];
    if (self != nil)
        _owner = aOwner;
    return self;
}

@end
