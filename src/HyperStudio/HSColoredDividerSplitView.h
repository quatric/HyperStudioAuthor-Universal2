#import "HyperStudioPrefix.h"


@interface HSColoredDividerSplitView : NSSplitView
{
    float _dividerThickness;
    NSColor *_dividerFillColor;
}
- (void)setDividerFillColor:(id)aColor;
- (id)dividerFillColor;
- (void)drawDividerInRect:(NSRect)aRect;
- (void)setDividerThickness:(CGFloat)aThickness;
- (CGFloat)dividerThickness;
- (BOOL)isFlipped;
@end

