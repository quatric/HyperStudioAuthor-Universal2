#import "HyperPlayerBasePrefix.h"
#import "HSSystemObjectData.h"


@interface HSSystemTextViewData : HSSystemObjectData
{
    unsigned int _borderType;
    BOOL _hasVerticalScroller;
    BOOL _isSelectable;
    BOOL _isEditable;
    unsigned int _scrollBarSize;
    BOOL _isRotatable;
    BOOL _isScrollable;
    NSColor *_backgroundColor;
}
- (id)XMLElementName;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)setScrollable:(BOOL)aScrollable;
- (BOOL)isScrollable;
- (void)setRotatable:(BOOL)aRotatable;
- (BOOL)isRotatable;
- (void)setScrollBarSize:(NSUInteger)aSize;
- (NSUInteger)scrollBarSize;
- (void)setEditable:(BOOL)aEditable;
- (BOOL)isEditable;
- (void)setSelectable:(BOOL)aSelectable;
- (BOOL)isSelectable;
- (void)setHasVerticalScroller:(BOOL)aScroller;
- (BOOL)hasVerticalScroller;
- (void)setBorderType:(NSUInteger)aType;
- (NSUInteger)borderType;
- (BOOL)wantsSystemView;
- (id)templateCocoaView;
- (void)dealloc;
- (id)init;
@end

