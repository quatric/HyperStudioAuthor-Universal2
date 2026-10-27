#import "HSEraseBackgroundDialogController.h"

@implementation HSEraseBackgroundDialogController

- (void)onChooseSolidColorPreset:(id)aPreset
{
    NSColor *color = [[aPreset cellAtRow:[aPreset selectedRow] column:[aPreset selectedColumn]] representedObject];
    [_solidColorWell setColor:color];
    [_cardPreview setBackgroundColor:color];
    [self updateCardPreview];
}

- (void)onSolidColor:(id)aColor
{
    [_cardPreview setBackgroundColor:[aColor color]];
    [self updateCardPreview];
}

- (void)updateCardPreview
{
    [_cardPreview setNeedsDisplay:YES];
}

- (NSSize)solidColorMatrixCellSize
{
    return NSMakeSize(40.0, 40.0);
}

- (id)solidColorPreset
{
    return [NSArray arrayWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"SolidColorMatrixPreset" ofType:@"plist"]];
}

- (id)imageWithSolidColor:(id)aColor
{
    NSImage *image = [[[NSImage alloc] initWithSize:[self solidColorMatrixCellSize]] autorelease];
    [image lockFocus];
    NSSize size = [image size];
    [(NSColor *)aColor set];
    NSRectFill(NSMakeRect(0.0, 0.0, size.width, size.height));
    [[[NSColor blackColor] colorWithAlphaComponent:0.3] set];
    NSFrameRectWithWidthUsingOperation(NSMakeRect(0.0, 0.0, size.width, size.height), 1.0, NSCompositingOperationSourceOver);
    [image unlockFocus];
    return image;
}

// The presets fill the matrix column by column.
- (void)setupSolidColortMatrix
{
    int rows = (int)[_solidColorMatrix numberOfRows];
    int columns = (int)[_solidColorMatrix numberOfColumns];
    id preset = [self solidColorPreset];
    for (int column = 0; column < columns; column++) {
        for (int row = 0; row < rows; row++) {
            NSCell *cell = [_solidColorMatrix cellAtRow:row column:column];
            NSColor *color = [[[NSColor alloc] initWithExtraDictionary:[preset extraObjectAtIndex:column * rows + row]] autorelease];
            [cell setImage:[self imageWithSolidColor:color]];
            [cell setRepresentedObject:color];
        }
    }
}

- (void)dealloc
{
    [_originalObject release];
    [_toolSettings release];
    [super dealloc];
}

- (void)applyChanges
{
    NSColor *color = [_solidColorWell color];
    if (color != nil) {
        [[_originalObject undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Erase Background" value:@"" table:@"UndoManager"]];
        [[_originalObject currentCard] eraseBackgroundWithColor:color];
        [_toolSettings setEraserColor:[color colorWithAlphaComponent:1.0]];
    }
}

- (id)initWithOriginalObject:(id)aObject
{
    self = [super init];
    if (self != nil) {
        _originalObject = [aObject retain];
        if (_originalObject != nil) {
            _toolSettings = [[[HSToolManager sharedToolManager] toolSettings] retain];
            if (_toolSettings != nil)
                return self;
        }
    }
    [self release];
    return nil;
}

- (void)didLoadNib
{
    NSColor *color = [_toolSettings eraserColor];
    [_solidColorWell setColor:color];
    [_solidColorWell setShowsAlphaForPanel:NO];
    [_solidColorWell setPatternSupportEnabled:NO];
    [_solidColorWell setGradientSupportEnabled:NO];
    [_cardPreview setCard:[_originalObject currentCard]];
    [_cardPreview setBackgroundColor:color];
    [self setupSolidColortMatrix];
    [self updateCardPreview];
}

- (id)nibName
{
    return @"EraseBackground";
}

@end
