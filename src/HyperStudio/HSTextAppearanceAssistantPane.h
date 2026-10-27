#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSTextAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    NSMatrix *_textTypeMatrix;
    NSButton *_drawScrollBarButton;
    NSButton *_drawFrameButton;
    NSButton *_readOnlyButton;
    NSButton *_scrollableButton;
    NSButton *_hasBackgroundColorButton;
    HSGradientColorWell *_textColorWell;
    HSGradientColorWell *_backgroundColorWell;
    NSTextField *_backgroundTextField;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)validateScrollBoxControls:(BOOL)aControls;
- (void)validateObjectName;
- (void)validateSystemTextViewUI;
- (void)validateUI;
- (void)validateSystemTextViewUIWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)setHasBackgroundColor:(id)aColor;
- (void)setTextType:(id)aType;
- (void)backgroundColorChanged:(id)aChanged;
- (void)textColorChanged:(id)aChanged;
- (void)scrollableChanged:(id)aChanged;
- (void)setDrawVerticalScroller:(id)aScroller;
- (void)getFile:(id)aFile;
- (void)editableChanged:(id)aChanged;
- (void)setName:(id)aName;
- (void)setDrawFrame:(id)aFrame;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)init;
@end

