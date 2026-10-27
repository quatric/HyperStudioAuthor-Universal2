#import "HyperStudioPrefix.h"


@interface HSToolSettings : NSObject <HSToolAttributes, HSToolTextColorAttribute, HSToolDrawColorAttribute, HSToolFillColorAttribute, HSToolEraserColorAttribute, HSToolStrokeWidthAttribute, HSToolSizeAttribute, HSToolEraserSizeAttribute, HSToolShapeStyleAttributes, HSToolEffectIntencityAttribute, HSToolCursorContourAttribute, HSTextToolShadowAttribute, HSToolAlternateProportionAttribute>
{
    NSMutableDictionary *_data;
    NSMutableDictionary *_additionalPrototypesByToolIdentifier;
    NSMutableDictionary *_additionalPrototypeSetsByToolIdentifier;
}
+ (id)standardSetsNames;
- (void)removeUserObjectPrototype:(id)aPrototype forTool:(id)aTool;
- (void)addUserObjectPrototype:(id)aPrototype forTool:(id)aTool;
- (void)updateObjectPrototypeForToolIdentifier:(id)aIdentifier;
- (void)setAlternateProportion:(CGFloat)aProportion;
- (CGFloat)alternateProportion;
- (void)setTextShadowEnabled:(BOOL)aEnabled;
- (void)setFlatTextShadowEnabled:(BOOL)aEnabled;
- (BOOL)textShadowEnabled;
- (BOOL)flatTextShadowEnabled;
- (void)setShouldUseCursorContours:(CGFloat)aContours;
- (CGFloat)shouldUseCursorContours;
- (void)setEffectIntencity:(CGFloat)aIntencity;
- (CGFloat)effectIntencity;
- (void)setShouldFillShapes:(BOOL)aShapes;
- (BOOL)shouldFillShapes;
- (void)setShouldStrokeShapes:(BOOL)aShapes;
- (BOOL)shouldStrokeShapes;
- (void)setStrokeWidth:(CGFloat)aWidth;
- (CGFloat)strokeWidth;
- (void)setEraserSize:(NSSize)aSize;
- (NSSize)eraserSize;
- (void)setSizeRatio:(CGFloat)aRatio;
- (CGFloat)sizeRatio;
- (void)setEraserColor:(id)aColor;
- (id)eraserColor;
- (void)setFillColor:(id)aColor;
- (id)fillColor;
- (void)setDrawColor:(id)aColor;
- (id)drawColor;
- (void)setTextColor:(id)aColor;
- (id)textColor;
- (void)resetColorsToDefault;
- (void)saveToolsSettingsToDefaults;
- (id)userObjectPrototypeForTool:(id)aTool;
- (id)primaryUserObjectPrototypeForTool:(id)aTool;
- (id)primaryUserObjectPrototypeForToolIdentifier:(id)aIdentifier;
- (id)settingForIdentifier:(id)aIdentifier andKey:(id)aKey;
- (void)setSetting:(id)aSetting forIdentifier:(id)aIdentifier andKey:(id)aKey;
- (id)mutableSettingDictionaryForKey:(id)aKey;
- (id)settings;
- (id)defaults;
- (id)settingsSetForName:(id)aName toolIdentifier:(id)aIdentifier index:(NSInteger)aIndex;
- (id)dictionaryWithName:(id)aName objectClass:(Class)aClass;
- (BOOL)processIdentifier:(id)aIdentifier inDictionary:(id)aDictionary;
- (void)applySettingsForTool:(id)aTool templateIndex:(NSInteger)aIndex setsNames:(id)aNames;
- (void)applySettingsForTool:(id)aTool templateIndex:(NSInteger)aIndex;
- (void)applySettingsForTool:(id)aTool;
- (id)settingsForTool:(id)aTool templateIndex:(NSInteger)aIndex setsNames:(id)aNames;
- (id)settingsForTool:(id)aTool templateIndex:(NSInteger)aIndex;
- (id)settingsForTool:(id)aTool;
- (NSInteger)appliedTemplateIndexForTool:(id)aTool;
- (id)imageForTemplateAtIndex:(NSUInteger)aIndex forTool:(id)aTool;
- (id)templateDictionaryAtIndex:(NSUInteger)aIndex forTool:(id)aTool;
- (NSUInteger)countOfTemplatesForTool:(id)aTool;
- (void)dealloc;
@end

