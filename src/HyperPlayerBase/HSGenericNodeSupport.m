#import "HSGenericNodeSupport.h"
// Minimal node support for nodes outside a document: no undo, scripts,
// delegate or card groups. Its "all objects" interface is the one node,
// or a proxy over all of them.

@implementation HSGenericNodeSupport

+ (id)nodeSupport
{
    return [[[self alloc] init] autorelease];
}

+ (id)sharedNodeSupport
{
    static HSGenericNodeSupport *support = nil;
    if (!support)
        support = [[self alloc] init];
    return support;
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}

- (id)cardGroupController
{
    return nil;
}

- (id)delegate
{
    return nil;
}

- (id)scriptController
{
    return nil;
}

- (id)undoManager
{
    return nil;
}

- (void)invalidateAllObjectsProxy
{
    [_allObjectsProxy release];
    _allObjectsProxy = nil;
}

- (id)allObjectsInterface
{
    if ([_nodes count] < 2)
        return [_nodes lastObject];
    return [self allObjectsProxy];
}

- (id)allObjectsProxy
{
    if (!_allObjectsProxy && _nodes)
        _allObjectsProxy = [[[NSArray arrayWithArray:_nodes] hyperObjectForAllInterfaces] retain];
    return _allObjectsProxy;
}

- (void)removeAllNodes
{
    [self invalidateAllObjectsProxy];
    [_nodes makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
    [_nodes removeAllObjects];
}

- (BOOL)removeNode:(id)aNode
{
    if (!_nodes)
        return NO;
    NSUInteger index = [_nodes indexOfObjectIdenticalTo:aNode];
    if (index == NSNotFound)
        return NO;
    [aNode setSupport:nil];
    [self invalidateAllObjectsProxy];
    [_nodes removeObjectAtIndex:index];
    return YES;
}

- (BOOL)addNodeIfSupportIsNeeded:(id)aNeeded
{
    if ([aNeeded support])
        return NO;
    [self addNode:aNeeded];
    return YES;
}

- (void)addNode:(id)aNode
{
    if (!_nodes)
        _nodes = [[NSMutableArray alloc] init];
    [_nodes addObject:aNode];
    [self invalidateAllObjectsProxy];
    [aNode setSupport:self];
}

- (void)dealloc
{
    [_nodes makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
    [_nodes release];
    [_allObjectsProxy release];
    [super dealloc];
}

@end
