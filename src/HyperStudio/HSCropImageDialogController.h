#import "HyperStudioPrefix.h"


@interface HSCropImageDialogController : NSWindowController
{
    NSScrollView *_scrollView;
    HSImageCropView *_imageCropView;
    NSSlider *_scaleSlider;
    NSMatrix *_toolMatrix;
    NSButton *_helpButton;
    NSButton *_OKButton;
    NSSlider *_toleranceSlider;
    NSView *_sensitivityView;
    NSView *_scalingView;
    int _selectedToolTag;
    float _selectionTolerance;
    float _selectionAlternateProportion;
    BOOL _isFlippedVertically;
    BOOL _isFlippedHorizontally;
}
- (void)clipViewBoundsChanged:(id)aChanged;
- (void)clipViewFrameChanged:(id)aChanged;
- (void)setupSelectionToolForResizeAndRotateOperation:(id *)aOperation;
- (id)toolForTag:(NSInteger)aTag;
- (id)magicLassoCreateSelectionTool;
- (id)shapeCreateSelectionToolWithPath:(id)aPath;
- (void)selectionToleranceChanged:(id)aChanged;
- (void)selectAllArea:(id)aArea;
- (void)toolChanged:(id)aChanged;
- (void)zoomMax:(id)aMax;
- (void)zoomMin:(id)aMin;
- (void)scaleChanged:(id)aChanged;
- (void)openHelp:(id)aHelp;
- (void)cancel:(id)aCancel;
- (void)crop:(id)aCrop;
- (void)closeDialogWithCode:(NSInteger)aCode;
- (void)setOKButtonTitle:(id)aTitle;
- (void)ensureNibIsLoaded;
- (void)setFlippedHorizontally:(BOOL)aHorizontally;
- (void)setFlippedVertically:(BOOL)aVertically;
- (void)setSelectionAlternateProportion:(CGFloat)aProportion;
- (CGFloat)selectionAlternateProportion;
- (CGFloat)selectionTolerance;
- (void)setSelectionTolerance:(CGFloat)aTolerance;
- (id)croppedImage;
- (BOOL)hasValidCropPath;
- (NSRect)croppedImageFrame;
- (struct CGPath *)borderPath;
- (struct CGPath *)cgPath;
- (void)setSourceNSImage:(id)aImage;
- (void)setSourceCGImage:(struct CGImage *)aImage size:(CGSize)aSize;
- (void)setSourceCGImage:(struct CGImage *)aImage;
- (void)setSourceImage:(id)aImage size:(CGSize)aSize;
- (void)setSourceImage:(id)aImage;
- (void)awakeFromNib;
- (void)validateToleranceSlider;
- (id)windowNibName;
- (void)dealloc;
- (id)init;
- (id)cropTool;
- (NSRect)croppedImageFrameClippedToOriginalImageBounds:(BOOL)aClipped;
- (id)croppedImageClippedToOriginalImageBounds:(BOOL)aClipped;
- (id)croppedImageWithHorizontalSelection;
- (id)croppedImageWithHorizontalSelectionClippedToOriginalImageBounds:(BOOL)aClipped;
- (NSSize)croppedImageWithHorizontalSelectionSize;
- (id)defaultCropTool;
- (void)hideToolMatrix;
- (id)rotateImage:(id)aImage rotationAngle:(float)aAngle;
- (CGRect)selectionBounds;
- (float)selectionRotationAngle;
@end

@interface HSScaledBTCGImage : NSObject <BTCGImage, BTImage, NSObject>
{
    id<BTCGImage> _image;
    NSSize _imageScaling;
}
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint;
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect;
- (CGSize)imageSize;
- (id)initWithBTCGImage:(id)aImage imageScaling:(NSSize)aScaling;
- (void)dealloc;
@end

