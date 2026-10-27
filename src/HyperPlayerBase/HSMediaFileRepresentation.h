#import "HyperPlayerBasePrefix.h"
#import "HSMediaRepresentation.h"


@interface HSMediaFileRepresentation : HSMediaRepresentation <HSPurgableObject, BTPurgableObject, NSObject>
{
    HSMediaFileRepresentation *_fileRepresentation;
    NSString *_filePath;
    BOOL _removeWhenDone;
    NSData *_data;
    NSString *_mediaType;
    FSRef _fsRef;
    BOOL _fsRefValid;
}
- (void)purge;
- (void)prepareToPurge;
- (NSUInteger)purgableSize;
- (id)debugDescription;
- (void)updatePathFromFSRefIfNeeded;
- (BOOL)isFilePathValid;
- (id)GPSDictionary;
- (BOOL)isValid;
- (id)mediaType;
- (id)mediaData;
- (id)resolvedPath;
- (id)path;
- (void)dealloc;
- (id)initWithRepresentation:(id)aRepresentation mediaType:(id)aType;
- (id)initWithPath:(id)aPath;
- (id)initWithPath:(id)aPath removeWhenDone:(BOOL)aDone;
@end

