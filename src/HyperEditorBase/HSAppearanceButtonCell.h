#import "HyperEditorBasePrefix.h"


@interface HSAppearanceButtonCell : NSButtonCell
{
    NSImage *_aquaAlternateImage;
    NSImage *_graphiteAlternateImage;
}
- (void)controlTintDidChange:(id)aChange;
- (void)setGraphiteAlternateImage:(id)aImage;
- (id)graphiteAlternateImage;
- (void)setAquaAlternateImage:(id)aImage;
- (id)aquaAlternateImage;
- (BOOL)isGraphiteTint;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
- (id)initImageCell:(id)aCell;
- (id)initTextCell:(id)aCell;
@end

