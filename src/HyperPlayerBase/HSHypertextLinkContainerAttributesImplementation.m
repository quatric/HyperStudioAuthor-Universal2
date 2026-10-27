#import "HSHypertextLinkContainerAttributesImplementation.h"
// Hypertext link container attributes of a node with a links container
// node unit. Finding the link at a text position looks at this
// container's link titles, then up the node's ancestors.

@implementation HSHypertextLinkContainerAttributesImplementation

+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSHypertextLinksContainerNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}

// (The original's walk starts at the node's grandparent; the parent's
// own container is never asked.)
- (id)hypertextLinkAtPosition:(NSUInteger)aPosition inText:(id)aText startPosition:(unsigned int *)aPosition2
{
    id link = [self HSHypertextLinkContainerAttributesImplementation_hypertextLinkAtPosition:aPosition inText:aText startPosition:aPosition2];
    id ancestor = [_node hyperParent];
    while (!link) {
        ancestor = [[ancestor queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
        if (!ancestor)
            break;
        link = [[ancestor queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] hypertextLinkAtPosition:aPosition inText:aText startPosition:aPosition2];
    }
    return link;
}

// Finds a link title (compared case-insensitively) that covers aPosition
// in aText, trying titles in sorted order.
- (id)HSHypertextLinkContainerAttributesImplementation_hypertextLinkAtPosition:(NSUInteger)aPosition inText:(id)aText startPosition:(unsigned int *)aPosition2
{
    NSUInteger textLength = [aText length];
    if (!textLength || textLength <= aPosition) {
        if (aPosition2)
            *aPosition2 = 0x7fffffff;
        return nil;
    }
    id link = nil;
    NSEnumerator *enumerator = [[_nodeUnit allSortedTitles] objectEnumerator];
    NSString *title;
    while (!link && (title = [enumerator nextObject])) {
        NSUInteger titleLength = [title length];
        if (titleLength > textLength)
            continue;
        NSUInteger start = aPosition + 1 >= titleLength ? aPosition + 1 - titleLength : 0;
        NSUInteger last = MIN(textLength - titleLength, aPosition);
        for (; start <= last; start++) {
            if ([aText compare:title options:NSCaseInsensitiveSearch range:NSMakeRange(start, titleLength)] == NSOrderedSame) {
                link = [_nodeUnit linkWithTitle:title];
                if (aPosition2)
                    *aPosition2 = (unsigned int)start;
                break;
            }
        }
    }
    return link;
}

- (void)takeLinkWithTitle:(id)aTitle fromContainer:(id)aContainer
{
    [_nodeUnit takeLinkWithTitle:aTitle fromContainer:aContainer];
}

- (void)renameLinkWithTitle:(id)aTitle to:(id)aTo
{
    [_nodeUnit renameLinkWithTitle:aTitle to:aTo];
}

- (void)removeLinkWithTitle:(id)aTitle
{
    [_nodeUnit removeLinkWithTitle:aTitle];
}

- (id)addLinkWithTitle:(id)aTitle
{
    return [_nodeUnit addLinkWithTitle:aTitle];
}

- (id)linkWithTitle:(id)aTitle
{
    return [_nodeUnit linkWithTitle:aTitle];
}

- (id)allSortedTitles
{
    return [_nodeUnit allSortedTitles];
}

- (id)allLinks
{
    return [_nodeUnit allLinks];
}

- (id)attributeObservingController
{
    return _node;
}

- (id)hyperObject
{
    return _node;
}

- (id)node
{
    return _node;
}

- (void)dealloc
{
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}

- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self) {
        _node = [aNode retain];
        _nodeUnit = [aUnit retain];
    }
    return self;
}

@end
