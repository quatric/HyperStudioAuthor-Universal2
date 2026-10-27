#import "HyperStudioPrefix.h"


@interface HSStackTextProvider : NSObject <HSTextObjectDataSource>
{
    HSMainWindowController *_windowController;
    HSStack *_stack;
    id<HSObjectNaming> _currentItem;
    id<HSCardAttributes> _currentCard;
    id _firstEnumerationItem;
    HSEditorSelectionController *_selectionController;
    NSRange _selectedRange;
    NSRange _selectedNameRange;
    int _direction;
    BOOL _wrapping;
    int _uniqueSpellTag;
    BOOL _includeObjectNames;
}
- (void)deactivateCurrentItem;
- (BOOL)hyperReplaceTextForCurrentItem:(id)aItem inRanges:(id)aRanges;
- (BOOL)setHyperNameForCurrentItem:(id)aItem;
- (void)setHyperTextForCurrentItem:(id)aItem;
- (void)selectCurrentItemNameWithRange:(NSRange)aRange;
- (void)selectCurrentItemStringWithRange:(NSRange)aRange;
- (void)activateInspectorOfCurrentItem;
- (void)activateCurrentItem;
- (NSInteger)hyperSpellDocumentTag;
- (NSRange)selectedRangeForCurrentItemName;
- (NSRange)selectedRangeForCurrentItem;
- (id)hyperNameForCurrentItem;
- (id)hyperTextForCurrentItem;
- (BOOL)moveToNext;
- (BOOL)shouldEnableIncludeObjectNamesButton;
- (void)setIncludeObjectNames:(BOOL)aNames;
- (void)setWrapsAround:(BOOL)aAround;
- (void)setDirection:(NSInteger)aDirection;
- (void)startEnumeration;
- (void)selectionChanged:(id)aChanged;
- (void)activeCardDidChange:(id)aChange;
- (void)nodeContainerDidRemoveChild:(id)aChild;
- (id)nearestTextItemInContainer:(id)aContainer forItem:(id)aItem;
- (id)nearestTextItemInContainer:(id)aContainer;
- (void)refreshCurrentItem;
- (BOOL)canBecomeCurrentItem:(id)aItem;
- (void)setCurrentItem:(id)aItem;
- (id)currentItem;
- (void)setCurrentCard:(id)aCard;
- (void)setSelectionController:(id)aController;
- (void)dealloc;
- (id)initWithWindowController:(id)aController selectionController:(id)aController2;
@end

