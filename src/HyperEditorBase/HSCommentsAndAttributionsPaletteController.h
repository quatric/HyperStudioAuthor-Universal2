#import "HyperEditorBasePrefix.h"
#import "HSValidatedUserInterfacePaletteController.h"


@interface HSCommentsAndAttributionsPaletteController : HSValidatedUserInterfacePaletteController
{
    id<HSCommentsAndAttributionsDataProvider> _dataProvider;
    HSSegmentedControl *_filterControl;
    HSPlaceholderTextView *_textView;
}
- (void)filterChanged:(id)aChanged;
- (void)willCloseWindow;
- (void)willShowWindow;
- (void)HSCommentsAndAttributionsPaletteController_cardDidChange:(id)aChange;
- (void)HSCommentsAndAttributionsPaletteController_unsubscribeFromAllCommentNotification;
- (void)HSCommentsAndAttributionsPaletteController_subscribeToAllCommentNotifications;
- (void)HSCommentsAndAttributionsPaletteController_refreshTextView:(id)aView;
- (NSRect)windowWillUseStandardFrame:(id)aFrame defaultFrame:(NSRect)aFrame2;
- (BOOL)paletteShouldBecomeKeyOnlyWhenNeeded;
- (void)didLoadNib;
- (id)commentsForCard:(id)aCard;
- (void)setDataProvider:(id)aProvider;
- (id)dataProvider;
- (id)nibName;
- (void)dealloc;
@end

