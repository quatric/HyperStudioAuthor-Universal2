#import "HSEditObjectDialogNodeSupport.h"

@implementation HSEditObjectDialogNodeSupport

- (id)hyperUID
{
    return [[_originalObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
}

- (id)childInTreeWithUID:(id)aUID
{
    return [[_originalObject queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
}

- (id)childWithUID:(id)aUID
{
    return [[_originalObject queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:aUID];
}

- (id)uniqueNameGenerator
{
    return [[_originalObject queryHyperInterface:@protocol(HSUserObjectSupport)] uniqueNameGenerator];
}

- (id)document
{
    return [[_originalObject queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

- (id)stack
{
    return [[_originalObject queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
}

- (id)card
{
    return [[_originalObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
}

- (id)cardGroupController
{
    return [[_originalObject hyperObject] cardGroupController];
}

- (id)undoManager
{
    return _undoManager;
}

- (void)invalidateUndoManager
{
    [_undoManager release];
    _undoManager = nil;
}

- (void)createUndoManager
{
    _undoManager = [NSUndoManager new];
}

- (id)cardForAction:(id)aAction ofObject:(id)aObject
{
    return [[_originalObject hyperObject] card];
}

- (void)setOriginalObject:(id)aObject
{
    if (_originalObject != aObject) {
        [_originalObject release];
        _originalObject = [aObject retain];
    }
}

- (void)dealloc
{
    [_undoManager release];
    [super dealloc];
}

@end
