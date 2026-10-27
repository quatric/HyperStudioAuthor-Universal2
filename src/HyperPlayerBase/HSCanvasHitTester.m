#import "HSCanvasHitTester.h"
#import "HSHitTestingCanvasItem.h"
#import "HSProtocolIdentifier.h"
#import "HSView.h"

// Canvas sublayer that hit-tests the user objects under _rootNode through the interface named by _hitTestingInterface.
@implementation HSCanvasHitTester
+ (BOOL)isEditorHitTestingEnabledForInterface:(id)aInterface
{
    return protocol_conformsToProtocol([(HSProtocolIdentifier *)aInterface protocol], @protocol(HSUserObjectEditorHitTesting));
}
// The card bounds in view space; empty when there is no card size to go by.
- (NSRect)HSCanvasHitTester_cardRect
{
    NSRect rect = NSZeroRect;
    HSView *view = [_context renderingView];
    if (_cardSizeAttributes != nil && view != nil) {
        rect.size = [_cardSizeAttributes size];
        rect = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(rect), [view userSpaceToViewSpaceCGAffineTransform]));
    }
    return rect;
}
- (id)representedObject
{
    return [self rootNode];
}
- (void)setRootNode:(id)aNode
{
    if (_rootNode == aNode)
        return;
    [self representedObjectWillChange];
    if (_rootNode != nil) {
        id container = [_rootNode queryHyperInterface:@protocol(HSNodeContainer)];
        [container removeObserver:self selector:@selector(userObjectHitTesterAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSUserObjectHitTesterAttribute)];
        [container removeObserver:self selector:@selector(hiddenAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectHiddenAttribute)];
    }
    [_rootNode autorelease];
    _rootNode = [aNode retain];
    [_cardSizeAttributes release];
    _cardSizeAttributes = nil;
    if (_rootNode != nil) {
        id container = [_rootNode queryHyperInterface:@protocol(HSNodeContainer)];
        [container addObserver:self selector:@selector(userObjectHitTesterAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSUserObjectHitTesterAttribute) withPriority:-0.25];
        [container addObserver:self selector:@selector(hiddenAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectHiddenAttribute) withPriority:-0.25];
        // Interactive hit testing is limited to the card area.
        if ([_hitTestingInterface isEqual:[HSProtocolIdentifier identifierForProtocol:@protocol(HSUserObjectInteractiveHitTesting)]])
            _cardSizeAttributes = [[_rootNode queryHyperInterface:@protocol(HSSizeAttributes)] retain];
    }
    [self representedObjectDidChange];
}
- (id)rootNode
{
    return _rootNode;
}
- (id)queryHyperInterface:(id)aInterface
{
    id result = [super queryHyperInterface:aInterface];
    if (HSProtocolsAreEqual(@protocol(HSCanvasEditorHitTesting), aInterface)
        && ![[self class] isEditorHitTestingEnabledForInterface:_hitTestingInterface])
        result = nil;
    return result;
}
// Nodes hit by aRect, frontmost last.
- (id)hitTestNodesInRect:(NSRect)aRect
{
    if (![[self class] isEditorHitTestingEnabledForInterface:_hitTestingInterface]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    NSRect cardRect = [self HSCanvasHitTester_cardRect];
    if (!NSIsEmptyRect(cardRect))
        aRect = NSIntersectionRect(aRect, cardRect);
    if (NSIsEmptyRect(aRect))
        return nil;
    NSUInteger index = [self numberOfCanvasItems];
    NSMutableArray *nodes = nil;
    while (index != 0) {
        id item = [self hitTestingItemAtIndex:index - 1];
        if ([self hitTestRect:aRect inItem:item]) {
            id node = [item queryHyperInterface:@protocol(HSNodeAttributes)];
            if (node != nil) {
                if (nodes == nil) {
                    nodes = [[NSMutableArray alloc] initWithCapacity:index];
                    [nodes addObject:node];
                } else {
                    [nodes insertObject:node atIndex:0];
                }
            }
        }
        index--;
    }
    NSArray *result = [nodes count] ? [NSArray arrayWithArray:nodes] : nil;
    [nodes release];
    return result;
}
- (BOOL)hasHitTesterForNode:(id)aNode
{
    return [self hitTesterForNode:aNode] != nil;
}
- (id)hitTesterForNode:(id)aNode point:(NSPoint)aPoint
{
    NSRect cardRect = [self HSCanvasHitTester_cardRect];
    if (!NSIsEmptyRect(cardRect) && !NSPointInRect(aPoint, cardRect))
        return nil;
    return [self hitTesterForNode:aNode];
}
- (id)hitTesterForNode:(id)aNode
{
    return [[self hitTestingItemForNode:aNode] hitTester];
}
- (id)hitTestingItemForNode:(id)aNode
{
    return [self canvasItemForNode:aNode];
}
- (id)hitTestingItemAtIndex:(NSUInteger)aIndex
{
    return [self canvasItemAtIndex:aIndex];
}
- (id)hitTestNodeAtPoint:(NSPoint)aPoint
{
    NSRect cardRect = [self HSCanvasHitTester_cardRect];
    if (!NSIsEmptyRect(cardRect) && !NSPointInRect(aPoint, cardRect))
        return nil;
    return [[self hitTestItem:aPoint] queryHyperInterface:@protocol(HSNodeAttributes)];
}
- (id)queryCanvasItemForNode:(id)aNode
{
    id hitTester = [aNode queryHyperInterface:[_hitTestingInterface protocol]];
    if (hitTester == nil)
        return nil;
    return [[[HSHitTestingCanvasItem alloc] initWithHitTester:hitTester] autorelease];
}
- (void)userObjectHitTesterAttributeDidChange:(id)aChange
{
    id node = [[aChange object] queryHyperInterface:@protocol(HSNodeAttributes)];
    if (node != nil)
        [self unregisterCanvasItemForNode:node];
}
- (void)renderRect:(NSRect)aRect
{
}
- (void)invalidateDisplay
{
}
- (BOOL)supportsHitTesting
{
    return YES;
}
- (id)context
{
    return _context;
}
- (void)setCanvasLayerContext:(id)aContext
{
    if (_context == aContext)
        return;
    [self contextWillChange];
    _context = aContext;
    [self contextDidChange];
}
- (id)hitTestingInterface
{
    return [[_hitTestingInterface retain] autorelease];
}
- (void)setHitTestingInterface:(id)aInterface
{
    if ([_hitTestingInterface isEqual:aInterface])
        return;
    [_hitTestingInterface release];
    _hitTestingInterface = [aInterface retain];
    [self unregisterAllCanvasItems];
}
- (void)hiddenAttributeDidChange:(id)aChange
{
    id node = [[aChange object] queryHyperInterface:@protocol(HSNodeAttributes)];
    if (node != nil)
        [self unregisterCanvasItemForRepresentedObject:node];
}
- (void)dealloc
{
    if (_rootNode != nil) {
        id container = [_rootNode queryHyperInterface:@protocol(HSNodeContainer)];
        [container removeObserver:self selector:@selector(userObjectHitTesterAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSUserObjectHitTesterAttribute)];
        [container removeObserver:self selector:@selector(hiddenAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectHiddenAttribute)];
    }
    [_hitTestingInterface release];
    [_rootNode release];
    [_cardSizeAttributes release];
    [super dealloc];
}
- (id)init
{
    return [self initWithHitTestingInterface:nil];
}
- (id)initWithHitTestingInterface:(id)aInterface
{
    self = [super init];
    if (self != nil)
        _hitTestingInterface = [aInterface retain];
    return self;
}
@end
