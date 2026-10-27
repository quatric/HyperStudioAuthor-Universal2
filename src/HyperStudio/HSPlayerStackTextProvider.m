#import "HSPlayerStackTextProvider.h"

@implementation HSPlayerStackTextProvider

- (void)deactivateCurrentItem
{
    [[_windowController cardView] selectRange:NSMakeRange(0, 0) inNode:[[self currentItem] queryHyperInterface:@protocol(HSNodeAttributes)]];
}

- (void)selectCurrentItemStringWithRange:(NSRange)aRange
{
    _selectedRange = aRange;
    if (aRange.length != 0 || aRange.location != 0) {
        [self activateCurrentItem];
        [[_windowController cardView] selectRange:aRange inNode:[[self currentItem] queryHyperInterface:@protocol(HSNodeAttributes)]];
    }
}

- (void)activateCurrentItem
{
    [[_selectionController stackController] selectHyperObject:[[[self currentItem] queryHyperInterface:@protocol(HSNodeChild)] hyperParent]];
}

- (NSRange)selectedRangeForCurrentItem
{
    id item = [self currentItem];
    NSRange range;
    if ([[item queryHyperInterface:@protocol(HSSystemEditableAttribute)] isEditable])
        range = [[_windowController cardView] selectedRangeInNode:[item queryHyperInterface:@protocol(HSNodeAttributes)]];
    else
        range = _selectedRange;
    if (range.location == NSNotFound)
        range = NSMakeRange(0, 0);
    return range;
}

- (id)hyperTextForCurrentItem
{
    if ([self currentItem]) {
        id attributes = [[self currentItem] queryHyperInterface:@protocol(HSGenericObjectStringAttribute)];
        if (attributes)
            return [attributes objectString];
    }
    return nil;
}

- (void)selectionChanged:(id)aChanged
{
    [self setCurrentItem:[[aChanged object] queryHyperInterface:@protocol(HSObjectNaming)]];
}

// Follows the selection: a run time editor switches to the select tool, an
// editable text view becomes the item itself, otherwise the nearest text item
// of the selected object's container (first or last child of the stack,
// depending on the search direction) is used.
- (void)refreshCurrentItem
{
    id object = [_selectionController selectedHyperObject];
    if ([object queryHyperInterface:@protocol(HSRunTimeEditor)])
        [(HSToolManager *)[HSToolManager sharedToolManager] selectToolWithTag:1];
    id textAttributes = [object queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (textAttributes && [[textAttributes queryHyperInterface:@protocol(HSSystemEditableAttribute)] isEditable]) {
        [self setCurrentItem:[textAttributes queryHyperInterface:@protocol(HSObjectNaming)]];
        return;
    }
    id child = [object queryHyperInterface:@protocol(HSNodeChild)];
    if (!child)
        return;
    id item;
    if ([child implementsHyperInterface:@protocol(HSStackAttributes)]) {
        id children = [child queryHyperInterface:@protocol(HSNodeContainerChildrenAttribute)];
        NSUInteger count = [children hyperCount];
        if (count == 0) {
            item = nil;
        } else {
            NSUInteger index = _direction == 1 ? 0 : count - 1;
            item = [self nearestTextItemInContainer:[children hyperChildAtIndex:index]];
        }
    } else if ([child implementsHyperInterface:@protocol(HSCardAttributes)]) {
        item = [self nearestTextItemInContainer:[child queryHyperInterface:@protocol(HSNodeContainer)]];
    } else {
        item = [self nearestTextItemInContainer:[child hyperParent] forItem:child];
    }
    [self setCurrentItem:item];
}

- (void)setCurrentItem:(id)aItem
{
    if (_currentItem != aItem) {
        [_currentItem release];
        _currentItem = [aItem retain];
    }
}

- (BOOL)canBecomeCurrentItem:(id)aItem
{
    return [[aItem queryHyperInterface:@protocol(HSSystemEditableAttribute)] isEditable];
}

- (id)initWithWindowController:(id)aController selectionController:(id)aController2
{
    self = [super initWithWindowController:aController selectionController:aController2];
    if (self)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:HSTextViewDidPerformClickNotification object:nil];
    return self;
}

@end
