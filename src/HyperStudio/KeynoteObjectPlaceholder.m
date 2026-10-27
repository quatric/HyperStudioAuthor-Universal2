#import "KeynoteObjectPlaceholder.h"

@implementation KeynoteObjectPlaceholder

// A node of the placeholder's content type over the placeholder's object.
- (id)referencedNode
{
    NSString *type = [[self nodeAttributes] objectForKey:@"content-type"];
    if (type == nil)
        return nil;
    KeynoteNode *node = [[[KeynoteTools classForXMLTreeName:type] new] autorelease];
    id object = [self keynoteObjectForXMLPath:@"./object"];
    [node setName:type];
    [node setChildren:[object children]];
    [node setNodeAttributes:[object nodeAttributes]];
    [node setParentNode:self];
    [node setRootNode:[self rootNode]];
    return node;
}

@end
