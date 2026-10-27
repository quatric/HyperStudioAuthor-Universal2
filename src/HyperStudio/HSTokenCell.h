#import "HyperStudioPrefix.h"


@interface HSTokenCell : NSCell <NSCoding, NSTextAttachmentCell, NSObject>
{
    NSTextFieldCell *_textFieldCell;
    NSPopUpButtonCell *_popUpButtonCell;
    NSColor *_menuTriangleColor;
    NSColor *_borderColor;
    NSColor *_highlightedBorderColor;
    NSColor *_backgroundColor;
    NSColor *_highlightedBackgroundColor;
    BOOL _canChangeHighlight;
    BOOL _autosize;
    NSTextAttachment *_textAttachment;
    BOOL _isDragging;
    int _selectedMenuItemIndex;
    NSSize _cellSize;
    id _target;
    SEL _action;
}
+ (id)defaultHighlightedBackgroundColor;
+ (id)defaultBackgroundColor;
+ (id)defaultHighlightedBorderColor;
+ (id)defaultBorderColor;
+ (id)defaultMenuTriangleColor;
- (void)popUpDidEnd:(id)aEnd;
- (NSRect)cellFrameForTextContainer:(id)aContainer proposedLineFragment:(NSRect)aFragment glyphPosition:(NSPoint)aPosition characterIndex:(NSUInteger)aIndex;
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView atCharacterIndex:(NSUInteger)aIndex untilMouseUp:(BOOL)aUp;
- (BOOL)wantsToTrackMouseForEvent:(id)aEvent inRect:(NSRect)aRect ofView:(id)aView atCharacterIndex:(NSUInteger)aIndex;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView characterIndex:(NSUInteger)aIndex layoutManager:(id)aManager;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView characterIndex:(NSUInteger)aIndex;
- (id)attachment;
- (void)setAttachment:(id)aAttachment;
- (NSPoint)cellBaselineOffset;
- (NSSize)cellSize;
- (void)setCellSize:(NSSize)aSize;
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (BOOL)wantsToTrackMouse;
- (void)invalidateSize;
- (NSRect)menuTriangleRectForRect:(NSRect)aRect;
- (void)drawMenuTriangleInRect:(NSRect)aRect flipped:(BOOL)aFlipped;
- (id)copy;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (void)setHighlightedBackgroundColor:(id)aColor;
- (id)highlightedBackgroundColor;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)setHighlightedBorderColor:(id)aColor;
- (id)highlightedBorderColor;
- (void)setBorderColor:(id)aColor;
- (id)borderColor;
- (void)setMenuTriangleColor:(id)aColor;
- (id)menuTriangleColor;
- (void)setAutosize:(BOOL)aAutosize;
- (BOOL)autosize;
- (id)popUpButtonCell;
- (void)setSelectedMenuItem:(id)aItem;
- (id)selectedMenuItem;
- (BOOL)activateMenuForEvent:(id)aEvent cellFrame:(NSRect)aFrame controlView:(id)aView;
- (void)highlight:(BOOL)aHighlight withFrame:(NSRect)aFrame inView:(id)aView;
- (BOOL)canChangeHighlight;
- (void)setCanChangeHighlight:(BOOL)aHighlight;
- (void)drawBackgroundInRect:(NSRect)aRect highlighted:(BOOL)aHighlighted flipped:(BOOL)aFlipped;
- (void)setUpTextFieldCellInitialSettings:(id)aSettings;
- (id)textFieldCell;
- (void)setAction:(SEL)aAction;
- (SEL)action;
- (id)target;
- (void)setTarget:(id)aTarget;
- (void)setFont:(id)aFont;
- (id)font;
- (id)menu;
- (void)setMenu:(id)aMenu;
- (void)setHighlighted:(BOOL)aHighlighted;
- (void)setTitle:(id)aTitle;
- (id)stringValue;
- (void)setStringValue:(id)aValue;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)dealloc;
- (id)init;
@end

