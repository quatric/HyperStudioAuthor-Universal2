#import "HyperStudioPrefix.h"
#import "HSFrameResizeSelectionTracker.h"


@interface HSImageObjectFrameResizeSelectionTracker : HSFrameResizeSelectionTracker
{
    NSRect _imageRectBeforeResize;
    NSSize _sizeBeforeResize;
    CGRect _startClipPathsBounds;
    NSRect _startRelativeImageRect;
    BOOL _needEnableOutline;
}
- (id)mutableClipPathsAttributes;
- (id)mutableImageRectAttributes;
- (void)updateStartClipPathsBounds;
- (BOOL)adjustSize:(NSSize *)aSize;
- (void)didResizeCardObject;
- (void)willResizeCardObject;
- (void)flagsChanged:(id)aChanged inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)preprocessMouseDown:(id)aDown inView:(id)aView;
- (id)HSFrameResizeSelection_undoManager;
@end

