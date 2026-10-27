#import "HyperPlayerBasePrefix.h"


@interface HSAttributePopUpButton : NSPopUpButton
{
    BOOL _hasMultipleValues;
}
- (void)setUpEmptyItem;
- (void)setMenu:(id)aMenu;
- (void)popUpButtonDidEndTrackingMenu:(id)aMenu;
- (void)popUpButtonWillShowMenu:(id)aMenu;
- (void)menuWillSendAction:(id)aAction;
- (void)selectItem:(id)aItem;
- (BOOL)selectItemWithTag:(NSInteger)aTag;
- (void)selectItemAtIndex:(NSInteger)aIndex;
- (void)setHasMultipleValues:(BOOL)aValues;
- (BOOL)hasMultipleValues;
- (void)dealloc;
@end

