#import "HyperEditorBasePrefix.h"
#import "HSSliderCell.h"


@interface HSBlueTriangleSliderCell : HSSliderCell
{
    BOOL _hasMultipleValues;
}
- (void)loadDefaultImages;
- (void)drawKnob:(NSRect)aKnob;
- (void)setHasMultipleValues:(BOOL)aValues;
- (BOOL)hasMultipleValues;
@end

