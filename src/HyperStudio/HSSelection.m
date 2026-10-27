#import "HSSelection.h"

@implementation HSSelection

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)notifySelectionDidChange
{
    [self setSelectedObject:nil];
    BOOL wasExpanded = _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification;
    _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification = NO;
    [_owner selectionDidChange:self wasExpanded:wasExpanded];
}

- (void)removeAllObjects
{
    [_objects removeAllObjects];
    [self notifySelectionDidChange];
}

- (void)removeObject:(id)aObject
{
    [_objects removeObject:aObject];
    [self notifySelectionDidChange];
}

- (void)addObject:(id)aObject
{
    [_objects addObject:aObject];
    _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification = YES;
    [self notifySelectionDidChange];
}

- (BOOL)containsObject:(id)aObject
{
    return [_objects containsObject:aObject];
}

- (id)anySelectedObject
{
    id objects = [self objects];
    if ([objects count] > 1)
        return [objects hyperObjectForAnyInterfaces];
    return [objects anyObject];
}

- (id)selectedObject
{
    if (!_selectedObject) {
        id objects = [self objects];
        id object = [objects count] > 1 ? [objects hyperObjectForAllInterfaces] : [objects anyObject];
        [self setSelectedObject:object];
    }
    return _selectedObject;
}

- (void)setSelectedObject:(id)aObject
{
    if (_selectedObject != aObject) {
        [_selectedObject release];
        _selectedObject = [aObject retain];
    }
}

- (id)objectEnumerator
{
    return [_objects objectEnumerator];
}

- (id)objectsArray
{
    return [_objects allObjects];
}

- (NSUInteger)objectsCount
{
    return [_objects count];
}

- (id)objects
{
    return [NSSet setWithSet:_objects];
}

- (void)dealloc
{
    [_objects release];
    [_selectedObject release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _objects = [[NSMutableSet alloc] init];
        if (!_objects) {
            [self release];
            self = nil;
        }
    }
    return self;
}

@end
