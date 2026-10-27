#import "HyperStudioPrefix.h"


@interface HSNotSizeableView : NSView
{
    NSSize _minSize;
    NSSize _maxSize;
    NSSize _windowMaxSize;
    NSSize _windowMinSize;
    NSSize _lastMinSize;
    NSSize _lastMaxSize;
    BOOL _minSizeInited;
    BOOL _maxSizeInited;
}
- (void)removeFromSuperview;
- (void)viewDidMoveToWindow;
- (void)viewDidFinishResizingInWindow;
- (NSSize)minSize;
- (NSSize)maxSize;
- (void)setMaxSize:(NSSize)aSize minSize:(NSSize)aSize2;
- (void)setMinSize:(NSSize)aSize;
- (void)setMaxSize:(NSSize)aSize;
- (id)initWithFrame:(NSRect)aFrame;
@end

