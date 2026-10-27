#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSGenericObjectFeaturesAssistantPane : HSObjectAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    NSTextField *_objectOwnerLabel;
    NSTextField *_objectNameLabel;
    HSCommentsTextView *_commentsTextView;
    NSImageView *_cursorImageView;
    NSButton *_cursorButton;
    NSButton *_draggableButton;
    NSButton *_draggableSwitch;
    NSButton *_groupObjectSwitch;
    NSObjectController *_cardObjectController;
    NSSize _draggableSwitchSize;
}
- (void)editCursor:(id)aCursor;
- (void)setDraggableOptions:(id)aOptions;
- (void)validateDropOptionsStateForDragableState:(BOOL)aState;
- (void)groupObjectChanged:(id)aChanged;
- (void)commentsChanged:(id)aChanged;
- (void)textDidChange:(id)aChange;
- (void)objectCursorAttributesDidChange:(id)aChange;
- (void)objectCommentsAttributesDidChange:(id)aChange;
- (void)textDidEndEditing:(id)aEditing;
- (void)objectAttributesDidChange:(id)aChange;
- (void)validateDraggableOptionsButton;
- (void)validateGroupObjectSwitch;
- (void)validateCursorView;
- (void)validateCommentsView;
- (void)validateUI;
- (void)unsubscribeFromNotifications;
- (void)subscribeToNotifications;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)snappingOptionsAttributes;
- (id)cardObjectAttributes;
- (id)objectAttributes;
- (BOOL)isEnabled;
- (void)dealloc;
- (id)initWithNibName:(id)aName;
- (id)init;
@end

