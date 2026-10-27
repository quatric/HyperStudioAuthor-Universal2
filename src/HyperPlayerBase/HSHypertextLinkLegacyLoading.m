#import "HSHypertextLinkLegacyLoading.h"
@implementation HSHypertextLinkLegacyLoading
+ (id)loaderWithHyperObject:(id)aObject
{
    HSHypertextLinkLegacyLoading *loader = nil;
    if (aObject != nil) {
        loader = [[self class] new];
        loader->_hyperObject = aObject;     // not retained
    }
    return [loader autorelease];
}
- (id)reloadExtraDictionaryRepresentation:(id)aRepresentation
{
    // links of old documents: {actor, title} dictionaries
    id container = [_hyperObject unitForRole:@"HypertextLinks Container Unit"];
    NSArray *links = [aRepresentation objectForKey:[@"links" extraKeyForCollection]];
    NSUInteger count = [links count];
    for (NSUInteger i = 0; i < count; i++) {
        NSDictionary *link = [links objectAtIndex:i];
        HSActor *actor = [HSActor objectWithExtraDictionary:[link objectForKey:@"actor"]];
        [container addLinkWithTitle:[link objectForKey:@"title"] actor:actor];
    }
    return self;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
@end
