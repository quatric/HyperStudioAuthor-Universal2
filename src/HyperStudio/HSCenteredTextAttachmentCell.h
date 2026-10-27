#import "HyperStudioPrefix.h"


@interface HSCenteredTextAttachmentCell : NSTextAttachmentCell
{
    NSPoint _baselineOffset;
}
- (void)centerCellForFont:(id)aFont;
- (void)setBaselineOffset:(NSPoint)aOffset;
- (NSPoint)cellBaselineOffset;
@end

