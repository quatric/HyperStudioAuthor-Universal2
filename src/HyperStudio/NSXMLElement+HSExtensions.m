#import "NSXMLElement+HSExtensions.h"

@implementation NSXMLElement (HSExtensions)

// The next node in document order with that name.
- (id)hyperElementNamed:(id)aNamed
{
    NSXMLNode *node = self;
    while ((node = [node nextNode]) != nil) {
        if ([[node name] isEqualToString:aNamed])
            return node;
    }
    return nil;
}

@end
