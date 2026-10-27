#import "HSATemplateChooser.h"
#import "HyperStudioUmbrella.h"

@interface NSColor (HSATemplateChooserColors)
- (CGColorRef)BT_coreGraphicsColor;
@end

static HSATemplateChooser *HSATemplateChooserShared;


@implementation HSATemplateChooser

+ (id)sharedTemplateChooser
{
    if (HSATemplateChooserShared == nil) {
        HSATemplateChooserShared = [self new];
    }
    return HSATemplateChooserShared;
}

- (void)dealloc
{
    [_window release];
    [_templatesBrowseItems release];
    [_openRecentButton release];
    [_recentDocuments release];
    [_zoomSlider release];
    [super dealloc];
}

- (id)window
{
    if (_window == nil) {
        [NSBundle loadNibNamed:@"HSATemplateChooser" owner:self];
        if (_window == nil) {
            return nil;
        }
        [self windowDidLoad];
    }
    return _window;
}

- (id)templatesBrowseItems
{
    if (_templatesBrowseItems == nil) {
        NSArray *list = [self templatesBrowseItemsList];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[list count]];
        for (NSDictionary *entry in list) {
            NSString *name = [entry objectForKey:@"TemplateName"];
            NSString *imagePath = [self pathForTemplateImageWithName:[entry objectForKey:@"ImageName"]];
            NSString *title = [entry objectForKey:@"Title"];
            if (name != nil && imagePath != nil && title != nil) {
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
                HSATemplateBrowseItem *item = [[HSATemplateBrowseItem alloc] initWithPreviewImage:image templateName:name title:title];
                [items addObject:[item autorelease]];
            }
        }
        _templatesBrowseItems = [[items sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
            return [[first imageTitle] localizedStandardCompare:[second imageTitle]];
        }] retain];
    }
    return _templatesBrowseItems;
}

- (id)templatesBrowseItemsList
{
    NSString *directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Ready Made Cards/iBooks Author"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:NULL];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[contents count]];
    for (NSString *file in contents) {
        if ([[file pathExtension] caseInsensitiveCompare:@"stack"] == NSOrderedSame) {
            NSString *last = [file lastPathComponent];
            NSString *imageName = [[last stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
            [result addObject:[NSDictionary dictionaryWithObjectsAndKeys:imageName, @"ImageName", last, @"TemplateName", [last stringByDeletingPathExtension], @"Title", nil]];
        }
    }
    return [NSArray arrayWithArray:result];
}

- (void)setTemplatesBrowseItems:(id)aItems
{
    if (_templatesBrowseItems != aItems) {
        [_templatesBrowseItems release];
        _templatesBrowseItems = [aItems retain];
    }
}

- (id)recentDocuments
{
    if (_recentDocuments == nil) {
        _recentDocuments = [[[NSDocumentController sharedDocumentController] recentDocumentURLs] retain];
    }
    return _recentDocuments;
}

- (void)setRecentDocuments:(id)aDocuments
{
    if (_recentDocuments != aDocuments) {
        [_recentDocuments release];
        _recentDocuments = [aDocuments retain];
    }
}

- (id)openRecentButton
{
    return _openRecentButton;
}

- (void)setOpenRecentButton:(id)aButton
{
    if (_openRecentButton != aButton) {
        [_openRecentButton release];
        _openRecentButton = [aButton retain];
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)zoomSlider
{
    return _zoomSlider;
}

- (void)setZoomSlider:(id)aSlider
{
    if (_zoomSlider != aSlider) {
        [_zoomSlider release];
        _zoomSlider = [aSlider retain];
    }
}

- (void)windowDidLoad
{
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:[[NSColor colorWithDeviceWhite:26.0f / 255.0f alpha:1.0] BT_coreGraphicsColor]];
    [_imageBrowserView setBackgroundLayer:layer];
    NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [style setAlignment:NSCenterTextAlignment];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSFont fontWithName:@"LucidaGrande-Bold" size:11.0] forKey:NSFontAttributeName];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    [_imageBrowserView setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
    [_imageBrowserView setValue:attributes forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
    [_imageBrowserView setAllowsEmptySelection:NO];
    [self configureOpenRecentMenu];
}

- (void)showWindow
{
    [[self window] center];
    [[self window] makeKeyAndOrderFront:nil];
    [_imageBrowserView reloadData];
    [_imageBrowserView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [self updateRecentDocuments];
}

- (void)close
{
    [_window orderOut:nil];
}

- (id)pathForTemplateWithName:(id)aName
{
    return [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Ready Made Cards/iBooks Author"] stringByAppendingPathComponent:aName];
}

- (id)pathForTemplateImageWithName:(id)aName
{
    return [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Ready Made Cards/iBooks Author/Previews"] stringByAppendingPathComponent:aName];
}

- (void)configureOpenRecentMenu
{
    NSMenu *menu = [[self openRecentButton] menu];
    NSImage *icon = [NSImage imageNamed:@"Document"];
    [menu removeAllItems];
    [menu addItem:[[[NSMenuItem alloc] initWithTitle:@"Open Recent" action:NULL keyEquivalent:@""] autorelease]];
    [icon setSize:NSMakeSize(16.0, 16.0)];
    NSInteger index = 0;
    for (NSURL *url in [self recentDocuments]) {
        NSString *title = [[url lastPathComponent] stringByDeletingPathExtension];
        NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title action:@selector(recentDocumentMenuItemClick:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [item setTag:index++];
        [item setImage:icon];
        [menu addItem:item];
    }
    if ([_recentDocuments count] != 0) {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    NSMenuItem *clear = [[[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(clearRecentDocuments:) keyEquivalent:@""] autorelease];
    [clear setTarget:self];
    [menu addItem:clear];
}

- (void)updateRecentDocuments
{
    [self setRecentDocuments:nil];
    [self recentDocuments];
    [self configureOpenRecentMenu];
}

- (void)openTemplateWithName:(id)aName
{
    NSString *path = [self pathForTemplateWithName:aName];
    [[self delegate] templateChooser:self didChooseTemplateAtPath:path];
}

- (IBAction)recentDocumentMenuItemClick:(id)aSender
{
    if ([aSender isKindOfClass:[NSMenuItem class]]) {
        NSURL *url = [[self recentDocuments] objectAtIndex:[aSender tag]];
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES error:NULL];
        [self close];
    }
}

- (IBAction)clearRecentDocuments:(id)aSender
{
    [[NSDocumentController sharedDocumentController] clearRecentDocuments:aSender];
    [self updateRecentDocuments];
}

- (IBAction)choose:(id)aSender
{
    [self close];
    NSIndexSet *selection = [_imageBrowserView selectionIndexes];
    if ([selection count] != 0) {
        [self openTemplateWithName:[[[_imageBrowserView cellForItemAtIndex:[selection firstIndex]] representedItem] templateName]];
    }
}

- (IBAction)cancel:(id)aSender
{
    [self close];
}

- (IBAction)openExistingFile:(id)aSender
{
    [[NSDocumentController sharedDocumentController] openDocument:nil];
}

- (IBAction)minimumZoom:(id)aSender
{
    float value = (float)[[self zoomSlider] minValue];
    [[self zoomSlider] setFloatValue:value];
    [_imageBrowserView setZoomValue:value];
}

- (IBAction)maximumZoom:(id)aSender
{
    float value = (float)[[self zoomSlider] maxValue];
    [[self zoomSlider] setFloatValue:value];
    [_imageBrowserView setZoomValue:value];
}

- (NSUInteger)numberOfItemsInImageBrowser:(id)aBrowser
{
    return [[self templatesBrowseItems] count];
}

- (id)imageBrowser:(id)aBrowser itemAtIndex:(NSUInteger)aIndex
{
    return [[self templatesBrowseItems] objectAtIndex:aIndex];
}

- (void)imageBrowser:(id)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)aIndex
{
    [self close];
    [self openTemplateWithName:[[[_imageBrowserView cellForItemAtIndex:aIndex] representedItem] templateName]];
}

@end
