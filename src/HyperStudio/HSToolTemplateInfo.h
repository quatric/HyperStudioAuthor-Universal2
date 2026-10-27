#import "HyperStudioPrefix.h"


@interface HSToolTemplateInfo : NSObject
{
    id _template;
    NSDictionary *_templateDictionary;
    id _previewPrototype;
    NSImage *_previewImage;
    NSImage *_samplePreviewImage;
    NSString *_displayName;
    NSString *_localizedDisplayName;
    NSString *_styleString;
}
- (void)setStyleString:(id)aString;
- (id)styleString;
- (void)setLocalizedDisplayName:(id)aName;
- (id)localizedDisplayName;
- (void)setDisplayName:(id)aName;
- (id)displayName;
- (void)setSamplePreviewImage:(id)aImage;
- (id)samplePreviewImage;
- (void)setPreviewImage:(id)aImage;
- (id)previewImage;
- (void)setPreviewPrototype:(id)aPrototype;
- (id)previewPrototype;
- (void)setTemplateDictionary:(id)aDictionary;
- (id)templateDictionary;
- (id)template;
- (id)initWithTemplate:(id)aTemplate;
- (void)dealloc;
@end

@interface HSCreationToolSettingsProvider : NSObject
{
    NSDictionary *_toolSettings;
    NSMutableDictionary *_prototypesByIdentifier;
    NSMutableDictionary *_toolTemplatesByIdentifier;
}
+ (id)pathForResourceOfType:(id)aType forToolIdentifier:(id)aIdentifier;
+ (id)pathForResourceOfType:(id)aType forToolIdentifier:(id)aIdentifier resourceName:(id *)aName;
+ (id)updatedHeadlineTemplateDictionary:(id)aDictionary displayName:(id *)aName;
+ (id)updatedShapeTemplateDictionary:(id)aDictionary displayName:(id *)aName;
+ (id)updatedTemplateDictionary:(id)aDictionary withPatternMatchingNodeSelector:(SEL)aSelector backgroundSerializationKey:(id)aKey displayName:(id *)aName;
+ (id)modifyBackgroundDescription:(id)aDescription withPatternName:(id)aName patternMatchingNode:(id)aNode serializationKey:(id)aKey;
+ (id)patternMatchingHeadline;
+ (id)patternMatchingShape;
+ (id)loadTemplateFonts;
+ (id)defaultFontForTextObject;
+ (id)sharedInstance;
- (NSUInteger)indexOfTemplateMatchingPrototype:(id)aPrototype forToolIdentifier:(id)aIdentifier;
- (id)localizedStyleStringForTemplateAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier;
- (id)localizedNameForTemplateAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier;
- (id)localizedStyleStringWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier;
- (id)localizedStyleStringWithPrototypeObject:(id)aObject forToolIdentifier:(id)aIdentifier;
- (id)localizedNameWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier;
- (id)templatePreviewImageForPrototype:(id)aPrototype;
- (id)previewImageWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier;
- (id)cachedPreviewPrototypeWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier;
- (id)previewPrototypeWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier;
- (id)attributedStringForTextToolWithTemplate:(id)aTemplate;
- (id)loadTemplateDictionaryWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier displayName:(id *)aName;
- (id)templateDictionaryWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier;
- (id)previewPrototypeAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier;
- (id)templatePreviewImageAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier;
- (id)templateDictionaryAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier;
- (NSUInteger)countOfTemplatesForToolIdentifier:(id)aIdentifier;
- (id)templateInfoAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier;
- (id)toolTemplatesForToolIdentifier:(id)aIdentifier;
- (id)loadToolTemplatesForToolIdentifier:(id)aIdentifier;
- (id)toolTemplatesByIdentifier;
- (id)previewPrototypeForToolIdentifier:(id)aIdentifier;
- (id)userObjectPrototypeForToolIdentifier:(id)aIdentifier;
- (id)prototypesByIdentifier;
- (id)loadUserObjectPrototypeForToolIdentifier:(id)aIdentifier;
- (id)loadUserObjectPrototypeWithTemplateDictionary:(id)aDictionary forToolIdentifier:(id)aIdentifier;
- (id)toolSettings;
- (void)dealloc;
- (id)init;
@end

