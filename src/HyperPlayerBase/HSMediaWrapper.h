#import "HyperPlayerBasePrefix.h"


@interface HSMediaWrapper : NSObject <EXKeyValueCoding, NSCopying>
{
    NSFileWrapper *_wrapper;
    HSUID *_uid;
    unsigned int _storageRetainCount;
    NSString *_mediaName;
    NSString *_mediaPath;
    NSString *_fullPathToMediaFile;
    BOOL _isFullPathTemporary;
    struct AliasRecord **_fileAlias;
    int _mediaGroup;
    NSString *_mediaType;
    NSNumber *_hfsTypeCode;
    NSNumber *_hfsCreatorCode;
    BOOL _isRestoredHFSAttributes;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setFullPathToMediaFile:(id)aFile isTemporary:(BOOL)aTemporary;
- (void)setFileWrapper:(id)aWrapper;
- (id)fileWrapper;
- (id)mediaPath;
- (void)releaseStorage;
- (id)retainStorage;
- (NSUInteger)storageRetainCount;
- (id)description;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithUID:(id)aUID mediaName:(id)aName fileWrapper:(id)aWrapper keyForFileWrapper:(id)aWrapper2;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
@end

@interface HSMediaWrapper (HSMediaWrapperPublic)
- (void)HSMediaWrapper_saveOrRestoreFileAttributes;
- (BOOL)canUseMediaFromPath:(id)aPath forMediaType:(NSInteger)aType;
- (id)mediaTypesFromDictionary:(id)aDictionary forFileType:(id)aType;
- (NSInteger)mediaTypeForMediaAtPath:(id)aPath;
- (id)mediaTypesByGroups;
- (id)dictionaryRepresentation;
- (id)fullPathToMediaFile;
- (id)mediaDataSize;
- (id)mediaData;
- (id)mediaName;
- (NSInteger)mediaGroup;
- (id)mediaType;
- (id)mediaUID;
@end

