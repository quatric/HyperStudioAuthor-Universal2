#import "HSCustomCellPropertiesCopier.h"

@implementation HSCustomCellPropertiesCopier

// What a replacement cell takes over from the cell a nib made, borders and
// bezels left off.
+ (void)copyProptiesFromCell:(id)aCell toCell:(id)aCell2
{
    NSCell *cell = aCell, *cell2 = aCell2;
    [cell2 setState:[cell state]];
    [cell2 setTarget:[cell target]];
    [cell2 setAction:[cell action]];
    [cell2 setTag:[cell tag]];
    id title = [cell title];
    [cell2 setTitle:title];
    [cell2 setEnabled:[cell isEnabled]];
    [cell2 setContinuous:[cell isContinuous]];
    [cell2 setEditable:[cell isEditable]];
    [cell2 setSelectable:[cell isSelectable]];
    [cell2 setBordered:NO];
    [cell2 setBezeled:NO];
    [cell2 setScrollable:[cell isScrollable]];
    [cell2 setHighlighted:[cell isHighlighted]];
    [cell2 setAlignment:[cell alignment]];
    [cell2 setWraps:[cell wraps]];
    [cell2 setFont:[cell font]];
    [cell2 setFormatter:[cell formatter]];
    id value = [cell objectValue];
    if (value != title)
        [cell2 setObjectValue:value];
    value = [cell stringValue];
    if (value != title)
        [cell2 setStringValue:value];
    [cell2 setImage:[cell image]];
    [cell2 setControlSize:[cell controlSize]];
    [cell2 setRepresentedObject:[cell representedObject]];
    [cell2 setMenu:[cell menu]];
    [cell2 setSendsActionOnEndEditing:[cell sendsActionOnEndEditing]];
    [cell2 setRefusesFirstResponder:[cell refusesFirstResponder]];
    [cell2 setShowsFirstResponder:[cell showsFirstResponder]];
    // (The control tint and mnemonic location the original copied too are
    // gone from AppKit.)
    id attributed = [cell attributedStringValue];
    if (attributed != nil)
        [cell2 setAttributedStringValue:attributed];
    [cell2 setAllowsEditingTextAttributes:[cell allowsEditingTextAttributes]];
    [cell2 setImportsGraphics:[cell importsGraphics]];
    [cell2 setAllowsMixedState:[cell allowsMixedState]];
    if ([cell2 respondsToSelector:@selector(setFocusRingType:)] && [cell respondsToSelector:@selector(focusRingType)])
        [cell2 setFocusRingType:[cell focusRingType]];
}

@end
