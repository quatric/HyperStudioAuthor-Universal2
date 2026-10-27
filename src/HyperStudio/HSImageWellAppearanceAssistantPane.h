#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSImageWellAppearanceAssistantPane : HSObjectAssistantPane
{
    NSImageView *_imageView;
    NSTextField *_nameTextField;
    NSButton *_clearButton;
    HSImportDialogController *_importGraphicsObjectDialogController;
}
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)setImage:(id)aImage;
- (void)clearImage:(id)aImage;
- (void)setName:(id)aName;
- (void)chooseImage:(id)aImage;
- (id)nameTextfField;
- (id)initialKeyView;
- (id)imageAttributes;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (id)init;
@end

