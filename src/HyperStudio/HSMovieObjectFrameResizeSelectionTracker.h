#import "HyperStudioPrefix.h"
#import "HSFrameResizeSelectionTracker.h"


@interface HSMovieObjectFrameResizeSelectionTracker : HSFrameResizeSelectionTracker
{
    NSSize _uncroppedFrameSize;
    NSRect _startRelativeMovieSourceRect;
}
- (void)mouseUp:(id)aUp inView:(id)aView;
- (BOOL)adjustSize:(NSSize *)aSize;
- (void)didResizeCardObject;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (id)mutableMovieAttributes;
@end

