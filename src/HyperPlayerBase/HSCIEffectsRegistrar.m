#import "HSCIEffectsRegistrar.h"
@implementation HSCIEffectsRegistrar
+ (void)registerObjects
{
    static BOOL registered;
    [HSCINoiseFilter class];
    if (NSClassFromString(@"CIFilter") != nil && !registered) {
        HSCIEffectsRegistrar *registrar = [[[self class] new] autorelease];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:HSCIEffectsCategory]
                                                               forKey:@"HSObjectCategoriesKey"];
        NSEnumerator *enumerator = [[HSCIEffect effectsDescription] keyEnumerator];
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
    return [[[HSCIEffect alloc] initWithName:aName] autorelease];
}
@end
