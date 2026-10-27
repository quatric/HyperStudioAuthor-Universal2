#import "HyperPlayerBasePrefix.h"
#import "HSSystemPushButton.h"


@interface HSSystemSquareButton : HSSystemPushButton <HSSystemSquareButtonAttributes, HSSystemPushButtonAttributes, HSSystemButtonAttributes, HSAttributes, HyperInterface, NSObject, HSTitleMutableAttributes, HSTitleAttributes, HSTitleStringAttribute, HSTitleAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSTitleFontAttribute, HSTitleRectAttribute, HSSystemControlSizeAttribute, HSSystemButtonBorderAttribute, HSSystemTransparencyAttribute, HSSystemButtonContinuousAttribute, HSSystemEnabledAttribute, HSSystemSquareButtonImageAttribute, HSImageAttribute, HSMediaUIDAttribute, HSMediaAttribute, HSSystemSquareButtonImageRectAttribute, HSVisualSystemSquareButtonAlternateImageAttribute, HSSystemSquareButtonAlternateImageAttribute, HSSystemSquareButtonImagePositionAttribute, HSMediaObject, HSMediaAttributes>
{
    HSNewMedia *_imageMedia;
    HSNewMedia *_alternateMedia;
}
+ (Class)nodeDataClass;
- (BOOL)isHyperEqual:(id)aEqual;
- (id)hyperSizeMaxValue;
- (id)hyperSizeMinValue;
- (NSUInteger)hyperTitleAlignment;
- (BOOL)hasHyperTitle;
- (void)setTitle:(id)aTitle;
- (BOOL)canResizeVertically;
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically;
- (void)setImagePosition:(NSUInteger)aPosition;
- (NSUInteger)imagePosition;
- (void)setAlternateImage:(id)aImage;
- (id)alternateImage;
- (void)setImageFromPath:(id)aPath;
- (void)setImage:(id)aImage;
- (id)image;
- (id)mediaUID;
- (id)nameBaseTemplates;
- (id)mediaUIDs;
- (void)setAlternateMedia:(id)aMedia;
- (id)alternateMedia;
- (void)setAlternateImageMediaUID:(id)aUID;
- (id)alternateImageMediaUID;
- (void)setImageMediaUID:(id)aUID;
- (id)imageMediaUID;
- (void)setMedia:(id)aMedia error:(id *)aError;
- (void)setMedia:(id)aMedia;
- (id)media;
- (void)systemButtonSetAlternateImage:(id)aImage;
- (void)systemButtonSetImage:(id)aImage;
- (void)didCreateSystemView;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)initWithMedia:(id)aMedia;
- (id)initWithMedia:(id)aMedia error:(id *)aError;
@end

