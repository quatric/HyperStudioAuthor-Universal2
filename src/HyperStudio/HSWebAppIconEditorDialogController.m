#import "HSWebAppIconEditorDialogController.h"
#import "HyperStudioUmbrella.h"

@interface HSWebAppIconEditorDialogController (HSWebAppIconEditorDialogControllerExtras)
- (id)cropTool;
- (void)hideToolMatrix;
- (id)croppedImageWithHorizontalSelectionClippedToOriginalImageBounds:(id)aBounds;
- (struct CGPath *)hyperCGPath;
@end

@interface NSBezierPath (HSWebAppIconEditorDialogControllerPaths)
- (struct CGPath *)hyperCGPath;
@end

@interface NSObject (HSWebAppIconEditorDialogControllerCards)
- (id)imageWithVisualizationProtocol:(Protocol *)aProtocol;
- (id)hyperTitle;
@end


@implementation HSWebAppIconEditorDialogController

- (id)init
{
    self = [super init];
    if (self != nil) {
        [[self cropTool] setValue:[NSNumber numberWithBool:YES] forInputKey:@"proportionalMode"];
        [[self cropTool] setValue:[NSNumber numberWithBool:YES] forInputKey:@"ignoreClickOutsidePath"];
        [self hideToolMatrix];
        [_imageCropView setDelegate:self];
        [_imageCropView setBackgroundColor:[self contentBackgroundColor]];
    }
    return self;
}

- (void)dealloc
{
    [_imageCropView setDelegate:nil];
    [[_stripScrollView mediaStripView] setDelegate:nil];
    [[_stripScrollView mediaStripView] setDataSource:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_cards release];
    [_cardImages release];
    [super dealloc];
}

- (id)windowNibName
{
    return @"WebAppIconEditorDialogController";
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
    [_cardIndexContainerView setDrawsBorder:NO];
    [_cardIndexContainerView setDrawsFill:YES];
    [_cardIndexContainerView setTintColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0]];
    [_cardIndexContainerView setOpaque:YES];
    [[_stripScrollView mediaStripView] setDelegate:self];
    [[_stripScrollView mediaStripView] setDataSource:self];
    [[_stripScrollView mediaStripView] setShowsLabels:YES];
    [[_stripScrollView mediaStripView] setShowsBadgedIcons:NO];
    [[_stripScrollView mediaStripView] setRemovesSelectionOnClickBetweenItems:NO];
    [[_stripScrollView mediaStripView] setShowsFirstResponderStatus:YES];
    [[self window] setInitialFirstResponder:_shadowView];
}

- (id)defaultCropTool
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0.0, 0.0, 1.0, 1.0) xRadius:0.175439f yRadius:0.175439f];
    struct CGPath *cgPath = [path hyperCGPath];
    id tool = [self shapeCreateSelectionToolWithPath:(id)cgPath];
    CGPathRelease(cgPath);
    return tool;
}

- (id)contentBackgroundPattern
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:HSWorkAreaBackgroundKey];
    NSString *path = [[NSBundle mainBundle] pathForResource:name != nil ? name : @"Denim" ofType:@"tiff" inDirectory:@"WABPatterns"];
    if (path == nil) {
        return nil;
    }
    return [[[NSImage alloc] initByReferencingFile:path] autorelease];
}

- (id)contentBackgroundColor
{
    id pattern = [self contentBackgroundPattern];
    return pattern != nil ? [NSColor colorWithPatternImage:pattern] : [NSColor clearColor];
}

- (id)webAppIcon
{
    NSImage *result = nil;
    NSImage *cropped = [self croppedImageWithHorizontalSelectionClippedToOriginalImageBounds:nil];
    if (cropped != nil && !NSEqualSizes([cropped size], NSZeroSize)) {
        result = [[NSImage alloc] initWithSize:[cropped size]];
        if (result != nil) {
            [result lockFocus];
            CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
            CGAffineTransform ctm = CGContextGetCTM(context);
            CGContextSetPatternPhase(context, CGSizeMake(ctm.tx, ctm.ty));
            [[_imageCropView backgroundColor] set];
            NSRectFill(NSMakeRect(0.0, 0.0, [result size].width, [result size].height));
            [cropped drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0.0, 0.0, [cropped size].width, [cropped size].height) operation:NSCompositeSourceOver fraction:1.0];
            [result unlockFocus];
        }
    }
    return [result autorelease];
}

- (void)setCards:(id)aCards
{
    [_cards release];
    [_cardImages release];
    _cards = [aCards copy];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (id card in aCards) {
        [images addObject:[card imageWithVisualizationProtocol:@protocol(HSPlayerVisualization)]];
    }
    [self setCardImages:images];
    [images release];
    [[_stripScrollView mediaStripView] noteNumberOfItemsChanged];
    [[_stripScrollView mediaStripView] reloadData];
    [self selectCardWithIndex:0];
    id tool = [self cropTool];
    if ([tool respondsToSelector:@selector(selectAllArea:)]) {
        [tool performSelector:@selector(selectAllArea:) withObject:nil];
    }
}

- (id)cardImages
{
    return _cardImages;
}

- (void)setCardImages:(id)aImages
{
    if (_cardImages != aImages) {
        [_cardImages release];
        _cardImages = [aImages retain];
    }
}

- (void)selectCardWithIndex:(NSUInteger)aIndex
{
    NSArray *images = [self cardImages];
    if (aIndex < [images count]) {
        [self setSourceNSImage:[images objectAtIndex:aIndex]];
        [_webAppIconPreviewView setIcon:[self webAppIcon]];
        [[_stripScrollView mediaStripView] setActiveItemIndex:aIndex];
        [self updateShadowPath];
    }
}

- (void)updateShadowPath
{
    CGAffineTransform transform = [_imageCropView imageToViewTransform];
    [_shadowView setPath:[NSBezierPath hyperBezierPathWithCGPath:[self borderPath] affineTransform:transform]];
}

- (void)selectionDidUpdateInView:(id)aView
{
    [self updateShadowPath];
    [_webAppIconPreviewView setIcon:[self webAppIcon]];
}

- (void)scaleFactorDidChangeInView:(id)aView
{
    [self updateShadowPath];
}

- (void)mouseEntered:(id)aEvent inView:(id)aView
{
    [[self window] makeFirstResponder:aView];
}

- (void)openHelp:(id)aSender
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSWebAppIcon"];
}

- (NSUInteger)numberOfRowsInMediaStrip:(id)aStrip
{
    return [[self cardImages] count];
}

- (NSSize)mediaStrip:(id)aStrip imageSizeForItemAtIndex:(NSUInteger)aIndex
{
    return [[[self cardImages] objectAtIndex:aIndex] size];
}

- (id)mediaStrip:(id)aStrip imageForItemAtIndex:(NSUInteger)aIndex
{
    return [[self cardImages] objectAtIndex:aIndex];
}

- (id)mediaStrip:(id)aStrip labelForItemAtIndex:(NSUInteger)aIndex
{
    return [[_cards objectAtIndex:aIndex] hyperTitle];
}

- (void)mediaStrip:(id)aStrip clickedOnItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aInside
{
    [self selectCardWithIndex:aIndex];
    [[_stripScrollView mediaStripView] setActiveItemIndex:aIndex];
}

- (void)mediaStrip:(id)aStrip doubleClickedOnItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aInside modifiers:(NSUInteger)aModifiers
{
    [self selectCardWithIndex:aIndex];
    [[_stripScrollView mediaStripView] setActiveItemIndex:aIndex];
}

- (void)windowDidResize:(id)aNotification
{
    [self updateShadowPath];
}

@end
