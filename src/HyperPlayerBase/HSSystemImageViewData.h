#import "HyperPlayerBasePrefix.h"
#import "HSSystemObjectData.h"


@interface HSSystemImageViewData : HSSystemObjectData
{
    HSNewMedia *_imageMedia;
    BOOL _imageValid;
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)setEditable:(BOOL)aEditable;
- (BOOL)isEditable;
- (void)setImageScaling:(NSUInteger)aScaling;
- (NSUInteger)imageScaling;
- (void)setImageFrameStyle:(NSUInteger)aStyle;
- (NSUInteger)imageFrameStyle;
- (void)setImageAlignment:(NSUInteger)aAlignment;
- (NSUInteger)imageAlignment;
- (void)setImageValid:(BOOL)aValid;
- (BOOL)isImageValid;
- (void)setImageMediaUID:(id)aUID;
- (id)imageMediaUID;
- (id)systemImageViewForSetAccessor;
- (id)systemImageViewForGetAccessor;
- (void)dealloc;
- (id)init;
- (id)templateCocoaView;
@end

