#import "HSInfoObjectProvider.h"
#import "NSMutableDictionary+EXExtensions.h"

@implementation HSInfoObjectProvider

+ (id)sharedProvider
{
    // One provider per subclass, keyed by class name.
    static NSMutableDictionary *sProviders = nil;
    NSString *className = NSStringFromClass([self class]);
    if (sProviders == nil)
        sProviders = [[NSMutableDictionary alloc] initWithCapacity:0];
    id provider = [sProviders objectForKey:className];
    if (provider == nil) {
        provider = [[[self class] alloc] initWithFileName:[[self infoObjectClass] providerKey]];
        [provider addCustomInfo];
        [sProviders setObject:provider forKey:className];
        [provider release];
    }
    return provider;
}

+ (Class)infoObjectClass
{
    return [HSInfoObject class];
}

- (void)unregisterInfoObject:(id)aObject
{
    NSUInteger index = [_objects indexOfObjectIdenticalTo:aObject];
    if (index != NSNotFound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HSInfoObjectProviderWillRemoveItemNotification object:aObject];
        [_objects removeObjectAtIndex:index];
    }
}

- (id)registeredInfoObject:(id)aObject
{
    if ([_objects containsObject:aObject])
        return [_objects objectAtIndex:[_objects indexOfObject:aObject]];
    [_objects addObject:aObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSInfoObjectProviderDidAddItemNotification object:aObject];
    return aObject;
}

- (id)objectDefaults
{
    return _defaults;
}

- (id)objects
{
    return _objects;
}

- (id)namedObjects
{
    return _namedObjects;
}

- (void)addCustomInfo
{
    NSString *path = [[[NSBundle bundleForClass:[self class]] resourcePath]
                         stringByAppendingPathComponent:[[[self class] infoObjectClass] providerKey]];
    [self addCustomInfoAtPath:path];
}

- (void)addCustomInfoAtPath:(id)aPath
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:aPath];
    id file;
    while ((file = [enumerator nextObject]) != nil)
        [self addCustomInfoFile:[aPath stringByAppendingPathComponent:file]];
}

- (void)addCustomInfoFile:(id)aFile
{
}

- (void)dealloc
{
    // _namedObjects is never released in the original.
    [_objects release];
    [_defaults release];
    [_defaultItem release];
    [super dealloc];
}

- (id)initWithFileName:(id)aName
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:aName ofType:@"plist"];
    return [self initWithPropertyList:[NSDictionary dictionaryWithContentsOfFile:path]];
}

- (id)initWithPropertyList:(id)aList
{
    self = [super init];
    if (self != nil) {
        NSDictionary *list = [aList objectForKey:@"List"];
        NSEnumerator *enumerator = [list keyEnumerator];
        _defaults = [[aList objectForKey:@"Defaults"] retain];
        _defaultItem = [[aList objectForKey:@"DefaultItem"] retain];
        _namedObjects = [[NSMutableDictionary alloc] initWithCapacity:[list count]];
        _objects = [[NSMutableArray alloc] initWithCapacity:[list count]];
        id name;
        while ((name = [enumerator nextObject]) != nil) {
            HSInfoObject *object = [[[[self class] infoObjectClass] alloc] initWithTitle:nil info:[list objectForKey:name]];
            [_namedObjects setObject:object forKey:name];
            [object retainOwnerCount];
            // The default item goes first.
            if ([_defaultItem isEqual:name])
                [_objects insertObject:object atIndex:0];
            else
                [_objects addObject:object];
            [object release];
        }
    }
    return self;
}

@end

@implementation HSInfoObject

+ (id)sharedProvider
{
    return [[self providerClass] sharedProvider];
}

+ (Class)providerClass
{
    return [HSInfoObjectProvider class];
}

+ (id)providerKey
{
    return @"";
}

- (id)title
{
    return _title;
}

- (id)mutableInfo
{
    if (_mutableInfo == nil) {
        id defaults = [[[self class] sharedProvider] objectDefaults];
        _mutableInfo = _info ? [_info mutableCopy] : [NSMutableDictionary new];
        [_mutableInfo extraAppendDictionary:defaults];
    }
    return _mutableInfo;
}

- (id)info
{
    return [self mutableInfo];
}

- (void)unregisterFromProvider
{
    [[[self class] sharedProvider] unregisterInfoObject:self];
}

- (id)registeredInProvider
{
    return [[[self class] sharedProvider] registeredInfoObject:self];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"title", nil];
}

- (BOOL)canBeExtraPostLoaded
{
    return NO;
}

- (id)_info
{
    return _info;
}

- (void)releaseOwnerCount
{
    if (_ownerCount < 2)
        [self unregisterFromProvider];
    _ownerCount--;
}

- (void)retainOwnerCount
{
    _ownerCount++;
}

- (void)dealloc
{
    [_title release];
    [_info release];
    [_mutableInfo release];
    [super dealloc];
}

- (id)initWithTitle:(id)aTitle info:(id)aInfo
{
    self = [super init];
    if (self != nil) {
        _title = [aTitle retain];
        _info = [aInfo retain];
    }
    return self;
}

- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    self = [super initWithExtraDictionary:aDictionary codingContext:aContext];
    if (self != nil) {
        // Decoded objects collapse onto the instance the provider already has.
        id registered = [self registeredInProvider];
        if (registered != self) {
            [self release];
            self = [registered retain];
        }
    }
    return self;
}

@end
