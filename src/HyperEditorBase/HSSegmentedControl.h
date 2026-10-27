#import "HyperEditorBasePrefix.h"


@interface HSSegmentedControl : NSMatrix <NSCopying, NSCoding>
{
    id _backgroundRenderer;
}
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)copyWithZone:(NSZone *)aZone;
- (void)awakeFromNib;
- (void)setupOnDidLoad;
- (void)setMode:(NSUInteger)aMode;
- (void)setIntercellSpacing:(NSSize)aSpacing;
- (BOOL)getAllowedIntercellWidth:(float *)aWidth;
- (void)fixCellCaps;
- (void)setBackgroundRenderer:(id)aRenderer;
- (id)backgroundRenderer;
- (void)updateCellInside:(id)aInside;
- (void)updateCell:(id)aCell;
- (void)mouseDown:(id)aDown;
- (void)updateSeparatorForCell:(id)aCell;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
@end

