#import "HSUserObject+FileTypes.h"
@implementation HSUserObject (FileTypes)
+ (id)typesForUserObjectClassName:(id)aName
{
    // the media types whose user classes include aName
    NSMutableArray *types = [NSMutableArray new];
    NSDictionary *classesForTypes = [HSPlayerBaseID extraDictionaryNamed:@"UserClassesForMediaTypes"];
    NSEnumerator *enumerator = [classesForTypes keyEnumerator];
    NSString *type;
    while ((type = [enumerator nextObject]) != nil) {
        if ([[classesForTypes objectForKey:type] containsObject:aName] && ![types containsObject:type])
            [types addObject:type];
    }
    return [types autorelease];
}
@end
