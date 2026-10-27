#import "HyperEditorBasePrefix.h"


@interface HSImageCropView : BTToolView
{
    double _scaleFactor;
}
- (NSRect)convertImageRectToViewRect:(NSRect)aRect;
- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint;
- (CGAffineTransform)imageToViewTransform;
- (NSRect)convertViewRectToImageRect:(NSRect)aRect;
- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint;
- (CGAffineTransform)viewToImageTransform;
- (NSPoint)imageOffset;
- (id)undoManagerForTool:(id)aTool category:(id)aCategory;
- (void)setScaleFactor:(double)aFactor;
- (void)setFrameSize:(NSSize)aSize;
- (void)HSImageCropView_updateFrameSize;
- (double)scaleFactor;
- (void)setImage:(id)aImage;
- (id)initWithFrame:(NSRect)aFrame;
- (void)drawContentRect:(NSRect)aRect;
@end

