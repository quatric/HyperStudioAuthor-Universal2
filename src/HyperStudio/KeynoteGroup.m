#import "KeynoteGroup.h"

@implementation KeynoteGroup

// The children without the group's own geometry. When a child lies left of
// or above the group's origin, the children are relative to the group.
- (id)items
{
    KeynoteGeometry *geometry = [self geometry];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self children]];
    [items removeObject:geometry];
    NSPoint origin = [geometry origin];
    NSEnumerator *enumerator = [items objectEnumerator];
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        if (![item isKindOfClass:[KeynoteItem class]])
            continue;
        NSPoint itemOrigin = [(KeynoteGeometry *)[item geometry] origin];
        if (origin.x > itemOrigin.x || origin.y > itemOrigin.y) {
            enumerator = [items objectEnumerator];
            while ((item = [enumerator nextObject]) != nil)
                [[item geometry] setParentGeometry:geometry];
            break;
        }
    }
    return items;
}

@end
