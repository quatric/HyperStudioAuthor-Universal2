#import "HyperPlayerBasePrefix.h"


@interface HSCroppedImageLegacyStoring : NSObject <EXKeyValueCoding, HSPromisedMediaDataRepresentationOwner>
{
    id<HSCroppedImageLegacyStoringOwner> _owner;
    HSNewMedia *_croppedImageMedia;
    HSNewMedia *_promisedMedia;
    HSPromisedMediaDataRepresentation *_promisedMediaRepresentation;
    BOOL _hasExternalMedia;
}
+ (id)extraClassNameForStoring;
+ (id)croppedImageLegacyStoringWithOwner:(id)aOwner;
- (id)mediaTypeForPromisedDataRepresentation:(id)aRepresentation;
- (id)mediaDataForPromisedDataRepresentation:(id)aRepresentation;
- (void)setEffectedImageBoundsAsString:(id)aString;
- (id)effectedImageBoundsAsString;
- (id)extraClassNameForStoring;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)imageUID;
- (void)setLegacyCroppedImageMedia:(id)aMedia;
- (void)setLegacyCroppedImageMedia:(id)aMedia externalMedia:(BOOL)aMedia2;
- (id)legacyCroppedImageMedia;
- (void)recreateLegacyCroppedImageMediaIfNeeded;
- (BOOL)shouldUsePromisedCroppedImageMedia;
- (id)promisedMedia;
- (id)uniqueNameForPromisedMedia;
- (void)dealloc;
- (id)initWithOwner:(id)aOwner;
@end

