#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSBitmapFillToolWrapper : HSBitmapTool
{
}
+ (Class)settingsSerializationClass;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)settingsIdentifiers;
@end

