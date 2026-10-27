#import "HSImageTextTableCell.h"
#import <objc/message.h>
// A text cell with an icon: position 1 puts the icon before the text, 2 at
// the right end, 3 draws a separator line instead of text. The object value
// can be [text, highlighted icon, icon] or [text, icon].
@implementation HSImageTextTableCell
// The text attributes a cell draws with (white when highlighted in the
// key view).
+ (id)defaultAttributesForCell:(id)aCell
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:0];
    NSCell *cell = aCell;
    if (![aCell isKindOfClass:[NSTextFieldCell class]] || aCell == nil)
        cell = [[[NSCell alloc] initTextCell:[NSString string]] autorelease];
    [attributes setObject:[cell font] forKey:NSFontAttributeName];
    BOOL notFirstResponder = !([[[cell controlView] window] firstResponder] == [cell controlView] && [cell controlView] != nil);
    NSColor *color;
    if (aCell != nil && !([cell isHighlighted] && !notFirstResponder))
        color = [(NSTextFieldCell *)cell textColor];
    else
        color = [NSColor whiteColor];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];
    if (aCell != nil && [(NSTextFieldCell *)cell drawsBackground])
        [attributes setObject:[(NSTextFieldCell *)cell backgroundColor] forKey:NSBackgroundColorAttributeName];
    NSLineBreakMode lineBreakMode;
    if ([cell respondsToSelector:@selector(lineBreakMode)])
        lineBreakMode = [cell lineBreakMode];
    else
        lineBreakMode = [cell wraps] ? NSLineBreakByWordWrapping : NSLineBreakByClipping;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:lineBreakMode];
    [style setAlignment:[cell alignment]];
    [style setLineSpacing:1.0];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    [style release];
    return attributes;
}
- (CGFloat)textHeight
{
    return _textHeight;
}
- (void)setTextHeight:(CGFloat)aHeight
{
    _textHeight = aHeight;
}
- (NSInteger)imageTextPosition
{
    return _imageTextPosition;
}
- (void)setImageTextPosition:(NSInteger)aPosition
{
    _imageTextPosition = (int)aPosition;
}
// (The icons are composited, i.e. drawn upright at their bottom-left
// point, as in the original.)
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    NSImage *icon = [self isHighlighted] && [self hasHighlightedIcon] ? [self highlightedIcon] : [self icon];
    if (icon != nil) {
        if (_imageTextPosition == 2) {
            [icon compositeToPoint:NSMakePoint((float)(aFrame.origin.x + aFrame.size.width) - (float)aFrame.size.height, (float)(aFrame.origin.y + aFrame.size.height)) operation:NSCompositingOperationSourceOver];
            aFrame.size.width = (float)((float)(aFrame.size.width - aFrame.size.height) + -3.0);
        } else if (_imageTextPosition == 1) {
            float margin = floorf((float)(aFrame.size.height - [icon size].height) * 0.5f);
            [icon compositeToPoint:NSMakePoint((float)(aFrame.origin.x + margin + 3.0), (float)(aFrame.origin.y + aFrame.size.height) - margin) operation:NSCompositingOperationSourceOver];
            // (The text moves by 6 more points than it shrinks.)
            aFrame.origin.x = (float)((double)(float)[icon size].width + margin + 3.0 + margin + 3.0 + (double)(float)aFrame.origin.x);
            aFrame.size.width = (float)(aFrame.size.width - ((float)[icon size].width + margin + margin));
        }
    }
    if (_imageTextPosition == 3) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        CGFloat y = aFrame.size.height * 0.5 + aFrame.origin.y;
        [path moveToPoint:NSMakePoint(aFrame.origin.x, y)];
        [path lineToPoint:NSMakePoint(aFrame.origin.x + aFrame.size.width, y)];
        [path setLineWidth:0.5];
        [[NSColor controlTextColor] set];
        [path stroke];
        return;
    }
    if (_textHeight > 0) {
        aFrame.origin.y = (float)((aFrame.size.height - _textHeight) * 0.55 + aFrame.origin.y);
        aFrame.size.height = _textHeight;
    }
    [super drawInteriorWithFrame:aFrame inView:aView];
}
- (BOOL)hasHighlightedIcon
{
    return _highlightedIcon != nil;
}
- (id)highlightedIcon
{
    return _highlightedIcon;
}
- (void)setHighlightedIcon:(id)aIcon
{
    if (_highlightedIcon == aIcon)
        return;
    [_highlightedIcon release];
    _highlightedIcon = [aIcon retain];
}
- (id)icon
{
    return _icon;
}
- (void)setIcon:(id)aIcon
{
    if (_icon == aIcon)
        return;
    [_icon release];
    _icon = [aIcon retain];
}
- (void)setObjectValue:(id)aValue
{
    [self setHighlightedIcon:nil];
    if ([aValue isKindOfClass:[NSArray class]] && [aValue count] == 3) {
        [super setObjectValue:[aValue objectAtIndex:0]];
        [self setHighlightedIcon:[aValue objectAtIndex:1]];
        [self setIcon:[aValue objectAtIndex:2]];
        [self setImageTextPosition:1];
        return;
    }
    if ([aValue isKindOfClass:[NSArray class]] && [aValue count] == 2) {
        [super setObjectValue:[aValue objectAtIndex:0]];
        [self setIcon:[aValue objectAtIndex:1]];
        return;
    }
    if ([aValue isKindOfClass:[NSArray class]])
        [super setObjectValue:[aValue objectAtIndex:0]];
    else
        [super setObjectValue:aValue];
    [self setIcon:nil];
}
- (void)dealloc
{
    [_highlightedIcon release];
    [_icon release];
    [super dealloc];
}
// NSCell's copy copies the ivars bitwise: the copy shares the icons.
- (id)copyWithZone:(NSZone *)aZone
{
    [_highlightedIcon retain];
    [_icon retain];
    return [super copyWithZone:aZone];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _imageTextPosition = 0;
    return self;
}
- (id)initImageCell:(id)aCell
{
    // (NSTextFieldCell marks initImageCell: unavailable; call NSCell's
    // through the superclass as the original did.)
    struct objc_super superclass = { self, [HSImageTextTableCell superclass] };
    self = ((id (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&superclass, @selector(initImageCell:), aCell);
    if (self != nil) {
        _imageTextPosition = 0;
        [self setStringValue:@""];
        [self setIcon:aCell];
    }
    return self;
}
- (id)initTextCell:(id)aCell
{
    self = [super initTextCell:aCell];
    if (self != nil)
        _imageTextPosition = 0;
    return self;
}
@end
