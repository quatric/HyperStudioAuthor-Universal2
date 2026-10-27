#import "HSUserObjectDefaultAttributesProvider.h"
#import "HSImageObject.h"
#import "HSPlayerBaseID.h"
#import "HSUserObject.h"
#import "HSUserObjectNamingStrategy.h"
#import "NSMutableDictionary+EXExtensions.h"

static HSUserObjectDefaultAttributesProvider *sSharedInstance = nil;

@implementation HSUserObjectDefaultAttributesProvider

+ (NSSize)defaultCardSize
{
    NSSize size = NSZeroSize;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:HSCardCurrentResolutionSize]) {
        size = [[NSScreen mainScreen] frame].size;
    } else {
        id sizeString = [[NSUserDefaults standardUserDefaults] objectForKey:HSCardDefaultSize];
        if (sizeString != nil)
            size = NSSizeFromString(sizeString);
    }
    return size;
}

+ (id)defaultNameForNewlyCreatedTextView
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Scrollable Text" value:@"" table:@"HyperPlayerBase"];
}

+ (id)defaultTextForNewlyCreatedRotatableTextObject
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Double-click to enter text" value:@"" table:@"HyperPlayerBase"];
}

+ (id)defaultTextForNewlyCreatedTextView
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Double-click to enter text" value:@"" table:@"HyperPlayerBase"];
}

+ (id)defaultFontForNewlyCreatedTextObjects
{
    CGFloat size;
    id sizeValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSDefaultFontSize"];
    if (sizeValue == nil) {
        NSFont *userFont = [NSFont userFontOfSize:-1.0];
        size = userFont ? (float)[userFont pointSize] : 12.0f;
    } else {
        size = (float)[sizeValue intValue];
    }
    id fontName = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSDefaultFontName"];
    if (fontName != nil) {
        NSFont *font = [NSFont fontWithName:fontName size:size];
        if (font != nil)
            return font;
    }
    return [NSFont userFontOfSize:size];
}

+ (id)defaultFontForNewlyCreatedRotatableTextObjects
{
    id fontName = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSDefaultFontName"];
    if (fontName != nil) {
        NSFont *font = [NSFont fontWithName:fontName size:24.0];
        if (font != nil)
            return font;
    }
    return [NSFont userFontOfSize:24.0];
}

+ (id)sharedInstance
{
    if (sSharedInstance == nil)
        [[HSUserObjectDefaultAttributesProvider alloc] init];
    return sSharedInstance;
}

- (id)defaultIdentifierTemplateWithNonLocalizedKindKey:(id)aKey
{
    id identifier = nil;
    if (![aKey length])
        aKey = nil;
    if (aKey != nil) {
        id localizedName = [self localizedKindNameForKey:aKey];
        if (localizedName != nil)
            identifier = [[HSUserObjectNamingStrategy defaultNamingStrategy] acceptableObjectName:localizedName];
    }
    return identifier ? identifier : aKey;
}

- (id)localizedKindNameForKey:(id)aKey
{
    return [HSPlayerBaseID localizedString:aKey fromTable:@"UserClassesLocalizable"];
}

- (id)defaultIdentifierTemplateForUserObjectClass:(Class)aClass key:(id)aKey
{
    id identifier;
    if (aKey == nil) {
        identifier = [[self defaultAttributesForUserObjectClass:aClass] objectForKey:HSUserObjectNameSerializationKey];
    } else {
        identifier = [[self defaultIdentifiersByCustomKeys] objectForKey:aKey];
        if (identifier == nil) {
            identifier = [self defaultIdentifierTemplateWithNonLocalizedKindKey:aKey];
            if (identifier != nil)
                [[self defaultIdentifiersByCustomKeys] setObject:identifier forKey:aKey];
        }
    }
    return identifier ? identifier : @"Object";
}

- (id)localizedKindNameForUserObjectClass:(Class)aClass key:(id)aKey
{
    if (aKey == nil)
        aKey = [self nonLocalizedKindNameForUserObjectClass:aClass];
    return [self localizedKindNameForKey:aKey];
}

- (id)nonLocalizedKindNameForPencilBrushObject
{
    return @"Pencil";
}

- (id)nonLocalizedKindNameForVectorGraphicsObjectIfClosed:(BOOL)aClosed straightLineMode:(BOOL)aMode
{
    if (aClosed)
        return aMode ? @"Polygon" : @"Shape";
    return aMode ? @"Line" : @"Curve";
}

- (id)nonLocalizedKindNameForUserObjectClass:(Class)aClass
{
    NSString *className = NSStringFromClass(aClass);
    id name = [[self nonLocalizedKeyNamesByClass] objectForKey:className];
    if (name == nil) {
        // Loading the attributes fills in the key name as a side effect.
        [self defaultAttributesForUserObjectClass:aClass];
        name = [[self nonLocalizedKeyNamesByClass] objectForKey:className];
    }
    return [name length] ? name : @"Object";
}

- (id)loadDefaultAttributesForClass:(Class)aClass
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    // Merge the descriptions from the base class down to aClass.
    NSMutableArray *classNames = [NSMutableArray arrayWithObject:NSStringFromClass(aClass)];
    Class cls = aClass;
    if (_baseClass != aClass) {
        do {
            cls = [cls superclass];
            [classNames addObject:NSStringFromClass(cls)];
        } while (cls != _baseClass);
    }
    NSEnumerator *enumerator = [classNames reverseObjectEnumerator];
    id className;
    while ((className = [enumerator nextObject]) != nil) {
        id description = [[self loadedDescriptions] objectForKey:className];
        if (description != nil)
            [attributes extraAppendDictionary:description];
    }

    NSString *ownClassName = NSStringFromClass(aClass);
    id keyName = [[self nonLocalizedKeyNamesByClass] objectForKey:ownClassName];
    if (keyName == nil) {
        id name = [attributes objectForKey:HSUserObjectNameSerializationKey];
        keyName = name ? name : @"";
        [[self nonLocalizedKeyNamesByClass] setObject:keyName forKey:ownClassName];
    }
    id identifier = [self defaultIdentifierTemplateWithNonLocalizedKindKey:[keyName length] ? keyName : nil];
    if (identifier != nil)
        [attributes setObject:identifier forKey:HSUserObjectNameSerializationKey];

    if ([aClass isSubclassOfClass:[HSImageObject class]]) {
        id shadowEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSDefaultImageShadowEnabled"];
        if (shadowEnabled != nil)
            [attributes setObject:shadowEnabled forKey:@"shadowEnabled"];
    }
    return [NSDictionary dictionaryWithDictionary:attributes];
}

- (id)defaultIdentifiersByCustomKeys
{
    if (_defaultIdentifiersByCustomKeys == nil)
        _defaultIdentifiersByCustomKeys = [NSMutableDictionary new];
    return _defaultIdentifiersByCustomKeys;
}

- (id)nonLocalizedKeyNamesByClass
{
    if (_nonLocalizedKeyNamesByClass == nil)
        _nonLocalizedKeyNamesByClass = [NSMutableDictionary new];
    return _nonLocalizedKeyNamesByClass;
}

- (id)defaultAttributesByClass
{
    if (_defaultAttributesByClass == nil)
        _defaultAttributesByClass = [NSMutableDictionary new];
    return _defaultAttributesByClass;
}

- (id)loadedDescriptions
{
    [self loadDescriptionsIfNeeded];
    return _loadedDescriptions;
}

- (void)setLoadedDescriptions:(id)aDescriptions
{
    if (_loadedDescriptions != aDescriptions) {
        [aDescriptions retain];
        [_loadedDescriptions release];
        _loadedDescriptions = aDescriptions;
        [_defaultAttributesByClass removeAllObjects];
    }
}

- (void)loadDescriptionsIfNeeded
{
    if (_loadedDescriptions == nil) {
        id descriptions = [HSPlayerBaseID extraDictionaryNamed:@"DefaultObjects"];
        if (descriptions == nil)
            descriptions = [NSDictionary dictionary];
        [self setLoadedDescriptions:descriptions];
    }
}

- (id)defaultAttributesForUserObjectClassName:(id)aName
{
    return [self defaultAttributesForUserObjectClass:NSClassFromString(aName)];
}

- (id)defaultAttributesForUserObjectClass:(Class)aClass
{
    NSString *className = NSStringFromClass(aClass);
    id attributes = [[self defaultAttributesByClass] objectForKey:className];
    if (attributes == nil) {
        attributes = [self loadDefaultAttributesForClass:aClass];
        [[self defaultAttributesByClass] setObject:attributes forKey:className];
    }
    return attributes;
}

- (Class)baseClass
{
    return _baseClass;
}

- (void)setBaseClass:(Class)aClass
{
    _baseClass = aClass;
}

- (void)dealloc
{
    if (sSharedInstance == self)
        sSharedInstance = nil;
    [_loadedDescriptions release];
    [_defaultAttributesByClass release];
    [_nonLocalizedKeyNamesByClass release];
    [_defaultIdentifiersByCustomKeys release];
    [super dealloc];
}

- (id)init
{
    if (sSharedInstance == nil) {
        self = [super init];
        if (self != nil) {
            [self setBaseClass:[HSUserObject class]];
            sSharedInstance = self;
        }
        return self;
    }
    [self release];
    return [sSharedInstance retain];
}

@end
