#import "HSHandleInsertNewlineCanvasLayer.h"

@implementation HSHandleInsertNewlineCanvasLayer

- (void)insertNewline:(id)aSender
{
    if ([_owner respondsToSelector:@selector(handleInsertNewlineFromCanvasLayer:)])
        [_owner handleInsertNewlineFromCanvasLayer:self];
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
