#import "HSMaskCIEffectsRegistrar.h"
@implementation HSMaskCIEffectsRegistrar
+ (void)registerObjects
{
    static BOOL registered;
    if (NSClassFromString(@"CIFilter") != nil && !registered) {
        HSMaskCIEffectsRegistrar *registrar = [[[self class] new] autorelease];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:HSMaskCIEffectsCategory]
                                                               forKey:@"HSObjectCategoriesKey"];
        NSEnumerator *enumerator = [[HSMaskCIEffect effectsDescription] keyEnumerator];
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
    return [[[HSMaskCIEffect alloc] initWithName:aName] autorelease];
}
@end
