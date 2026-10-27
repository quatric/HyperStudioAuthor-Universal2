#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSBitmapDrawLineToolWrapper : HSBitmapTool
{
}
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)settingsIdentifiers;
@end

