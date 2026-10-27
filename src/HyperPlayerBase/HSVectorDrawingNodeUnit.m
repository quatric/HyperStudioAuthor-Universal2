#import "HSVectorDrawingNodeUnit.h"
// A node unit drawn with a paint tool (subclasses pick the tool): the tool's
// settings are stored through a settings serialization wrapper, whose changes
// are pushed into the tool.
@implementation HSVectorDrawingNodeUnit
+ (Class)settingsSerializationClass
{
    return [BTBrushToolSettingsSerialization class];
}
+ (id)createNewTool
{
    return nil;
}
- (id)mediaUIDs
{
    return [_toolSettingsWrapper mediaUIDs];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"toolSettingsWrapper"];
}
- (void)setting:(id)aSetting didChangeInSerialization:(id)aSerialization
{
    if (_tool != nil)
        [_tool setInputs:[_toolSettingsWrapper toolInputs]];
}
- (void)setToolSettings:(id)aSettings
{
    [_toolSettingsWrapper setDelegate:nil];
    [_toolSettingsWrapper release];
    _toolSettingsWrapper = [[[self class] settingsSerializationClass] new];
    [_toolSettingsWrapper setDelegate:self];
    [_toolSettingsWrapper setSettings:aSettings];
    if (_tool != nil)
        [_tool setInputs:[_toolSettingsWrapper toolInputs]];
}
- (void)setToolSettingsWrapper:(id)aWrapper
{
    if (_toolSettingsWrapper == aWrapper)
        return;
    [_toolSettingsWrapper setDelegate:nil];
    [_toolSettingsWrapper release];
    _toolSettingsWrapper = [aWrapper retain];
    [_toolSettingsWrapper setDelegate:self];
    if (_tool != nil)
        [_tool setInputs:[_toolSettingsWrapper toolInputs]];
}
- (id)toolSettingsWrapper
{
    return _toolSettingsWrapper;
}
// Created on demand, without the settings' display name.
- (id)tool
{
    if (_tool == nil) {
        _tool = [[self class] createNewTool];
        NSMutableDictionary *inputs = [NSMutableDictionary dictionaryWithDictionary:[_toolSettingsWrapper toolInputs]];
        [inputs removeObjectForKey:@"displayName"];
        [_tool setInputs:inputs];
    }
    return _tool;
}
- (void)dealloc
{
    [_tool release];
    [_toolSettingsWrapper release];
    [super dealloc];
}
@end
