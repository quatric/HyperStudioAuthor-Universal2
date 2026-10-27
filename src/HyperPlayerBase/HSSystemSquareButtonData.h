#import "HyperPlayerBasePrefix.h"
#import "HSSystemButtonData.h"


@interface HSSystemSquareButtonData : HSSystemButtonData
{
    HSNewMedia *_imageMedia;
    BOOL _imageValid;
    HSNewMedia *_alternateImageMedia;
    BOOL _alternateImageValid;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setImagePosition:(NSUInteger)aPosition;
- (NSUInteger)imagePosition;
- (void)setAlternateImageValid:(BOOL)aValid;
- (BOOL)isAlternateImageValid;
- (void)setAlternateImageMediaUID:(id)aUID;
- (id)alternateImageMediaUID;
- (void)setImageValid:(BOOL)aValid;
- (BOOL)isImageValid;
- (void)setImageMediaUID:(id)aUID;
- (id)imageMediaUID;
- (void)dealloc;
- (id)templateCocoaView;
@end

