#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSVectorDrawingNodeUnit : HSNodeUnit
{
    BTTool *_tool;
    BTToolSettingsSerialization *_toolSettingsWrapper;
}
+ (Class)settingsSerializationClass;
+ (id)createNewTool;
- (id)mediaUIDs;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setting:(id)aSetting didChangeInSerialization:(id)aSerialization;
- (void)setToolSettings:(id)aSettings;
- (void)setToolSettingsWrapper:(id)aWrapper;
- (id)toolSettingsWrapper;
- (id)tool;
- (void)dealloc;
@end

