#import "HyperEditorBasePrefix.h"


@interface HSPaneScroller : NSScroller
{
    NSImage * _scrollerImages[13];
    NSRect _scrollerImagesRects[9];
    BOOL _isScrollerTogether;
}
- (BOOL)isScrollerTogether;
- (void)loadScrollerImages;
- (void)applyFlipToImagesIfNeeded;
- (NSRect)imageRect:(id)aRect;
- (NSRect)rectForImagePosition:(NSInteger)aPosition;
- (void)drawKnobSlotInRect:(NSRect)aRect highlight:(BOOL)aHighlight;
- (void)drawKnob;
- (void)drawArrow:(NSInteger)aArrow highlightPart:(NSInteger)aPart;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame;
- (void)defaultInitialization;
@end

