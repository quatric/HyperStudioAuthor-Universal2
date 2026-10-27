#import "HyperPlayerBasePrefix.h"


@interface HSUserObjectDefaultAttributesProvider : NSObject
{
    Class _baseClass;
    NSDictionary *_loadedDescriptions;
    NSMutableDictionary *_defaultAttributesByClass;
    NSMutableDictionary *_nonLocalizedKeyNamesByClass;
    NSMutableDictionary *_defaultIdentifiersByCustomKeys;
}
+ (NSSize)defaultCardSize;
+ (id)defaultNameForNewlyCreatedTextView;
+ (id)defaultTextForNewlyCreatedRotatableTextObject;
+ (id)defaultTextForNewlyCreatedTextView;
+ (id)defaultFontForNewlyCreatedTextObjects;
+ (id)defaultFontForNewlyCreatedRotatableTextObjects;
+ (id)sharedInstance;
- (id)defaultIdentifierTemplateWithNonLocalizedKindKey:(id)aKey;
- (id)localizedKindNameForKey:(id)aKey;
- (id)defaultIdentifierTemplateForUserObjectClass:(Class)aClass key:(id)aKey;
- (id)localizedKindNameForUserObjectClass:(Class)aClass key:(id)aKey;
- (id)nonLocalizedKindNameForPencilBrushObject;
- (id)nonLocalizedKindNameForVectorGraphicsObjectIfClosed:(BOOL)aClosed straightLineMode:(BOOL)aMode;
- (id)nonLocalizedKindNameForUserObjectClass:(Class)aClass;
- (id)loadDefaultAttributesForClass:(Class)aClass;
- (id)defaultIdentifiersByCustomKeys;
- (id)nonLocalizedKeyNamesByClass;
- (id)defaultAttributesByClass;
- (id)loadedDescriptions;
- (void)setLoadedDescriptions:(id)aDescriptions;
- (void)loadDescriptionsIfNeeded;
- (id)defaultAttributesForUserObjectClassName:(id)aName;
- (id)defaultAttributesForUserObjectClass:(Class)aClass;
- (Class)baseClass;
- (void)setBaseClass:(Class)aClass;
- (void)dealloc;
- (id)init;
@end

