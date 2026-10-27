#import "HSVisualUserObject.h"
@implementation HSVisualUserObject
- (void)HSVisualUserObject_subobjectWillDidChangeUndoableAttribute:(id)aAttribute
{
    NSDictionary *description = [NSDictionary dictionaryWithObjectsAndKeys:
        aAttribute, @"HSUndoableSubobjectAttributeNotification",
        [[aAttribute object] queryHyperInterface:@protocol(HSNodeChild)], @"HSUndoableSubobject",
        nil];
    NSArray *descriptions = description != nil ? [NSArray arrayWithObject:description] : nil;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        aAttribute, @"HSUnderlyingAttributeNotification",
        descriptions, @"HSUndoableSubobjectChangeDescriptions",
        nil];
    [self notifyChange:[aAttribute attributeChange] ofAttribute:@protocol(HSUndoableSubobjectsAttribute) withUserInfo:userInfo];
}
- (void)HSVisualUserObject_subobjectWillDidChangeVisualAttribute:(id)aAttribute
{
    NSDictionary *description = [NSDictionary dictionaryWithObjectsAndKeys:
        aAttribute, @"HSVisualSubobjectAttributeNotification",
        [[aAttribute object] queryHyperInterface:@protocol(HSNodeChild)], @"HSVisualSubobject",
        nil];
    NSArray *descriptions = description != nil ? [NSArray arrayWithObject:description] : nil;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        aAttribute, @"HSUnderlyingAttributeNotification",
        descriptions, @"HSVisualSubobjectChangeDescriptions",
        nil];
    [self notifyChange:[aAttribute attributeChange] ofAttribute:@protocol(HSVisualSubobjectsAttribute) withUserInfo:userInfo];
}
- (id)children
{
    // Children are observed lazily, from the first time they're asked for.
    id children = [super children];
    if (!_observesChildrenVisualAttributes) {
        _observesChildrenVisualAttributes = YES;
        [self addObserver:self selector:@selector(HSVisualUserObject_subobjectWillDidChangeVisualAttribute:)
                ofChanges:HSActualAttributeChanges | 0xc0 ofChildrenAttribute:@protocol(HSVisualAttribute) withPriority:0];
    }
    if (!_observesChildrenUndoableAttributes) {
        _observesChildrenUndoableAttributes = YES;
        [self addObserver:self selector:@selector(HSVisualUserObject_subobjectWillDidChangeUndoableAttribute:)
                ofChanges:HSActualAttributeChanges ofChildrenAttribute:@protocol(HSUndoableAttribute) withPriority:0];
    }
    return children;
}
- (oneway void)release
{
    // Observing ourselves retains nothing, but the observations must go before the last release.
    if ([self retainCount] == 1) {
        if (_observesChildrenVisualAttributes) {
            [self removeObserver:self selector:@selector(HSVisualUserObject_subobjectWillDidChangeVisualAttribute:)
                       ofChanges:HSActualAttributeChanges | 0xc0 ofChildrenAttribute:@protocol(HSVisualAttribute)];
            _observesChildrenVisualAttributes = NO;
        }
        if (_observesChildrenUndoableAttributes) {
            [self removeObserver:self selector:@selector(HSVisualUserObject_subobjectWillDidChangeUndoableAttribute:)
                       ofChanges:HSActualAttributeChanges ofChildrenAttribute:@protocol(HSUndoableAttribute)];
            _observesChildrenUndoableAttributes = NO;
        }
    }
    [super release];
}
@end
