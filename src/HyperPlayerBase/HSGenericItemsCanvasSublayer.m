#import "HSGenericItemsCanvasSublayer.h"
// Canvas sublayer holding a list of canvas items. Each item's will/did
// change notifications invalidate its display.

static NSString *const HSGenericCanvasItemWillChangeNotification = @"HSGenericCanvasItemWillChangeNotification";
static NSString *const HSGenericCanvasItemDidChangeNotification = @"HSGenericCanvasItemDidChangeNotification";

@implementation HSGenericItemsCanvasSublayer

- (void)canvasItemWillOrDidChange:(id)aChange
{
    [self invalidateDisplayForCanvasItem:[aChange object]];
}

- (void)setCursorIdentifier:(id)aIdentifier
{
    if (![_cursorIdentifier isEqualToString:aIdentifier]) {
        [_cursorIdentifier release];
        _cursorIdentifier = [aIdentifier retain];
    }
}

- (id)cursorIdentifier
{
    return _cursorIdentifier;
}

- (void)willRemoveCanvasItem:(id)aItem
{
    [self invalidateDisplayForCanvasItem:aItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSGenericCanvasItemWillChangeNotification object:aItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSGenericCanvasItemDidChangeNotification object:aItem];
}

- (void)didAddCanvasItem:(id)aItem
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasItemWillOrDidChange:) name:HSGenericCanvasItemWillChangeNotification object:aItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasItemWillOrDidChange:) name:HSGenericCanvasItemDidChangeNotification object:aItem];
    [self invalidateDisplayForCanvasItem:aItem];
}

- (void)removeAllCanvasItems
{
    NSEnumerator *enumerator = [_canvasItems objectEnumerator];
    id item;
    while ((item = [enumerator nextObject])) {
        [self invalidateDisplayForCanvasItem:item];
        [self willRemoveCanvasItem:item];
    }
    [_canvasItems removeAllObjects];
}

- (void)removeCanvasItem:(id)aItem
{
    if (!_canvasItems)
        return;
    NSUInteger index = [_canvasItems indexOfObjectIdenticalTo:aItem];
    if (index == NSNotFound)
        return;
    [self invalidateDisplayForCanvasItem:aItem];
    [self willRemoveCanvasItem:aItem];
    [_canvasItems removeObjectAtIndex:index];
}

- (void)addCanvasItem:(id)aItem
{
    [[self mutableCanvasItems] addObject:aItem];
    [self didAddCanvasItem:aItem];
    [self invalidateDisplayForCanvasItem:aItem];
}

- (id)canvasItems
{
    return _canvasItems ? _canvasItems : [NSArray array];
}

- (id)mutableCanvasItems
{
    if (!_canvasItems)
        _canvasItems = [NSMutableArray new];
    return _canvasItems;
}

- (void)setSupportsHitTesting:(BOOL)aTesting
{
    _supportsHitTesting = aTesting;
}

- (BOOL)supportsHitTesting
{
    return _supportsHitTesting;
}

- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    return [_canvasItems objectAtIndex:aIndex];
}

- (NSUInteger)numberOfCanvasItems
{
    return [_canvasItems count];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_canvasItems removeAllObjects];
    [_canvasItems release];
    [_cursorIdentifier release];
    [super dealloc];
}

@end
