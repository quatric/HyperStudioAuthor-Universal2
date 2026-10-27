#import "KeynoteListstyle.h"

@implementation KeynoteListstyle

// Label types listed inline or as references to cached ones.
- (id)detailedListLabelTypes
{
    NSArray *children = [[self keynoteObjectForXMLPath:@"./property-map/listLabelTypes/array"] children];
    if (children == nil)
        children = [[self keynoteObjectForXMLPath:@"./property-map/listLabelTypes/mutable-array"] children];
    if (children == nil)
        return nil;
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:[children count]];
    NSEnumerator *enumerator = [children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if ([[(KeynoteObject *)child name] isEqualToString:@"list-label-typeinfo"]) {
            [types addObject:child];
        } else if ([[(KeynoteObject *)child name] isEqualToString:@"list-label-typeinfo-ref"]) {
            id type = [[self cache] objectOfType:@"listLabelType" inCacheForId:[[child nodeAttributes] objectForKey:@"IDREF"]];
            // Original quirk kept: nil when the reference is not cached.
            [types addObject:type];
        }
    }
    return types;
}

// Prefixes every non-empty paragraph with the level's list label.
- (void)applyTo:(id)aTo withStringAttributes:(id)aAttributes listLevel:(NSInteger)aLevel
{
    NSArray *types = [self detailedListLabelTypes];
    NSArray *paragraphs = [[aTo string] componentsSeparatedByString:@"\n"];
    NSUInteger count = [paragraphs count];
    NSUInteger location = 0;
    for (NSUInteger i = 0; i < count; i++) {
        NSString *paragraph = [paragraphs objectAtIndex:i];
        if ([paragraph isEqualToString:@""])
            continue;
        id type = [types objectAtIndex:aLevel];
        [type setTopicsInfo:[self topicsInfo]];
        NSAttributedString *prefix = [type prefixWithStringAttributes:aAttributes listLevel:aLevel];
        if (prefix != nil)
            [aTo insertAttributedString:prefix atIndex:location];
        location += [paragraph length] + [prefix length];
    }
}

- (void)setTopicsInfo:(id)aInfo
{
    _topicsInfo = aInfo;
}

- (id)topicsInfo
{
    return _topicsInfo;
}

@end
