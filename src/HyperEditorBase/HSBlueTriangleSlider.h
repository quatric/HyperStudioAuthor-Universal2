#import "HyperEditorBasePrefix.h"


@interface HSBlueTriangleSlider : NSSlider
{
    id _delegate;
}
+ (Class)cellClass;
- (void)setHasMultipleValues:(BOOL)aValues;
- (BOOL)hasMultipleValues;
- (void)mouseDown:(id)aDown;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)awakeFromNib;
@end

