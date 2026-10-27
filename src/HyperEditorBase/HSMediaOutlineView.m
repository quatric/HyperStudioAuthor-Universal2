#import "HSMediaOutlineView.h"
#import <objc/message.h>

// The media library outline: cells with action buttons get the mouse
// first; a click on the selected row edits it, return edits, delete asks
// the delegate.

// The delegate's validateDelete:/validatePaste: answers (BOOL, typed id
// by the compiler).
static BOOL HSMediaOutlineViewDelegateValidates(id aDelegate, SEL aSelector, id aItem)
{
    return ((BOOL (*)(id, SEL, id))objc_msgSend)(aDelegate, aSelector, aItem);
}

@implementation HSMediaOutlineView

- (void)textDidEndEditing:(id)aEditing
{
    NSInteger row = [self selectedRow];
    [super textDidEndEditing:aEditing];
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [_endEditingEvent release];
    _endEditingEvent = [[[self window] currentEvent] retain];
}

- (void)keyDown:(id)aDown
{
    id delegate = [self delegate];
    switch ([(NSEvent *)aDown keyCode]) {
        case 0x24:
        case 0x34:
        case 0x4c:
            if ([self numberOfSelectedRows] == 1) {
                [self editColumn:0 row:[self selectedRow] withEvent:nil select:YES];
                return;
            }
            break;
        case 0x33:
        case 0x75:
            if ([delegate respondsToSelector:@selector(validateDelete:)] && HSMediaOutlineViewDelegateValidates(delegate, @selector(validateDelete:), nil)) {
                [self delete:nil];
                return;
            }
            break;
        case 0x73:
            [self scrollRowToVisible:0];
            return;
        case 0x77:
            [self scrollRowToVisible:[self numberOfRows] - 1];
            return;
    }
    [super keyDown:aDown];
}

- (void)collapseItem:(id)aItem collapseChildren:(BOOL)aChildren
{
    [super collapseItem:aItem collapseChildren:aChildren];
    [self sizeLastColumnToFit];
}

- (void)expandItem:(id)aItem expandChildren:(BOOL)aChildren
{
    [super expandItem:aItem expandChildren:aChildren];
    [self sizeLastColumnToFit];
}

- (void)paste:(id)aPaste
{
    if ([[self delegate] respondsToSelector:@selector(paste:)])
        [(id)[self delegate] paste:aPaste];
}

- (void)delete:(id)aDelete
{
    if ([[self delegate] respondsToSelector:@selector(deleteMediaLibrary:)])
        [(id)[self delegate] deleteMediaLibrary:aDelete];
}

- (void)cut:(id)aCut
{
}

- (void)copy:(id)aCopy
{
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    id delegate = [self delegate];
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(delete:) && [delegate respondsToSelector:@selector(validateDelete:)])
        return HSMediaOutlineViewDelegateValidates(delegate, @selector(validateDelete:), aItem);
    if (action == @selector(paste:) && [delegate respondsToSelector:@selector(validatePaste:)])
        return HSMediaOutlineViewDelegateValidates(delegate, @selector(validatePaste:), aItem);
    return NO;
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    [[self window] makeKeyWindow];
    return YES;
}

// The cell under the mouse, showing its row's value, when it handles aSelector.
- (id)HSMediaOutlineView_cellAtPoint:(NSPoint)aPoint handling:(SEL)aSelector column:(NSInteger *)aColumn row:(NSInteger *)aRow
{
    NSInteger column = [self columnAtPoint:aPoint];
    NSInteger row = [self rowAtPoint:aPoint];
    *aColumn = column;
    *aRow = row;
    if (column < 0 || row < 0)
        return nil;
    NSTableColumn *tableColumn = [[self tableColumns] objectAtIndex:column];
    NSCell *cell = [tableColumn dataCellForRow:row];
    if (![cell respondsToSelector:aSelector])
        return cell;
    [cell setObjectValue:[(id)[self dataSource] outlineView:self objectValueForTableColumn:tableColumn byItem:[self itemAtRow:row]]];
    return cell;
}

- (void)mouseMoved:(id)aMoved
{
    NSPoint point = [self convertPoint:[(NSEvent *)aMoved locationInWindow] fromView:[[self window] contentView]];
    NSInteger column, row;
    id cell = [self HSMediaOutlineView_cellAtPoint:point handling:@selector(mouseMoved:inRect:ofView:) column:&column row:&row];
    if ([cell respondsToSelector:@selector(mouseMoved:inRect:ofView:)]
            && [cell mouseMoved:aMoved inRect:[self frameOfCellAtColumn:column row:row] ofView:self])
        return;
    [super mouseMoved:aMoved];
}

- (void)mouseDown:(id)aDown
{
    NSPoint point = [self convertPoint:[(NSEvent *)aDown locationInWindow] fromView:[[self window] contentView]];
    NSInteger column, row;
    id cell = [self HSMediaOutlineView_cellAtPoint:point handling:@selector(mouseDown:inRect:ofView:) column:&column row:&row];
    if (cell != nil) {
        NSRect frame = [self frameOfCellAtColumn:column row:row];
        if ([cell respondsToSelector:@selector(mouseDown:inRect:ofView:)] && [cell mouseDown:aDown inRect:frame ofView:self])
            return;
        // A second click on the selected row (not one ending editing, nor
        // on the disclosure area) edits it.
        if (![[[self window] currentEvent] isEqual:_endEditingEvent] && row == [self selectedRow] && [(NSCell *)cell isEditable]) {
            NSTableColumn *tableColumn = [[self tableColumns] objectAtIndex:column];
            if (tableColumn != [self outlineTableColumn] || point.x > [self levelForRow:row] * [self indentationPerLevel] + frame.origin.x) {
                [self editColumn:column row:row withEvent:nil select:YES];
                return;
            }
        }
    }
    [super mouseDown:aDown];
}

- (void)dealloc
{
    [_endEditingEvent release];
    [super dealloc];
}

@end
