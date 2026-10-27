#import "HyperPlayerBasePrefix.h"


@interface HSImageTextTableCell : NSTextFieldCell
{
    int _imageTextPosition;
    float _textHeight;
    NSImage *_highlightedIcon;
    NSImage *_icon;
}
+ (id)defaultAttributesForCell:(id)aCell;
- (CGFloat)textHeight;
- (void)setTextHeight:(CGFloat)aHeight;
- (NSInteger)imageTextPosition;
- (void)setImageTextPosition:(NSInteger)aPosition;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (BOOL)hasHighlightedIcon;
- (id)highlightedIcon;
- (void)setHighlightedIcon:(id)aIcon;
- (id)icon;
- (void)setIcon:(id)aIcon;
- (void)setObjectValue:(id)aValue;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
- (id)initImageCell:(id)aCell;
- (id)initTextCell:(id)aCell;
@end

