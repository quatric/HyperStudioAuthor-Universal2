#import "HSQTEffectRegistrar.h"
@implementation HSQTEffectRegistrar
+ (void)registerObjects
{
    static BOOL registered;
    if (!registered) {
        HSQTEffectRegistrar *registrar = [[[self class] new] autorelease];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:HSQTEffectsCategory]
                                                               forKey:@"HSObjectCategoriesKey"];
        NSEnumerator *enumerator = [[HSQTEffect effectsDescription] keyEnumerator];
        NSString *name;
        while ((name = [enumerator nextObject]) != nil)
            [HSEffect registerEffectName:name constructor:registrar classAttributes:attributes];
        registered = YES;
    }
}
+ (void)load
{
    [HSEffect registerRegistrar:self];
}
- (id)objectWithName:(id)aName
{
    return [[[HSQTEffect alloc] initWithName:aName] autorelease];
}
@end
