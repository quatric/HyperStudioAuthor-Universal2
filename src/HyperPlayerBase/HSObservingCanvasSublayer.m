#import "HSObservingCanvasSublayer.h"

@implementation HSObservingCanvasSublayer

// Marks represented objects that have no canvas item.
+ (id)stubCanvasItem
{
    static id sStub = nil;
    if (sStub == nil)
        sStub = [[NSNull null] retain];
    return sStub;
}

- (void)willUnregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    if ([self activeItem] == aItem)
        [self setActiveItem:nil];
    if ([self invalidatesDisplayUponRegisterUnregister])
        [self invalidateDisplayForCanvasItem:aItem];
}

- (void)didRegisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    if ([self invalidatesDisplayUponRegisterUnregister])
        [self invalidateDisplayForCanvasItem:aItem];
}

- (BOOL)invalidatesDisplayUponRegisterUnregister
{
    return NO;
}

- (void)updateCanvasItemsIfNeeded
{
    [self updateRegisteredCanvasItemsIfNeeded];
}

- (void)updateRegisteredCanvasItemsIfNeeded
{
    NSEnumerator *enumerator = [[self registeredCanvasItems] objectEnumerator];
    id item;
    while ((item = [enumerator nextObject]) != nil)
        [self updateCanvasItemIfNeeded:item];
}

- (void)dereferenceRegisteredCanvasItems:(id)aItems
{
}

- (id)privateRegisteredCanvasItems
{
    if (_itemsByRepresentedObject == nil)
        return nil;
    NSArray *items = NSAllMapTableValues(_itemsByRepresentedObject);
    if (items == nil || ![self storesStubItems])
        return items;
    NSUInteger count = [items count];
    if (count == 0)
        return items;

    // Filter out stubs, copying lazily once the first stub is seen.
    NSMutableArray *filtered = nil;
    for (NSUInteger i = 0; i < count; i++) {
        id item = [items objectAtIndex:i];
        if (item == [[self class] stubCanvasItem]) {
            if (filtered == nil) {
                filtered = [NSMutableArray arrayWithCapacity:count];
                if (i != 0)
                    [filtered replaceObjectsInRange:NSMakeRange(0, 0) withObjectsFromArray:items range:NSMakeRange(0, i)];
            }
        } else if (filtered != nil) {
            [filtered addObject:item];
        }
    }
    return filtered ? filtered : items;
}

- (id)registeredCanvasItems
{
    return [self privateRegisteredCanvasItems];
}

- (id)registeredCanvasItemsByRepresentedObject
{
    if (_itemsByRepresentedObject == nil)
        _itemsByRepresentedObject = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    return _itemsByRepresentedObject;
}

- (void)unregisterAllCanvasItems
{
    if (_itemsByRepresentedObject == nil)
        return;
    NSEnumerator *enumerator = [NSAllMapTableKeys(_itemsByRepresentedObject) objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id item = NSMapGet(_itemsByRepresentedObject, object);
        if (item != [[self class] stubCanvasItem])
            [self willUnregisterCanvasItem:item forRepresentedObject:object];
    }
    NSResetMapTable(_itemsByRepresentedObject);
}

- (void)unregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    [self unregisterExistingCanvasItem:aItem forRepresentedObject:aObject];
}

- (void)unregisterCanvasItem:(id)aItem
{
    [self unregisterExistingCanvasItem:aItem forRepresentedObject:[self representedObjectForCanvasItem:aItem]];
}

- (void)unregisterCanvasItemForRepresentedObject:(id)aObject
{
    id item = NSMapGet([self registeredCanvasItemsByRepresentedObject], aObject);
    if (item != nil)
        [self unregisterExistingCanvasItem:item forRepresentedObject:aObject];
}

- (void)unregisterExistingCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    if ([[self class] stubCanvasItem] != aItem)
        [self willUnregisterCanvasItem:aItem forRepresentedObject:aObject];
    NSMapRemove(_itemsByRepresentedObject, aObject);
}

- (void)registerCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    NSMapInsertKnownAbsent([self registeredCanvasItemsByRepresentedObject], aObject, aItem);
    if ([[self class] stubCanvasItem] != aItem)
        [self didRegisterCanvasItem:aItem forRepresentedObject:aObject];
}

- (id)canvasItemForRepresentedObject:(id)aObject
{
    return [self canvasItemForRepresentedObject:aObject createIfNeeded:YES];
}

- (id)canvasItemForRepresentedObjectIfExists:(id)aExists
{
    return [self canvasItemForRepresentedObject:aExists createIfNeeded:NO];
}

- (id)canvasItemForRepresentedObject:(id)aObject createIfNeeded:(BOOL)aNeeded
{
    id item = NSMapGet([self registeredCanvasItemsByRepresentedObject], aObject);
    if (item == nil && aNeeded) {
        item = [self queryCanvasItemForRepresentedObject:aObject];
        if (item == nil && [self storesStubItems])
            item = [[self class] stubCanvasItem];
        if (item != nil)
            [self registerCanvasItem:item forRepresentedObject:aObject];
    }
    return item != [[self class] stubCanvasItem] ? item : nil;
}

- (id)representedObjectForCanvasItem:(id)aItem
{
    return nil;
}

- (id)queryCanvasItemForRepresentedObject:(id)aObject
{
    return nil;
}

- (id)objectInRepresentedObjectsAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)countOfRepresentedObjects
{
    return 0;
}

- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    return [self canvasItemForRepresentedObject:[self objectInRepresentedObjectsAtIndex:aIndex]];
}

- (BOOL)storesStubItems
{
    return YES;
}

- (NSUInteger)numberOfCanvasItems
{
    return [self countOfRepresentedObjects];
}

- (void)representedObjectDidChange
{
    [self setRootRepresentedObject:[self representedObject]];
}

- (void)setRootRepresentedObject:(id)aObject
{
    if (_rootRepresentedObject == aObject)
        return;
    if (_rootRepresentedObject != nil) {
        [self stopObservingNotificationsFromRootRepresentedObject:_rootRepresentedObject];
        [self unregisterAllCanvasItems];
    }
    [_rootRepresentedObject release];
    _rootRepresentedObject = [aObject retain];
    if (_rootRepresentedObject != nil)
        [self observeNotificationsFromRootRepresentedObject:_rootRepresentedObject];
}

- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject
{
}

- (void)observeNotificationsFromRootRepresentedObject:(id)aObject
{
}

- (void)dealloc
{
    if (_rootRepresentedObject != nil) {
        [self stopObservingNotificationsFromRootRepresentedObject:_rootRepresentedObject];
        [_rootRepresentedObject release];
    }
    [self dereferenceRegisteredCanvasItems:[self privateRegisteredCanvasItems]];
    if (_itemsByRepresentedObject != nil)
        NSFreeMapTable(_itemsByRepresentedObject);
    [super dealloc];
}

@end
