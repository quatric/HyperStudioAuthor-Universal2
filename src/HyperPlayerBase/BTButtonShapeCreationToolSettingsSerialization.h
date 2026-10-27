#import "HyperPlayerBasePrefix.h"
#import "HSSettingsSerialization.h"


@interface BTToolSettingsSerialization : HSSettingsSerialization
{
    NSMutableArray *_medias;
}
+ (struct CGImage *)imageWithData:(id)aData;
+ (struct CGImage *)loadImageAtPath:(id)aPath;
- (id)inputKeyForKey:(id)aKey;
- (id)convertValue:(id)aValue forKey:(id)aKey;
- (void)dealloc;
@end

@interface BTButtonShapeCreationToolSettingsSerialization : BTToolSettingsSerialization
{
}
- (id)inputKeyForKey:(id)aKey;
@end

@interface BTShapeCreationToolSettingsSerialization : BTToolSettingsSerialization
{
}
- (id)inputKeyForKey:(id)aKey;
@end

@interface BTFillToolSettingsSerialization : BTToolSettingsSerialization
{
}
- (id)inputKeyForKey:(id)aKey;
@end

@interface BTEraserToolSettingsSerialization : BTToolSettingsSerialization
{
}
- (id)inputKeyForKey:(id)aKey;
@end

@interface BTBrushToolSettingsSerialization : BTToolSettingsSerialization
{
}
- (id)inputKeyForKey:(id)aKey;
@end

