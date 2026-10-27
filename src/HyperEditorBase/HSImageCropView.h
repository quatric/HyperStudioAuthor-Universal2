#import "HyperEditorBasePrefix.h"


@interface HSImageCropView : BTToolView
{
    double _scaleFactor;
    NSColor *_backgroundColor;
    id _delegate;
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
- (void)dealloc;
- (void)mouseEntered:(id)aEvent;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)backgroundColor;
- (void)setBackgroundColor:(id)aColor;
@end

