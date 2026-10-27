#import "EXBundleID.h"
// The bundle of the class (or a subclass) and its resources.
@implementation EXBundleID
+ (BOOL)loadNibNamed:(id)aNamed owner:(id)aOwner
{
    NSZone *zone = [aOwner zone];
    NSDictionary *table = [NSDictionary dictionaryWithObject:aOwner forKey:@"NSOwner"];
    if ([[self bundle] loadNibFile:aNamed externalNameTable:table withZone:zone])
        return YES;
    return [NSBundle loadNibNamed:aNamed owner:aOwner];
}
+ (id)localizedString:(id)aString fromTable:(id)aTable
{
    return [[self bundle] localizedStringForKey:aString value:@"" table:aTable];
}
+ (id)localizedString:(id)aString
{
    return [[self bundle] localizedStringForKey:aString value:@"" table:nil];
}
+ (id)extraDictionaryNamed:(id)aNamed
{
    return [NSDictionary extraDictionaryNamed:aNamed inBundle:[self bundle]];
}
+ (id)identifier
{
    return [[self bundle] bundleIdentifier];
}
+ (NSUInteger)signature
{
    return [[[self infoDictionary] objectForKey:@"CFBundleSignature"] extraFourCharCode];
}
+ (id)infoDictionary
{
    return [[self bundle] infoDictionary];
}
+ (id)bundle
{
    return [NSBundle bundleForClass:self];
}
@end
