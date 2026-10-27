#import "HyperPlayerBasePrefix.h"


@interface HSInfoObjectProvider : NSObject
{
    NSMutableDictionary *_namedObjects;
    NSMutableArray *_objects;
    NSDictionary *_defaults;
    NSString *_defaultItem;
}
+ (id)sharedProvider;
+ (Class)infoObjectClass;
- (void)unregisterInfoObject:(id)aObject;
- (id)registeredInfoObject:(id)aObject;
- (id)objectDefaults;
- (id)objects;
- (id)namedObjects;
- (void)addCustomInfo;
- (void)addCustomInfoAtPath:(id)aPath;
- (void)addCustomInfoFile:(id)aFile;
- (void)dealloc;
- (id)initWithFileName:(id)aName;
- (id)initWithPropertyList:(id)aList;
@end

@interface HSInfoObject : NSObject <EXKeyValueCoding>
{
    unsigned int _ownerCount;
    NSString *_title;
    NSDictionary *_info;
    NSMutableDictionary *_mutableInfo;
}
+ (id)sharedProvider;
+ (Class)providerClass;
+ (id)providerKey;
- (id)title;
- (id)mutableInfo;
- (id)info;
- (void)unregisterFromProvider;
- (id)registeredInProvider;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
- (id)_info;
- (void)releaseOwnerCount;
- (void)retainOwnerCount;
- (void)dealloc;
- (id)initWithTitle:(id)aTitle info:(id)aInfo;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
@end

