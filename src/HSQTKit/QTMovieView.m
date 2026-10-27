#import "HSQTKit.h"

// QTMovieView's controller bar was 16 points high below the movie.
#define CONTROLLER_HEIGHT 16.0

@interface QTMovie (HSQTKitPrivate)
- (NSSize)naturalSize;
@end

@implementation QTMovieView

- (void)setUp
{
    AVPlayerView *playerView = [[AVPlayerView alloc] initWithFrame:[self bounds]];
    [playerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [playerView setControlsStyle:AVPlayerViewControlsStyleNone];
    [playerView setVideoGravity:AVLayerVideoGravityResizeAspect];
    [playerView setShowsFullScreenToggleButton:NO];
    [self addSubview:playerView];
    _playerView = playerView;
    _controllerVisible = YES;
    _preservesAspectRatio = YES;
    _volumeButtonVisible = YES;
    _stepButtonsVisible = YES;
    _fillColor = [[NSColor clearColor] retain];
    [self setWantsLayer:YES];
    [self setControllerVisible:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
        [self setUp];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self setUp];
        if ([coder allowsKeyedCoding]) {
            if ([coder containsValueForKey:@"QTMovieViewControllerVisible"])
                [self setControllerVisible:[coder decodeBoolForKey:@"QTMovieViewControllerVisible"]];
            if ([coder containsValueForKey:@"QTMovieViewPreservesAspectRatio"])
                [self setPreservesAspectRatio:[coder decodeBoolForKey:@"QTMovieViewPreservesAspectRatio"]];
        }
    }
    return self;
}

- (void)dealloc
{
    [(AVPlayerView *)_playerView setPlayer:nil];
    [_playerView release];
    [_movie release];
    [_fillColor release];
    [super dealloc];
}

- (QTMovie *)movie { return _movie; }

- (void)setMovie:(QTMovie *)movie
{
    if (movie == _movie)
        return;
    [_movie release];
    _movie = [movie retain];
    [(AVPlayerView *)_playerView setPlayer:[movie AVPlayer]];
}

- (NSRect)movieControllerBounds
{
    if (!_controllerVisible)
        return NSZeroRect;
    NSRect bounds = [self bounds];
    return NSMakeRect(NSMinX(bounds), [self isFlipped] ? NSMaxY(bounds) - CONTROLLER_HEIGHT : NSMinY(bounds),
                      NSWidth(bounds), CONTROLLER_HEIGHT);
}

- (NSRect)movieBounds
{
    NSRect bounds = [self bounds];
    if (_controllerVisible) {
        bounds.size.height = MAX(0, bounds.size.height - CONTROLLER_HEIGHT);
        if (![self isFlipped])
            bounds.origin.y += CONTROLLER_HEIGHT;
    }
    if (!_preservesAspectRatio || !_movie)
        return bounds;
    NSSize natural = [_movie naturalSize];
    if (natural.width <= 0 || natural.height <= 0)
        return bounds;
    CGRect fit = AVMakeRectWithAspectRatioInsideRect(NSSizeToCGSize(natural), NSRectToCGRect(bounds));
    return NSRectFromCGRect(fit);
}

- (NSColor *)fillColor { return _fillColor; }

- (void)setFillColor:(NSColor *)fillColor
{
    [_fillColor autorelease];
    _fillColor = [fillColor retain];
    [_playerView setWantsLayer:YES];
    [[_playerView layer] setBackgroundColor:[fillColor CGColor]];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    [_fillColor set];
    NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (BOOL)isControllerVisible { return _controllerVisible; }

- (void)setControllerVisible:(BOOL)controllerVisible
{
    _controllerVisible = controllerVisible;
    [(AVPlayerView *)_playerView setControlsStyle:controllerVisible ? AVPlayerViewControlsStyleInline : AVPlayerViewControlsStyleNone];
}

- (BOOL)preservesAspectRatio { return _preservesAspectRatio; }

- (void)setPreservesAspectRatio:(BOOL)preservesAspectRatio
{
    _preservesAspectRatio = preservesAspectRatio;
    [(AVPlayerView *)_playerView setVideoGravity:preservesAspectRatio ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResize];
}

- (BOOL)isEditable { return _editable; }
- (void)setEditable:(BOOL)editable { _editable = editable; }
- (void)setShowsResizeIndicator:(BOOL)show { _showsResizeIndicator = show; }
- (BOOL)isBackButtonVisible { return _backButtonVisible; }
- (void)setBackButtonVisible:(BOOL)state { _backButtonVisible = state; }
- (BOOL)isCustomButtonVisible { return _customButtonVisible; }
- (void)setCustomButtonVisible:(BOOL)state { _customButtonVisible = state; }
- (BOOL)isHotSpotButtonVisible { return _hotSpotButtonVisible; }
- (void)setHotSpotButtonVisible:(BOOL)state { _hotSpotButtonVisible = state; }
- (BOOL)areStepButtonsVisible { return _stepButtonsVisible; }

- (void)setStepButtonsVisible:(BOOL)state
{
    _stepButtonsVisible = state;
    [(AVPlayerView *)_playerView setShowsFrameSteppingButtons:state];
}

- (BOOL)isTranslateButtonVisible { return _translateButtonVisible; }
- (void)setTranslateButtonVisible:(BOOL)state { _translateButtonVisible = state; }
- (BOOL)isVolumeButtonVisible { return _volumeButtonVisible; }
- (void)setVolumeButtonVisible:(BOOL)state { _volumeButtonVisible = state; }
- (BOOL)areZoomButtonsVisible { return _zoomButtonsVisible; }
- (void)setZoomButtonsVisible:(BOOL)state { _zoomButtonsVisible = state; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }

- (IBAction)play:(id)sender { [_movie play]; }
- (IBAction)pause:(id)sender { [_movie stop]; }
- (IBAction)gotoBeginning:(id)sender { [_movie gotoBeginning]; }
- (IBAction)gotoEnd:(id)sender { [_movie gotoEnd]; }
- (IBAction)gotoNextSelectionPoint:(id)sender { [_movie gotoNextSelectionPoint]; }
- (IBAction)gotoPreviousSelectionPoint:(id)sender { [_movie gotoPreviousSelectionPoint]; }
- (IBAction)gotoPosterFrame:(id)sender { [_movie gotoPosterTime]; }
- (IBAction)stepForward:(id)sender { [_movie stepForward]; }
- (IBAction)stepBackward:(id)sender { [_movie stepBackward]; }

// ---- editing, on the movie's selection

- (BOOL)canEdit
{
    return _editable && [[_movie attributeForKey:QTMovieEditableAttribute] boolValue];
}

- (QTTimeRange)selectionOrAll:(QTMovie *)movie
{
    if ([movie selectionDuration].timeValue)
        return QTMakeTimeRange([movie selectionStart], [movie selectionDuration]);
    return QTMakeTimeRange(QTZeroTime, [movie duration]);
}

- (IBAction)copy:(id)sender
{
    QTMovie *part = [_movie movieWithTimeRange:[self selectionOrAll:_movie] error:NULL];
    NSData *data = [part movieFormatRepresentation];
    if (!data)
        return;
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setData:data forType:QTMoviePasteboardType];
}

- (IBAction)cut:(id)sender
{
    if (![self canEdit])
        return;
    [self copy:sender];
    [self delete:sender];
}

- (IBAction)delete:(id)sender
{
    if (![self canEdit] || ![_movie selectionDuration].timeValue)
        return;
    [_movie deleteSegment:QTMakeTimeRange([_movie selectionStart], [_movie selectionDuration])];
    [_movie setSelection:QTMakeTimeRange([_movie selectionStart], QTZeroTime)];
}

- (IBAction)paste:(id)sender
{
    if (![self canEdit])
        return;
    QTMovie *clip = [QTMovie movieWithPasteboard:[NSPasteboard generalPasteboard] error:NULL];
    if (clip)
        [_movie replaceSelectionWithSelectionFromMovie:clip];
}

- (IBAction)add:(id)sender
{
    if (![self canEdit])
        return;
    QTMovie *clip = [QTMovie movieWithPasteboard:[NSPasteboard generalPasteboard] error:NULL];
    if (clip)
        [_movie insertSegmentOfMovie:clip timeRange:QTMakeTimeRange(QTZeroTime, [clip duration]) atTime:[_movie currentTime]];
}

- (IBAction)addScaled:(id)sender
{
    if (![self canEdit] || ![_movie selectionDuration].timeValue)
        return;
    QTMovie *clip = [QTMovie movieWithPasteboard:[NSPasteboard generalPasteboard] error:NULL];
    if (clip)
        [_movie insertSegmentOfMovie:clip fromRange:QTMakeTimeRange(QTZeroTime, [clip duration])
                       scaledToRange:QTMakeTimeRange([_movie selectionStart], [_movie selectionDuration])];
}

- (IBAction)replace:(id)sender { [self paste:sender]; }

- (IBAction)trim:(id)sender
{
    if (![self canEdit] || ![_movie selectionDuration].timeValue)
        return;
    QTTime end = QTTimeIncrement([_movie selectionStart], [_movie selectionDuration]);
    [_movie deleteSegment:QTMakeTimeRange(end, QTTimeDecrement([_movie duration], end))];
    [_movie deleteSegment:QTMakeTimeRange(QTZeroTime, [_movie selectionStart])];
    [_movie setSelection:QTMakeTimeRange(QTZeroTime, [_movie duration])];
}

- (IBAction)selectAll:(id)sender { [_movie setSelection:QTMakeTimeRange(QTZeroTime, [_movie duration])]; }
- (IBAction)selectNone:(id)sender { [_movie setSelection:QTMakeTimeRange([_movie currentTime], QTZeroTime)]; }

@end
