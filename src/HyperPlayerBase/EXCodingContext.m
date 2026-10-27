#import "EXCodingContext.h"
#import "NSString+EXMacTypes.h"

// Settings for one extra-dictionary coding pass: the operation name, whether
// missing values are zeroed on loading, and free-form options.
@implementation EXCodingContext

+ (id)codingContextWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading options:(id)aOptions
{
    return [[[self alloc] initWithOperation:aOperation shouldZeroMissingValuesOnLoading:aLoading options:aOptions] autorelease];
}

+ (id)codingContextWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading
{
    return [[[self alloc] initWithOperation:aOperation shouldZeroMissingValuesOnLoading:aLoading options:nil] autorelease];
}

+ (id)defaultCodingContext
{
    static EXCodingContext *context = nil;
    if (context == nil)
        context = [[EXCodingContext alloc] initWithOperation:@"" shouldZeroMissingValuesOnLoading:NO options:nil];
    return context;
}

- (id)options
{
    return _options;
}

- (BOOL)shouldZeroMissingValuesOnLoading
{
    return _shouldZeroMissingValuesOnLoading;
}

- (id)codingOperation
{
    return _codingOperation;
}

- (void)dealloc
{
    [_options release];
    [_codingOperation release];
    [super dealloc];
}

- (id)initWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading options:(id)aOptions
{
    self = [super init];
    if (self != nil) {
        _codingOperation = [aOperation retain];
        _shouldZeroMissingValuesOnLoading = aLoading;
        _options = [aOptions copy];
    }
    return self;
}

- (id)initWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading
{
    return [self initWithOperation:aOperation shouldZeroMissingValuesOnLoading:aLoading options:nil];
}

@end

// An "EXInitializer" entry: the init selector and up to two arguments used
// instead of -extraInit when an object is created from a dictionary.
@implementation _EXInitializer

// nil when the arguments are not an array of at most two objects.
- (id)initTarget:(id)aTarget
{
    if (_initSelector == NULL)
        return [aTarget init];
    if (![_arguments isKindOfClass:[NSArray class]])
        return nil;
    switch ([_arguments count]) {
    case 0:
        return [aTarget performSelector:_initSelector];
    case 1:
        return [aTarget performSelector:_initSelector withObject:[_arguments objectAtIndex:0]];
    case 2:
        return [aTarget performSelector:_initSelector withObject:[_arguments objectAtIndex:0] withObject:[_arguments objectAtIndex:1]];
    default:
        return nil;
    }
}

- (void)setInitSelector:(id)aSelector
{
    _initSelector = NSSelectorFromString(aSelector);
}

// Write-only; the original never stores the selector name back.
- (id)initSelector
{
    return nil;
}

- (void)dealloc
{
    [_arguments release];
    [super dealloc];
}

@end

@implementation NSObject (EXKeyValueCodingBackwardCompatibility)

+ (BOOL)overridesSelector:(SEL)aSelector ofBaseClass:(Class)aClass
{
    return [self instanceMethodForSelector:aSelector] != [aClass instanceMethodForSelector:aSelector];
}

@end

@implementation NSDictionary (EXObjectVersion)

- (CGFloat)extraCodingVersion
{
    NSNumber *version = [self objectForKey:@"EXCodingVersion"];
    if (version == nil)
        return 0.0f;
    return [version floatValue];
}

@end

// Key suffixes select how a value is stored: archived, keyed-archived, as a
// collection of coded objects, or in several representations.
@implementation NSString (EXKeyValueSuffixes)

- (id)extraNormalizedKey
{
    NSMutableString *key = [[self mutableCopy] autorelease];
    if (![key extraReplaceString:@"-EXUseArchiver" withString:@""]
        && ![key extraReplaceString:@"-EXUseKeyedArchiver" withString:@""]
        && ![key extraReplaceString:@"-EXConformedCollection" withString:@""])
        [key extraReplaceString:@"-EXMultiRepresentations" withString:@""];
    return [[key copy] autorelease];
}

- (id)extraKeyForMultiRepresentations
{
    return [self stringByAppendingString:@"-EXMultiRepresentations"];
}

- (id)extraKeyForCollection
{
    return [self stringByAppendingString:@"-EXConformedCollection"];
}

- (id)extraKeyForKeyedArchiving
{
    return [self stringByAppendingString:@"-EXUseKeyedArchiver"];
}

- (id)extraKeyForArchiving
{
    return [self stringByAppendingString:@"-EXUseArchiver"];
}

@end

@implementation NSString (EXASCIIPlistReading)

// "YES"/"TRUE" in any case, else a non-zero number.
- (BOOL)charValue
{
    if ([self compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return YES;
    if ([self compare:@"TRUE" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return YES;
    return [self intValue] != 0;
}

@end

// The coding way a key suffix selects: 1 archiver, 2 keyed archiver,
// 3 conformed collection, 4 multiple representations, 0 plain. aKey loses
// the suffix.
static NSInteger EXCodingWayRemovingSuffix(NSMutableString *aKey)
{
    if ([aKey extraReplaceString:@"-EXUseArchiver" withString:@""])
        return 1;
    if ([aKey extraReplaceString:@"-EXUseKeyedArchiver" withString:@""])
        return 2;
    if ([aKey extraReplaceString:@"-EXConformedCollection" withString:@""])
        return 3;
    return [aKey extraReplaceString:@"-EXMultiRepresentations" withString:@""] ? 4 : 0;
}

// Key-value coding through extra dictionaries: an object stores the values of
// its -keysForExtraStoringWithCodingContext: keys plus its class name, and is
// recreated from such a dictionary. Values that are themselves EXKeyValueCoding
// objects are stored as nested dictionaries.
@implementation NSObject (EXKeyValueCoding)

+ (id)extraClassNameForStoring
{
    return NSStringFromClass(self);
}

+ (id)objectWithExtraDictionary:(id)aDictionary
{
    return [self objectWithExtraDictionary:aDictionary zone:NULL];
}

+ (id)objectWithExtraDictionary:(id)aDictionary zone:(NSZone *)aZone
{
    return [self objectWithExtraDictionary:aDictionary zone:aZone codingContext:[EXCodingContext defaultCodingContext]];
}

// The stored class name picks the class. Classes that don't override
// -initWithExtraDictionary:codingContext: get the context-less initializer;
// the original checks the receiver, not the stored class.
+ (id)objectWithExtraDictionary:(id)aDictionary zone:(NSZone *)aZone codingContext:(id)aContext
{
    Class objectClass = self;
    NSString *className = [aDictionary objectForKey:@"EXClassName"];
    if (className != nil)
        objectClass = NSClassFromString(className);
    BOOL usesContext = [self overridesSelector:@selector(initWithExtraDictionary:codingContext:) ofBaseClass:[NSObject class]];
    id object = [objectClass allocWithZone:aZone];
    if (usesContext)
        object = [object initWithExtraDictionary:aDictionary codingContext:aContext];
    else
        object = [object initWithExtraDictionary:aDictionary];
    return [object autorelease];
}

- (id)extraPlistValue
{
    return [self extraPlistValueWithCodingContext:[EXCodingContext defaultCodingContext]];
}

- (id)extraPlistValueWithCodingContext:(id)aContext
{
    return [self _extraPlistValueWithCodingWay:0 codingContext:aContext];
}

- (id)extraPlistValueWithKey:(id)aKey codingContext:(id)aContext
{
    NSMutableString *key = [NSMutableString stringWithString:aKey];
    return [self _extraPlistValueWithCodingWay:EXCodingWayRemovingSuffix(key) codingContext:aContext];
}

- (id)reloadExtraDictionaryRepresentation:(id)aRepresentation
{
    return [[self class] objectWithExtraDictionary:aRepresentation zone:[self zone]];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    if ([self conformsToProtocol:@protocol(EXKeyValueCoding)]) {
        NSArray *keys = [(id<EXKeyValueCoding>)self keysForExtraStoringWithCodingContext:aContext];
        if (keys != nil)
            return keys;
    }
    return [NSArray array];
}

- (BOOL)canBeExtraPostLoaded
{
    return YES;
}

- (BOOL)canHaveExtraInitializer
{
    return YES;
}

- (id)extraInit
{
    return [self init];
}

- (id)extraClassNameForStoring
{
    return [[self class] extraClassNameForStoring];
}

- (CGFloat)extraCodingVersion
{
    return 0.0f;
}

- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    if (![self conformsToProtocol:@protocol(EXKeyValueCoding)])
        return nil;
    NSArray *keys = [[(id<EXKeyValueCoding>)self keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"EXClassName"];
    NSEnumerator *enumerator = [keys objectEnumerator];
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil) {
        id value = [self _extraSerializedValueForKey:key codingContext:aContext];
        if (value != nil)
            [representation setObject:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:representation];
}

- (id)extraDictionaryRepresentation
{
    return [self extraDictionaryRepresentationWithCodingContext:[EXCodingContext defaultCodingContext]];
}

// Only the loading keys are loaded (all keys when there are none); others go
// to -setExtraValue:forUndefinedKey: when implemented.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableSet *keys = [NSMutableSet setWithArray:[aRepresentation allKeys]];
    [keys removeObject:@"EXInitializer"];
    [keys removeObject:@"EXClassName"];
    NSMutableSet *loadingKeys = [NSMutableSet set];
    NSArray *keysForLoading = [self keysForExtraLoadingWithCodingContext:aContext];
    NSUInteger count = [keysForLoading count];
    if (count != 0) {
        NSEnumerator *enumerator = [keysForLoading objectEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject]) != nil)
            [loadingKeys addObject:[key extraNormalizedKey]];
    }
    NSEnumerator *enumerator = [keys objectEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil) {
        id value = [aRepresentation objectForKey:key];
        NSString *normalizedKey = [key extraNormalizedKey];
        if (count == 0 || [loadingKeys containsObject:normalizedKey])
            [self _loadExtraSerializedValue:value forKey:key codingContext:aContext];
        else if ([self respondsToSelector:@selector(setExtraValue:forUndefinedKey:)])
            [(id)self setExtraValue:value forUndefinedKey:normalizedKey];
    }
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation
{
    [self loadExtraDictionaryRepresentation:aRepresentation withCodingContext:[EXCodingContext defaultCodingContext]];
}

- (id)initWithExtraDictionary:(id)aDictionary
{
    return [self initWithExtraDictionary:aDictionary codingContext:[EXCodingContext defaultCodingContext]];
}

// An "EXInitializer" entry replaces -extraInit. A loading exception releases
// the object and returns nil.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    id initializer = nil;
    if ([self canHaveExtraInitializer])
        initializer = [aDictionary objectForKey:@"EXInitializer"];
    if (initializer != nil)
        initializer = [_EXInitializer objectWithExtraDictionary:initializer];
    id object = initializer != nil ? [initializer initTarget:self] : [self extraInit];
    if (object == nil || aDictionary == nil)
        return object;
    @try {
        [object loadExtraDictionaryRepresentation:aDictionary withCodingContext:aContext];
    } @catch (NSException *exception) {
        [object release];
        object = nil;
    }
    return object;
}

// Unknown keys go to -extraValueForUndefinedKey: when implemented; coded
// objects without it answer nil, others raise.
- (id)extraValueForKey:(id)aKey
{
    if ([aKey isEqual:@"EXClassName"])
        return [self extraClassNameForStoring];
    id value = nil;
    @try {
        value = [self valueForKey:aKey];
    } @catch (NSException *exception) {
        if ([self respondsToSelector:@selector(extraValueForUndefinedKey:)])
            value = [(id)self extraValueForUndefinedKey:aKey];
        else if (![self conformsToProtocol:@protocol(EXKeyValueCoding)])
            [exception raise];
    }
    return value;
}

// The class name and initializer are not values.
- (void)setExtraValue:(id)aValue forKey:(id)aKey
{
    if ([aKey isEqual:@"EXClassName"] || [aKey isEqual:@"EXInitializer"])
        return;
    @try {
        [self setValue:aValue forKey:aKey];
    } @catch (NSException *exception) {
        if ([self respondsToSelector:@selector(setExtraValue:forUndefinedKey:)])
            [(id)self setExtraValue:aValue forUndefinedKey:aKey];
        else if (![self conformsToProtocol:@protocol(EXKeyValueCoding)])
            [exception raise];
    }
}

// The archived representation is used when it was written by this or an
// older Foundation; otherwise the cross-platform dictionary.
- (void)_extraLoadPlist:(id)aPlist forMultiRepresentationsKey:(id)aKey
{
    if (![aPlist isKindOfClass:[NSDictionary class]])
        return;
    double version = 0.0;
    NSString *archiveKey = nil;
    NSEnumerator *enumerator = [aPlist keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil) {
        if ([key hasPrefix:@"Mac"]) {
            version = [[[key componentsSeparatedByString:@"-"] objectAtIndex:1] doubleValue];
            archiveKey = key;
        }
    }
    id crossPlatform = [aPlist objectForKey:@"cross-platform"];
    BOOL loaded = NO;
    double current = NSFoundationVersionNumber;
    double magnitude = current != 0.0 ? fabs(current) : 1.0;
    double magnitude2 = version != 0.0 ? fabs(version) : 1.0;
    if (magnitude2 <= magnitude)
        magnitude2 = magnitude;
    BOOL newer = magnitude2 * 1e-05 < fabs(current - version) && current <= version;
    if (!newer) {
        BOOL archiver = [archiveKey hasSuffix:@"-EXUseArchiver"];
        BOOL keyedArchiver = !archiver && [archiveKey hasSuffix:@"-EXUseKeyedArchiver"];
        if (archiver || keyedArchiver) {
            @try {
                NSData *data = [aPlist objectForKey:archiveKey];
                id value = archiver ? [NSUnarchiver unarchiveObjectWithData:data] : [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if (value != nil) {
                    [self setExtraValue:value forKey:aKey];
                    loaded = YES;
                }
            } @catch (NSException *exception) {
            }
        }
    }
    if (crossPlatform != nil && !loaded) {
        id value = [NSObject objectWithExtraDictionary:[aPlist objectForKey:@"cross-platform"]];
        if (value != nil)
            [self setExtraValue:value forKey:aKey];
    }
}

// A cross-platform dictionary plus an archive keyed by the Foundation version.
- (id)_extraPlistMultiRepresentationsOfValue:(id)aValue
{
    NSMutableDictionary *representations = [NSMutableDictionary dictionary];
    id crossPlatform = [aValue extraDictionaryRepresentation];
    if (crossPlatform != nil)
        [representations setObject:crossPlatform forKey:@"cross-platform"];
    double version = NSFoundationVersionNumber;
    if (version >= 462.0) {
        NSString *key = [[@"Mac" stringByAppendingFormat:@"-%f", version] extraKeyForKeyedArchiving];
        [representations setObject:[NSKeyedArchiver archivedDataWithRootObject:aValue] forKey:key];
    } else if (version >= 397.4) {
        NSString *key = [[@"Mac" stringByAppendingFormat:@"-%f", version] extraKeyForArchiving];
        [representations setObject:[NSArchiver archivedDataWithRootObject:aValue] forKey:key];
    }
    return [[representations copy] autorelease];
}

- (void)_extraLoadPlist:(id)aPlist forConformedCollectionKey:(id)aKey
{
    id value;
    if ([aPlist isKindOfClass:[NSDictionary class]])
        value = [self _extraConformedDictionaryFromPlist:aPlist];
    else
        value = [self _extraConformedArrayFromPlist:aPlist];
    [self setExtraValue:value forKey:aKey];
}

- (id)_extraPlistRepresentationOfConformedCollection:(id)aCollection
{
    if ([aCollection isKindOfClass:[NSDictionary class]])
        return [self _extraPlistFromConformedDictionary:aCollection];
    return [self _extraPlistFromConformedArray:aCollection];
}

- (id)_extraPlistFromConformedDictionary:(id)aDictionary
{
    NSEnumerator *enumerator = [aDictionary keyEnumerator];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithCapacity:[aDictionary count]];
    id key;
    while ((key = [enumerator nextObject]) != nil) {
        id value = [aDictionary objectForKey:key];
        if ([value conformsToProtocol:@protocol(EXKeyValueCoding)]) {
            id representation = [value extraDictionaryRepresentation];
            if (representation != nil)
                [plist setObject:representation forKey:key];
        }
    }
    return plist;
}

- (id)_extraPlistFromConformedArray:(id)aArray
{
    NSEnumerator *enumerator = [aArray objectEnumerator];
    NSMutableArray *plist = [NSMutableArray arrayWithCapacity:[aArray count]];
    id value;
    while ((value = [enumerator nextObject]) != nil) {
        if ([value conformsToProtocol:@protocol(EXKeyValueCoding)]) {
            id representation = [value extraDictionaryRepresentation];
            if (representation != nil)
                [plist addObject:representation];
        }
    }
    return plist;
}

- (id)_extraConformedArrayFromPlist:(id)aPlist
{
    NSEnumerator *enumerator = [aPlist objectEnumerator];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[aPlist count]];
    id representation;
    while ((representation = [enumerator nextObject]) != nil) {
        id object = [NSObject objectWithExtraDictionary:representation];
        if (object != nil)
            [array addObject:object];
    }
    return array;
}

- (id)_extraConformedDictionaryFromPlist:(id)aPlist
{
    NSEnumerator *enumerator = [aPlist keyEnumerator];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[aPlist count]];
    id key;
    while ((key = [enumerator nextObject]) != nil) {
        id object = [NSObject objectWithExtraDictionary:[aPlist objectForKey:key]];
        if (object != nil)
            [dictionary setObject:object forKey:key];
    }
    return dictionary;
}

// Archived values are unarchived; a value already present that can be
// post-loaded loads the dictionary in place (or is recreated when the stored
// class differs); other dictionaries with a class name become new objects.
- (void)_loadExtraSerializedValue:(id)aValue forKey:(id)aKey codingContext:(id)aContext
{
    NSMutableString *key = [NSMutableString stringWithString:aKey];
    if ([key extraReplaceString:@"-EXConformedCollection" withString:@""]) {
        [self _extraLoadPlist:aValue forConformedCollectionKey:key];
        return;
    }
    if ([key extraReplaceString:@"-EXMultiRepresentations" withString:@""]) {
        [self _extraLoadPlist:aValue forMultiRepresentationsKey:key];
        return;
    }
    BOOL archiver = [key extraReplaceString:@"-EXUseArchiver" withString:@""];
    BOOL keyedArchiver = !archiver && [key extraReplaceString:@"-EXUseKeyedArchiver" withString:@""];
    if (archiver || keyedArchiver) {
        id value = nil;
        @try {
            value = archiver ? [NSUnarchiver unarchiveObjectWithData:aValue] : [NSKeyedUnarchiver unarchiveObjectWithData:aValue];
        } @catch (NSException *exception) {
        }
        if (value != nil)
            [self setExtraValue:value forKey:key];
        return;
    }
    id current = nil;
    @try {
        current = [self extraValueForKey:key];
    } @catch (NSException *exception) {
    }
    if ([current conformsToProtocol:@protocol(EXKeyValueCoding)] && [current canBeExtraPostLoaded]) {
        id className = [aValue objectForKey:@"EXClassName"];
        if (className == nil || [NSStringFromClass([current class]) isEqual:className])
            [current loadExtraDictionaryRepresentation:aValue withCodingContext:aContext];
        else
            [self setExtraValue:[current reloadExtraDictionaryRepresentation:aValue] forKey:key];
        return;
    }
    id value = aValue;
    if ([aValue isKindOfClass:[NSDictionary class]] && [aValue objectForKey:@"EXClassName"] != nil)
        value = [NSObject objectWithExtraDictionary:aValue zone:[self zone] codingContext:aContext];
    [self setExtraValue:value forKey:key];
}

- (id)_extraSerializedValueForKey:(id)aKey codingContext:(id)aContext
{
    NSMutableString *key = [NSMutableString stringWithString:aKey];
    NSInteger way = EXCodingWayRemovingSuffix(key);
    return [[self extraValueForKey:key] _extraPlistValueWithCodingWay:way codingContext:aContext];
}

// Plain values are their own plist unless they are coded objects.
- (id)_extraPlistValueWithCodingWay:(NSInteger)aWay codingContext:(id)aContext
{
    switch (aWay) {
    case 1:
        return [NSArchiver archivedDataWithRootObject:self];
    case 2:
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    case 3:
        return [self _extraPlistRepresentationOfConformedCollection:self];
    case 4:
        return [self _extraPlistMultiRepresentationsOfValue:self];
    default:
        if ([self conformsToProtocol:@protocol(EXKeyValueCoding)])
            return [self extraDictionaryRepresentationWithCodingContext:aContext];
        return self;
    }
}

@end
