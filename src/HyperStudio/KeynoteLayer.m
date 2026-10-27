#import "KeynoteLayer.h"

@implementation KeynoteLayer

// The drawables, with placeholder references replaced by the master's
// placeholders and object references by the objects they name.
- (id)items
{
    id drawables = [self keynoteObjectForXMLPath:@"./drawables"];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[drawables children]];
    NSEnumerator *enumerator = [[drawables children] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        NSString *name = [(KeynoteNode *)child name];
        if ([name hasSuffix:@"placeholder-ref"]) {
            NSString *path = [name substringToIndex:[name length] - 4];
            id placeholder = [[self keynoteObjectForXMLPath:@"../../.."] keynoteObjectForXMLPath:path];
            if (placeholder != nil && [placeholder isKindOfClass:[KeynotePlaceholder class]])
                [items replaceObjectAtIndex:[items indexOfObject:child] withObject:placeholder];
        } else if ([name hasSuffix:@"-ref"]) {
            NSString *reference = [[child nodeAttributes] objectForKey:@"IDREF"];
            id node = [[self keynoteObjectForXMLPath:@"./../../../object-placeholder"] referencedNode];
            if ([[node nodeId] isEqualToString:reference])
                [items replaceObjectAtIndex:[items indexOfObject:child] withObject:node];
        }
    }
    return items;
}

@end
