#import "HSHTML5ExportAccessoryViewController.h"

@implementation HSHTML5ExportAccessoryViewController

- (void)controlTextDidChange:(id)aChange
{
    int depth = [_linkedStacksDepthTextField intValue];
    if ((unsigned)(depth - 1) < 99)
        [_linkedStacksDepthStepper setIntValue:depth];
}

- (void)linkedStacksDepthChanged:(id)aChanged
{
    int depth = [aChanged intValue];
    if (aChanged == _linkedStacksDepthTextField)
        [_linkedStacksDepthStepper setIntValue:depth];
    else
        [_linkedStacksDepthTextField setIntValue:depth];
}

- (void)exportWithDepthChanged:(id)aChanged
{
    BOOL enabled = [aChanged state] == NSControlStateValueOn;
    [_linkedStacksDepthTextField setEnabled:enabled];
    [_linkedStacksDepthStepper setEnabled:enabled];
    [_explanationText setTextColor:enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:_linkedStacksDepthTextField];
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL linkedStacks = [[NSUserDefaults standardUserDefaults] boolForKey:@"HSHTML5ExportAreLinkedStacksInDocument"];
    [_exportWithDepthCheckbox setEnabled:linkedStacks];
    [_exportWithDepthCheckbox setState:linkedStacks ? NSControlStateValueOn : NSControlStateValueOff];
    [_linkedStacksDepthTextField setEnabled:linkedStacks];
    [_linkedStacksDepthStepper setEnabled:linkedStacks];
    [_explanationText setTextColor:linkedStacks ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    return [self initWithNibName:@"ExportToHTML5AccessoryView"];
}

- (id)stack
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] stack];
}

+ (CGFloat)webAppContentLayerCornerRadiusForLayerSize:(CGSize)aSize
{
    return (float)(fminf(aSize.width, aSize.height) * 0.17543859649122806);
}

- (void)editWebAppIcon:(id)aSender
{
    id dialog = [[HSWebAppIconEditorDialogController new] autorelease];
    [dialog setCards:[[self stack] children]];
    if ([[NSApplication sharedApplication] runModalForWindow:[dialog window]] == NSModalResponseOK)
        [self updateWebAppIconWithImage:[dialog croppedImageWithHorizontalSelection]];
}

- (void)updateWebAppIconWithImage:(id)aImage
{
    [[self stack] setWebAppIcon:aImage];
    CALayer *layer = [_webAppIconPreviewView layer];
    CGSize layerSize = layer != nil ? [layer bounds].size : CGSizeZero;
    [layer setContents:[[self class] webAppContentLayerImageFromImage:[[self stack] webAppIcon] forContentLayerSize:layerSize]];
}

- (void)configureWebIconPreviewView
{
    CALayer *layer = [CALayer layer];
    [layer setMasksToBounds:YES];
    CGRect bounds = _webAppIconPreviewView != nil ? [_webAppIconPreviewView bounds] : CGRectZero;
    [layer setFrame:bounds];
    [layer setCornerRadius:[[self class] webAppContentLayerCornerRadiusForLayerSize:bounds.size]];
    [layer setBorderWidth:1.0];
    CGColorRef borderColor = [[NSColor controlShadowColor] newHyperCGColor];
    [layer setBorderColor:borderColor];
    CGColorRelease(borderColor);
    CGSize layerSize = layer != nil ? [layer bounds].size : CGSizeZero;
    [layer setContents:[[self class] webAppContentLayerImageFromImage:[[self stack] webAppIcon] forContentLayerSize:layerSize]];
    [_webAppIconPreviewView setLayer:layer];
    [_webAppIconPreviewView setWantsLayer:YES];
}

+ (id)webAppContentLayerImageFromImage:(id)aImage forContentLayerSize:(NSSize)aSize
{
    NSImage *result = [[[NSImage alloc] initWithSize:aSize] autorelease];
    [result lockFocus];
    [aImage drawInRect:NSMakeRect(0, 0, [result size].width, [result size].height) fromRect:NSMakeRect(0, 0, [aImage size].width, [aImage size].height) operation:NSCompositingOperationSourceOver fraction:1.0];
    [result unlockFocus];
    return result;
}

@end
