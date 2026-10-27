#import "HyperPlayerBasePrefix.h"


@protocol HSPauseViewDelegate <NSObject>
- (void)resumeButtonDidClick;
@end

@interface HSPauseView : NSView
{
    id <HSPauseViewDelegate> _delegate;
}
- (BOOL)acceptsFirstResponder;
- (void)mouseDown:(NSEvent *)aEvent;
- (void)drawRect:(NSRect)aRect;
- (void)resetCursorRects;
- (NSRect)pauseButtonFrame;
- (void)setDelegate:(id <HSPauseViewDelegate>)aDelegate;
@end
