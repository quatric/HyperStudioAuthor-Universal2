#import "HSSystemTextViewData.h"

// Data of a system (Cocoa) text view object; defaults come from the
// VisualSystemTextView template nib.
@implementation HSSystemTextViewData
- (id)XMLElementName
{
    return @"textNodeData";
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"borderType"];
    [keys addObject:@"hasVerticalScroller"];
    [keys addObject:@"selectable"];
    [keys addObject:@"editable"];
    [keys addObject:@"scrollBarSize"];
    [keys addObject:@"rotatable"];
    [keys addObject:@"scrollable"];
    [keys addObject:@"backgroundColor"];
    return keys;
}
- (void)setBackgroundColor:(id)aColor
{
    [aColor retain];
    [_backgroundColor release];
    _backgroundColor = aColor;
}
- (id)backgroundColor
{
    return _backgroundColor;
}
- (void)setScrollable:(BOOL)aScrollable
{
    _isScrollable = aScrollable;
}
- (BOOL)isScrollable
{
    return _isScrollable;
}
- (void)setRotatable:(BOOL)aRotatable
{
    _isRotatable = aRotatable;
}
- (BOOL)isRotatable
{
    return _isRotatable;
}
- (void)setScrollBarSize:(NSUInteger)aSize
{
    _scrollBarSize = (unsigned int)aSize;
}
- (NSUInteger)scrollBarSize
{
    return _scrollBarSize;
}
- (void)setEditable:(BOOL)aEditable
{
    _isEditable = aEditable;
}
- (BOOL)isEditable
{
    return _isEditable;
}
- (void)setSelectable:(BOOL)aSelectable
{
    _isSelectable = aSelectable;
}
- (BOOL)isSelectable
{
    return _isSelectable;
}
- (void)setHasVerticalScroller:(BOOL)aScroller
{
    _hasVerticalScroller = aScroller;
}
- (BOOL)hasVerticalScroller
{
    return _hasVerticalScroller;
}
- (void)setBorderType:(NSUInteger)aType
{
    _borderType = (unsigned int)aType;
}
- (NSUInteger)borderType
{
    return _borderType;
}
- (BOOL)wantsSystemView
{
    return NO;
}
- (id)templateCocoaView
{
    return nil;
}
- (void)dealloc
{
    [_backgroundColor release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        NSScrollView *view = [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSystemTextView"];
        _borderType = (unsigned int)[view borderType];
        _hasVerticalScroller = [view hasVerticalScroller];
        _isSelectable = [(NSTextView *)[view documentView] isSelectable];
        _isEditable = [(NSTextView *)[view documentView] isEditable];
        _scrollBarSize = (unsigned int)[[view verticalScroller] controlSize];
        _isScrollable = [(id)view isScrollable];
        _backgroundColor = [[view backgroundColor] retain];
    }
    return self;
}
@end
