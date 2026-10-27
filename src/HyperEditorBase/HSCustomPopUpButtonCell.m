#import "HSCustomPopUpButtonCell.h"

// A pop-up of values (percents) that can also be typed in: clicking the
// title edits it in place, the arrow button pops the menu up.

@implementation HSCustomPopUpButtonCell

- (void)textDidEndEditing:(id)aEditing
{
    _isInEditableMode = NO;
    [_textFieldCell endEditing:_textView];
}

// A number is taken (and sent); anything else goes back to the
// previous value if asked to.
- (BOOL)textShouldEndEditing:(id)aEditing
{
    NSString *string = [(NSText *)aEditing string];
    id number = [[_textFieldCell formatter] numberFromString:string];
    if (_shouldRestorePreviousValue && number == nil && _previousValueString != nil) {
        string = _previousValueString;
        number = [[_textFieldCell formatter] numberFromString:string];
    }
    if (number != nil) {
        [self setStringValue:string];
        [NSApp sendAction:[self action] to:[self target] from:[self controlView]];
    }
    [self setPreviousValueString:nil];
    return number != nil;
}

- (BOOL)textShouldBeginEditing:(id)aEditing
{
    if (_shouldRestorePreviousValue)
        [self setPreviousValueString:[(NSText *)aEditing string]];
    return YES;
}

// Digits only.
- (BOOL)textView:(id)aView shouldChangeTextInRange:(NSRange)aRange replacementString:(id)aString
{
    if ([aString length] == 0)
        return YES;
    return [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[aString characterAtIndex:0]];
}

- (void)setupTextFieldCell
{
    _textFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [_textFieldCell setScrollable:NO];
    [_textFieldCell setSelectable:YES];
    [_textFieldCell setEnabled:YES];
    [_textFieldCell setWraps:YES];
    [_textFieldCell setLineBreakMode:NSLineBreakByTruncatingTail];
    [_textFieldCell setAlignment:NSTextAlignmentCenter];
    [_textFieldCell setControlView:[self controlView]];
    [_textFieldCell setEditable:YES];
    NSNumberFormatter *formatter = [[NSNumberFormatter new] autorelease];
    [formatter setAllowsFloats:NO];
    [formatter setFormat:@"0;0;0"];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_0];
    [_textFieldCell setFormatter:formatter];
    [_textFieldCell setStringValue:[[self selectedItem] title]];
    _textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
    [_textView setFieldEditor:YES];
    [_textView setSelectable:YES];
    [_textView setEditable:YES];
}

static NSImage *HSCustomPopUpButtonCellImage(NSString *aName)
{
    NSString *path = [[NSBundle bundleForClass:[HSCustomPopUpButtonCell class]] pathForResource:aName ofType:@"tiff"];
    return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}

- (void)loadDefaultImages
{
    [self setPopUpButtonImage:HSCustomPopUpButtonCellImage(@"popup_button")];
    [self setSelectedPopUpButtonImage:HSCustomPopUpButtonCellImage(@"popup_button_selected")];
    [self setPopUpButtonPreviewFieldImage:HSCustomPopUpButtonCellImage(@"popup_prerview_field")];
    NSSize size = [_popUpButtonImage size];
    _popUpButtonImageRect = NSMakeRect(0, 0, size.width, size.height);
    size = [_selectedPopUpButtonImage size];
    _selectedPopUpButtonImageRect = NSMakeRect(0, 0, size.width, size.height);
    size = [_popUpButtonPreviewFieldImage size];
    _popUpButtonPreviewFieldImageRect = NSMakeRect(0, 0, size.width, size.height);
}

- (void)acceptPropertiesFromPopUpButtonCell:(id)aCell
{
    NSPopUpButtonCell *cell = aCell;
    [HSCustomCellPropertiesCopier copyProptiesFromCell:cell toCell:self];
    [self setPullsDown:NO];
    [self setAutoenablesItems:[cell autoenablesItems]];
    [self setPreferredEdge:[cell preferredEdge]];
    [self setUsesItemFromMenu:[cell usesItemFromMenu]];
    [self setAltersStateOfSelectedItem:[cell altersStateOfSelectedItem]];
    [self setArrowPosition:[cell arrowPosition]];
    [self selectItem:[cell selectedItem]];
    [self loadDefaultImages];
    [self setupTextFieldCell];
}

- (void)applyDefaultSettings
{
    [super setBezelStyle:NSBezelStyleShadowlessSquare];
    [super setBordered:NO];
    [super setBezeled:NO];
    [self loadDefaultImages];
}

- (void)dismissPopUp
{
    _isMenuAttached = NO;
    [super dismissPopUp];
}

- (void)attachPopUpWithFrame:(NSRect)aFrame inView:(id)aView
{
    _isMenuAttached = YES;
    [super attachPopUpWithFrame:aFrame inView:aView];
}

// The arrow pops the menu up; elsewhere starts editing the title.
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    NSPoint point = [aView convertPoint:[(NSEvent *)aMouse locationInWindow] fromView:nil];
    if (NSPointInRect(point, [self buttonRectForBounds:aRect]))
        return [super trackMouse:aMouse inRect:aRect ofView:aView untilMouseUp:aUp];
    if (!_isInEditableMode && [self isEnabled]) {
        _isInEditableMode = YES;
        [_textFieldCell selectWithFrame:[self titleRectForBounds:aRect] inView:[self controlView] editor:_textView delegate:self start:0 length:5];
        [_textView setDelegate:self];
    }
    return NO;
}

- (void)setPreviousValueString:(id)aString
{
    if (_previousValueString != aString) {
        [_previousValueString release];
        _previousValueString = [aString copy];
    }
}

- (id)previousValueString
{
    return _previousValueString;
}

- (void)setShouldRestorePreviousValue:(BOOL)aValue
{
    _shouldRestorePreviousValue = aValue;
}

- (BOOL)shouldRestorePreviousValue
{
    return _shouldRestorePreviousValue;
}

- (void)setEnabled:(BOOL)aEnabled
{
    if (!aEnabled && _isInEditableMode)
        [_textFieldCell endEditing:_textView];
    [_textFieldCell setEnabled:aEnabled];
    [super setEnabled:aEnabled];
}

// A value not in the menu deselects its item.
- (void)setStringValue:(id)aValue
{
    if (_shouldRestorePreviousValue)
        [self setPreviousValueString:aValue];
    [_textFieldCell setStringValue:aValue];
    if (_isInEditableMode) {
        [_textView setSelectedRange:NSMakeRange(0, [[_textView string] length])];
        [_textView delete:self];
        [_textView insertText:aValue replacementRange:[_textView selectedRange]];
    }
    if (![aValue isEqualToString:[[self selectedItem] title]])
        [self selectItemAtIndex:-1];
    [super setStringValue:aValue];
}

// The item's object, else the typed percent as a fraction.
- (id)representedObject
{
    id object = [[self selectedItem] representedObject];
    if (object == nil)
        object = [NSNumber numberWithFloat:[_textFieldCell floatValue] / 100.0f];
    return object;
}

- (void)selectItem:(id)aItem
{
    [self setStringValue:[aItem title]];
    [super selectItem:aItem];
}

- (NSRect)titleRectForBounds:(NSRect)aBounds
{
    NSSize size = [_textFieldCell cellSize];
    return NSMakeRect(2.5, size.height * -0.5 + aBounds.size.height * 0.5, aBounds.size.width - _popUpButtonImageRect.size.width - 2.5, size.height);
}

- (NSRect)buttonRectForBounds:(NSRect)aBounds
{
    return NSMakeRect(aBounds.origin.x + aBounds.size.width - _popUpButtonImageRect.size.width, 0, _popUpButtonImageRect.size.width, _popUpButtonImageRect.size.height);
}

- (NSRect)previewFieldRectForBounds:(NSRect)aBounds
{
    return NSMakeRect(aBounds.origin.x, aBounds.origin.y, _popUpButtonPreviewFieldImageRect.size.width, _popUpButtonPreviewFieldImageRect.size.height);
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    [[self popUpButtonPreviewFieldImage] drawInRect:[self previewFieldRectForBounds:aFrame] fromRect:_popUpButtonPreviewFieldImageRect operation:NSCompositingOperationSourceOver fraction:1.0];
    if (_isMenuAttached)
        [[self selectedPopUpButtonImage] drawInRect:[self buttonRectForBounds:aFrame] fromRect:_selectedPopUpButtonImageRect operation:NSCompositingOperationSourceOver fraction:1.0];
    else
        [[self popUpButtonImage] drawInRect:[self buttonRectForBounds:aFrame] fromRect:_popUpButtonImageRect operation:NSCompositingOperationSourceOver fraction:1.0];
    if (!_isInEditableMode)
        [_textFieldCell drawInteriorWithFrame:[self titleRectForBounds:aFrame] inView:aView];
}

- (void)setPopUpButtonPreviewFieldImage:(id)aImage
{
    if (_popUpButtonPreviewFieldImage != aImage) {
        [_popUpButtonPreviewFieldImage release];
        _popUpButtonPreviewFieldImage = [aImage retain];
    }
}

- (id)popUpButtonPreviewFieldImage
{
    return _popUpButtonPreviewFieldImage;
}

- (void)setSelectedPopUpButtonImage:(id)aImage
{
    if (_selectedPopUpButtonImage != aImage) {
        [_selectedPopUpButtonImage release];
        _selectedPopUpButtonImage = [aImage retain];
    }
}

- (id)selectedPopUpButtonImage
{
    return _selectedPopUpButtonImage;
}

- (void)setPopUpButtonImage:(id)aImage
{
    if (_popUpButtonImage != aImage) {
        [_popUpButtonImage release];
        _popUpButtonImage = [aImage retain];
    }
}

- (id)popUpButtonImage
{
    return _popUpButtonImage;
}

- (void)dealloc
{
    [_popUpButtonImage release];
    [_selectedPopUpButtonImage release];
    [_popUpButtonPreviewFieldImage release];
    [_textFieldCell release];
    [_textView release];
    [_previousValueString release];
    [super dealloc];
}

// Original quirk kept: always pulls down here (acceptProperties... sets
// it back).
- (id)initTextCell:(id)aCell pullsDown:(BOOL)aDown
{
    if ((self = [super initTextCell:aCell pullsDown:YES]))
        [self applyDefaultSettings];
    return self;
}

- (id)initWithPopUpButtonCell:(id)aCell
{
    if ([(NSCell *)aCell type] == NSImageCellType)
        self = [super initImageCell:nil];
    else
        self = [super initTextCell:@""];
    if (self != nil)
        [self acceptPropertiesFromPopUpButtonCell:aCell];
    return self;
}

@end
