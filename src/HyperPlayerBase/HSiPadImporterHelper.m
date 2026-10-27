#import "HSiPadImporterHelper.h"
@implementation HSiPadImporterHelper
+ (id)cardObjectClassNameForIPadObjectName:(id)aName
{
    static NSDictionary *classNames;
    if (classNames == nil)
        classNames = [[NSDictionary extraDictionaryNamed:@"CardObjectsByIPadObjectNames.plist"] retain];
    return [classNames objectForKey:aName];
}
+ (id)actionClassNameForIPadActionName:(id)aName
{
    static NSDictionary *classNames;
    if (classNames == nil)
        classNames = [[NSDictionary extraDictionaryNamed:@"ActionClassesByIPadActions.plist"] retain];
    return [classNames objectForKey:aName];
}
@end
