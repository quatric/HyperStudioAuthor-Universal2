#import "HSStackCursorsDataSource.h"

@implementation HSStackCursorsDataSource

- (id)cursorAtIndex:(NSUInteger)aIndex
{
    return [[self cursors] objectAtIndex:aIndex];
}

- (NSUInteger)countOfCursors
{
    return [[self cursors] count];
}

- (void)stackObjectsDidChange:(id)aChange
{
    NSArray *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if (removed != nil) {
        NSEnumerator *enumerator = [removed objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil) {
            id attributes = [child queryHyperInterface:@protocol(HSCursorAttribute)];
            id cursor = [attributes hyperCursor];
            if (attributes != nil && cursor != nil)
                [[self cursors] removeObject:cursor];
        }
    } else {
        NSArray *added = [[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"];
        if (added != nil) {
            NSEnumerator *enumerator = [added objectEnumerator];
            id child;
            while ((child = [enumerator nextObject]) != nil) {
                id attributes = [child queryHyperInterface:@protocol(HSCursorAttribute)];
                id cursor = [attributes hyperCursor];
                if (attributes != nil && cursor != nil)
                    [self addCursor:cursor];
            }
        }
    }
}

- (void)addCursor:(id)aCursor
{
    if (![[self cursors] containsObject:aCursor])
        [[self cursors] addObject:aCursor];
}

- (id)cursors
{
    if (_cursors == nil)
        [self updateCursors];
    return _cursors;
}

- (void)HSStackCursorsDataSource_addCursorOfObject:(id)aObject mediaUIDs:(NSMutableArray *)aMediaUIDs
{
    id cursor = [[aObject queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
    if (cursor == nil || [_cursors indexOfObjectIdenticalTo:cursor] != NSNotFound)
        return;
    if ([aMediaUIDs containsObject:[[cursor imageMedia] mediaUID]])
        return;
    [_cursors addObject:cursor];
    if ([cursor imageMedia] != nil)
        [aMediaUIDs addObject:[[cursor imageMedia] mediaUID]];
}

- (void)updateCursors
{
    [_cursors release];
    _cursors = [[NSMutableArray alloc] init];
    if (_stack == nil)
        return;
    NSMutableArray *mediaUIDs = [NSMutableArray new];
    id stackCursor = [[_stack queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
    if (stackCursor != nil) {
        [_cursors addObject:stackCursor];
        if ([stackCursor imageMedia] != nil)
            [mediaUIDs addObject:[[stackCursor imageMedia] mediaUID]];
    }
    NSEnumerator *cards = [[_stack hyperChildren] objectEnumerator];
    id card;
    while ((card = [cards nextObject]) != nil) {
        [self HSStackCursorsDataSource_addCursorOfObject:card mediaUIDs:mediaUIDs];
        NSEnumerator *objects = [card hyperEnumerator];
        id object;
        while ((object = [objects nextObject]) != nil)
            [self HSStackCursorsDataSource_addCursorOfObject:object mediaUIDs:mediaUIDs];
    }
    [mediaUIDs release];
}

- (id)stack
{
    return _stack;
}

- (void)setStack:(id)aStack
{
    if (_stack != aStack) {
        [_stack removeAttributeObserver:self];
        [_stack release];
        _stack = [aStack retain];
        if (_stack != nil)
            [_stack addObserver:self selector:@selector(stackObjectsDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25];
    }
}

- (id)initWithStack:(id)aStack
{
    self = [super init];
    if (self != nil)
        [self setStack:aStack];
    return self;
}

- (void)dealloc
{
    [_stack removeAttributeObserver:self];
    [_stack release];
    [_cursors release];
    [super dealloc];
}

@end
