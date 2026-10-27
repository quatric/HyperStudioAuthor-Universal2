#import "HSAttributePopUpButton.h"
// A pop-up for an attribute of several objects: when their values differ, an
// empty last item is selected (shown as a blank title) and the items show the
// "multiple values" state. The empty item is removed while the menu is shown
// and put back after; choosing an item ends the multiple-values mode.
@implementation HSAttributePopUpButton
// The first item's state is kept across the insertion (selecting changes it).
- (void)setUpEmptyItem
{
    NSInteger state = [[self itemAtIndex:0] state];
    [self insertItemWithTitle:@"" atIndex:[self numberOfItems]];
    [super selectItemAtIndex:[self numberOfItems] - 1];
    [[self itemAtIndex:0] setState:state];
}
- (void)setMenu:(id)aMenu
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super setMenu:aMenu];
}
- (void)popUpButtonDidEndTrackingMenu:(id)aMenu
{
    if (_hasMultipleValues)
        [self setUpEmptyItem];
}
- (void)popUpButtonWillShowMenu:(id)aMenu
{
    if (!_hasMultipleValues)
        return;
    NSInteger state = [[self itemAtIndex:0] state];
    [self removeItemAtIndex:[self numberOfItems] - 1];
    [[self itemAtIndex:0] setState:state];
}
- (void)menuWillSendAction:(id)aAction
{
    [self setHasMultipleValues:NO];
}
- (void)selectItem:(id)aItem
{
    if (!_hasMultipleValues)
        [super selectItem:aItem];
    else
        [self selectItemAtIndex:[self indexOfItem:aItem]];
}
- (BOOL)selectItemWithTag:(NSInteger)aTag
{
    NSInteger index = [self indexOfItemWithTag:aTag];
    if (index != -1)
        [self selectItemAtIndex:index];
    return index != -1;
}
// With multiple values the item only gets the "mixed" state.
- (void)selectItemAtIndex:(NSInteger)aIndex
{
    if (!_hasMultipleValues)
        [super selectItemAtIndex:aIndex];
    else
        [[self itemAtIndex:aIndex] setState:[[HSMultipleUIValue multipleUIValue] stateValue]];
}
// Leaving the mode removes the empty item and gives the items their normal
// on/off states; entering it watches the menu (action sent, tracking ended)
// and this button (about to pop up).
- (void)setHasMultipleValues:(BOOL)aValues
{
    if (_hasMultipleValues == aValues)
        return;
    _hasMultipleValues = aValues;
    if (!aValues) {
        [self removeItemAtIndex:[self numberOfItems] - 1];
        [self synchronizeTitleAndSelectedItem];
        for (NSMenuItem *item in [self itemArray])
            [item setState:item == [self selectedItem]];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else {
        [self setUpEmptyItem];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(menuWillSendAction:) name:NSMenuWillSendActionNotification object:[self menu]];
        [center addObserver:self selector:@selector(popUpButtonDidEndTrackingMenu:) name:NSMenuDidEndTrackingNotification object:[self menu]];
        [center addObserver:self selector:@selector(popUpButtonWillShowMenu:) name:NSPopUpButtonWillPopUpNotification object:self];
    }
}
- (BOOL)hasMultipleValues
{
    return _hasMultipleValues;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
