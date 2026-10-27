#import "HSSoundsLibraryTableView.h"

// The sounds library table: a centred placeholder on white when empty,
// return plays (the double action), copy asks the delegate.

@implementation HSSoundsLibraryTableView

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    if ([self shouldDrawPlaceholderString])
        [self drawPlaceholderStringInRect:aRect];
}

- (void)drawPlaceholderStringInRect:(NSRect)aRect
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[self placeholderString]];
    NSRange range = NSMakeRange(0, [string length]);
    [string addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:20.0] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:range];
    NSSize size = [string size];
    [string drawInRect:NSMakeRect(NSMidX(aRect) - size.width * 0.5, NSMidY(aRect) - size.height * 0.5, size.width, size.height)];
    [string release];
}

- (void)drawGridInClipRect:(NSRect)aRect
{
    if (![self shouldDrawPlaceholderString]) {
        [super drawGridInClipRect:aRect];
        return;
    }
    [[NSColor whiteColor] set];
    NSRectFill(aRect);
}

- (void)drawBackgroundInClipRect:(NSRect)aRect
{
    if (![self shouldDrawPlaceholderString]) {
        [super drawBackgroundInClipRect:aRect];
        return;
    }
    [[NSColor whiteColor] set];
    NSRectFill(aRect);
}

- (BOOL)shouldDrawPlaceholderString
{
    return [self numberOfRows] == 0 && [[self placeholderString] length] != 0;
}

- (void)setPlaceholderString:(id)aString
{
    if ([_placeholderString isEqualToString:aString])
        return;
    [_placeholderString release];
    _placeholderString = [aString copy];
}

- (id)placeholderString
{
    return _placeholderString;
}

// No double action without a clicked (or, from the keyboard, selected) row.
- (BOOL)sendAction:(SEL)aAction to:(id)aTo
{
    if ([self doubleAction] == aAction) {
        NSInteger column = [self clickedColumn];
        NSInteger row = [self clickedRow];
        if ((row == -1) != (column == -1))
            return NO;
        if (column == -1 && row == -1 && [self selectedRow] == -1)
            return NO;
    }
    return [super sendAction:aAction to:aTo];
}

- (void)keyDown:(id)aDown
{
    unsigned short keyCode = [(NSEvent *)aDown keyCode];
    if (keyCode == 0x73)
        [self scrollRowToVisible:0];
    else if (keyCode == 0x77)
        [self scrollRowToVisible:[self numberOfRows] - 1];
    else if (keyCode == 0x24 || keyCode == 0x4c || keyCode == 0x34)
        [self sendAction:[self doubleAction] to:[self target]];
    else
        [super keyDown:aDown];
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    [[self window] makeKeyWindow];
    return YES;
}

- (void)awakeFromNib
{
    [self setAllowsColumnReordering:YES];
    [self setAllowsColumnResizing:YES];
    [self setAllowsEmptySelection:YES];
    [self setAllowsColumnSelection:NO];
    [self setIntercellSpacing:NSMakeSize(1.0, 0)];
    [self setAutoresizingMask:NSViewNotSizable];
    [self setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
}

- (void)copy:(id)aCopy
{
    if ([[self delegate] respondsToSelector:@selector(copyMediaItem:)])
        [(id)[self delegate] copyMediaItem:aCopy];
}

- (void)paste:(id)aPaste
{
}

- (void)delete:(id)aDelete
{
}

- (void)cut:(id)aCut
{
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    id delegate = [self delegate];
    if ([(id<NSValidatedUserInterfaceItem>)aItem action] == @selector(copy:) && [delegate respondsToSelector:@selector(validateCopy:)])
        return ((BOOL (*)(id, SEL, id))objc_msgSend)(delegate, @selector(validateCopy:), aItem);
    return NO;
}

- (void)dealloc
{
    [_placeholderString release];
    [super dealloc];
}

@end
