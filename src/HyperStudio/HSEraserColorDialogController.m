#import "HSEraserColorDialogController.h"

@implementation HSEraserColorDialogController

- (void)dealloc
{
    [_originalObject release];
    [super dealloc];
}

- (void)applyChanges
{
    NSColor *color = [_backgroundColorMatrix selectedColor];

    if (color != nil)
        [[[HSToolManager sharedToolManager] toolSettings] setEraserColor:[color colorWithAlphaComponent:1.0]];
}

- (id)initWithOriginalObject:(id)aObject
{
    self = [super init];
    if (self != nil) {
        _originalObject = [aObject retain];
        if (_originalObject != nil)
            return self;
    }
    [self release];
    return nil;
}

- (void)didLoadNib
{
    [_backgroundColorMatrix setSelectedColor:[[[HSToolManager sharedToolManager] toolSettings] eraserColor]];
}

- (id)nibName
{
    return @"EraserColor";
}

@end

@implementation HSEraserColorDialogController (IBActions)

// Fills the current card's background image with the eraser color.
- (void)actionEraseBackground:(id)aBackground
{
    id attributes;
    id image;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), nil };
    NSSize size;

    [self ok:aBackground];
    attributes = [[_originalObject currentCard] queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (attributes == nil || (image = [attributes queryImageWithRequiredProtocols:required optionalProtocols:NULL]) == nil)
        return;
    size = [image imageSize];
    [[_originalObject undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Erase Background" value:@"" table:@"UndoManager"]];
    [attributes beginEditImage:image inRect:NSMakeRect(0.0, 0.0, size.width, size.height)];
    [image beginCocoaEditing];
    [(NSColor *)[[[HSToolManager sharedToolManager] toolSettings] eraserColor] set];
    [NSBezierPath fillRect:NSMakeRect(0.0, 0.0, size.width, size.height)];
    [image endCocoaEditing];
    [attributes endEditImage];
}

@end
