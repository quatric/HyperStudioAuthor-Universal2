#import "HyperPlayerBasePrefix.h"


@interface EXCodingContext : NSObject
{
    NSString *_codingOperation;
    BOOL _shouldZeroMissingValuesOnLoading;
    NSDictionary *_options;
}
+ (id)codingContextWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading options:(id)aOptions;
+ (id)codingContextWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading;
+ (id)defaultCodingContext;
- (id)options;
- (BOOL)shouldZeroMissingValuesOnLoading;
- (id)codingOperation;
- (void)dealloc;
- (id)initWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading options:(id)aOptions;
- (id)initWithOperation:(id)aOperation shouldZeroMissingValuesOnLoading:(BOOL)aLoading;
@end

@interface _EXInitializer : NSObject
{
    SEL _initSelector;
    id _arguments;
}
- (id)initTarget:(id)aTarget;
- (void)setInitSelector:(id)aSelector;
- (id)initSelector;
- (void)dealloc;
@end

@interface NSObject (EXKeyValueCodingBackwardCompatibility)
+ (BOOL)overridesSelector:(SEL)aSelector ofBaseClass:(Class)aClass;
@end

@interface NSDictionary (EXObjectVersion)
- (CGFloat)extraCodingVersion;
@end

@interface NSString (EXKeyValueSuffixes)
- (id)extraNormalizedKey;
- (id)extraKeyForMultiRepresentations;
- (id)extraKeyForCollection;
- (id)extraKeyForKeyedArchiving;
- (id)extraKeyForArchiving;
@end

@interface NSString (EXASCIIPlistReading)
- (BOOL)charValue;
@end

@interface NSObject (EXKeyValueCoding)
+ (id)extraClassNameForStoring;
+ (id)objectWithExtraDictionary:(id)aDictionary;
+ (id)objectWithExtraDictionary:(id)aDictionary zone:(NSZone *)aZone;
+ (id)objectWithExtraDictionary:(id)aDictionary zone:(NSZone *)aZone codingContext:(id)aContext;
- (id)extraPlistValue;
- (id)extraPlistValueWithCodingContext:(id)aContext;
- (id)extraPlistValueWithKey:(id)aKey codingContext:(id)aContext;
- (id)reloadExtraDictionaryRepresentation:(id)aRepresentation;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
- (BOOL)canHaveExtraInitializer;
- (id)extraInit;
- (id)extraClassNameForStoring;
- (CGFloat)extraCodingVersion;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentation;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation;
- (id)initWithExtraDictionary:(id)aDictionary;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (id)extraValueForKey:(id)aKey;
- (void)setExtraValue:(id)aValue forKey:(id)aKey;
- (void)_extraLoadPlist:(id)aPlist forMultiRepresentationsKey:(id)aKey;
- (id)_extraPlistMultiRepresentationsOfValue:(id)aValue;
- (void)_extraLoadPlist:(id)aPlist forConformedCollectionKey:(id)aKey;
- (id)_extraPlistRepresentationOfConformedCollection:(id)aCollection;
- (id)_extraPlistFromConformedDictionary:(id)aDictionary;
- (id)_extraPlistFromConformedArray:(id)aArray;
- (id)_extraConformedArrayFromPlist:(id)aPlist;
- (id)_extraConformedDictionaryFromPlist:(id)aPlist;
- (void)_loadExtraSerializedValue:(id)aValue forKey:(id)aKey codingContext:(id)aContext;
- (id)_extraSerializedValueForKey:(id)aKey codingContext:(id)aContext;
- (id)_extraPlistValueWithCodingWay:(NSInteger)aWay codingContext:(id)aContext;
@end

