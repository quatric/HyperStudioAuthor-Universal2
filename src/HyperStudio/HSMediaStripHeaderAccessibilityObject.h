#import "HyperStudioPrefix.h"


@interface HSMediaStripHeaderAccessibilityObject : NSObject
{
    HSMediaStripScrollView *_owner;
}
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
- (void)accessibilityPerformAction:(id)aAction;
- (id)accessibilityActionDescription:(id)aDescription;
- (id)accessibilityActionNames;
- (void)accessibilitySetValue:(id)aValue forAttribute:(id)aAttribute;
- (BOOL)accessibilityIsAttributeSettable:(id)aSettable;
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityAttributeNames;
- (id)initWithOwner:(id)aOwner;
@end

@interface HSMediaStripScrollView : NSScrollView
{
    NSString *_title;
    NSRect _titleRect;
    NSRect _footerRect;
    NSRect _boundsRect;
    NSRect _endRollingRect;
    BOOL _titleHeightAndOriginValid;
    NSTimer *_rollTimer;
    double _rollStartTime;
    double _rollInterval;
    float _rollDelta;
    NSImage *_headerImage;
    NSImage *_footerImage;
    NSImage *_backgroundImage;
    NSImage *_filmPartImage;
    NSImage *_offscreenCache;
    NSColor *_patternColor;
    BOOL _cornerSplitterShown;
    BOOL _isRolling;
    id _cornerSplitter;
    id _headerAccessibilityObject;
}
- (void)setDocumentView:(id)aView;
- (void)setHorizontalScroller:(id)aScroller;
- (void)setVerticalScroller:(id)aScroller;
- (BOOL)hasHorizontalScroller;
- (void)setHasHorizontalScroller:(BOOL)aScroller;
- (BOOL)hasVerticalScroller;
- (void)setHasVerticalScroller:(BOOL)aScroller;
- (void)scrollWheel:(id)aWheel;
- (void)mouseDown:(id)aDown;
- (id)view:(id)aView stringForToolTip:(NSInteger)aTip point:(NSPoint)aPoint userData:(void *)aData;
- (void)drawRect:(NSRect)aRect;
- (void)drawBackgroundImageAsPatternInRect:(NSRect)aRect;
- (void)tile;
- (void)reflectScrolledClipView:(id)aView;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)stopRolling:(id)aRolling;
- (BOOL)isRollingRolling;
- (BOOL)isRolling;
- (void)startRolling:(id)aRolling;
- (void)startUnrolling:(id)aUnrolling;
- (void)unrollImmediately;
- (void)unroll:(id)aUnroll;
- (void)roll:(id)aRoll;
- (void)scrollDownAction:(id)aAction;
- (void)scrollUpAction:(id)aAction;
- (void)setShowsStopButton:(BOOL)aButton;
- (BOOL)showsStopButton;
- (void)setCornerSplitter:(id)aSplitter;
- (id)cornerSplitter;
- (void)setCornerSplitterShown:(BOOL)aShown;
- (BOOL)isCornerSplitterShown;
- (id)mediaStripScroller;
- (id)mediaStripView;
- (void)setTitle:(id)aTitle;
- (id)title;
- (BOOL)isOpaque;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
- (id)patternColor;
- (NSRect)headerRect;
- (NSRect)scrollerRect;
- (NSRect)cornerSplitterRectForBounds:(NSRect)aBounds scrollerRect:(NSRect *)aRect;
- (NSRect)contentRectForBounds:(NSRect)aBounds headerMaxY:(CGFloat)aY footerMaxY:(CGFloat)aY2;
- (NSRect)contentRectForBounds:(NSRect)aBounds headerMaxY:(CGFloat)aY scrollerMinX:(CGFloat)aX;
- (NSRect)scrollerRectForBounds:(NSRect)aBounds headerMaxY:(CGFloat)aY;
- (NSRect)contentBounds;
@end

