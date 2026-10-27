#import "HSSelectImagePartPane.h"

@implementation HSSelectImagePartPane

- (void)handleCancelOperationForImagePartSelectionTool:(id)aTool
{
    [self HSSelectImagePartPane_paneDidCancel];
}

- (void)handleInsertNewlineForImagePartSelectionTool:(id)aTool
{
    [self HSSelectImagePartPane_paneDidOK];
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (void)paneDidCancel:(id)aCancel
{
    [self HSSelectImagePartPane_paneDidCancel];
}

- (void)paneDidOK:(id)aOK
{
    [self HSSelectImagePartPane_paneDidOK];
}

- (void)HSSelectImagePartPane_paneDidCancel
{
    if ([_delegate respondsToSelector:@selector(selectImagePartPaneCancel:)])
        [_delegate selectImagePartPaneCancel:self];
    else
        [self dismiss:YES];
}

- (void)HSSelectImagePartPane_paneDidOK
{
    if ([_delegate respondsToSelector:@selector(selectImagePartPaneCrop:)]) {
        [_delegate selectImagePartPaneCrop:self];
    } else {
        [self cropImageObject];
        [self dismiss:YES slide:NO];
    }
}

- (id)newBackgroundImage
{
    return [HSObjectAssistantNavigationPaneSwitcher new];
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return YES;
}

- (void)cropImageObject
{
    if ([[[[HSToolManager sharedToolManager] currentTool] toolIdentifier] isEqual:[self coachingKey]])
        [[HSImageCropApplier cropApplierForImageObject:[self hyperObject]] cropImageObjectWithPath:[self borderPath]];
}

// The path is copied from the image part selection tool while it is current.
- (struct CGPath *)borderPath
{
    if (!_borderPath) {
        id tool = [[HSToolManager sharedToolManager] currentTool];
        if ([[tool toolIdentifier] isEqual:[self coachingKey]])
            _borderPath = [tool copiedCGPath];
    }
    return _borderPath;
}

- (id)geometryAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)hyperObject
{
    return [[self assistant] object];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)modeToolTags
{
    return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x3e], [NSNumber numberWithUnsignedInt:0x3f], [NSNumber numberWithUnsignedInt:0x40], nil];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    CGPathRelease(_borderPath);
    _borderPath = NULL;
    [super viewWillDisappear:aDisappear];
}

- (id)assistantPaneUndoManager
{
    if (![_delegate respondsToSelector:@selector(undoManagerForImagePartPane:)])
        return nil;
    return [_delegate undoManagerForImagePartPane:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)HSSelectImagePartPane_windowDidResignMain:(id)aResign
{
    id current = [[HSEditorController sharedDocumentController] currentDocument];

    if (current != nil && current != [[self stack] document])
        [self HSSelectImagePartPane_paneDidCancel];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSSelectImagePartPane_windowDidResignMain:) name:NSWindowDidResignMainNotification object:[[[[self stack] document] cardView] window]];
    [super viewWillAppear:aAppear];
}

@end
