#import "HSToolTemplateInfo.h"
static id sPatternMatchingShape;
static id sMissingPrototypeMarker;
static id sDAT_003429b8;
static id sDAT_003429c4;

static id sDAT_003429b8;
static id sDAT_003429c4;


@implementation HSToolTemplateInfo

/* i386 ivar offsets: _template=0x4, _templateDictionary=0x8, _previewPrototype=0xc, _previewImage=0x10, _samplePreviewImage=0x14, _displayName=0x18, _localizedDisplayName=0x1c, _styleString=0x20 */

- (void)setStyleString:(id)aString
{
    if (_styleString != aString) {
        [_styleString release];
        _styleString = [aString retain];
    }
}

- (id)styleString
{
    return _styleString;
}

- (void)setLocalizedDisplayName:(id)aName
{
    if (_localizedDisplayName != aName) {
        [_localizedDisplayName release];
        _localizedDisplayName = [aName retain];
    }
}

- (id)localizedDisplayName
{
    return _localizedDisplayName;
}

- (void)setDisplayName:(id)aName
{
    if (_displayName != aName) {
        [_displayName release];
        _displayName = [aName retain];
    }
}

- (id)displayName
{
    return _displayName;
}

- (void)setSamplePreviewImage:(id)aImage
{
    if (_samplePreviewImage != aImage) {
        [_samplePreviewImage release];
        _samplePreviewImage = [aImage retain];
    }
}

- (id)samplePreviewImage
{
    return _samplePreviewImage;
}

- (void)setPreviewImage:(id)aImage
{
    if (_previewImage != aImage) {
        [_previewImage release];
        _previewImage = [aImage retain];
    }
}

- (id)previewImage
{
    return _previewImage;
}

- (void)setPreviewPrototype:(id)aPrototype
{
    if (_previewPrototype != aPrototype) {
        [_previewPrototype release];
        _previewPrototype = [aPrototype retain];
    }
}

- (id)previewPrototype
{
    return _previewPrototype;
}

- (void)setTemplateDictionary:(id)aDictionary
{
    if (_templateDictionary != aDictionary) {
        [_templateDictionary release];
        _templateDictionary = [aDictionary retain];
    }
}

- (id)templateDictionary
{
    return _templateDictionary;
}

- (id)template
{
    return _template;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00192670 @ 00192670, 89 bytes * /

id FUN_00192670(HSToolTemplateInfo *self,SEL _cmd,id initWithTemplate)

{
  id pvVar1;
  id pvVar2;
  HSToolTemplateInfo *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_00352970;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithTemplate,sel_retain);
    *(id *)((int)pvVar1 + 4) = pvVar2;
  }
  return pvVar1;
}

*/
- (id)initWithTemplate:(id)aTemplate
{
    self = [super init];
    if (self != nil) {
        _template = [aTemplate retain];
    }
    return self;
}

- (void)dealloc
{
    [_template release];
    [_templateDictionary release];
    [_previewPrototype release];
    [_previewImage release];
    [_samplePreviewImage release];
    [_displayName release];
    [_styleString release];
    [super dealloc];
}

@end

@implementation HSCreationToolSettingsProvider

/* i386 ivar offsets: _toolSettings=0x4, _prototypesByIdentifier=0x8, _toolTemplatesByIdentifier=0xc */

+ (id)pathForResourceOfType:(id)aType forToolIdentifier:(id)aIdentifier
{
    return [self pathForResourceOfType:aType forToolIdentifier:aIdentifier resourceName:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018fbba @ 0018fbba, 413 bytes * /

id FUN_0018fbba(id self,SEL _cmd,id pathForResourceOfType,id forToolIdentifier,id *resourceName)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined4 local_14;
  
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pvVar2 = pathForResourceOfType;
  local_14 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,forToolIdentifier,
                           pathForResourceOfType);
  if (local_14 == (id)0x0) {
    uVar4 = *(undefined4 *)PTR_PTR_003362b8;
    pvVar3 = _objc_msgSend(forToolIdentifier,sel_isEqual_,uVar4,pvVar2);
    puVar1 = cls_NSBundle;
    if ((char)pvVar3 != '\0') {
      forToolIdentifier = *(id *)PTR_PTR_003362f4;
      pvVar2 = _objc_msgSend(self,sel_class,uVar4,pvVar2);
      pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      pvVar2 = pathForResourceOfType;
      local_14 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,forToolIdentifier,
                               pathForResourceOfType);
    }
  }
  puVar1 = cls_HSToolManager;
  if (local_14 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,forToolIdentifier,pvVar2);
    pvVar3 = _objc_msgSend(puVar1,sel_toolClassForTag_,pvVar2);
    if (pvVar3 == (id)0x0) {
      forToolIdentifier = (id)0x0;
    }
    else {
      forToolIdentifier = (id)_NSStringFromClass(pvVar3);
      puVar1 = cls_NSBundle;
      pvVar2 = _objc_msgSend(self,sel_class,pvVar2);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      local_14 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,forToolIdentifier,
                               pathForResourceOfType);
      if (local_14 == (id)0x0) {
        forToolIdentifier = (id)0x0;
      }
    }
  }
  if (resourceName != (id *)0x0) {
    *resourceName = forToolIdentifier;
  }
  return local_14;
}

*/
+ (id)pathForResourceOfType:(id)aType forToolIdentifier:(id)aIdentifier resourceName:(id *)aName
{
    id resourceName = aIdentifier;
    id path = [[NSBundle bundleForClass:[self class]] pathForResource:resourceName ofType:aType];

    if (path == nil && [resourceName isEqual:@"HSPolygonTool"]) {
        resourceName = @"HSShapeTool";
        path = [[NSBundle bundleForClass:[self class]] pathForResource:resourceName ofType:aType];
    }
    if (path == nil) {
        Class toolClass = [HSToolManager toolClassForTag:[HSToolManager toolTagForIdentifier:resourceName]];
        if (toolClass == Nil) {
            resourceName = nil;
        }
        else {
            resourceName = NSStringFromClass(toolClass);
            path = [[NSBundle bundleForClass:[self class]] pathForResource:resourceName ofType:aType];
            if (path == nil) {
                resourceName = nil;
            }
        }
    }
    if (aName != NULL) {
        *aName = resourceName;
    }
    return path;
}

+ (id)updatedHeadlineTemplateDictionary:(id)aDictionary displayName:(id *)aName
{
    return [self updatedTemplateDictionary:aDictionary withPatternMatchingNodeSelector:@selector(patternMatchingHeadline) backgroundSerializationKey:[HSHeadlineObject backgroundAttributesSerializationKey] displayName:aName];
}

+ (id)updatedShapeTemplateDictionary:(id)aDictionary displayName:(id *)aName
{
    return [self updatedTemplateDictionary:aDictionary withPatternMatchingNodeSelector:@selector(patternMatchingShape) backgroundSerializationKey:[HSVectorGraphicsObject backgroundAttributesSerializationKey] displayName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018fe0f @ 0018fe0f, 568 bytes * /

id FUN_0018fe0f(id self,SEL _cmd,id updatedTemplateDictionary,SEL withPatternMatchingNodeSelector,
               id backgroundSerializationKey,id *displayName)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  cfstringStruct *self_01;
  cfstringStruct *pcVar5;
  id pvVar6;
  
  pvVar1 = _objc_msgSend(updatedTemplateDictionary,sel_objectForKey_,&cfstr_HSToolBackgroundPattern)
  ;
  pcVar5 = &cfstr_HSToolTemplateDisplayName;
  pvVar2 = _objc_msgSend(updatedTemplateDictionary,sel_objectForKey_,
                         &cfstr_HSToolTemplateDisplayName);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  if (pvVar1 != (id)0x0 || pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc,pcVar5);
    self_00 = _objc_msgSend(pvVar3,sel_init);
    pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
    pvVar3 = updatedTemplateDictionary;
    self_01 = _objc_msgSend(pvVar4,sel_initWithDictionary_,updatedTemplateDictionary);
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_retain,pvVar3);
      _objc_msgSend(pvVar3,sel_autorelease);
      _objc_msgSend(self_01,sel_removeObjectForKey_,&cfstr_HSToolBackgroundPattern);
      pvVar3 = _objc_msgSend(updatedTemplateDictionary,sel_objectForKey_,backgroundSerializationKey)
      ;
      pvVar4 = _objc_msgSend(self,sel_performSelector_,withPatternMatchingNodeSelector);
      if (pvVar4 != (id)0x0) {
        pvVar6 = backgroundSerializationKey;
        pvVar1 = _objc_msgSend(self,
                               sel_modifyBackgroundDescription_withPatternName_patternMatchingNode_serializationKey_
                               ,pvVar3,pvVar1,pvVar4,backgroundSerializationKey);
        if ((pvVar1 != pvVar3) && (pvVar1 != (id)0x0)) {
          _objc_msgSend(self_01,sel_setObject_forKey_,pvVar1,backgroundSerializationKey,pvVar4,
                        pvVar6);
        }
      }
    }
    _objc_msgSend(self_01,sel_removeObjectForKey_,&cfstr_HSToolTemplateDisplayName);
    _objc_msgSend(self_00,sel_release);
    pcVar5 = self_01;
    updatedTemplateDictionary =
         _objc_msgSend(cls_NSDictionary,sel_dictionaryWithDictionary_,self_01);
    _objc_msgSend(self_01,sel_release);
  }
  _objc_msgSend(pvVar2,sel_autorelease,pcVar5);
  if (displayName != (id *)0x0) {
    *displayName = pvVar2;
  }
  return updatedTemplateDictionary;
}

*/
+ (id)updatedTemplateDictionary:(id)aDictionary withPatternMatchingNodeSelector:(SEL)aSelector backgroundSerializationKey:(id)aKey displayName:(id *)aName
{
    id patternName = [aDictionary objectForKey:@"HSToolBackgroundPattern"];
    id displayName = [aDictionary objectForKey:@"HSToolTemplateDisplayName"];

    if (patternName != nil || displayName != nil) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:aDictionary];
        if (patternName != nil) {
            [dictionary removeObjectForKey:@"HSToolBackgroundPattern"];
            id description = [aDictionary objectForKey:aKey];
            id node = [self performSelector:aSelector];
            if (node != nil) {
                id newDescription = [self modifyBackgroundDescription:description withPatternName:patternName patternMatchingNode:node serializationKey:aKey];
                if (newDescription != description && newDescription != nil) {
                    [dictionary setObject:newDescription forKey:aKey];
                }
            }
        }
        [dictionary removeObjectForKey:@"HSToolTemplateDisplayName"];
        [pool release];
        aDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
        [dictionary release];
    }
    if (aName != NULL) {
        *aName = displayName;
    }
    return aDictionary;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00190047 @ 00190047, 295 bytes * /

id FUN_00190047(id self,SEL _cmd,id modifyBackgroundDescription,id withPatternName,
               id patternMatchingNode,id serializationKey)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSPatternsSharedProvider,sel_sharedPatternsProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperPatternPathForName_,withPatternName);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar2 != (id)0x0) {
    pvVar2 = serializationKey;
    pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,
                           modifyBackgroundDescription,serializationKey);
    _objc_msgSend(patternMatchingNode,sel_loadExtraDictionaryRepresentation_,pvVar3);
    pvVar3 = _objc_msgSend(patternMatchingNode,sel_queryHyperInterface_,&DAT_0037a13c);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryBackgroundGraphicsInterface_,&DAT_0037a3bc);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_setHyperImageFromPath_,pvVar1,pvVar2);
      pvVar1 = _objc_msgSend(patternMatchingNode,sel_extraDictionaryRepresentation);
      modifyBackgroundDescription = _objc_msgSend(pvVar1,sel_objectForKey_,serializationKey);
    }
  }
  return modifyBackgroundDescription;
}

*/
+ (id)modifyBackgroundDescription:(id)aDescription withPatternName:(id)aName patternMatchingNode:(id)aNode serializationKey:(id)aKey
{
    id path = [[HSPatternsSharedProvider sharedPatternsProvider] hyperPatternPathForName:aName];

    if ([path length] != 0) {
        [aNode loadExtraDictionaryRepresentation:[NSDictionary dictionaryWithObject:aDescription forKey:aKey]];
        id image = [[aNode queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] queryBackgroundGraphicsInterface:@protocol(HSMutableImage)];
        if (image != nil) {
            [image setHyperImageFromPath:path];
            aDescription = [[aNode extraDictionaryRepresentation] objectForKey:aKey];
        }
    }
    return aDescription;
}

+ (id)patternMatchingHeadline
{
    if (sDAT_003429c4 == nil) {
        sDAT_003429c4 = [[HSHeadlineObject alloc] init];
        [[HSGenericNodeSupport sharedNodeSupport] addNode:sDAT_003429c4];
    }
    return sDAT_003429c4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001901f5 @ 001901f5, 248 bytes * /

id FUN_001901f5(id self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  
  if (DAT_003429c0 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,0,0x4220000042200000);
    self_00 = _objc_msgSend(cls_HSVectorGraphicsObject,sel_alloc);
    DAT_003429c0 = _objc_msgSend(self_00,sel_initWithBezierPath_originAtPoint_,pvVar1,
                                 *(undefined4 *)PTR_00336074,*(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = _objc_msgSend(cls_HSGenericNodeSupport,sel_sharedNodeSupport);
    _objc_msgSend(pvVar1,sel_addNode_,DAT_003429c0);
  }
  return DAT_003429c0;
}

*/
+ (id)patternMatchingShape
{
    if (sPatternMatchingShape == nil) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 40, 40)];
        sPatternMatchingShape = [[HSVectorGraphicsObject alloc] initWithBezierPath:path originAtPoint:NSZeroPoint];
        [[HSGenericNodeSupport sharedNodeSupport] addNode:sPatternMatchingShape];
    }
    return sPatternMatchingShape;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001902ed @ 001902ed, 378 bytes * /

id FUN_001902ed(id self,SEL _cmd)

{
  undefined *self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  id self_02;
  id pvVar3;
  double dVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  float fVar7;
  float local_1c;
  
  self_01 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
  pvVar1 = _objc_msgSend(self_01,sel_availableFontFamilies);
  pvVar2 = _objc_msgSend(pvVar1,sel_sortedArrayUsingSelector_,sel_compare_);
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(pvVar2,sel_count);
  self_02 = _objc_msgSend(self_00,sel_arrayWithCapacity_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  dVar4 = _objc_msgSend_fpret(cls_NSFont,sel_systemFontSize);
  local_1c = (float)dVar4;
  pvVar3 = _objc_msgSend(self,sel_defaultFontForTextObject);
  if (pvVar3 != (id)0x0) {
    dVar4 = _objc_msgSend_fpret(pvVar3,sel_pointSize);
    local_1c = (float)dVar4;
  }
  while (pvVar1 = _objc_msgSend(pvVar2,sel_nextObject,pvVar1), pvVar1 != (id)0x0) {
    uVar6 = 5;
    uVar5 = 0;
    fVar7 = local_1c;
    pvVar3 = _objc_msgSend(self_01,sel_fontWithFamily_traits_weight_size_,pvVar1,0,5,local_1c);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self_02,sel_addObject_,pvVar3,uVar5,uVar6,fVar7);
      pvVar1 = pvVar3;
    }
  }
  return self_02;
}

*/
+ (id)loadTemplateFonts
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSArray *families = [[fontManager availableFontFamilies] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *fonts = [NSMutableArray arrayWithCapacity:[families count]];
    NSEnumerator *enumerator = [families objectEnumerator];
    CGFloat size = [NSFont systemFontSize];
    NSFont *defaultFont = [self defaultFontForTextObject];
    id family;

    if (defaultFont != nil) {
        size = [defaultFont pointSize];
    }
    while ((family = [enumerator nextObject]) != nil) {
        NSFont *font = [fontManager fontWithFamily:family traits:0 weight:5 size:size];
        if (font != nil) {
            [fonts addObject:font];
        }
    }
    return fonts;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00190467 @ 00190467, 180 bytes * /

id FUN_00190467(id self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(self,sel_sharedInstance);
  puVar2 = *(undefined **)PTR_PTR_00336310;
  self_00 = _objc_msgSend(pvVar1,sel_userObjectPrototypeForToolIdentifier_,puVar2);
  pvVar1 = (id)0x0;
  if (self_00 != (id)0x0) {
    puVar2 = &DAT_0037a038;
    pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0037a038);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperFont,puVar2);
  if (pvVar1 == (id)0x0) {
    puVar2 = (undefined *)0x42000000;
    pvVar1 = _objc_msgSend(cls_NSFont,sel_systemFontOfSize_,0x42000000);
  }
  _objc_msgSend(pvVar1,sel_retain,puVar2);
  return pvVar1;
}

*/
+ (id)defaultFontForTextObject
{
    id prototype = [[self sharedInstance] userObjectPrototypeForToolIdentifier:@"HSTextTool"];
    id attributes = nil;

    if (prototype != nil) {
        attributes = [prototype queryHyperInterface:@protocol(HSTextObjectAttributes)];
    }
    id font = [attributes hyperFont];
    if (font == nil) {
        font = [NSFont systemFontOfSize:32];
    }
    // The original also retained the font here, leaking it on every call.
    return font;
}

+ (id)sharedInstance
{
    if (sDAT_003429b8 == nil) {
        sDAT_003429b8 = [[self alloc] init];
    }
    return sDAT_003429b8;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00190565 @ 00190565, 405 bytes * /

uint FUN_00190565(HSCreationToolSettingsProvider *self,SEL _cmd,id indexOfTemplateMatchingPrototype,
                 id forToolIdentifier)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  
  uVar6 = *(undefined4 *)PTR_PTR_00336310;
  pvVar2 = _objc_msgSend(forToolIdentifier,sel_isEqualToString_,uVar6);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(indexOfTemplateMatchingPrototype,sel_extraDictionaryRepresentation,uVar6)
    ;
    pvVar3 = _objc_msgSend(self,sel_countOfTemplatesForToolIdentifier_,forToolIdentifier);
    for (pvVar5 = (id)0x0; pvVar5 < pvVar3; pvVar5 = (id)((int)pvVar5 + 1)) {
      pvVar4 = _objc_msgSend(self,sel_templateDictionaryAtIndex_forToolIdentifier_,pvVar5,
                             forToolIdentifier);
      pvVar4 = _objc_msgSend(pvVar2,sel_extraContainsDictionary_,pvVar4);
      if ((char)pvVar4 != '\0') {
        return (uint)pvVar5;
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(indexOfTemplateMatchingPrototype,sel_queryHyperInterface_,&DAT_0037a038);
    pvVar3 = _objc_msgSend(pvVar2,sel_hyperFontFamily);
    if ((pvVar2 != (id)0x0) && (pvVar3 != (id)0x0)) {
      pvVar2 = _objc_msgSend(self,sel_countOfTemplatesForToolIdentifier_,forToolIdentifier);
      puVar1 = PTR_003366b4;
      for (pvVar5 = (id)0x0; pvVar5 < pvVar2; pvVar5 = (id)((int)pvVar5 + 1)) {
        pvVar4 = _objc_msgSend(self,sel_templateDictionaryAtIndex_forToolIdentifier_,pvVar5,
                               forToolIdentifier);
        pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,*(undefined4 *)puVar1);
        pvVar4 = _objc_msgSend(pvVar4,sel_isEqualToString_,pvVar3);
        if ((char)pvVar4 != '\0') {
          return (uint)pvVar5;
        }
      }
    }
  }
  return 0x7fffffff;
}

*/
- (NSUInteger)indexOfTemplateMatchingPrototype:(id)aPrototype forToolIdentifier:(id)aIdentifier
{
    NSUInteger index;
    NSUInteger count;

    if (![aIdentifier isEqualToString:@"HSTextTool"]) {
        id representation = [aPrototype extraDictionaryRepresentation];
        count = [self countOfTemplatesForToolIdentifier:aIdentifier];
        for (index = 0; index < count; index++) {
            if ([representation extraContainsDictionary:[self templateDictionaryAtIndex:index forToolIdentifier:aIdentifier]]) {
                return index;
            }
        }
    }
    else {
        id attributes = [aPrototype queryHyperInterface:@protocol(HSTextObjectAttributes)];
        id family = [attributes hyperFontFamily];
        if (attributes != nil && family != nil) {
            count = [self countOfTemplatesForToolIdentifier:aIdentifier];
            for (index = 0; index < count; index++) {
                if ([[[self templateDictionaryAtIndex:index forToolIdentifier:aIdentifier] objectForKey:HSTextFontFamilySerializationKey] isEqualToString:family]) {
                    return index;
                }
            }
        }
    }
    return NSNotFound;
}

- (id)localizedStyleStringForTemplateAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier
{
    id pvVar1;
    id self_00;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        self_00 = [self templateInfoAtIndex:aIndex forToolIdentifier:aIdentifier];
        pvVar1 = [self_00 styleString];
        if (pvVar1 == nil) {
            pvVar1 = [self localizedStyleStringWithTemplate:self_00 forToolIdentifier:aIdentifier];
            [self_00 setStyleString:pvVar1];
        }
    }
    return pvVar1;
}

- (id)localizedNameForTemplateAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier
{
    id pvVar1;
    id self_00;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        self_00 = [self templateInfoAtIndex:aIndex forToolIdentifier:aIdentifier];
        pvVar1 = [self_00 localizedDisplayName];
        if (pvVar1 == nil) {
            pvVar1 = [self localizedNameWithTemplate:self_00 forToolIdentifier:aIdentifier];
            [self_00 setLocalizedDisplayName:pvVar1];
        }
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019081c @ 0019081c, 160 bytes * /

id FUN_0019081c(HSCreationToolSettingsProvider *self,SEL _cmd,id localizedStyleStringWithTemplate,
               id forToolIdentifier)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(forToolIdentifier,sel_isEqual_,*(undefined4 *)PTR_PTR_003362f4);
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(forToolIdentifier,sel_isEqual_,*(undefined4 *)PTR_PTR_003362b8),
     (char)pvVar1 == '\0')) {
    return &cfstr_empty;
  }
  pvVar1 = _objc_msgSend(self,sel_cachedPreviewPrototypeWithTemplate_forToolIdentifier_,
                         localizedStyleStringWithTemplate,forToolIdentifier);
  pvVar1 = _objc_msgSend(self,sel_localizedStyleStringWithPrototypeObject_forToolIdentifier_,pvVar1,
                         forToolIdentifier);
  return pvVar1;
}

*/
- (id)localizedStyleStringWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier
{
    if (![aIdentifier isEqual:@"HSShapeTool"] && ![aIdentifier isEqual:@"HSPolygonTool"]) {
        return @"";
    }
    return [self localizedStyleStringWithPrototypeObject:[self cachedPreviewPrototypeWithTemplate:aTemplate forToolIdentifier:aIdentifier] forToolIdentifier:aIdentifier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001908bc @ 001908bc, 1016 bytes * /

id FUN_001908bc(HSCreationToolSettingsProvider *self,SEL _cmd,
               id localizedStyleStringWithPrototypeObject,id forToolIdentifier)

{
  cfstringStruct *self_00;
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *self_01;
  SEL op;
  undefined *puVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  cfstringStruct *pcVar7;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  puVar4 = &DAT_0037a13c;
  pvVar1 = _objc_msgSend(localizedStyleStringWithPrototypeObject,sel_queryHyperInterface_,
                         &DAT_0037a13c);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_backgroundGraphics,puVar4);
    puVar4 = &DAT_0037a1a0;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0037a1a0);
    if (pvVar2 == (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_backgroundGraphics,puVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037a218);
      if (pvVar1 == (id)0x0) goto LAB_00190a0c;
      pcVar3 = &cfstr_HSShapeToolPreset_Image;
    }
    else {
      pvVar1 = _objc_msgSend(pvVar2,sel_isHyperSolid,puVar4);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(pvVar2,sel_hyperKind,puVar4);
        if (pvVar1 == (id)0x0) {
          pcVar3 = &cfstr_HSShapeToolPreset_LinearGradient;
        }
        else {
          pvVar1 = _objc_msgSend(pvVar2,sel_hyperKind,puVar4);
          if (pvVar1 != (id)0x1) goto LAB_00190a0c;
          pcVar3 = &cfstr_HSShapeToolPreset_RadialGradient;
        }
      }
      else {
        pcVar3 = &cfstr_HSShapeToolPreset_Solid;
      }
    }
    _objc_msgSend(self_00,sel_addObject_,pcVar3);
  }
LAB_00190a0c:
  puVar4 = &DAT_0037a22c;
  pvVar1 = _objc_msgSend(localizedStyleStringWithPrototypeObject,sel_queryHyperInterface_,
                         &DAT_0037a22c);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(pvVar1,sel_hyperLineDashInfo,puVar4), pvVar1 != (id)0x0)) {
    _objc_msgSend(self_00,sel_addObject_,&cfstr_HSShapeToolPreset_Line);
  }
  pcVar3 = (cfstringStruct *)&DAT_0037a344;
  pvVar1 = _objc_msgSend(localizedStyleStringWithPrototypeObject,sel_queryHyperInterface_,
                         &DAT_0037a344);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(pvVar1,sel_isHyperShadowEnabled,pcVar3), (char)pvVar1 != '\0')) {
    pcVar3 = &cfstr_HSShapeToolPreset_Shadow;
    _objc_msgSend(self_00,sel_addObject_,&cfstr_HSShapeToolPreset_Shadow);
  }
  pvVar1 = _objc_msgSend(self_00,sel_count,pcVar3);
  if (pvVar1 != (id)0x0) {
    pcVar5 = self_00;
    pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,self_00);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    _objc_msgSend(self_00,sel_removeAllObjects);
    pcVar3 = _objc_msgSend(pvVar1,sel_nextObject);
    while (pcVar3 != (cfstringStruct *)0x0) {
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar5);
      pcVar7 = &cfstr_Tools;
      pcVar6 = &cfstr_empty;
      self_01 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,
                              &cfstr_Tools);
      pvVar2 = _objc_msgSend(self_01,sel_isEqualToString_);
      pcVar5 = pcVar3;
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(self_00,sel_addObject_,self_01,pcVar6,pcVar7);
        pcVar5 = self_01;
      }
      pcVar3 = _objc_msgSend(pvVar1,sel_nextObject,pcVar5,pcVar6,pcVar7);
    }
    pvVar1 = _objc_msgSend(self_00,sel_count,pcVar5);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self_00,sel_count);
      op = sel_lastObject;
      if ((id)0x1 < pvVar1) {
        pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
        pcVar3 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                               &cfstr_ToolStyleStringSeparator,&cfstr_empty,&cfstr_Tools);
        pvVar1 = _objc_msgSend(pcVar3,sel_isEqualToString_,&cfstr_ToolStyleStringSeparator);
        op = sel_componentsJoinedByString_;
        pcVar5 = &cfstr___;
        if ((char)pvVar1 != '\0') {
          pcVar5 = pcVar3;
        }
      }
      pvVar1 = _objc_msgSend(self_00,op,pcVar5);
      return pvVar1;
    }
  }
  return &cfstr_empty;
}

*/
- (id)localizedStyleStringWithPrototypeObject:(id)aObject forToolIdentifier:(id)aIdentifier
{
    NSMutableArray *keys = [NSMutableArray array];
    id background = [aObject queryHyperInterface:@protocol(HSMutableBackgroundAttributes)];

    if (background != nil) {
        id color = [[background backgroundGraphics] queryHyperInterface:@protocol(HSMutableColor)];
        NSString *key = nil;
        if (color == nil) {
            if ([[background backgroundGraphics] queryHyperInterface:@protocol(HSImage)] != nil) {
                key = @"HSShapeToolPreset-Image";
            }
        }
        else if ([color isHyperSolid]) {
            key = @"HSShapeToolPreset-Solid";
        }
        else if ([color hyperKind] == 0) {
            key = @"HSShapeToolPreset-LinearGradient";
        }
        else if ([color hyperKind] == 1) {
            key = @"HSShapeToolPreset-RadialGradient";
        }
        if (key != nil) {
            [keys addObject:key];
        }
    }
    id vectorAttributes = [aObject queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    if (vectorAttributes != nil && [vectorAttributes hyperLineDashInfo] != nil) {
        [keys addObject:@"HSShapeToolPreset-Line"];
    }
    id shadow = [aObject queryHyperInterface:@protocol(HSShadowAttributes)];
    if (shadow != nil && [shadow isHyperShadowEnabled]) {
        [keys addObject:@"HSShapeToolPreset-Shadow"];
    }
    if ([keys count] == 0) {
        return @"";
    }
    NSEnumerator *enumerator = [[NSArray arrayWithArray:keys] objectEnumerator];
    NSString *key;
    [keys removeAllObjects];
    while ((key = [enumerator nextObject]) != nil) {
        NSString *localized = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:@"Tools"];
        if (![localized isEqualToString:key]) {
            [keys addObject:localized];
        }
    }
    if ([keys count] == 0) {
        return @"";
    }
    if ([keys count] < 2) {
        return [keys lastObject];
    }
    NSString *separator = [[NSBundle mainBundle] localizedStringForKey:@"ToolStyleStringSeparator" value:@"" table:@"Tools"];
    // The original picked the untranslated key as the separator and ", " for a translated one; this uses ", " only as the fallback.
    if ([separator isEqualToString:@"ToolStyleStringSeparator"]) {
        separator = @", ";
    }
    return [keys componentsJoinedByString:separator];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00190cb4 @ 00190cb4, 313 bytes * /

id FUN_00190cb4(HSCreationToolSettingsProvider *self,SEL _cmd,id localizedNameWithTemplate,
               id forToolIdentifier)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  int *piVar4;
  int local_14;
  
  pvVar1 = _objc_msgSend(localizedNameWithTemplate,sel_displayName);
  if (pvVar1 == (id)0x0) {
    pvVar2 = forToolIdentifier;
    _objc_msgSend(self,sel_templateDictionaryWithTemplate_forToolIdentifier_,
                  localizedNameWithTemplate,forToolIdentifier);
    pvVar1 = _objc_msgSend(localizedNameWithTemplate,sel_displayName);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(localizedNameWithTemplate,sel_setDisplayName_,&cfstr_empty,pvVar2);
    }
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar2 != (id)0x0) {
    local_14 = 0;
    pvVar2 = _objc_msgSend(self,sel_class);
    piVar4 = &local_14;
    pcVar3 = &cfstr_strings;
    pvVar2 = _objc_msgSend(pvVar2,sel_pathForResourceOfType_forToolIdentifier_resourceName_,
                           &cfstr_strings,forToolIdentifier,piVar4);
    if ((pvVar2 != (id)0x0) && (local_14 != 0)) {
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar3,forToolIdentifier,piVar4);
      pvVar1 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pvVar1,&cfstr_empty,
                             local_14);
      return pvVar1;
    }
  }
  return &cfstr_empty;
}

*/
- (id)localizedNameWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier
{
    id name = [aTemplate displayName];

    if (name == nil) {
        [self templateDictionaryWithTemplate:aTemplate forToolIdentifier:aIdentifier];
        name = [aTemplate displayName];
        if (name == nil) {
            [aTemplate setDisplayName:@""];
        }
    }
    if ([name length] != 0) {
        id table = nil;
        id path = [[self class] pathForResourceOfType:@"strings" forToolIdentifier:aIdentifier resourceName:&table];
        if (path != nil && table != nil) {
            return [[NSBundle mainBundle] localizedStringForKey:name value:@"" table:table];
        }
    }
    return @"";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00190ded @ 00190ded, 287 bytes * /

id FUN_00190ded(HSCreationToolSettingsProvider *self,SEL _cmd,id templatePreviewImageForPrototype)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  if (templatePreviewImageForPrototype != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSGenericNodeSupport,sel_sharedNodeSupport);
    pvVar2 = _objc_msgSend(pvVar1,sel_addNodeIfSupportIsNeeded_,templatePreviewImageForPrototype);
    pvVar1 = templatePreviewImageForPrototype;
    pvVar3 = _objc_msgSend(cls_HSUserObjectInPlayerPreviewView,sel_previewImageForObject_,
                           templatePreviewImageForPrototype);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(cls_HSGenericNodeSupport,sel_sharedNodeSupport,pvVar1);
      _objc_msgSend(pvVar1,sel_removeNode_,templatePreviewImageForPrototype);
    }
    if (pvVar3 != (id)0x0) {
      return pvVar3;
    }
  }
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSize_,0x3f800000,0x3f800000);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar1,sel_lockFocus);
  _objc_msgSend(pvVar1,sel_unlockFocus);
  return pvVar1;
}

*/
- (id)templatePreviewImageForPrototype:(id)aPrototype
{
    if (aPrototype != nil) {
        BOOL added = [[HSGenericNodeSupport sharedNodeSupport] addNodeIfSupportIsNeeded:aPrototype];
        id image = [HSUserObjectInPlayerPreviewView previewImageForObject:aPrototype];
        if (added) {
            [(HSGenericNodeSupport *)[HSGenericNodeSupport sharedNodeSupport] removeNode:aPrototype];
        }
        if (image != nil) {
            return image;
        }
    }
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(1, 1)] autorelease];
    [image lockFocus];
    [image unlockFocus];
    return image;
}

- (id)previewImageWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier
{
    return [self templatePreviewImageForPrototype:[self cachedPreviewPrototypeWithTemplate:aTemplate forToolIdentifier:aIdentifier]];
}

- (id)cachedPreviewPrototypeWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier
{
    id pvVar1;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [aTemplate previewPrototype];
        if (pvVar1 == nil) {
            pvVar1 = [self previewPrototypeWithTemplate:aTemplate forToolIdentifier:aIdentifier];
            [aTemplate setPreviewPrototype:pvVar1];
        }
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00190fcc @ 00190fcc, 397 bytes * /

id FUN_00190fcc(HSCreationToolSettingsProvider *self,SEL _cmd,id previewPrototypeWithTemplate,
               id forToolIdentifier)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_previewPrototypeForToolIdentifier_,forToolIdentifier);
  pvVar3 = forToolIdentifier;
  pvVar1 = _objc_msgSend(self,sel_templateDictionaryWithTemplate_forToolIdentifier_,
                         previewPrototypeWithTemplate,forToolIdentifier);
  if ((self_00 != (id)0x0) && (pvVar1 != (id)0x0)) {
    _objc_msgSend(self_00,sel_loadExtraDictionaryRepresentation_,pvVar1,pvVar3);
  }
  pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0037a038,pvVar3);
  if ((pvVar1 == (id)0x0) ||
     (pvVar2 = _objc_msgSend(forToolIdentifier,sel_isEqualToString_,*(undefined4 *)PTR_PTR_00336310,
                             pvVar3), (char)pvVar2 == '\0')) {
    pvVar3 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0037a128,pvVar3);
    if (pvVar3 == (id)0x0) {
      return self_00;
    }
    pvVar2 = *(id *)PTR_PTR_00336268;
    pvVar1 = _objc_msgSend(forToolIdentifier,sel_isEqualToString_,pvVar2);
    op = sel_hyperAutoSizeToFitText;
    if ((char)pvVar1 == '\0') {
      return self_00;
    }
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_attributedStringForTextToolWithTemplate_,
                           previewPrototypeWithTemplate,pvVar3);
    pvVar2 = _objc_msgSend(cls_HSCoreText,sel_alloc);
    pvVar3 = _objc_msgSend(pvVar2,sel_initWithAttributedString_,pvVar3);
    pvVar2 = pvVar3;
    _objc_msgSend(pvVar1,sel_hyperReplaceText_,pvVar3);
    op = sel_release;
  }
  _objc_msgSend(pvVar3,op,pvVar2);
  return self_00;
}

*/
- (id)previewPrototypeWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier
{
    id prototype = [self previewPrototypeForToolIdentifier:aIdentifier];
    id dictionary = [self templateDictionaryWithTemplate:aTemplate forToolIdentifier:aIdentifier];

    if (prototype != nil && dictionary != nil) {
        [prototype loadExtraDictionaryRepresentation:dictionary];
    }
    id textAttributes = [prototype queryHyperInterface:@protocol(HSTextObjectAttributes)];
    if (textAttributes != nil && [aIdentifier isEqualToString:@"HSTextTool"]) {
        HSCoreText *text = [[HSCoreText alloc] initWithAttributedString:[self attributedStringForTextToolWithTemplate:aTemplate]];
        [textAttributes hyperReplaceText:text];
        [text release];
    }
    else {
        id sizingAttributes = [prototype queryHyperInterface:@protocol(HSTextObjectSizingAttributes)];
        if (sizingAttributes != nil && [aIdentifier isEqualToString:@"HSHeadlineTool"]) {
            [sizingAttributes hyperAutoSizeToFitText];
        }
    }
    return prototype;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00191159 @ 00191159, 268 bytes * /

id FUN_00191159(HSCreationToolSettingsProvider *self,SEL _cmd,
               id attributedStringForTextToolWithTemplate)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(attributedStringForTextToolWithTemplate,sel_template);
  pvVar2 = _objc_msgSend(pvVar1,sel_familyName);
  if ((pvVar1 != (id)0x0) && (pvVar3 = _objc_msgSend(pvVar2,sel_length), pvVar3 != (id)0x0)) {
    pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar1,
                           *(undefined4 *)PTR_00336068);
    pvVar3 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar3,sel_initWithString_attributes_,pvVar2,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    pvVar2 = _objc_msgSend(pvVar1,sel_length);
    _objc_msgSend(pvVar1,sel_fixAttributesInRange_,0,pvVar2);
    return pvVar1;
  }
  return (id)0x0;
}

*/
- (id)attributedStringForTextToolWithTemplate:(id)aTemplate
{
    id font = [aTemplate template];
    id family = [font familyName];

    if (font != nil && [family length] != 0) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:family attributes:attributes] autorelease];
        [string fixAttributesInRange:NSMakeRange(0, [string length])];
        return string;
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00191265 @ 00191265, 688 bytes * /

id FUN_00191265(HSCreationToolSettingsProvider *self,SEL _cmd,id loadTemplateDictionaryWithTemplate,
               id forToolIdentifier,id *displayName)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  id pvVar3;
  id *ppvVar4;
  SEL op;
  undefined4 uVar5;
  id *ppvVar6;
  id local_18;
  id local_14;
  
  pvVar1 = _objc_msgSend(loadTemplateDictionaryWithTemplate,sel_template);
  local_14 = (id)0x0;
  pvVar2 = _objc_msgSend(cls_NSDictionary,sel_class);
  pvVar2 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
  if ((char)pvVar2 == '\0') {
    pvVar2 = *(id *)PTR_PTR_00336310;
    pvVar3 = _objc_msgSend(forToolIdentifier,sel_isEqual_,pvVar2);
    if ((char)pvVar3 == '\0') {
LAB_00191436:
      pvVar2 = _objc_msgSend(cls_HSVectorGraphicsLineDashInfoObject,sel_class,pvVar2);
      pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
      if ((char)pvVar3 != '\0') {
        local_18 = (id)0x0;
        ppvVar6 = &local_18;
        ppvVar4 = _objc_msgSend(cls_HSVectorGraphics,
                                sel_serializationKeyForLineDashInfo_serializedValue_,pvVar1,ppvVar6)
        ;
        if (ppvVar4 == (id *)0x0) {
          local_18 = (id)0x0;
        }
        pvVar2 = _objc_msgSend(local_18,sel_extraPlistValue,pvVar1,ppvVar6);
        self_00 = cls_NSDictionary;
        op = sel_dictionaryWithObjectsAndKeys_;
        local_18 = pvVar2;
        goto LAB_001914de;
      }
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSFont,sel_class,pvVar2);
      pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
      if ((char)pvVar3 == '\0') goto LAB_00191436;
      pvVar3 = _objc_msgSend(pvVar1,sel_familyName,pvVar2);
      if ((pvVar1 != (id)0x0) &&
         (pvVar1 = _objc_msgSend(pvVar3,sel_length,pvVar2), pvVar1 != (id)0x0)) {
        ppvVar4 = *(id **)PTR_003366b4;
        self_00 = cls_NSDictionary;
        op = sel_dictionaryWithObjectsAndKeys_;
        pvVar2 = pvVar3;
        goto LAB_001914de;
      }
    }
  }
  else {
    uVar5 = *(undefined4 *)PTR_PTR_003362f4;
    pvVar2 = _objc_msgSend(forToolIdentifier,sel_isEqual_,uVar5);
    if ((char)pvVar2 == '\0') {
      uVar5 = *(undefined4 *)PTR_PTR_003362b8;
      pvVar2 = _objc_msgSend(forToolIdentifier,sel_isEqual_,uVar5);
      if ((char)pvVar2 != '\0') goto LAB_0019130f;
      pvVar2 = *(id *)PTR_PTR_00336268;
      pvVar3 = _objc_msgSend(forToolIdentifier,sel_isEqual_,pvVar2);
      if ((char)pvVar3 != '\0') {
        self_00 = _objc_msgSend(self,sel_class,pvVar2);
        op = sel_updatedHeadlineTemplateDictionary_displayName_;
        goto LAB_0019132a;
      }
    }
    else {
LAB_0019130f:
      self_00 = _objc_msgSend(self,sel_class,uVar5);
      op = sel_updatedShapeTemplateDictionary_displayName_;
LAB_0019132a:
      ppvVar4 = &local_14;
      pvVar2 = pvVar1;
LAB_001914de:
      pvVar1 = _objc_msgSend(self_00,op,pvVar2,ppvVar4);
    }
    if (pvVar1 != (id)0x0) goto LAB_001914ff;
  }
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionary,pvVar2);
LAB_001914ff:
  if (displayName != (id *)0x0) {
    *displayName = local_14;
  }
  return pvVar1;
}

*/
- (id)loadTemplateDictionaryWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier displayName:(id *)aName
{
    id templateObject = [aTemplate template];
    id displayName = nil;
    id dictionary = nil;

    if ([templateObject isKindOfClass:[NSDictionary class]]) {
        if ([aIdentifier isEqual:@"HSShapeTool"] || [aIdentifier isEqual:@"HSPolygonTool"]) {
            dictionary = [[self class] updatedShapeTemplateDictionary:templateObject displayName:&displayName];
        }
        else if ([aIdentifier isEqual:@"HSHeadlineTool"]) {
            dictionary = [[self class] updatedHeadlineTemplateDictionary:templateObject displayName:&displayName];
        }
        else {
            dictionary = templateObject;
        }
    }
    else if ([aIdentifier isEqual:@"HSTextTool"] && [templateObject isKindOfClass:[NSFont class]]) {
        id family = [templateObject familyName];
        if ([family length] != 0) {
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:family, HSTextFontFamilySerializationKey, nil];
        }
    }
    else if ([templateObject isKindOfClass:[HSVectorGraphicsLineDashInfoObject class]]) {
        id value = nil;
        id key = [HSVectorGraphics serializationKeyForLineDashInfo:templateObject serializedValue:&value];
        if (key == nil) {
            value = nil;
        }
        value = [value extraPlistValue];
        if (key != nil && value != nil) {
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:value, key, nil];
        }
    }
    if (dictionary == nil) {
        dictionary = [NSDictionary dictionary];
    }
    if (aName != NULL) {
        *aName = displayName;
    }
    return dictionary;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00191515 @ 00191515, 145 bytes * /

id FUN_00191515(HSCreationToolSettingsProvider *self,SEL _cmd,id templateDictionaryWithTemplate,
               id forToolIdentifier)

{
  id pvVar1;
  undefined4 local_14;
  
  pvVar1 = _objc_msgSend(templateDictionaryWithTemplate,sel_templateDictionary);
  if (pvVar1 == (id)0x0) {
    local_14 = 0;
    pvVar1 = _objc_msgSend(self,
                           sel_loadTemplateDictionaryWithTemplate_forToolIdentifier_displayName_,
                           templateDictionaryWithTemplate,forToolIdentifier,&local_14);
    _objc_msgSend(templateDictionaryWithTemplate,sel_setTemplateDictionary_,pvVar1);
    _objc_msgSend(templateDictionaryWithTemplate,sel_setDisplayName_,local_14);
  }
  return pvVar1;
}

*/
- (id)templateDictionaryWithTemplate:(id)aTemplate forToolIdentifier:(id)aIdentifier
{
    id dictionary = [aTemplate templateDictionary];

    if (dictionary == nil) {
        id displayName = nil;
        dictionary = [self loadTemplateDictionaryWithTemplate:aTemplate forToolIdentifier:aIdentifier displayName:&displayName];
        [aTemplate setTemplateDictionary:dictionary];
        [aTemplate setDisplayName:displayName];
    }
    return dictionary;
}

- (id)previewPrototypeAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier
{
    id pvVar1;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [self cachedPreviewPrototypeWithTemplate:[self templateInfoAtIndex:aIndex forToolIdentifier:aIdentifier] forToolIdentifier:aIdentifier];
    }
    return [[pvVar1 copy] autorelease];
}

- (id)templatePreviewImageAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier
{
    id pvVar1;
    id self_00;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        self_00 = [self templateInfoAtIndex:aIndex forToolIdentifier:aIdentifier];
        pvVar1 = [self_00 previewImage];
        if (pvVar1 == nil) {
            pvVar1 = [self previewImageWithTemplate:self_00 forToolIdentifier:aIdentifier];
            [self_00 setPreviewImage:pvVar1];
        }
    }
    return pvVar1;
}

- (id)templateDictionaryAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier
{
    id pvVar1;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [self templateDictionaryWithTemplate:[self templateInfoAtIndex:aIndex forToolIdentifier:aIdentifier] forToolIdentifier:aIdentifier];
    }
    return pvVar1;
}

- (NSUInteger)countOfTemplatesForToolIdentifier:(id)aIdentifier
{
    NSUInteger pvVar1;

    if (aIdentifier == nil) {
        pvVar1 = 0;
    }
    else {
        pvVar1 = [[self toolTemplatesForToolIdentifier:aIdentifier] count];
    }
    return (unsigned int)pvVar1;
}

- (id)templateInfoAtIndex:(NSUInteger)aIndex forToolIdentifier:(id)aIdentifier
{
    id self_00;
    id self_01;

    self_00 = [self toolTemplatesForToolIdentifier:aIdentifier];
    self_01 = [self_00 objectAtIndex:aIndex];
    if (![self_01 isKindOfClass:[HSToolTemplateInfo class]]) {
        self_01 = [[HSToolTemplateInfo alloc] initWithTemplate:self_01];
        [self_00 replaceObjectAtIndex:aIndex withObject:self_01];
        [self_01 release];
    }
    return self_01;
}

- (id)toolTemplatesForToolIdentifier:(id)aIdentifier
{
    id pvVar1_2;

    pvVar1_2 = [[self toolTemplatesByIdentifier] objectForKey:aIdentifier];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [self loadToolTemplatesForToolIdentifier:aIdentifier];
        [[self toolTemplatesByIdentifier] setObject:pvVar1_2 forKey:aIdentifier];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001918d4 @ 001918d4, 449 bytes * /

id FUN_001918d4(HSCreationToolSettingsProvider *self,SEL _cmd,id loadToolTemplatesForToolIdentifier)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  undefined4 uVar4;
  
  pcVar2 = *(cfstringStruct **)PTR_PTR_00336310;
  pvVar1 = _objc_msgSend(loadToolTemplatesForToolIdentifier,sel_isEqual_,pcVar2);
  if ((char)pvVar1 == '\0') {
    uVar4 = *(undefined4 *)PTR_PTR_003362b4;
    pvVar1 = _objc_msgSend(loadToolTemplatesForToolIdentifier,sel_isEqual_,uVar4);
    if ((char)pvVar1 == '\0') {
      uVar4 = *(undefined4 *)PTR_PTR_003362b0;
      pvVar1 = _objc_msgSend(loadToolTemplatesForToolIdentifier,sel_isEqual_,uVar4);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(self,sel_class,uVar4);
        pcVar2 = &cfstr_plist;
        pvVar1 = _objc_msgSend(pvVar1,sel_pathForResourceOfType_forToolIdentifier_,&cfstr_plist,
                               loadToolTemplatesForToolIdentifier);
        if (pvVar1 == (id)0x0) goto LAB_00191a75;
        pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_alloc,pcVar2,
                               loadToolTemplatesForToolIdentifier);
        pvVar1 = _objc_msgSend(pvVar3,sel_initWithContentsOfFile_,pvVar1);
        pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
        pcVar2 = _objc_msgSend(cls_NSArray,sel_class);
        pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pcVar2);
        if ((char)pvVar3 == '\0') goto LAB_00191a75;
        goto LAB_00191a71;
      }
    }
    pvVar1 = _objc_msgSend(cls_HSVectorGraphicsLineDashInfoObjectProvider,sel_sharedProvider,uVar4);
    self_00 = cls_NSMutableArray;
    pcVar2 = _objc_msgSend(pvVar1,sel_objects);
    pvVar1 = _objc_msgSend(self_00,sel_arrayWithArray_,pcVar2);
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_class,pcVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_loadTemplateFonts);
  }
LAB_00191a71:
  if (pvVar1 != (id)0x0) {
    return pvVar1;
  }
LAB_00191a75:
  pvVar1 = _objc_msgSend(cls_NSArray,sel_array,pcVar2);
  return pvVar1;
}

*/
- (id)loadToolTemplatesForToolIdentifier:(id)aIdentifier
{
    id templates = nil;

    if ([aIdentifier isEqual:@"HSTextTool"]) {
        templates = [[self class] loadTemplateFonts];
    }
    else if ([aIdentifier isEqual:@"HSPolyLineTool"] || [aIdentifier isEqual:@"HSPolyCurveTool"]) {
        templates = [NSMutableArray arrayWithArray:[[HSVectorGraphicsLineDashInfoObjectProvider sharedProvider] objects]];
    }
    else {
        id path = [[self class] pathForResourceOfType:@"plist" forToolIdentifier:aIdentifier];
        if (path != nil) {
            templates = [[[NSMutableArray alloc] initWithContentsOfFile:path] autorelease];
            if (![templates isKindOfClass:[NSArray class]]) {
                templates = nil;
            }
        }
    }
    if (templates == nil) {
        templates = [NSArray array];
    }
    return templates;
}

- (id)toolTemplatesByIdentifier
{
    id pvVar1;

    pvVar1 = _toolTemplatesByIdentifier;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary alloc] init];
        _toolTemplatesByIdentifier = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00191ae1 @ 00191ae1, 157 bytes * /

id FUN_00191ae1(HSCreationToolSettingsProvider *self,SEL _cmd,id previewPrototypeForToolIdentifier)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,previewPrototypeForToolIdentifier);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_previewPrototype);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(self,
                             sel_loadUserObjectPrototypeWithTemplateDictionary_forToolIdentifier_,
                             pvVar1,previewPrototypeForToolIdentifier), pvVar1 != (id)0x0)) {
    return pvVar1;
  }
  pvVar1 = _objc_msgSend(self,sel_userObjectPrototypeForToolIdentifier_,
                         previewPrototypeForToolIdentifier);
  return pvVar1;
}

*/
- (id)previewPrototypeForToolIdentifier:(id)aIdentifier
{
    id dictionary = [[[self toolSettings] objectForKey:aIdentifier] objectForKey:@"previewPrototype"];

    if (dictionary != nil) {
        id prototype = [self loadUserObjectPrototypeWithTemplateDictionary:dictionary forToolIdentifier:aIdentifier];
        if (prototype != nil) {
            return prototype;
        }
    }
    return [self userObjectPrototypeForToolIdentifier:aIdentifier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00191b7e @ 00191b7e, 606 bytes * /

id FUN_00191b7e(HSCreationToolSettingsProvider *self,SEL _cmd,
               id userObjectPrototypeForToolIdentifier)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  cfstringStruct *pcVar2;
  id self_02;
  cfstringStruct *pcVar3;
  id local_14;
  
  if (userObjectPrototypeForToolIdentifier == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    if (DAT_003429bc == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSNull,sel_null);
      DAT_003429bc = _objc_msgSend(pvVar1,sel_retain);
    }
    pvVar1 = _objc_msgSend(self,sel_prototypesByIdentifier);
    local_14 = _objc_msgSend(pvVar1,sel_objectForKey_,userObjectPrototypeForToolIdentifier);
    if (local_14 == (id)0x0) {
      pcVar3 = *(cfstringStruct **)PTR_PTR_00336310;
      pvVar1 = _objc_msgSend(userObjectPrototypeForToolIdentifier,sel_isEqualToString_,pcVar3);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar3);
        pcVar3 = &cfstr_HSPreserveToolsSettings;
        pvVar1 = _objc_msgSend(pvVar1,sel_boolForKey_,&cfstr_HSPreserveToolsSettings);
        if ((char)pvVar1 != '\0') {
          pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar3);
          pcVar3 = *(cfstringStruct **)PTR_0033667c;
          pcVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,pcVar3);
          self_01 = cls_EXCodingContext;
          self_00 = cls_NSDictionary;
          if (pcVar2 != (cfstringStruct *)0x0) {
            pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
            pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar1,
                                   *(undefined4 *)PTR_003366b0);
            pvVar1 = _objc_msgSend(self_01,
                                   sel_codingContextWithOperation_shouldZeroMissingValuesOnLoading_options_
                                   ,*(undefined4 *)PTR_003366ac,0,pvVar1);
            local_14 = _objc_msgSend(cls_HSTextObject,
                                     sel_objectWithExtraDictionary_zone_codingContext_,pcVar2,0,
                                     pvVar1);
            pcVar3 = pcVar2;
          }
        }
      }
      if (local_14 == (id)0x0) {
        pcVar3 = userObjectPrototypeForToolIdentifier;
        local_14 = _objc_msgSend(self,sel_loadUserObjectPrototypeForToolIdentifier_,
                                 userObjectPrototypeForToolIdentifier);
      }
      self_02 = _objc_msgSend(self,sel_prototypesByIdentifier,pcVar3);
      pvVar1 = DAT_003429bc;
      if (local_14 != (id)0x0) {
        pvVar1 = local_14;
      }
      _objc_msgSend(self_02,sel_setObject_forKey_,pvVar1,userObjectPrototypeForToolIdentifier);
    }
    pvVar1 = (id)0x0;
    if (local_14 != DAT_003429bc) {
      pvVar1 = local_14;
    }
  }
  return pvVar1;
}

*/
- (id)userObjectPrototypeForToolIdentifier:(id)aIdentifier
{
    id prototype;

    if (aIdentifier == nil) {
        return nil;
    }
    if (sMissingPrototypeMarker == nil) {
        sMissingPrototypeMarker = [[NSNull null] retain];
    }
    prototype = [[self prototypesByIdentifier] objectForKey:aIdentifier];
    if (prototype == nil) {
        if ([aIdentifier isEqualToString:@"HSTextTool"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"HSPreserveToolsSettings"]) {
            id settings = [[NSUserDefaults standardUserDefaults] objectForKey:HSTextToolSettingsPreferencesKey];
            if (settings != nil) {
                NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:HSDisableClassSubstitutionCodingKey];
                id context = [EXCodingContext codingContextWithOperation:EXDefaultCodingOperation shouldZeroMissingValuesOnLoading:NO options:options];
                prototype = [HSTextObject objectWithExtraDictionary:settings zone:NULL codingContext:context];
            }
        }
        if (prototype == nil) {
            prototype = [self loadUserObjectPrototypeForToolIdentifier:aIdentifier];
        }
        [[self prototypesByIdentifier] setObject:(prototype != nil ? prototype : sMissingPrototypeMarker) forKey:aIdentifier];
    }
    if (prototype == sMissingPrototypeMarker) {
        return nil;
    }
    return prototype;
}

- (id)prototypesByIdentifier
{
    id pvVar1;

    pvVar1 = _prototypesByIdentifier;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary alloc] init];
        _prototypesByIdentifier = pvVar1;
    }
    return pvVar1;
}

- (id)loadUserObjectPrototypeForToolIdentifier:(id)aIdentifier
{
    id pvVar1;

    if (aIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [self loadUserObjectPrototypeWithTemplateDictionary:[[[self toolSettings] objectForKey:aIdentifier] objectForKey:@"prototype"] forToolIdentifier:aIdentifier];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00191eac @ 00191eac, 807 bytes * /

id FUN_00191eac(HSCreationToolSettingsProvider *self,SEL _cmd,
               id loadUserObjectPrototypeWithTemplateDictionary,id forToolIdentifier)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  
  self_01 = cls_EXCodingContext;
  self_00 = cls_NSDictionary;
  puVar2 = cls_HSToolManager;
  if (loadUserObjectPrototypeWithTemplateDictionary == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,forToolIdentifier);
    pvVar1 = _objc_msgSend(puVar2,sel_toolClassForTag_,pvVar1);
    loadUserObjectPrototypeWithTemplateDictionary = _objc_msgSend(cls_HSCreationTool,sel_class);
    pvVar3 = _objc_msgSend(pvVar1,sel_isSubclassOfClass_,
                           loadUserObjectPrototypeWithTemplateDictionary);
    if (((char)pvVar3 != '\0') &&
       (pvVar1 = _objc_msgSend(pvVar1,sel_userObjectClass,
                               loadUserObjectPrototypeWithTemplateDictionary), pvVar1 != (id)0x0)) {
      pvVar1 = _objc_msgSend(pvVar1,sel_alloc,loadUserObjectPrototypeWithTemplateDictionary);
      puVar2 = _objc_msgSend(pvVar1,sel_init);
      op = sel_autorelease;
      goto LAB_0019202a;
    }
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
    pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar1,
                           *(undefined4 *)PTR_003366b0);
    _objc_msgSend(self_01,sel_codingContextWithOperation_shouldZeroMissingValuesOnLoading_options_,
                  *(undefined4 *)PTR_003366ac,0,pvVar1);
    puVar2 = cls_HSNode;
    op = sel_nodeWithDictionary_children_explicitNodeDataProvider_codingContext_;
LAB_0019202a:
    pvVar1 = _objc_msgSend(puVar2,op,loadUserObjectPrototypeWithTemplateDictionary);
  }
  pvVar3 = _objc_msgSend(cls_HSVectorGraphicsObject,sel_class,
                         loadUserObjectPrototypeWithTemplateDictionary);
  pvVar4 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar3);
  if ((char)pvVar4 == '\0') {
    pvVar3 = _objc_msgSend(cls_HSHeadlineObject,sel_class,pvVar3);
    pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar3);
    if ((char)pvVar3 == '\0') goto LAB_001920f3;
  }
  pvVar3 = _objc_msgSend(self,sel_countOfTemplatesForToolIdentifier_,forToolIdentifier);
  if ((pvVar3 != (id)0x0) &&
     (pvVar3 = forToolIdentifier,
     pvVar4 = _objc_msgSend(self,sel_templateDictionaryAtIndex_forToolIdentifier_,0,
                            forToolIdentifier), pvVar4 != (id)0x0)) {
    _objc_msgSend(pvVar1,sel_loadExtraDictionaryRepresentation_,pvVar4,pvVar3);
  }
LAB_001920f3:
  pvVar3 = _objc_msgSend(forToolIdentifier,sel_isEqual_,*(undefined4 *)PTR_PTR_00336310);
  if (((char)pvVar3 == '\0') &&
     (pvVar3 = _objc_msgSend(forToolIdentifier,sel_isEqual_,*(undefined4 *)PTR_PTR_00336268),
     (char)pvVar3 == '\0')) {
    return pvVar1;
  }
  pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037a038);
  _objc_msgSend(pvVar3,sel_setHyperTextAlignment_,0);
  _objc_msgSend(pvVar3,sel_hyperReplaceTextWithString_,&cfstr_Abc);
  _objc_msgSend(pvVar3,sel_setHyperFontSize_,0x41900000);
  _objc_msgSend(pvVar3,sel_setHyperSpaceBetweenCharacters_,0);
  return pvVar1;
}

*/
- (id)loadUserObjectPrototypeWithTemplateDictionary:(id)aDictionary forToolIdentifier:(id)aIdentifier
{
    id prototype = nil;

    if (aDictionary == nil) {
        Class toolClass = [HSToolManager toolClassForTag:[HSToolManager toolTagForIdentifier:aIdentifier]];
        if ([toolClass isSubclassOfClass:[HSCreationTool class]]) {
            Class objectClass = [toolClass userObjectClass];
            if (objectClass != Nil) {
                prototype = [[[objectClass alloc] init] autorelease];
            }
        }
    }
    else {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:HSDisableClassSubstitutionCodingKey];
        id context = [EXCodingContext codingContextWithOperation:EXDefaultCodingOperation shouldZeroMissingValuesOnLoading:NO options:options];
        prototype = [HSNode nodeWithDictionary:aDictionary children:nil explicitNodeDataProvider:nil codingContext:context];
    }
    if ([prototype isKindOfClass:[HSVectorGraphicsObject class]] || [prototype isKindOfClass:[HSHeadlineObject class]]) {
        if ([self countOfTemplatesForToolIdentifier:aIdentifier] != 0) {
            id dictionary = [self templateDictionaryAtIndex:0 forToolIdentifier:aIdentifier];
            if (dictionary != nil) {
                [prototype loadExtraDictionaryRepresentation:dictionary];
            }
        }
    }
    if (![aIdentifier isEqual:@"HSTextTool"] && ![aIdentifier isEqual:@"HSHeadlineTool"]) {
        return prototype;
    }
    id attributes = [prototype queryHyperInterface:@protocol(HSTextObjectAttributes)];
    [attributes setHyperTextAlignment:0];
    [attributes hyperReplaceTextWithString:@"Abc"];
    [attributes setHyperFontSize:18];
    [attributes setHyperSpaceBetweenCharacters:0];
    return prototype;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001921d3 @ 001921d3, 314 bytes * /

id FUN_001921d3(HSCreationToolSettingsProvider *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id self_01;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  
  self_00 = cls_NSBundle;
  if (self->_toolSettings != (id)0x0) {
    return self->_toolSettings;
  }
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
  pcVar3 = &cfstr_plist;
  pcVar2 = &cfstr_CreationToolSettings;
  pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_CreationToolSettings,&cfstr_plist
                        );
  if (pvVar1 != (id)0x0) {
    self_01 = _objc_msgSend(cls_NSDictionary,sel_alloc,pcVar2,pcVar3);
    pvVar1 = _objc_msgSend(self_01,sel_initWithContentsOfFile_,pvVar1);
    self->_toolSettings = pvVar1;
    pcVar2 = _objc_msgSend(cls_NSDictionary,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pcVar2);
    if ((char)pvVar1 == '\0') {
      _objc_msgSend(self->_toolSettings,sel_release,pcVar2);
      self->_toolSettings = (id)0x0;
      goto LAB_001922d8;
    }
  }
  if (self->_toolSettings != (id)0x0) {
    return self->_toolSettings;
  }
LAB_001922d8:
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_alloc,pcVar2,pcVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_init);
  self->_toolSettings = pvVar1;
  return pvVar1;
}

*/
- (id)toolSettings
{
    if (_toolSettings != nil) {
        return _toolSettings;
    }
    id path = [[NSBundle bundleForClass:[self class]] pathForResource:@"CreationToolSettings" ofType:@"plist"];
    if (path != nil) {
        _toolSettings = [[NSDictionary alloc] initWithContentsOfFile:path];
        if (![_toolSettings isKindOfClass:[NSDictionary class]]) {
            [_toolSettings release];
            _toolSettings = nil;
        }
    }
    if (_toolSettings == nil) {
        _toolSettings = [[NSDictionary alloc] init];
    }
    return _toolSettings;
}

- (void)dealloc
{
    if (sDAT_003429b8 == self) {
        sDAT_003429b8 = nil;
    }
    [_toolSettings release];
    [_prototypesByIdentifier release];
    [_toolTemplatesByIdentifier release];
    [super dealloc];
}

- (id)init
{
    if (sDAT_003429b8 == nil) {
        self = [super init];
        if (self != nil) {
            sDAT_003429b8 = self;
        }
    }
    else {
        [super dealloc];
        self = [sDAT_003429b8 retain];
    }
    return self;
}

@end

