#import "HSCenteredTextAttachmentCell.h"

@implementation HSCenteredTextAttachmentCell

// Vertically centers the attachment on the font's cap height.
- (void)centerCellForFont:(id)aFont
{
    CGFloat capHeight = [aFont capHeight];
    [self setBaselineOffset:NSMakePoint(0, (float)([self cellSize].height * -0.5 + capHeight * 0.5))];
}

- (void)setBaselineOffset:(NSPoint)aOffset
{
    _baselineOffset = aOffset;
}

- (NSPoint)cellBaselineOffset
{
    return _baselineOffset;
}

@end
