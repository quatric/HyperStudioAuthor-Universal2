#import "HyperStudioPrefix.h"
#import "HSOpaqueView.h"


@interface HSObjectAssistantContainerView : HSOpaqueView
{
    NSBezierPath *_contentPath;
    NSBezierPath *_bottomAreaPath;
    BOOL _separatesBottomArea;
}
- (void)setFrameSize:(NSSize)aSize;
- (BOOL)mouseDownCanMoveWindow;
- (void)drawRect:(NSRect)aRect;
- (id)bottomAreaPath;
- (id)contentPath;
- (void)setSeparatesBottomArea:(BOOL)aArea;
- (BOOL)separatesBottomArea;
- (void)dealloc;
@end

