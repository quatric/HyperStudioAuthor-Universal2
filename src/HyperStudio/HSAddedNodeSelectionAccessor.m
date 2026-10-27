#import "HSAddedNodeSelectionAccessor.h"

@implementation HSAddedNodeSelectionAccessor

+ (id)nodeSelectionAccessorWithObjectsArray:(id)aArray
{
    return [[[self alloc] initWithSelectedObjectsArray:aArray] autorelease];
}

+ (id)nodeSelectionAccessorWithObject:(id)aObject
{
    return [[[self alloc] initWithSelectedObject:aObject] autorelease];
}

- (void)dealloc
{
    [_selectedObject release];
    [super dealloc];
}

- (id)initWithSelectedObjectsArray:(id)aArray
{
    id object = [aArray count] < 2 ? [aArray lastObject] : [aArray hyperObjectForAllInterfaces];
    return [self initWithHyperSelectedObject:object];
}

- (id)initWithSelectedObject:(id)aObject
{
    return [self initWithHyperSelectedObject:aObject];
}

- (id)initWithHyperSelectedObject:(id)aObject
{
    self = [super init];
    if (self != nil && aObject != nil) {
        _selectedObject = [aObject retain];
        id proxy = [_selectedObject hyperAnyProxy];
        if ([proxy queryHyperInterface:@protocol(HSStackAttributes)] != nil)
            _containsStack = YES;
        if ([proxy queryHyperInterface:@protocol(HSCardAttributes)] != nil)
            _containsCards = YES;
        if ([proxy queryHyperInterface:@protocol(HSCardObjectAttributes)] != nil)
            _containsCardObjects = YES;
    }
    return self;
}

- (id)queryHyperInterface:(id)aInterface
{
    id result = [super queryHyperInterface:aInterface];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSStackSelectionAccessor)))
        return _containsStack ? result : nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSCardSelectionAccessor)))
        return _containsCards ? result : nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSCardObjectSelectionAccessor)))
        return _containsCardObjects ? result : nil;
    return result;
}

- (id)selectedHyperObject
{
    return _selectedObject;
}

@end
