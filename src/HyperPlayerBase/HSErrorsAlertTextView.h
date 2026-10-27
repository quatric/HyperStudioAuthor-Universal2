#import "HyperPlayerBasePrefix.h"


@interface HSErrorsAlertTextView : NSTextView
{
    BOOL _inited;
    NSArray *_highlitedRanges;
    NSMutableArray *_highlightedRects;
    NSColor *_highlitedFillColor;
    NSColor *_highlitedLineColor;
}
- (void)highlightedRectsCalculation;
- (void)drawRect:(NSRect)aRect;
- (void)setHighlitedRanges:(id)aRanges;
- (id)highlitedRanges;
- (void)dealloc;
- (void)onceInit;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame textContainer:(id)aContainer;
@end

