#import "HSColoredDividerSplitView.h"

@implementation HSColoredDividerSplitView

- (void)setDividerFillColor:(id)aColor
{
    if (_dividerFillColor != aColor) {
        [_dividerFillColor release];
        _dividerFillColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)dividerFillColor
{
    return _dividerFillColor;
}

- (void)drawDividerInRect:(NSRect)aRect
{
    [_dividerFillColor set];
    if (_dividerThickness <= 0.0f || _dividerFillColor == nil)
        [super drawDividerInRect:aRect];
    else
        NSRectFillUsingOperation(aRect, [self isOpaque] ? NSCompositingOperationCopy : NSCompositingOperationSourceOver);
}

- (void)setDividerThickness:(CGFloat)aThickness
{
    _dividerThickness = aThickness;
}

- (CGFloat)dividerThickness
{
    return _dividerThickness;
}

- (BOOL)isFlipped
{
    return YES;
}

@end
