#import "HyperPlayerBasePrefix.h"
#import "HSGraphics.h"


@interface HSImage : HSGraphics <HSMutableImage, HSImage, HSGraphics, HyperInterface, NSObject, EXKeyValueCoding, NSCopying, HSMutableGraphics, HSMediaCopySupport>
{
    HSNewMedia *_imageMedia;
    unsigned int _imageAlignment;
    int _imageScaling;
    NSSize _imageSize;
}
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)setHyperImageUID:(id)aUID;
- (id)mediaUIDs;
- (id)ownedMediaUIDs;
- (id)copyWithZone:(NSZone *)aZone;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setSizeAsString:(id)aString;
- (id)sizeAsString;
- (void)setImageData:(id)aData;
- (id)imageData;
- (id)image;
- (void)setImageUID:(id)aUID;
- (id)imageUID;
- (void)setMedia:(id)aMedia;
- (id)media;
- (void)setHyperImageScaling:(NSInteger)aScaling;
- (void)setImageScaling:(NSInteger)aScaling;
- (void)setHyperImageAlignment:(NSUInteger)aAlignment;
- (void)setImageAlignment:(NSUInteger)aAlignment;
- (void)setHyperImage:(id)aImage;
- (void)setHyperImageFromPath:(id)aPath;
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)setHyperImageSize:(NSSize)aSize;
- (NSSize)hyperImageSize;
- (NSInteger)hyperImageScaling;
- (NSUInteger)hyperImageAlignment;
- (id)hyperImage;
- (id)hyperData;
- (void)dealloc;
@end

