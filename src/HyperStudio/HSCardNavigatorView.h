#import "HyperStudioPrefix.h"


@interface HSCardNavigatorView : NSView
{
    HSCard *_card;
    NSImage *_cachedCardImage;
    NSColor *_backgroundColor;
    NSColor *_visibleFrameColor;
    NSColor *_secondVisibleFrameColor;
    NSRect _cardRepresentationRect;
    id _delegate;
}
+ (id)defaultSecondVisibleFrameColor;
+ (id)defaultVisibleFrameColor;
+ (id)defaultBackgroundColor;
+ (id)patternColor;
- (void)mouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (BOOL)mouseDownCanMoveWindow;
- (void)scrollCardViewToRectWithCenterAtLocalPoint:(NSPoint)aPoint;
- (id)secondVisibleFrameColor;
- (void)setSecondVisibleFrameColor:(id)aColor;
- (id)visibleFrameColor;
- (void)setVisibleFrameColor:(id)aColor;
- (id)backgroundColor;
- (void)setBackgroundColor:(id)aColor;
- (void)deskPatternChanged:(id)aChanged;
- (CGFloat)frameHeightAccordingToCardProporsions;
- (void)setFrameSizeAccordingToCardProporsions;
- (NSRect)cardRect;
- (NSRect)visibleFrame;
- (void)updateCachedImage;
- (void)invalidateCachedImage;
- (void)visualAttributeDidChange:(id)aChange;
- (id)card;
- (void)setCard:(id)aCard;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

