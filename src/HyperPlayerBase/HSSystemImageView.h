#import "HyperPlayerBasePrefix.h"
#import "HSSystemObject.h"


@interface HSSystemImageView : HSSystemObject <HSSystemImageViewAttributes, HSImageMutableAttributes, HSImageAttributes, HSAttributes, HyperInterface, NSObject, HSImageAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSImageRectAttribute, HSMediaAttribute, HSSystemImageViewAlignmentAttribute, HSSystemImageViewFrameStyleAttribute, HSSystemImageViewScalingAttribute, HSSystemEditableAttribute, HSSystemEnabledAttribute, HSMediaObject, HSMediaAttributes, HSMediaUIDAttribute, HSDefaultSizeSubattributes>
{
    HSNewMedia *_media;
}
+ (Class)nodeDataClass;
- (id)HTML5UnsupportedFunctionalityDescription;
- (id)hyperSizeMaxValue;
- (id)hyperSizeMinValue;
- (NSSize)defaultSize;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)setEditable:(BOOL)aEditable;
- (BOOL)isEditable;
- (void)setHyperImageScaling:(NSUInteger)aScaling;
- (NSUInteger)hyperImageScaling;
- (void)setHyperImageFrameStyle:(NSUInteger)aStyle;
- (NSUInteger)hyperImageFrameStyle;
- (void)setHyperImageAlignment:(NSUInteger)aAlignment;
- (NSUInteger)hyperImageAlignment;
- (void)setImageWithPath:(id)aPath;
- (void)setImage:(id)aImage;
- (NSRect)imageRect;
- (BOOL)isImageComposite;
- (id)image;
- (id)queryNewHyperInterface:(id)aInterface;
- (void)setImageScaling:(NSUInteger)aScaling;
- (NSUInteger)imageScaling;
- (void)setImageFrameStyle:(NSUInteger)aStyle;
- (NSUInteger)imageFrameStyle;
- (void)setImageAlignment:(NSUInteger)aAlignment;
- (NSUInteger)imageAlignment;
- (id)queryImageWellObjectHitTester;
- (id)queryInteractivePlayerItem;
- (id)nameBaseTemplates;
- (void)setMedia:(id)aMedia;
- (void)setMedia:(id)aMedia error:(id *)aError;
- (id)media;
- (id)mediaUID;
- (void)didCreateSystemView;
- (id)placeholderSystemView;
- (id)hyperSystemView;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)initWithMedia:(id)aMedia;
- (id)initWithMedia:(id)aMedia error:(id *)aError;
@end

