#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSBitmapBrushToolWrapper : HSBitmapTool
{
    HSBrushTouchesStorage *_touchStorage;
    CGRect _brushBounds;
}
+ (Class)settingsSerializationClass;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)settingsIdentifiers;
- (id)bitmapTool;
- (void)dealloc;
- (void)deactivateBitmapTool;
- (BOOL)activateBitmapTool;
@end

