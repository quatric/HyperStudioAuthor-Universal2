#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMediaFileWrapper : NSFileWrapper
{
    HSNewMedia *_media;
}
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames;
- (NSInteger)writeToStream:(id)aStream retrying:(BOOL)aRetrying CRC32:(unsigned int *)a32 writtenLength:(unsigned int *)aLength error:(id *)aError;
- (id)regularFileContents;
- (void)dealloc;
- (id)initWithMedia:(id)aMedia;
@end

@interface HSNewMedia : HSWeaklyReferencedObject <EXKeyValueCoding>
{
    HSUID *_uid;
    NSString *_mediaName;
    int _mediaGroup;
    NSMutableArray *_representations;
    unsigned int _storageRetainCount;
}
+ (id)crossplatformCompatibleMediaTypes;
+ (id)filteredTypeForFileType:(id)aType;
+ (id)uniqueTempPathWithExtension:(id)aExtension baseName:(id)aName;
+ (NSInteger)mediaGroupForMediaType:(id)aType;
+ (id)mediaTypesByGroups;
+ (id)extraClassNameForStoring;
+ (id)mediaWithPasteboard:(id)aPasteboard mediaGroup:(NSInteger)aGroup;
+ (BOOL)canInitMediaWithPasteboard:(id)aPasteboard mediaGroup:(NSInteger)aGroup;
+ (id)mediaWithQTMovie:(id)aMovie name:(id)aName type:(id)aType;
+ (id)mediaWithImage:(id)aImage;
+ (id)mediaWithImage:(id)aImage name:(id)aName;
+ (id)mediaWithMedia:(id)aMedia type:(id)aType;
+ (id)mediaWithPath:(id)aPath;
+ (id)mediaWithPath:(id)aPath mediaUID:(id)aUID;
+ (id)mediaWithPath:(id)aPath removeWhenDone:(BOOL)aDone;
+ (id)mediaWithPath:(id)aPath name:(id)aName;
+ (id)mediaWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone;
+ (id)mediaWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone mediaUID:(id)aUID;
+ (id)mediaWithData:(id)aData name:(id)aName type:(id)aType;
- (id)debugDescription;
- (id)auxiliaryPreferedFilenameForName:(id)aName;
- (id)auxiliaryMediaType;
- (id)auxiliaryMediaData;
- (BOOL)shouldStoreAuxiliaryMediaData;
- (id)GPSDictionary;
- (id)fullPathToMediaFile;
- (id)fullPathToMediaFileCreateIfNeeded:(BOOL)aNeeded;
- (NSInteger)mediaGroupForMediaAtPath:(id)aPath;
- (id)mediaTypesFromDictionary:(id)aDictionary forFileType:(id)aType;
- (BOOL)canUseMediaFromPath:(id)aPath forMediaType:(NSInteger)aType;
- (id)dictionaryRepresentation;
- (id)extraClassNameForStoring;
- (NSInteger)writeToStream:(id)aStream retrying:(BOOL)aRetrying CRC32:(unsigned int *)a32 writtenLength:(unsigned int *)aLength error:(id *)aError;
- (BOOL)HSNewMedia_writeFileAtPath:(id)aPath toStream:(id)aStream CRC32:(unsigned int *)a32 writtenLength:(unsigned int *)aLength error:(id *)aError failedToRead:(BOOL *)aRead failedToWrite:(BOOL *)aWrite tempFilePath:(id *)aPath2;
- (id)HSNewMedia_generateTempFilePath;
- (BOOL)HSNewMedia_shouldWriteToTempFile;
- (BOOL)isValid;
- (id)mediaData;
- (id)mediaName;
- (id)mediaType;
- (void)setMediaPath:(id)aPath;
- (id)mediaPath;
- (NSInteger)mediaGroup;
- (id)mediaUID;
- (id)representations;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)incrementStorageRetainCountBy:(NSUInteger)aBy;
- (NSUInteger)storageRetainCount;
- (void)resetStorageRetainCount;
- (void)dealloc;
- (id)initWithMedia:(id)aMedia type:(id)aType;
- (id)initWithMediaUID:(id)aUID representation:(id)aRepresentation name:(id)aName;
- (id)initWithPath:(id)aPath;
- (id)initWithPath:(id)aPath mediaUID:(id)aUID;
- (id)initWithPath:(id)aPath removeWhenDone:(BOOL)aDone;
- (id)initWithPath:(id)aPath name:(id)aName;
- (id)initWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone;
- (id)initWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone mediaUID:(id)aUID;
- (id)initWithData:(id)aData name:(id)aName type:(id)aType;
@end

@interface HSNewMedia (StoringSupport)
- (id)fileWrapper;
@end

