#import "HyperStudioPrefix.h"


@interface HSProgressPlaceholderView : NSView
{
    NSProgressIndicator *_progressIndicator;
    BOOL _isSpinning;
    NSAttributedString *_title;
}
- (void)drawRect:(NSRect)aRect;
- (void)setIsSpinning:(BOOL)aSpinning;
- (BOOL)isSpinning;
- (void)dealloc;
- (void)setTitle:(id)aTitle;
- (id)title;
- (void)frameDidChanged:(id)aChanged;
- (id)initWithFrame:(NSRect)aFrame;
- (NSRect)progressIndicatorFrameForBounds:(NSRect)aBounds;
@end

