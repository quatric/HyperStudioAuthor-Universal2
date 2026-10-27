#import "HyperEditorBasePrefix.h"


@interface HSCustomPopUpButtonCell : NSPopUpButtonCell <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    NSImage *_popUpButtonImage;
    NSImage *_selectedPopUpButtonImage;
    NSImage *_popUpButtonPreviewFieldImage;
    NSRect _popUpButtonImageRect;
    NSRect _selectedPopUpButtonImageRect;
    NSRect _popUpButtonPreviewFieldImageRect;
    NSTextFieldCell *_textFieldCell;
    NSTextView *_textView;
    BOOL _isMenuAttached;
    BOOL _isInEditableMode;
    BOOL _shouldRestorePreviousValue;
    NSString *_previousValueString;
}
- (void)textDidEndEditing:(id)aEditing;
- (BOOL)textShouldEndEditing:(id)aEditing;
- (BOOL)textShouldBeginEditing:(id)aEditing;
- (BOOL)textView:(id)aView shouldChangeTextInRange:(NSRange)aRange replacementString:(id)aString;
- (void)setupTextFieldCell;
- (void)loadDefaultImages;
- (void)acceptPropertiesFromPopUpButtonCell:(id)aCell;
- (void)applyDefaultSettings;
- (void)dismissPopUp;
- (void)attachPopUpWithFrame:(NSRect)aFrame inView:(id)aView;
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (void)setPreviousValueString:(id)aString;
- (id)previousValueString;
- (void)setShouldRestorePreviousValue:(BOOL)aValue;
- (BOOL)shouldRestorePreviousValue;
- (void)setEnabled:(BOOL)aEnabled;
- (void)setStringValue:(id)aValue;
- (id)representedObject;
- (void)selectItem:(id)aItem;
- (NSRect)titleRectForBounds:(NSRect)aBounds;
- (NSRect)buttonRectForBounds:(NSRect)aBounds;
- (NSRect)previewFieldRectForBounds:(NSRect)aBounds;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)setPopUpButtonPreviewFieldImage:(id)aImage;
- (id)popUpButtonPreviewFieldImage;
- (void)setSelectedPopUpButtonImage:(id)aImage;
- (id)selectedPopUpButtonImage;
- (void)setPopUpButtonImage:(id)aImage;
- (id)popUpButtonImage;
- (void)dealloc;
- (id)initTextCell:(id)aCell pullsDown:(BOOL)aDown;
- (id)initWithPopUpButtonCell:(id)aCell;
@end

