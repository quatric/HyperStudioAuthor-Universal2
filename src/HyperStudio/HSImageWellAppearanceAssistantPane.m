#import "HSImageWellAppearanceAssistantPane.h"

@implementation HSImageWellAppearanceAssistantPane

- (void)validateUI
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (attributes != nil)
        [_nameTextField setStringValue:[attributes hyperName]];
    [_imageView setImage:[[self imageAttributes] image]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)setImage:(id)aImage
{
    [[self imageAttributes] setImage:[NSImage hyperImageWithNSImage:[aImage image]]];
}

- (void)clearImage:(id)aImage
{
    [[self imageAttributes] setImage:nil];
}

- (void)setName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:[aName stringValue]];
}

- (void)chooseImage:(id)aImage
{
    if (_importGraphicsObjectDialogController == nil) {
        _importGraphicsObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:@"HSImportDialogControllerTypeGraphicObject"];
        [_importGraphicsObjectDialogController setupDialogInterfaceWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:4] forKey:@"HSImportDialogGraphicsObjectLayout"]];
        [_importGraphicsObjectDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
        [_importGraphicsObjectDialogController setObjectOptionsDisabled:YES];
        [_importGraphicsObjectDialogController setHelpTopicKey:@"HSAddImageWell"];
    }
    [_importGraphicsObjectDialogController setHyperDocument:[[NSDocumentController sharedDocumentController] currentDocument]];
    if ([_importGraphicsObjectDialogController runModal] != 1)
        return;
    id image = [[_importGraphicsObjectDialogController dialogUserOptions] valueForKey:@"HSImportDialogGraphicsOptionKeyCroppedImage"];
    id attributes = [self imageAttributes];
    if (image != nil) {
        [attributes setImage:image];
    } else {
        id path = [_importGraphicsObjectDialogController fileName];
        if (path != nil)
            [attributes setImageWithPath:path];
    }
}

- (id)imageAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSSystemImageViewAttributes)];
}

- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    [[[self imageAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemImageViewAttributes)];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25f];
    [[[self imageAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemImageViewAttributes) withPriority:-0.25f];
}

- (void)dealloc
{
    [_importGraphicsObjectDialogController release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ImageWellAppearancePane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end
