#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSBitmapPencilToolWrapper : HSBitmapTool
{
}
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)settingsIdentifiers;
@end

