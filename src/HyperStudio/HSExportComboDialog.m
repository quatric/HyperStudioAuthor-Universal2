#import "HSExportComboDialog.h"

@implementation HSExportComboDialog

- (void)exportToImageSequence:(id)aSequence
{
    _exportFormat = 3;
    [self finishDialog:YES];
}

- (void)exportToWebPage:(id)aPage
{
    _exportFormat = 7;
    [self finishDialog:YES];
}

- (void)exportToStackToGo:(id)aGo
{
    _exportFormat = 2;
    [self finishDialog:YES];
}

- (void)exportToQuickTimeMovie:(id)aMovie
{
    _exportFormat = 4;
    [self finishDialog:YES];
}

- (void)exportToiPod:(id)aPod
{
    _exportFormat = 5;
    [self finishDialog:YES];
}

- (void)exportToiPhone:(id)aPhone
{
    _exportFormat = 6;
    [self finishDialog:YES];
}

- (void)exportToVideoPodcast:(id)aPodcast
{
    // (The original uses the same format code as the iPhone export.)
    _exportFormat = 6;
    [self finishDialog:YES];
}

- (void)cancel:(id)aCancel
{
    _exportFormat = 0;
    _publishType = 0;
    [super cancel:aCancel];
}

- (NSInteger)publishType
{
    return _publishType;
}

- (NSInteger)exportFormat
{
    return _exportFormat;
}

- (void)willShowWindow
{
    [super willShowWindow];
    [self mountView:_exportChoicesView animate:NO];
}

// Resizes the window so the mounted view fits the container; the window is
// kept centred on its old frame. (The original takes the width delta from the
// window's width, not the container's, so the window ends up as wide as the
// mounted view.)
- (void)mountView:(id)aView animate:(BOOL)aAnimate
{
    NSRect windowFrame = [[self window] frame];
    NSRect containerFrame = [_containerView frame];
    float heightDelta = (NSHeight(windowFrame) - NSHeight(containerFrame) + NSHeight([aView frame])) - NSHeight(windowFrame);
    windowFrame.size.height += heightDelta;
    windowFrame.origin.y -= floorf(heightDelta * 0.5f);
    float widthDelta = NSWidth([aView frame]) - NSWidth(windowFrame);
    windowFrame.size.width += widthDelta;
    windowFrame.origin.x -= floorf(widthDelta * 0.5f);

    [_mountedView removeFromSuperview];
    [_mountedView release];
    [[self window] setFrame:windowFrame display:YES animate:aAnimate];
    [aView setFrame:[_containerView bounds]];
    [_containerView addSubview:aView];
    [(NSView *)aView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
    _mountedView = [aView retain];
    [[self window] setInitialFirstResponder:_iPhoneButton];
}

- (void)didLoadNib
{
    NSButton *buttons[] = { _iTunesAudioButton, _audioBookButton, _podcastAudioButton, _flashVideoButton, _iPhoneButton, _iPodButton, _quickTimeMovieButton, _stackToGoButton, _webPageButton, _imageSequenceButton };
    for (int i = 0; i < 10; i++) {
        id cell = [buttons[i] cell];
        if ([cell respondsToSelector:@selector(setBackgroundRenderer:)])
            [[buttons[i] cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    }
    _publishType = 1;
}

- (id)nibName
{
    return @"ExportDialogAR2";
}

- (void)dealloc
{
    [_mountedView release];
    [super dealloc];
}

- (IBAction)goBack:(id)aBack
{
    [self mountView:_exportChoicesView animate:YES];
}

- (IBAction)exportForiBooksAuthor:(id)aSender
{
    _exportFormat = 10;
    _publishType = 4;
    [self finishDialog:YES];
}

- (IBAction)exportToFTPServer:(id)aSender
{
    _exportFormat = 11;
    _publishType = 5;
    [self finishDialog:YES];
}

- (IBAction)exportToHTML5:(id)aSender
{
    _exportFormat = 7;
    _publishType = 1;
    [self finishDialog:YES];
}

@end
