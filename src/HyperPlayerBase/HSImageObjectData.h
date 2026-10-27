#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSImageObjectData : HSShadowedObjectData <HSGraphicsDelegate, HyperInterface, NSObject, HSCroppedImageLegacyStoringOwner>
{
    HSImage *_originalImage;
    HSImage *_effectedImage;
    HSCroppedImageLegacyStoring *_legacyImageStoring;
    BOOL _bordered;
    NSColor *_borderColor;
    float _borderWidth;
    NSRect _relativeImageRect;
    NSBezierPath *_borderPath;
    NSBezierPath *_relativeBorderPath;
    NSArray *_initialClipPaths;
    BOOL _canRestoreToInitialClipPaths;
    BOOL _canBeHighlighted;
}
+ (id)nodeDataKeysToNodeKeysMap;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)undoManagerForGraphics:(id)aGraphics;
- (void)hyperVisualAttributesChanged:(id)aChanged;
- (void)setRelativeImageRectAsString:(id)aString;
- (id)relativeImageRectAsString;
- (void)setRelativeImageRect:(NSRect)aRect;
- (NSRect)relativeImageRect;
- (void)setCanRestoreClipPathsNumber:(id)aNumber;
- (id)canRestoreClipPathsNumber;
- (void)setCanRestoreToInitialClipPaths:(BOOL)aPaths;
- (BOOL)canRestoreToInitialClipPaths;
- (void)setInitialClipPaths:(id)aPaths;
- (id)initialClipPaths;
- (void)setBinaryInitialClipPaths:(id)aPaths;
- (id)binaryInitialClipPaths;
- (void)setCanBeHighlighted:(BOOL)aHighlighted;
- (BOOL)canBeHighlighted;
- (void)setRelativeBorderPath:(id)aPath;
- (id)relativeBorderPath;
- (void)setBorderPath:(id)aPath;
- (id)borderPath;
- (void)setBorderWidth:(CGFloat)aWidth;
- (CGFloat)borderWidth;
- (void)setBorderColor:(id)aColor;
- (id)borderColor;
- (void)setBordered:(BOOL)aBordered;
- (BOOL)isBordered;
- (id)currentImage;
- (void)setEffectedMediaUID:(id)aUID;
- (id)effectedMediaUID;
- (void)setEffectedImage:(id)aImage;
- (id)effectedImage;
- (void)setOriginalMediaUID:(id)aUID;
- (id)originalMediaUID;
- (void)setOriginalMediaUIDPost670Format:(id)aFormat;
- (id)originalMediaUIDPost670Format;
- (void)setOriginalImage:(id)aImage;
- (id)originalImage;
- (id)legacyCroppedImageMedia;
- (void)setLegacyCroppedImageMedia:(id)aMedia;
- (void)setImage:(id)aImage;
- (id)image;
- (id)croppedImageLegacyStoring;
- (id)imageObjectForLegacyImageStoring:(id)aStoring;
- (void)willRemoveOwningObjectFromDocument:(id)aDocument;
- (void)didAddOwningObjectToDocument:(id)aDocument;
- (void)dealloc;
- (id)init;
@end

