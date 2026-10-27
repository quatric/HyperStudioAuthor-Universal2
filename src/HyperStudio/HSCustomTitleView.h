#import "HyperStudioPrefix.h"


@interface HSCustomTitleView : HSTexturedView
{
    NSTextFieldCell *_titleCell;
    NSColor *_frontColor;
    NSColor *_shadowColor;
    NSSize _shadowOffset;
    BOOL _drawsTitle;
    NSWindow *_ownerWindow;
}
- (void)setTitleFrontColor:(id)aColor;
- (id)titleFrontColor;
- (void)setTitleShadowColor:(id)aColor;
- (id)titleShadowColor;
- (void)setTitleShadowOffset:(NSSize)aOffset;
- (NSSize)titleShadowOffset;
- (void)setDrawsTitle:(BOOL)aTitle;
- (BOOL)drawsTitle;
- (id)ownerWindow;
- (void)mouseDown:(id)aDown;
- (void)drawRect:(NSRect)aRect;
- (id)_titleCell;
- (id)_titleFont;
- (CGFloat)_titleFontSize;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame ownerWindow:(id)aWindow;
@end

@interface NSWindow (HSCustomTitleExtension)
- (id)hyperCustomTitleView;
@end

