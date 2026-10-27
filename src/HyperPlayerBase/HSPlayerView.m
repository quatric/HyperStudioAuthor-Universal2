#import "HSPlayerView.h"
#import "HyperPlayerBaseData.h"

// Navigation operation stages handled by the player view.
enum {
    HSPlayerViewNavigationStageMoveToStack = 11,
    HSPlayerViewNavigationStageMoveToCard = 12,
    HSPlayerViewNavigationStageCancelled = 14
};

static id HSPlayerViewDefaultSlideshowAttributes = nil;

@implementation HSPlayerView

// Frames go to every consumer: the card view's alone, or mixed with a
// graphic composition or over the slideshow background.
- (void)capturingDataSource:(id)aSource didOutputFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime
{
    if (_activeConsumers == NULL)
        return;
    if (aSource == _cardView) {
        CVPixelBufferRelease(_cardViewPixelBuffer);
        _cardViewPixelBuffer = CVPixelBufferRetain(aFrame);
    }
    CVPixelBufferRef frame = NULL;
    if ([self isGraphicCompositionPlaying]) {
        if (aSource == _graphicCompositionView) {
            CVPixelBufferRelease(_graphicCompositionViewPixelBuffer);
            _graphicCompositionViewPixelBuffer = CVPixelBufferRetain(aFrame);
        }
        if (_cardViewPixelBuffer != NULL && _graphicCompositionViewPixelBuffer != NULL)
            frame = [self HSPlayerView_createMixedFrameWithPixelBuffer:_cardViewPixelBuffer andPixelBuffer:_graphicCompositionViewPixelBuffer];
    } else if ([self isSlideshow]) {
        if (_slideshowBackgroundPixelBuffer != NULL)
            frame = [self HSPlayerView_createMixedFrameWithPixelBuffer:_slideshowBackgroundPixelBuffer andPixelBuffer:aFrame];
    } else
        frame = CVPixelBufferRetain(aFrame);
    if (frame != NULL) {
        CFIndex count = CFDictionaryGetCount(_activeConsumers);
        if (count == 1) {
            const void *consumer = NULL;
            CFDictionaryGetKeysAndValues(_activeConsumers, &consumer, NULL);
            [(id)consumer capturingDataSource:self didOutputFrame:frame atTime:aTime];
        } else if (count > 1) {
            const void **consumers = malloc(count * sizeof(void *));
            if (consumers != NULL) {
                CFDictionaryGetKeysAndValues(_activeConsumers, consumers, NULL);
                for (CFIndex i = 0; i < count; i++) {
                    if (CFDictionaryGetValue(_activeConsumers, consumers[i]) != NULL)
                        [(id)consumers[i] capturingDataSource:self didOutputFrame:frame atTime:aTime];
                }
                free(consumers);
            }
        }
    }
    CVPixelBufferRelease(frame);
}

// A copy of the first buffer with the second drawn over it.
- (struct __CVBuffer *)HSPlayerView_createMixedFrameWithPixelBuffer:(struct __CVBuffer *)aBuffer andPixelBuffer:(struct __CVBuffer *)aBuffer2
{
    CVPixelBufferRef mixed = NULL;
    if (aBuffer == NULL || aBuffer2 == NULL)
        return NULL;
    size_t width = CVPixelBufferGetWidth(aBuffer);
    size_t height = CVPixelBufferGetHeight(aBuffer);
    if (width == 0 || height == 0)
        return NULL;
    CVPixelBufferPoolRef pool = [self HSPlayerView_pixelBufferPoolWithWidth:width height:height];
    if (pool == NULL)
        return NULL;
    CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &mixed);
    if (mixed == NULL)
        return NULL;
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(mixed, 0);
    if (context == NULL) {
        CVPixelBufferRelease(mixed);
        return NULL;
    }
    if (CVPixelBufferLockBaseAddress(aBuffer, 0) != kCVReturnSuccess) {
        CGContextRelease(context);
        CVPixelBufferRelease(mixed);
        return NULL;
    }
    memcpy(CVPixelBufferGetBaseAddress(mixed), CVPixelBufferGetBaseAddress(aBuffer), CVEPixelBufferGetDataSize(aBuffer));
    CVPixelBufferUnlockBaseAddress(aBuffer, 0);
    CGImageRef image = (CGImageRef)CVBufferGetAttachment(aBuffer2, CFSTR("HSPixelBufferCGImage"), NULL);
    if (image != NULL)
        CGImageRetain(image);
    else
        image = CGEImageCreateWithPixelBuffer(aBuffer2, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    if (image == NULL) {
        CGContextRelease(context);
        CVPixelBufferRelease(mixed);
        return NULL;
    }
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, (float)CGImageGetWidth(image), (float)CGImageGetHeight(image)), image);
    CGContextRelease(context);
    CGImageRelease(image);
    return mixed;
}

// The last consumer stops the capture of whatever is showing.
- (void)stopCapturingForConsumer:(id)aConsumer
{
    if (_activeConsumers == NULL)
        return;
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer);
    if (count == 0)
        return;
    if (count != 1) {
        CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)(count - 1));
        return;
    }
    CFDictionaryRemoveValue(_activeConsumers, aConsumer);
    if (CFDictionaryGetCount(_activeConsumers) != 0)
        return;
    if ([self isTransitionPlaying])
        [_transitionView stopCapturingForConsumer:self];
    else if ([self isSlideshow]) {
        [_cardView stopCapturingForConsumer:self];
        [[[self slideshow] transitionView] stopCapturingForConsumer:self];
        [self removeSlideshowBackgroundPixelBuffer];
    } else {
        if ([self isGraphicCompositionPlaying])
            [[self HSPlayerView_graphicCompositionView] stopCapturingForConsumer:self];
        [_cardView stopCapturingForConsumer:self];
    }
    CVPixelBufferRelease(_cardViewPixelBuffer);
    _cardViewPixelBuffer = NULL;
    CVPixelBufferRelease(_graphicCompositionViewPixelBuffer);
    _graphicCompositionViewPixelBuffer = NULL;
}

// The first consumer starts the capture of whatever is showing.
- (void)startCapturingForConsumer:(id)aConsumer
{
    if (_activeConsumers == NULL) {
        _activeConsumers = CFDictionaryCreateMutable(NULL, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_activeConsumers == NULL)
            return;
        CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)1);
    } else {
        CFIndex count = CFDictionaryGetCount(_activeConsumers);
        NSUInteger value = count != 0 ? (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer) + 1 : 1;
        CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)value);
        if (count != 0)
            return;
    }
    if ([self isTransitionPlaying])
        [_transitionView startCapturingForConsumer:self];
    else if ([self isSlideshow]) {
        if (![self createSlideshowBackgroundPixelBuffer])
            return;
        [_cardView stopCapturingForConsumer:self];
        [[[self slideshow] transitionView] startCapturingForConsumer:self];
    } else {
        BOOL compositionPlaying = [self isGraphicCompositionPlaying];
        [_cardView startCapturingForConsumer:self];
        if (compositionPlaying)
            [[self HSPlayerView_graphicCompositionView] startCapturingForConsumer:self];
    }
}

- (void)removeSlideshowBackgroundPixelBuffer
{
    CVPixelBufferRelease(_slideshowBackgroundPixelBuffer);
    _slideshowBackgroundPixelBuffer = NULL;
    CVPixelBufferPoolRelease(_pixelBufferPool);
    _pixelBufferPool = NULL;
}

// A white frame of the presentation size under the slideshow.
- (BOOL)createSlideshowBackgroundPixelBuffer
{
    if (_slideshowBackgroundPixelBuffer == NULL) {
        NSRect bounds = [[self presentationView] bounds];
        float boundsWidth = bounds.size.width, boundsHeight = bounds.size.height;
        NSUInteger width = boundsWidth > 0.0f ? lroundf(ceilf(boundsWidth)) : 0;
        NSUInteger height = boundsHeight > 0.0f ? lroundf(ceilf(boundsHeight)) : 0;
        CVPixelBufferPoolRef pool = [self HSPlayerView_pixelBufferPoolWithWidth:width height:height];
        if (pool != NULL) {
            CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &_slideshowBackgroundPixelBuffer);
            if (_slideshowBackgroundPixelBuffer != NULL) {
                CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(_slideshowBackgroundPixelBuffer, 0);
                if (context != NULL) {
                    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, (float)width, (float)height));
                    CGContextRelease(context);
                }
            }
        }
    }
    return _slideshowBackgroundPixelBuffer != NULL;
}

// One BGRA pool, recreated when the size changes.
- (struct __CVPixelBufferPool *)HSPlayerView_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight
{
    if (_pixelBufferPool != NULL) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        if ([[attributes objectForKey:(NSString *)kCVPixelBufferWidthKey] unsignedLongValue] == aWidth && [[attributes objectForKey:(NSString *)kCVPixelBufferHeightKey] unsignedLongValue] == aHeight)
            return _pixelBufferPool;
        CVPixelBufferPoolRelease(_pixelBufferPool);
        _pixelBufferPool = NULL;
    }
    NSDictionary *attachments = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCGImageAlphaPremultipliedFirst], kCVEPixelBufferAlphaInfoKey, nil];
    if (attachments == nil)
        return _pixelBufferPool;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (NSString *)kCVPixelBufferPixelFormatTypeKey,
        [NSNumber numberWithUnsignedLong:aWidth], (NSString *)kCVPixelBufferWidthKey,
        [NSNumber numberWithUnsignedLong:aHeight], (NSString *)kCVPixelBufferHeightKey,
        (id)kCFBooleanTrue, (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey,
        (id)kCFBooleanTrue, (NSString *)kCVPixelBufferCGImageCompatibilityKey,
        attachments, (NSString *)kCVBufferNonPropagatedAttachmentsKey, nil];
    if (attributes != nil)
        CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)attributes, &_pixelBufferPool);
    return _pixelBufferPool;
}

- (void)cardView:(id)aView didSetCard:(id)aCard
{
    if ([_delegate respondsToSelector:@selector(cardView:inPlayerView:didSetCard:)])
        [_delegate cardView:aView inPlayerView:self didSetCard:aCard];
}

- (void)cardView:(id)aView willSetCard:(id)aCard
{
    if ([_delegate respondsToSelector:@selector(cardView:inPlayerView:willSetCard:)])
        [_delegate cardView:aView inPlayerView:self willSetCard:aCard];
}

- (void)presentationWillInterrupt
{
    [self stopTransition];
    if ([self isSlideshow])
        [self interruptSlideshow];
}

// Moving to another stack shows the transition view over the old card;
// moving to a card goes there; a cancelled operation is finished.
- (void)performNavigationOperation:(id)aOperation
{
    if ([_delegate respondsToSelector:@selector(canPerformNavigationOperationInPalyerView:)] && ![_delegate canPerformNavigationOperationInPalyerView:self])
        return;
    if ([aOperation stage] == HSPlayerViewNavigationStageMoveToStack) {
        [self setNavigationOperation:aOperation];
        id transition = [aOperation transition];
        [[self HSPlayerView_transitionView] setTransitionEffect:[transition effect]];
        [_transitionView setTransitionDuration:[(HSTransition *)transition duration]];
        [self HSPlayerView_showTransitionView];
    } else if ([aOperation stage] == HSPlayerViewNavigationStageMoveToCard) {
        if (_navigationOperation == nil)
            [self setNavigationOperation:aOperation];
        BOOL ignoresSlideshow = [aOperation ignoresSlideshow];
        [self goToCard:[aOperation destinationCard] inStack:[aOperation destinationStack] withTransition:[aOperation transition] interruptSlideshow:!ignoresSlideshow];
    } else if ([aOperation stage] == HSPlayerViewNavigationStageCancelled)
        [self finishNavigationOperationIfNeeded];
}

- (void)setNavigationOperation:(id)aOperation
{
    if ([_navigationOperation isEqual:aOperation])
        return;
    if (_navigationOperation != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNavigationControllerDidFinishNavigationOperationNotification" object:[[self document] navigationController]];
        [_navigationOperation release];
    }
    _navigationOperation = [aOperation retain];
    if (_navigationOperation != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationOperationDidFinish:) name:@"HSNavigationControllerDidFinishNavigationOperationNotification" object:[[self document] navigationController]];
}

// Only a live slideshow lets navigation through, cancelling its timers.
- (void)goToCard:(id)aCard inStack:(id)aStack withTransition:(id)aTransition interruptSlideshow:(BOOL)aSlideshow
{
    BOOL isSlideshow = [self isSlideshow];
    if (!_liveSlideshow) {
        if (isSlideshow)
            return;
    } else if (isSlideshow && [[self slideshowAttributes] startsNextSlideAutomatically] && aSlideshow) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnToOriginalSlide) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSPlayerView_goToNextSlide) object:nil];
    }
    [self HSPlayerView_goToCard:aCard inStack:aStack withTransition:aTransition];
}

- (void)HSPlayerView_goToCard:(id)aCard inStack:(id)aStack withTransition:(id)aTransition
{
    [self stopTransition];
    if (aTransition == nil || [aTransition isFastestTransition]) {
        [[self cardView] setCard:aCard];
        [[self cardView] activate];
        [self finishNavigationOperationIfNeeded];
        return;
    }
    if ([[self presentationView] superview] == nil)
        return;
    [[self HSPlayerView_transitionView] setTransitionEffect:[aTransition effect]];
    [_transitionView setTransitionDuration:[(HSTransition *)aTransition duration]];
    id sourceCard = [_navigationOperation sourceCard];
    if (sourceCard == nil)
        sourceCard = [[self cardView] card];
    [self setTransitionSourceCard:sourceCard];
    [self setTransitionDestinationCard:aCard];
    [_transitionView invalidateStartImage];
    [_transitionView invalidateEndImage];
    [self HSPlayerView_showTransitionView];
    [self startTransition];
    [self setStack:aStack];
}

- (BOOL)isTransitionPlaying
{
    return [_transitionView isTransitionPlaying];
}

- (void)stopTransition
{
    if ([_transitionView isTransitionPlaying])
        [_transitionView stopTransition];
}

// A transition on the active card itself.
- (void)showTransition:(id)aTransition
{
    [[self cardView] deactivate];
    if ([[self presentationView] superview] == nil)
        return;
    [[self HSPlayerView_transitionView] setTransitionEffect:[aTransition effect]];
    [_transitionView setTransitionDuration:[(HSTransition *)aTransition duration]];
    [self setTransitionSourceCard:[self activeCard]];
    [self setTransitionDestinationCard:[self activeCard]];
    [_transitionView invalidateStartImage];
    [_transitionView invalidateEndImage];
    [self startTransitionView];
}

// The destination renderer is refreshed when the card's children changed.
- (id)endImageForTransitionView:(id)aView
{
    if (!_isTransitionDestinationCardRendererValid)
        [_transitionDestinationCardDrawable setRenderer:[self HSPlayerView_transitionDestinationCardRenderer]];
    [_transitionDestinationCardDrawable setColorProfile:[_transitionView colorSyncProfile] colorSpace:[_transitionView colorSpace]];
    return (id)[_transitionDestinationCardDrawable pixelBuffer];
}

- (id)startImageForTransitionView:(id)aView
{
    [_transitionSourceCardDrawable setColorProfile:[_transitionView colorSyncProfile] colorSpace:[_transitionView colorSpace]];
    return (id)[_transitionSourceCardDrawable pixelBuffer];
}

- (void)transitionViewDidFinishTransition:(id)aTransition
{
    if (aTransition == _transitionView)
        [self HSPlayerView_transitionDidEnd];
    [super transitionViewDidFinishTransition:aTransition];
}

- (void)transitionViewDidStopTransition:(id)aTransition
{
    if (aTransition == _transitionView)
        [self HSPlayerView_transitionDidEnd];
    [super transitionViewDidStopTransition:aTransition];
}

- (void)startTransitionView
{
    [self HSPlayerView_showTransitionView];
    [self startTransition];
}

- (void)startTransition
{
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0) {
        [_cardView stopCapturingForConsumer:self];
        [_transitionView startCapturingForConsumer:self];
    }
    [self startImageForTransitionView:_transitionView];
    [self endImageForTransitionView:_transitionView];
    if (![_transitionView startTransition])
        [self HSPlayerView_transitionDidEnd];
}

// The card view takes the destination card (the source one when cancelled)
// back from the transition view.
- (void)HSPlayerView_transitionDidEnd
{
    if (_transitionSourceCard == _transitionDestinationCard)
        [[self document] refreshMoviesHiddenStateForCard:_transitionDestinationCard];
    if ([[self presentationView] superview] == nil)
        [self finishNavigationOperationIfNeeded];
    else {
        NSWindow *window = [_cardView window];
        [window disableScreenUpdatesUntilFlush];
        BOOL cancelled = [_navigationOperation stage] == HSPlayerViewNavigationStageCancelled;
        [_cardView setCard:cancelled ? [self transitionSourceCard] : [self transitionDestinationCard]];
        if (![self isFullScreen]) {
            if ([_cardView enclosingScrollView] != nil && ![[[self document] fileType] isEqualToString:@"HSWebDocumentType"])
                [_cardView autosizeCenteringAtUserPoint:_transitionCenter respectingLastVisibleContent:NO];
        } else {
            id sizeAttributes = [[_cardView card] queryHyperInterface:@protocol(HSSizeAttributes)];
            NSSize size = sizeAttributes != nil ? [(id<HSSizeAttributes>)sizeAttributes size] : NSZeroSize;
            [_cardView setZoomFactor:[[_cardView class] zoomFactorForFullScreen:size]];
            [self adjustCardViewSize];
            [self centrateCardView];
        }
        [window makeFirstResponder:_cardView];
        [_transitionView removeFromSuperview];
        if (_wasOpenGLSurfaceEnabled)
            [_cardView enableOpenGLSurface];
        else
            [_cardView disableOpenGLSurfaceDetachingImmediately:NO];
        [_cardView setNeedsDisplay:YES];
        [self finishNavigationOperationIfNeeded];
        [window displayIfNeeded];
        [_transitionView setTransitionEffect:nil];
        if (_isBorderless && ![[self window] isOpaque])
            [[self window] invalidateShadow];
    }
    if (_transitionSourceCard == _transitionDestinationCard)
        [_transitionDestinationCard removeObserver:self selector:@selector(HSPlayerView_transitionDestinationCardDidChangeChildren:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [_transitionDestinationCardDrawable setAutoInvalidationDelegate:nil];
    [_transitionDestinationCardDrawable release];
    _transitionDestinationCardDrawable = nil;
    _isTransitionDestinationCardRendererValid = 0;
    [_transitionSourceCardDrawable setAutoInvalidationDelegate:nil];
    [_transitionSourceCardDrawable release];
    _transitionSourceCardDrawable = nil;
    [self setTransitionDestinationCard:nil];
    [self setTransitionSourceCard:nil];
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0) {
        [_transitionView stopCapturingForConsumer:self];
        [_cardView startCapturingForConsumer:self];
    }
    [[self cardView] activate];
}

- (void)setTransitionSourceCard:(id)aCard
{
    if (_transitionSourceCard != aCard) {
        [_transitionSourceCard release];
        _transitionSourceCard = [aCard retain];
    }
}

- (id)transitionSourceCard
{
    return _transitionSourceCard;
}

- (void)setTransitionDestinationCard:(id)aCard
{
    if (_transitionDestinationCard != aCard) {
        [_transitionDestinationCard release];
        _transitionDestinationCard = [aCard retain];
    }
}

- (id)transitionDestinationCard
{
    return _transitionDestinationCard;
}

- (void)finishNavigationOperationIfNeeded
{
    if (_navigationOperation == nil)
        return;
    if ([_navigationOperation stage] != HSPlayerViewNavigationStageCancelled)
        [[_delegate navigationControllerForPlayerView:self] finishNavigationOperation:_navigationOperation];
    [_navigationOperation release];
    _navigationOperation = nil;
    if ([_delegate respondsToSelector:@selector(navigationOperationDidFinishInPlayerView:)])
        [_delegate navigationOperationDidFinishInPlayerView:self];
}

- (void)doCommandBySelector:(SEL)aSelector
{
    _didHandleKeyEvent = 1;
    [super doCommandBySelector:aSelector];
}

- (void)insertText:(id)aText
{
    _didHandleKeyEvent = 1;
    [super insertText:aText];
}

// A click stops a transition, or ends or advances a live slideshow.
- (BOOL)handleMouseDownEvent:(id)aEvent
{
    if ([self isTransitionPlaying]) {
        [self stopTransition];
        return YES;
    }
    if (!_liveSlideshow || ![self isSlideshow])
        return NO;
    if ([[self slideshowAttributes] useClickOnExitCard]) {
        [self stopSlideshow];
        return YES;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnToOriginalSlide) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSPlayerView_goToNextSlide) object:nil];
    [self ignoreDurationBetweenSlides];
    [self performNavigationDidFinishForceNextSlide:YES];
    return YES;
}

// A key stops a transition, or ends or advances a live slideshow; other keys
// are interpreted.
- (BOOL)handleKeyDownEvent:(id)aEvent
{
    _didHandleKeyEvent = 0;
    if ([self isTransitionPlaying]) {
        [self stopTransition];
        _didHandleKeyEvent = 1;
    }
    if (!_didHandleKeyEvent && _liveSlideshow && [self isSlideshow]) {
        if (![[self slideshowAttributes] useKeystrokeOnExitCard:aEvent]) {
            [self stopSlideshow];
            _didHandleKeyEvent = 1;
        } else
            _didHandleKeyEvent = [self HSPlayerView_goToNextSlide] ? 1 : 0;
    }
    if (!_didHandleKeyEvent)
        [self interpretKeyEvents:[NSArray arrayWithObject:aEvent]];
    return _didHandleKeyEvent != 0;
}

- (void)graphicCompositionViewDidFinishRendering:(id)aRendering
{
    if (aRendering == _graphicCompositionView)
        [self HSPlayerView_graphicCompositionDidEnd];
    [super graphicCompositionViewDidFinishRendering:aRendering];
}

- (void)graphicCompositionViewDidStopRendering:(id)aRendering
{
    if (aRendering == _graphicCompositionView)
        [self HSPlayerView_graphicCompositionDidEnd];
    [super graphicCompositionViewDidStopRendering:aRendering];
}

- (BOOL)isGraphicCompositionPlaying
{
    return [_graphicCompositionView isRendering];
}

- (void)stopGraphicComposition
{
    if ([_graphicCompositionView isRendering])
        [_graphicCompositionView stopRendering];
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0)
        [_graphicCompositionView stopCapturingForConsumer:self];
}

// The composition plays over the card view's viewing rect.
- (void)showGraphicComposition:(id)aComposition duringTimeInterval:(double)aInterval stopOnMouseClick:(BOOL)aClick
{
    if ([_presentationView superview] == nil || [self HSPlayerView_graphicCompositionView] == nil)
        return;
    [_cardView deactivate];
    [_graphicCompositionView setGraphicComposition:aComposition];
    [_graphicCompositionView setRenderingDuration:aInterval];
    [_graphicCompositionView setStopsOnMouseClick:aClick];
    [_graphicCompositionView setFrame:[_cardView cardViewingRect]];
    NSWindow *window = [_cardView window];
    _wasOpenGLSurfaceEnabled = [_cardView isOpenGLSurfaceEnabled] ? 1 : 0;
    [_cardView disableOpenGLSurfaceDetachingImmediately:NO];
    [_cardView setNeedsDisplay:YES];
    [_cardView addSubview:_graphicCompositionView];
    [window makeFirstResponder:_graphicCompositionView];
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0)
        [_graphicCompositionView startCapturingForConsumer:self];
    if (![_graphicCompositionView startRendering])
        [self HSPlayerView_graphicCompositionDidEnd];
}

- (void)HSPlayerView_graphicCompositionDidEnd
{
    [_cardView activate];
    NSWindow *window = [_cardView window];
    [window disableScreenUpdatesUntilFlush];
    [window makeFirstResponder:_cardView];
    [_graphicCompositionView removeFromSuperview];
    if (_wasOpenGLSurfaceEnabled)
        [_cardView enableOpenGLSurface];
    else
        [_cardView disableOpenGLSurfaceDetachingImmediately:NO];
    [_cardView setNeedsDisplay:YES];
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0)
        [_graphicCompositionView stopCapturingForConsumer:self];
    [window displayIfNeeded];
    [_graphicCompositionView setGraphicComposition:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayerViewGraphicCompositionDidEndNotification" object:self];
}

- (void)pausePictureShow
{
    [[self slideshow] pauseSlideshow];
}

- (void)resumePictureShow
{
    [[self slideshow] resumeSlideshow];
}

- (BOOL)isPictureShow
{
    return _isPictureShow != 0;
}

- (void)setOriginalCard:(id)aCard
{
    if (_originalCard != aCard) {
        [_originalCard release];
        _originalCard = [aCard retain];
    }
}

- (id)originalCard
{
    return _originalCard;
}

// The slideshow starts at the active card over the transition background.
- (id)checkOptions:(id)aOptions
{
    NSMutableDictionary *options = aOptions != nil ? [NSMutableDictionary dictionaryWithDictionary:aOptions] : [NSMutableDictionary dictionary];
    if ([options valueForKey:@"IKSlideshowStartIndex"] == nil)
        [options setValue:[NSNumber numberWithInt:(int)[self activeCardIndex]] forKey:@"IKSlideshowStartIndex"];
    if ([options valueForKey:HSTransitionBackgroundColor] == nil)
        [options setValue:[self transitionBackgroundColor] forKey:HSTransitionBackgroundColor];
    return options;
}

- (id)transitionBackgroundColor
{
    id color = [self selfBackgroundColor];
    if (color == nil) {
        id view = [[self subviews] lastObject];
        if (![view isKindOfClass:[NSScrollView class]])
            view = [self window];
        color = [view backgroundColor];
    }
    return color;
}

- (BOOL)slideshowExecutedByAction
{
    return _slideShowExecutedByAction != 0;
}

- (id)slideshowAttributes
{
    if (_liveSlideShowAttributes != nil)
        return _liveSlideShowAttributes;
    return [self HSPlayerView_slideShowAttributesFromDefaults];
}

// Shared by all player views, reloaded after the defaults changed.
- (id)HSPlayerView_slideShowAttributesFromDefaults
{
    if (HSPlayerViewDefaultSlideshowAttributes == nil || _slideShowAttributesChanged) {
        [HSPlayerViewDefaultSlideshowAttributes release];
        HSPlayerViewDefaultSlideshowAttributes = [[HSSlideshowAttributes objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSSlideshowAttributesKeyString"]] retain];
        _slideShowAttributesChanged = 0;
    }
    return HSPlayerViewDefaultSlideshowAttributes;
}

- (void)stopSlideshow
{
    _isPictureShow = 0;
    if ([[self slideshowAttributes] returnsToOriginalCard]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSPlayerView_goToNextSlide) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnToOriginalSlide) object:nil];
        [self returnToOriginalSlide];
    } else
        [self interruptSlideshow];
}

- (void)interruptSlideshow
{
    if (![self isSlideshow])
        return;
    id document = [self document];
    if ([document navigationController] == nil)
        return;
    id manager = [[document queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
    if (manager == nil)
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionExecutionManagerDidBecomeIdleNotification" object:manager];
    if (!_liveSlideshow) {
        [self setIsSlideshow:NO];
        [[self slideshow] stopSlideshow:self];
        return;
    }
    if ([[self slideshowAttributes] startsNextSlideAutomatically]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnToOriginalSlide) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSPlayerView_goToNextSlide) object:nil];
    }
    [self stopTransition];
    [self setIsSlideshow:NO];
    [[self window] makeFirstResponder:[self cardView]];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSPlayerViewSlideshowDidStopNotification object:self];
    [[self document] slideshowDidStop];
    [_liveSlideShowAttributes release];
    _liveSlideShowAttributes = nil;
    _liveSlideshow = 0;
}

// A picture show (or another data source) runs as an image slideshow; the
// live slideshow goes through the cards themselves.
- (void)startSlideshowWithDataSource:(id)aSource options:(id)aOptions
{
    id pictureShow = [aSource queryHyperInterface:@protocol(HSPictureShowActionAttributes)];
    _isPictureShow = pictureShow != nil ? 1 : 0;
    if ([self isSlideshow] && pictureShow == nil)
        return;
    id options = [self checkOptions:aOptions];
    if (!_liveSlideshow) {
        [self setIsSlideshow:YES];
        [[self document] setRequiredSlideshowItemType:HSSlideshowItemImage];
        [[self slideshow] runSlideshowWithDataSource:aSource delegate:self options:options];
        if (_activeConsumers == NULL || CFDictionaryGetCount(_activeConsumers) < 1)
            return;
        if (![self createSlideshowBackgroundPixelBuffer])
            return;
        [_cardView stopCapturingForConsumer:self];
        [[[self slideshow] transitionView] startCapturingForConsumer:self];
        return;
    }
    // The original overwrote the previous attributes without releasing them.
    [_liveSlideShowAttributes release];
    _liveSlideShowAttributes = [[options objectForKey:HSCustomSlideshowAttributesKey] retain];
    _slideShowExecutedByAction = [[options objectForKey:HSSlideshowExecutedByActionKey] boolValue] ? 1 : 0;
    [self setOriginalCard:[_cardView card]];
    id document = [self document];
    [document slideshowWillStart];
    BOOL onLastCard = NO;
    if ([_liveSlideShowAttributes stopsAfterEnd])
        onLastCard = [[document stack] indexOfHyperChild:[document currentCard]] == [[document stack] hyperCount] - 1;
    _needOnceJumpToBegin = onLastCard ? 1 : 0;
    if ([[self slideshowAttributes] startsNextSlideAutomatically])
        [self performSelector:@selector(HSPlayerView_goToNextSlide) withObject:nil afterDelay:[[self slideshowAttributes] durationBetweenSlides] inModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self setIsSlideshow:YES];
    [document setRequiredSlideshowItemType:HSSlideshowLiveSlides];
    [[self window] makeFirstResponder:[self cardView]];
}

- (void)startSlideshowWithOptions:(id)aOptions
{
    _liveSlideshow = 1;
    [self startSlideshowWithDataSource:self options:aOptions];
}

- (void)startSlideshow
{
    _liveSlideshow = 1;
    [self startSlideshowWithOptions:nil];
}

// A solid background is judged by its colour, others by the background
// view's rendering of the rect averaged into one pixel.
- (BOOL)isBackgroundRatherLightInRect:(NSRect)aRect
{
    id graphics = [[self backgroundRenderer] backgroundGraphics];
    if ([self presentationSettings] != nil)
        graphics = [[[[self document] currentWindowController] playerSettingsDataSource] backgroundGraphics];
    if ([graphics isMemberOfClass:[HSGraphics class]])
        return NO;
    id colorAttributes = [graphics queryHyperInterface:@protocol(HSColor)];
    NSColor *color = [colorAttributes isHyperSolid] ? [colorAttributes hyperSolidColor] : nil;
    NSImage *patternImage = nil;
    @try {
        patternImage = [color patternImage];
    } @catch (NSException *exception) {
    }
    if (patternImage == nil && color != nil && ![color isKindOfClass:[HSGradientColor class]]) {
        color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        if ((float)[color saturationComponent] > 1.0f)
            return NO;
        return (float)[color brightnessComponent] > 0.5f;
    }
    NSRect rect = [self convertRect:aRect toView:_backgroundView];
    if (NSIsEmptyRect(rect))
        return NO;
    uint8_t pixel[4] = { 0, 0, 0, 0 };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    float scaleX = rect.size.width != 0.0 ? 1.0f / (float)rect.size.width : 1.0f;
    float scaleY = rect.size.height != 0.0 ? 1.0f / (float)rect.size.height : 1.0f;
    CGContextConcatCTM(context, CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, 0.0f - (float)rect.origin.x * scaleX, 0.0f - (float)rect.origin.y * scaleY));
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    NSGraphicsContext *savedContext = [[NSGraphicsContext currentContext] retain];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    [graphicsContext setImageInterpolation:NSImageInterpolationHigh];
    [_backgroundView drawRect:rect];
    [NSGraphicsContext setCurrentContext:savedContext];
    [savedContext release];
    CGContextRelease(context);
    float alpha = pixel[0] != 0 ? (float)pixel[0] : 255.0f;
    CGFloat saturation = 0.0, value = 0.0;
    CGEColorConvertRGBToHSV((float)pixel[1] / alpha, (float)pixel[2] / alpha, (float)pixel[3] / alpha, NULL, &saturation, &value);
    if ((float)saturation > 1.0f)
        return NO;
    return (float)value > 0.5f;
}

- (void)setupBackgroundAttributes
{
    id source = [self presentationSettings] != nil ? [self presentationSettings] : self;
    [_backgroundView setBackgroundRenderer:[source backgroundRenderer]];
    [_backgroundView setNeedsDisplay:YES];
}

- (id)presentationSettings
{
    return [[[self document] currentWindowController] playerSettingsDataSource];
}

- (id)backgroundRenderer
{
    return [[self stack] queryHyperInterface:@protocol(HSBackgroundRenderer)];
}

- (void)setFullScreenAttributes:(id)aAttributes
{
    if (_fullScreenAttributes != aAttributes) {
        [_fullScreenAttributes release];
        _fullScreenAttributes = [aAttributes retain];
    }
}

- (void)defaultBackgroundAttributesDidChange:(id)aChange
{
    [_defaultBackgroundRenderer release];
    _defaultBackgroundRenderer = nil;
    [self setupBackgroundAttributes];
}

- (void)stackDidChangeBackgroundAttributes:(id)aAttributes
{
    [self setupBackgroundAttributes];
}

- (BOOL)isOpaque
{
    return !_isBorderless;
}

- (BOOL)includesBorderThicknessInOptimalSize
{
    return NO;
}

// The stack size plus the card container's border and, in a scroll view,
// the scrollers unless they hide themselves.
- (NSSize)frameSizeForStackSize:(NSSize)aSize withScrollView:(BOOL)aView
{
    float width = aSize.width, height = aSize.height;
    if ([self includesBorderThicknessInOptimalSize]) {
        float border = [[self cardContainerView] borderThickness];
        width = aSize.width + (border + border);
        height = aSize.height + (border + border);
    }
    if (!aView || [[self containerView] superview] == nil)
        return NSMakeSize(width, height);
    NSScrollView *scrollView = nil;
    BOOL hasScrollers = YES;
    if ([[self containerView] isKindOfClass:[NSScrollView class]]) {
        scrollView = [self containerView];
        if (scrollView != nil && [scrollView autohidesScrollers])
            hasScrollers = NO;
    }
    return [NSScrollView frameSizeForContentSize:NSMakeSize(width, height) hasHorizontalScroller:hasScrollers hasVerticalScroller:hasScrollers borderType:[scrollView borderType]];
}

// The presentation view goes back into the card container.
- (void)exitBorderlesMode
{
    [self pauseSlideshowIfNeeded];
    [[self presentationView] retain];
    [[self presentationView] removeFromSuperview];
    if (_isFullScreen)
        [_backgroundView removeFromSuperview];
    [self addSubview:_containerView];
    [_cardSuperview addSubview:[self presentationView]];
    float border = [(HSTintedView *)_cardSuperview borderThickness];
    [[self presentationView] setFrameOrigin:NSMakePoint(border, border)];
    [self setAutoresizesSubviews:YES];
    [_containerView setAutoresizingMask:_containerViewAutoresizingMask];
    [_containerView setAutoresizesSubviews:YES];
    [(NSView *)[self presentationView] setAutoresizingMask:_cardViewAutoresizingMask];
    [[self presentationView] release];
    [_containerView release];
    _isFullScreen = NO;
    _isBorderless = 0;
    [self resumeSlideshowIfNeeded];
}

// The presentation view leaves the card container: centred over the
// background view in full screen, at the origin otherwise.
- (void)makeBorderlessWithFullScreen:(BOOL)aScreen
{
    if ((_isFullScreen && aScreen) || (_isBorderless && !aScreen))
        return;
    [self pauseSlideshowIfNeeded];
    _isBorderless = aScreen ? 0 : 1;
    _isFullScreen = aScreen;
    _cardViewAutoresizingMask = (unsigned int)[(NSView *)[self presentationView] autoresizingMask];
    _containerViewAutoresizingMask = (unsigned int)[_containerView autoresizingMask];
    // Released when leaving the borderless mode.
    [_containerView retain];
    if (_isFullScreen) {
        [self createBackgroundViewIfNeeded];
        NSView *presentationView = [self presentationView];
        NSRect bounds = [self bounds];
        NSRect viewBounds = [[self presentationView] bounds];
        NSRect frame;
        frame.origin.x = ((bounds.size.width * 0.5f + bounds.origin.x) - (viewBounds.size.width * 0.5f + viewBounds.origin.x)) + viewBounds.origin.x;
        frame.origin.y = ((bounds.size.height * 0.5f + bounds.origin.y) - (viewBounds.size.height * 0.5f + viewBounds.origin.y)) + viewBounds.origin.y;
        frame.size = viewBounds.size;
        [presentationView setFrame:frame];
    } else {
        [[self presentationView] setFrameOrigin:NSZeroPoint];
        [self addSubview:[self presentationView]];
    }
    [_containerView removeFromSuperview];
    [self setAutoresizesSubviews:YES];
    [(NSView *)[self presentationView] setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    [self resumeSlideshowIfNeeded];
}

- (void)createBackgroundViewIfNeeded
{
    if (_backgroundView == nil) {
        _backgroundView = [[HSBackgroundRendererView alloc] initWithFrame:[self bounds]];
        [_backgroundView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    [_backgroundView setFrame:[self bounds]];
    [self addSubview:_backgroundView];
    [_backgroundView addSubview:[self presentationView]];
    [self setupBackgroundAttributes];
}

- (void)resumeSlideshowIfNeeded
{
    if (_paused) {
        _paused = 0;
        [self performNavigationDidFinish];
    }
}

- (void)pauseSlideshowIfNeeded
{
    if ([self isSlideshow] && !_paused) {
        _paused = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnToOriginalSlide) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSPlayerView_goToNextSlide) object:nil];
    }
}

- (id)selfBackgroundColor
{
    if (_isBorderless && ![[self window] isOpaque])
        return [NSColor clearColor];
    if (!_isFullScreen)
        return nil;
    return [_fullScreenAttributes backGroundColor];
}

- (NSUInteger)cardCount
{
    return [[self cardContainer] hyperCount];
}

- (NSUInteger)activeCardIndex
{
    id container = [self cardContainer];
    if (container == nil)
        return NSNotFound;
    return [container indexOfHyperChild:[[self activeCard] queryHyperInterface:@protocol(HSNodeChild)]];
}

- (id)cardContainer
{
    return [self stack];
}

- (void)setSlideshow:(id)aSlideshow
{
    if (_slideshow != aSlideshow) {
        [_slideshow release];
        _slideshow = [aSlideshow retain];
    }
}

// Live slideshows have no image slideshow.
- (id)slideshow
{
    if (_liveSlideshow)
        return nil;
    if (_slideshow == nil)
        [self setSlideshow:[[HSSlideshow new] autorelease]];
    return _slideshow;
}

- (void)setPresentationView:(id)aView
{
    if (_presentationView != aView)
        _presentationView = aView;
}

- (id)presentationView
{
    return _presentationView;
}

- (BOOL)isFullScreen
{
    return _isFullScreen;
}

// Image slideshows present the card view in a slideshow context.
- (void)setIsSlideshow:(BOOL)aSlideshow
{
    if (_liveSlideshow)
        _isSlideShowModeEnabled = aSlideshow ? 1 : 0;
    else
        [_cardView setPresentationContext:aSlideshow ? [HSSlideshowContext presentationContext] : nil];
}

- (BOOL)isSlideshow
{
    if (_liveSlideshow)
        return _isSlideShowModeEnabled != 0;
    return [_cardView isSlideshow];
}

- (BOOL)canDoSlideshow
{
    return [self nextCardForSlideshow] != nil;
}

// The slideshow wraps around unless it stops after the end.
- (id)nextCardForSlideshow
{
    id card = [self nextCard];
    if (card == nil && ![[[[NSUserDefaults standardUserDefaults] objectForKey:@"HSSlideshowAttributesKeyString"] valueForKey:@"_stopsAfterEnd"] boolValue])
        card = [[self cardContainer] hyperChildAtIndex:0];
    return card;
}

- (id)nextCard
{
    if ([self activeCardIndex] == NSNotFound)
        return nil;
    if ([self activeCardIndex] + 1 >= [self cardCount])
        return nil;
    return [[self cardContainer] hyperChildAtIndex:[self activeCardIndex] + 1];
}

- (id)activeCard
{
    return [_cardView card];
}

- (void)setActiveCard:(id)aCard
{
    [_cardView setCard:aCard];
}

- (id)cardView
{
    return _cardView;
}

- (id)containerView
{
    return _containerView;
}

- (id)cardContainerView
{
    return _cardSuperview;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate)
        _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)centrateCardView
{
    NSView *cardView = [self cardView];
    NSRect bounds = [[cardView superview] bounds];
    NSRect frame = [cardView frame];
    frame.origin.x = ((bounds.size.width * 0.5f + bounds.origin.x) - (frame.size.width * 0.5f + frame.origin.x)) + frame.origin.x;
    frame.origin.y = ((bounds.size.height * 0.5f + bounds.origin.y) - (frame.size.height * 0.5f + frame.origin.y)) + frame.origin.y;
    [cardView setFrame:frame];
}

- (void)adjustCardViewSize
{
    NSSize size = [self stack] != nil ? [[self stack] hyperCardSize] : NSZeroSize;
    NSRect rect = [[self cardView] viewBoundingRectForUserRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height)];
    [[self cardContainerView] setFrameSize:rect.size];
    [[self presentationView] setFrameSize:rect.size];
}

// A new stack opens on its poster card, or on the home stack's default
// card.
- (void)setStack:(id)aStack
{
    if (_stack == aStack)
        return;
    [_stack removeObserver:self selector:@selector(stackDidChangeBackgroundAttributes:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBackgroundAttributes)];
    [_stack release];
    _stack = [aStack retain];
    id card;
    if ([HSHomeStackController isHomeStackSupportedByCurrentEnvironment] && [[[HSHomeStackController sharedHomeStackController] homeStackURL] isEqual:[[_stack document] fileURL]])
        card = [_stack hyperChildAtIndex:[[HSHomeStackController sharedHomeStackController] defaultCardIndex]];
    else
        card = [_stack posterCard];
    [_cardView setCard:card];
    [_stack addObserver:self selector:@selector(stackDidChangeBackgroundAttributes:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBackgroundAttributes) withPriority:-0.75f];
    [self setupBackgroundAttributes];
}

- (id)document
{
    return [_stack document];
}

- (id)stack
{
    return _stack;
}

- (void)awakeFromNib
{
    if (NSAppKitVersionNumber >= 1038.0)
        [self setAcceptsTouchEvents:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_cardView playerView] == self)
        [_cardView setPlayerView:nil];
    if ([self isSlideshow]) {
        if (_liveSlideshow)
            [self interruptSlideshow];
        else
            [_slideshow stopSlideshow:nil];
    }
    [_originalCard release];
    [_liveSlideShowAttributes release];
    [_slideshow release];
    if ([_cardView delegate] == self)
        [_cardView setDelegate:nil];
    if ([_transitionView delegate] == self)
        [_transitionView setDelegate:nil];
    if ([_transitionView dataSource] == self)
        [_transitionView setDataSource:nil];
    [_transitionView release];
    [_handledSwipe release];
    if ([_graphicCompositionView delegate] == self)
        [_graphicCompositionView setDelegate:nil];
    [_graphicCompositionView release];
    [_cardView release];
    [_backgroundView release];
    [_fullScreenAttributes release];
    [_defaultBackgroundRenderer release];
    [_stack release];
    [_transitionDestinationCard release];
    [_transitionSourceCard release];
    [_playerTopView release];
    // The original leaked a pending navigation operation.
    [_navigationOperation release];
    if (_activeConsumers != NULL)
        CFRelease(_activeConsumers);
    CVPixelBufferRelease(_cardViewPixelBuffer);
    CVPixelBufferRelease(_graphicCompositionViewPixelBuffer);
    CVPixelBufferRelease(_slideshowBackgroundPixelBuffer);
    CVPixelBufferPoolRelease(_pixelBufferPool);
    [super dealloc];
}

// The content view comes from the nib and fills the player view.
- (id)onceInit
{
    if (![[self bundleIDClassForContentViewNib] loadNibNamed:[self contentViewNibName] owner:self]) {
        [self release];
        return nil;
    }
    [_containerView retain];
    [_containerView removeFromSuperview];
    [_containerView setFrame:[self bounds]];
    [self addSubview:_containerView];
    [_containerView release];
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_containerView setAutoresizesSubviews:YES];
    [_containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self setPresentationView:_cardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSPlayerView_defaultSlideshowAttributesDidChange:) name:@"HSSlideshowDidChangeAttributesNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultBackgroundAttributesDidChange:) name:HSUICoverDesktopBackgroundDidChangeNotification object:nil];
    [self setupBackgroundAttributes];
    [_cardView retain];
    [_cardView setPlayerView:self];
    return self;
}

- (id)contentViewNibName
{
    return @"PlayerContentView";
}

- (Class)bundleIDClassForContentViewNib
{
    return [HSPlayerBaseID class];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil && !_inited) {
        _inited = 1;
        self = [self onceInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil && !_inited) {
        _inited = 1;
        self = [self onceInit];
    }
    return self;
}

- (void)rendererStreamDrawable:(id)aDrawable didAutoInvalidateInRects:(NSRect *)aRects count:(NSUInteger)aCount
{
    if (aDrawable == _transitionSourceCardDrawable)
        [_transitionView invalidateStartImage];
    else if (aDrawable == _transitionDestinationCardDrawable)
        [_transitionView invalidateEndImage];
}

- (void)HSPlayerView_transitionDestinationCardDidChangeChildren:(id)aChildren
{
    _isTransitionDestinationCardRendererValid = 0;
}

// Both cards render into drawables covering the union of their view rects;
// the transition view takes that rect over the card view.
- (void)HSPlayerView_showTransitionView
{
    if ([self HSPlayerView_transitionView] == nil)
        return;
    id sourceSizeAttributes = [_transitionSourceCard queryHyperInterface:@protocol(HSSizeAttributes)];
    NSSize sourceSize = sourceSizeAttributes != nil ? [(id<HSSizeAttributes>)sourceSizeAttributes size] : NSZeroSize;
    id destinationSizeAttributes = [_transitionDestinationCard queryHyperInterface:@protocol(HSSizeAttributes)];
    NSSize destinationSize = destinationSizeAttributes != nil ? [(id<HSSizeAttributes>)destinationSizeAttributes size] : NSZeroSize;
    CGAffineTransform viewTransform = [_cardView NSE_affineTransformToView:nil];
    CGAffineTransform userTransform = [_cardView userSpaceToViewSpaceCGAffineTransform];
    CGAffineTransform destinationTransform = CGAffineTransformConcat(userTransform, viewTransform);
    CGAffineTransform sourceTransform = destinationTransform;
    if ([self isFullScreen]) {
        NSRect windowFrame = [[self window] frame];
        float zoom = [[_cardView class] zoomFactorForFullScreen:destinationSize];
        // The destination is shown flipped at the full screen zoom, centred
        // in the window.
        destinationTransform = CGAffineTransformMakeScale(zoom, zoom);
        float offsetY = ((float)windowFrame.size.height - (float)destinationSize.height * zoom) * 0.5f + (float)destinationTransform.ty;
        float offsetX = ((float)windowFrame.size.width - zoom * (float)destinationSize.width) * 0.5f + (float)destinationTransform.tx;
        destinationTransform.b = -destinationTransform.b;
        destinationTransform.d = -destinationTransform.d;
        destinationTransform.tx = offsetX;
        destinationTransform.ty = (float)windowFrame.size.height - offsetY;
    }
    if ([_navigationOperation sourceCard] != nil)
        sourceTransform = CGAffineTransformConcat([_navigationOperation sourceCardUserSpaceToViewSpaceTransform], [_navigationOperation sourceCardViewTransform]);
    CGRect sourceRect = CGRectApplyAffineTransform(CGRectMake(CGPointZero.x, CGPointZero.y, sourceSize.width, sourceSize.height), sourceTransform);
    CGRect destinationRect = CGRectApplyAffineTransform(CGRectMake(CGPointZero.x, CGPointZero.y, destinationSize.width, destinationSize.height), destinationTransform);
    float minX = MIN((float)destinationRect.origin.x, (float)sourceRect.origin.x);
    float maxX = MAX((float)(destinationRect.origin.x + destinationRect.size.width), (float)(sourceRect.origin.x + sourceRect.size.width));
    float minY = MIN((float)destinationRect.origin.y, (float)sourceRect.origin.y);
    float maxY = MAX((float)(destinationRect.size.height + destinationRect.origin.y), (float)(sourceRect.size.height + sourceRect.origin.y));
    CGRect unionRect = CGRectIntegral(CGRectMake(minX, minY, maxX - minX, maxY - minY));
    long width = lroundf(unionRect.size.width);
    if (width == 0)
        return;
    long height = lroundf(unionRect.size.height);
    if (height == 0)
        return;
    id sourceRenderer = [[_transitionSourceCard queryHyperInterface:[[_cardView class] visualizationProtocol]] queryRenderer];
    if (sourceRenderer == nil)
        return;
    _transitionSourceCardDrawable = [[HSRendererStreamDrawable alloc] initWithWidth:width height:height];
    if (_transitionSourceCardDrawable == nil)
        return;
    CGAffineTransform drawableTransform = sourceTransform;
    drawableTransform.tx = (float)sourceTransform.tx - (float)unionRect.origin.x;
    drawableTransform.ty = (float)sourceTransform.ty - (float)unionRect.origin.y;
    [_transitionSourceCardDrawable setRendererTransform:drawableTransform];
    [_transitionSourceCardDrawable setRenderer:sourceRenderer];
    [_transitionSourceCardDrawable setRenderDelegate:[_cardView renderDelegate]];
    [_transitionSourceCardDrawable setAutoInvalidates:YES];
    [_transitionSourceCardDrawable setAutoInvalidationDelegate:self];
    id destinationRenderer = [self HSPlayerView_transitionDestinationCardRenderer];
    if (destinationRenderer != nil) {
        _transitionDestinationCardDrawable = [[HSRendererStreamDrawable alloc] initWithWidth:width height:height];
        if (_transitionDestinationCardDrawable != nil) {
            drawableTransform = destinationTransform;
            drawableTransform.tx = (float)destinationTransform.tx - (float)unionRect.origin.x;
            drawableTransform.ty = (float)destinationTransform.ty - (float)unionRect.origin.y;
            [_transitionDestinationCardDrawable setRendererTransform:drawableTransform];
            [_transitionDestinationCardDrawable setRenderer:destinationRenderer];
            [_transitionDestinationCardDrawable setRenderDelegate:[_cardView renderDelegate]];
            [_transitionDestinationCardDrawable setAutoInvalidates:YES];
            [_transitionDestinationCardDrawable setAutoInvalidationDelegate:self];
            if (_transitionSourceCard == _transitionDestinationCard)
                [_transitionDestinationCard addObserver:self selector:@selector(HSPlayerView_transitionDestinationCardDidChangeChildren:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75f];
        }
    }
    if (_transitionDestinationCardDrawable == nil) {
        [_transitionSourceCardDrawable setAutoInvalidationDelegate:nil];
        [_transitionSourceCardDrawable release];
        _transitionSourceCardDrawable = nil;
        return;
    }
    // The card view is re-centred on this point afterwards.
    NSScrollView *scrollView = [_cardView enclosingScrollView];
    if (scrollView == nil) {
        _transitionCenter.x = (float)destinationSize.width * 0.5f;
        _transitionCenter.y = (float)destinationSize.height * 0.5f;
    } else {
        NSSize contentSize = [[scrollView class] contentSizeForFrameSize:[scrollView frame].size hasHorizontalScroller:NO hasVerticalScroller:NO borderType:[scrollView borderType]];
        NSRect visibleRect = [_cardView convertRect:[[scrollView contentView] frame] fromView:scrollView];
        _transitionCenter = [_cardView convertPointFromViewSpaceToUserSpace:NSMakePoint(contentSize.width * 0.5f + visibleRect.origin.x, visibleRect.origin.y + contentSize.height * 0.5f)];
    }
    [_cardView setCard:nil];
    CGAffineTransform viewSpaceTransform = CGAffineTransformInvert([_cardView NSE_affineTransformToView:nil]);
    CGAffineTransform sourceViewTransform = CGAffineTransformConcat(sourceTransform, viewSpaceTransform);
    CGAffineTransform destinationViewTransform = CGAffineTransformConcat(destinationTransform, viewSpaceTransform);
    CGRect destinationViewRect = CGRectApplyAffineTransform(CGRectMake(CGPointZero.x, CGPointZero.y, destinationSize.width, destinationSize.height), destinationViewTransform);
    CGRect sourceViewRect = CGRectApplyAffineTransform(CGRectMake(CGPointZero.x, CGPointZero.y, sourceSize.width, sourceSize.height), sourceViewTransform);
    if ([self isFullScreen])
        destinationViewRect.origin = CGPointZero;
    [_transitionView setFrame:NSIntegralRect(NSUnionRect(NSRectFromCGRect(destinationViewRect), NSRectFromCGRect(sourceViewRect)))];
    _wasOpenGLSurfaceEnabled = [_cardView isOpenGLSurfaceEnabled] ? 1 : 0;
    [_cardView disableOpenGLSurfaceDetachingImmediately:NO];
    [_cardView setNeedsDisplay:YES];
    if ([self isFullScreen]) {
        NSRect frame = [_transitionView frame];
        NSRect superFrame = [[_cardView superview] frame];
        frame.origin.x = ((superFrame.size.width * 0.5f + superFrame.origin.x) - (frame.size.width * 0.5f + frame.origin.x)) + frame.origin.x;
        frame.origin.y = ((superFrame.size.height * 0.5f + superFrame.origin.y) - (frame.size.height * 0.5f + frame.origin.y)) + frame.origin.y;
        [_cardView setFrame:NSIntersectionRect(frame, superFrame)];
    }
    [_cardView addSubview:_transitionView];
    [[_cardView window] makeFirstResponder:_transitionView];
}

// When a card transitions to itself, temporary objects and hidden movies
// are left out of its new image.
- (id)HSPlayerView_transitionDestinationCardRenderer
{
    NSDictionary *options = nil;
    if (_transitionSourceCard == _transitionDestinationCard) {
        NSMutableSet *ignored = [NSMutableSet set];
        if (ignored == nil)
            return nil;
        NSEnumerator *enumerator = [_transitionDestinationCard hyperEnumerator];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            if ([object isTemporary] || ([object implementsHyperInterface:@protocol(HSMovieObjectAttributes)] && [[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isHidden]))
                [ignored addObject:object];
        }
        options = [NSDictionary dictionaryWithObject:ignored forKey:@"HSIgnoredSubobjectsVisualizationOption"];
        if (options == nil)
            return nil;
    }
    id renderer = [[_transitionDestinationCard queryHyperInterface:[[_cardView class] visualizationProtocol]] queryRendererWithVisualizationOptions:options];
    if (renderer != nil)
        _isTransitionDestinationCardRendererValid = 1;
    return renderer;
}

- (id)HSPlayerView_transitionView
{
    if (_transitionView == nil) {
        _transitionView = [[HSPlayerView_HSTransitionView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 32.0, 32.0)];
        [_transitionView enableOpenGLSurface];
        [_transitionView setDelegate:self];
        [_transitionView setDataSource:self];
    }
    return _transitionView;
}

- (id)HSPlayerView_graphicCompositionView
{
    if (_graphicCompositionView == nil) {
        _graphicCompositionView = [[HSPlayerView_HSGraphicCompositionView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 32.0, 32.0)];
        [_graphicCompositionView enableOpenGLSurface];
        [_graphicCompositionView setDelegate:self];
    }
    return _graphicCompositionView;
}

// A fluid swipe drives the transition itself: the first change with a
// forward amount starts the transition to the next card, and the ending
// phase navigates when no transition took over.
- (void)handleFluidSwipe:(id)aSwipe
{
    if ([aSwipe phase] == NSEventPhaseBegan) {
        if ([self isTransitionPlaying])
            [self stopTransition];
        if (![[self document] isInPurePlayerMode] && ![[self document] isInPresentationMode])
            return;
        if (!([aSwipe gestureAmount] < 0))
            return;
        [_handledSwipe release];
        _handledSwipe = [aSwipe retain];
        [[self HSPlayerView_transitionView] setTransitionPlaybackController:self];
        [[self document] advanceToNextCardWithoutLeaveActions:self];
    } else if ([aSwipe phase] == NSEventPhaseEnded) {
        if ([_transitionView transitionPlaybackController] == self)
            return;
        if ([aSwipe gestureAmount] < 0)
            [[self document] goToNextCardWithoutLeaveActions:self];
        else if ([aSwipe gestureAmount] > 0)
            [[self document] goToPreviousCardWithoutLeaveActions:self];
    }
}

- (BOOL)canceledWithSwipe
{
    if ([_transitionView transitionPlaybackController] != self)
        return NO;
    return [_handledSwipe isCanceled] || 0.0f < [_handledSwipe gestureAmount];
}

- (BOOL)isComplete
{
    return [_handledSwipe isComplete];
}

- (double)transitionAmount
{
    if ([_handledSwipe gestureAmount] > 0.0f)
        return 0.0;
    return fabsf([_handledSwipe gestureAmount]);
}

- (void)pauseTransition
{
    [_transitionView pause];
}

- (void)resumeTransition
{
    [_transitionView resume];
}

- (void)viewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform
{
    [_graphicCompositionView setFrame:(_cardView != nil ? [_cardView cardViewingRect] : NSZeroRect)];
}

@end

@implementation HSPlayerView_HSGraphicCompositionView

// Any key stops the composition.
- (void)keyDown:(id)aDown
{
    if ([self isRendering])
        [self stopRendering];
    else
        [super keyDown:aDown];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end

@implementation HSPlayerView_HSTransitionView

- (void)mouseDown:(id)aDown
{
    if (![[self delegate] handleMouseDownEvent:aDown])
        [super mouseDown:aDown];
}

// Escape interrupts the presentation.
- (void)keyDown:(id)aDown
{
    unsigned short keyCode = [(NSEvent *)aDown keyCode];
    id delegate = [self delegate];
    if (keyCode == 0x35)
        [delegate presentationWillInterrupt];
    else if (![delegate handleKeyDownEvent:aDown])
        [super keyDown:aDown];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end

@implementation HSPlayerView (SimpleSlideShow)

// After each slide the next one (or the return to the original card) is
// scheduled, immediately when the duration is ignored.
- (void)performNavigationDidFinishForceNextSlide:(BOOL)aSlide
{
    if (!_liveSlideshow || _paused)
        return;
    id document = [self document];
    if (![self isSlideshow])
        return;
    NSUInteger index = [[document currentCard] hyperIndex];
    if ([[self slideshowAttributes] stopsAfterEnd] && index + 1 >= [document numberOfSlideshowItems]) {
        if ([[self slideshowAttributes] returnsToOriginalCard]) {
            NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
            double delay = _delayedByAction ? 0.0 : [[self slideshowAttributes] durationBetweenSlides];
            [self performSelector:@selector(returnToOriginalSlide) withObject:nil afterDelay:delay inModes:modes];
        } else
            [self interruptSlideshow];
    } else if (aSlide || [[self slideshowAttributes] startsNextSlideAutomatically]) {
        NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
        double delay = _delayedByAction ? 0.0 : [[self slideshowAttributes] durationBetweenSlides];
        [self performSelector:@selector(HSPlayerView_goToNextSlide) withObject:nil afterDelay:delay inModes:modes];
    }
    if ([self isSlideshow])
        [self slideshowDidChangeCurrentIndex:index];
}

- (void)performNavigationDidFinish
{
    [self performNavigationDidFinishForceNextSlide:NO];
}

// Running actions are stopped first; the slide waits for any that keep
// running.
- (BOOL)HSPlayerView_goToNextSlide
{
    _delayedByAction = 0;
    if (![self isSlideshow])
        return NO;
    id document = [self document];
    id navigationController = [document navigationController];
    id manager = [[document queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
    id currentOperation = [navigationController currentNavigationOperation];
    BOOL running = NO;
    if ([manager areAnyActionsRunning]) {
        [manager stopAllActionQueues];
        running = [manager areAnyActionsRunning];
    }
    if (running) {
        _delayedByAction = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionExecutionManagerDidBecomeIdle:) name:@"HSActionExecutionManagerDidBecomeIdleNotification" object:manager];
        return NO;
    }
    if (currentOperation != nil)
        return NO;
    NSUInteger index = [[document currentCard] hyperIndex];
    NSUInteger destinationIndex;
    if (index + 1 < [document numberOfSlideshowItems])
        destinationIndex = index + 1;
    else {
        if ([[self slideshowAttributes] stopsAfterEnd] && !_needOnceJumpToBegin)
            return NO;
        _needOnceJumpToBegin = 0;
        destinationIndex = 0;
    }
    HSNavigationOperation *operation = [[HSNavigationOperation alloc] initWithDestinationStackURL:nil destinationCardIndex:destinationIndex transition:[[self slideshowAttributes] transition]];
    [operation setSourceCard:[document currentCard]];
    [operation setIgnoresSlideshow:YES];
    [operation setSourceCardUserSpaceToViewSpaceTransform:[_cardView userSpaceToViewSpaceCGAffineTransform]];
    [operation setSourceCardViewTransform:[_cardView NSE_affineTransformToView:nil]];
    [navigationController startNavigationOperation:operation];
    [operation release];
    return YES;
}

- (void)ignoreDurationBetweenSlides
{
    _delayedByAction = 1;
}

// Ends the slideshow and goes back to the card it started on.
- (void)returnToOriginalSlide
{
    _delayedByAction = 0;
    id document = [self document];
    id navigationController = [document navigationController];
    id manager = [[document queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
    id currentOperation = [navigationController currentNavigationOperation];
    BOOL running = NO;
    if ([manager areAnyActionsRunning]) {
        [manager stopAllActionQueues];
        running = [manager areAnyActionsRunning];
    }
    if (running) {
        _delayedByAction = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionExecutionManagerDidBecomeIdle:) name:@"HSActionExecutionManagerDidBecomeIdleNotification" object:manager];
        return;
    }
    if (currentOperation != nil)
        return;
    id transition = [[[[self slideshowAttributes] transition] retain] autorelease];
    [self interruptSlideshow];
    HSNavigationOperation *operation = [[HSNavigationOperation alloc] initWithDestinationStackURL:[document fileURL] destinationCardIndex:[[self originalCard] hyperIndex] transition:transition];
    [operation setIgnoresSlideshow:YES];
    [navigationController startNavigationOperation:operation];
    [operation release];
}

- (void)navigationOperationDidFinish:(id)aFinish
{
    [self setNavigationOperation:nil];
    [self performNavigationDidFinish];
}

- (void)actionExecutionManagerDidBecomeIdle:(id)aIdle
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionExecutionManagerDidBecomeIdleNotification" object:[aIdle object]];
    [self performNavigationDidFinish];
}

- (void)HSPlayerView_defaultSlideshowAttributesDidChange:(id)aChange
{
    _slideShowAttributesChanged = 1;
}

@end

@implementation HSPlayerView (HSPlayerViewIKSlideshowDataSource)

// The card view's frame in full screen, else the card's rect in the view.
- (NSRect)slideshowFrame
{
    if ([self isFullScreen])
        return [[self cardView] frame];
    NSSize size = [[self stack] hyperCardSize];
    return [[self cardView] viewBoundingRectForUserRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height)];
}

- (NSUInteger)slideshowAutoresizingMask
{
    return [_cardView autoresizingMask];
}

- (NSUInteger)slideshowViewAllowsAddSubview
{
    if (_liveSlideshow)
        return 0;
    if (_isBorderless)
        return ![[self window] hasShadow];
    return 1;
}

- (id)slideshowView
{
    if (_liveSlideshow)
        return nil;
    return _slideshowContentView != nil ? _slideshowContentView : _slideshowScrollView;
}

- (void)slideshowDidChangeCurrentIndex:(NSUInteger)aIndex
{
    [[self document] slideshowDidChangeCurrentIndex:aIndex];
}

- (void)slideshowDidStop
{
    [self setIsSlideshow:NO];
    [self unmountSlideshow];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSPlayerViewSlideshowDidStopNotification object:self];
    [[self document] slideshowDidStop];
}

- (void)slideshowWillStart
{
    [[self document] slideshowWillStart];
    [self setIsSlideshow:YES];
    [self stopTransition];
    [self mountSlideshow];
}

// The card view comes back in place of the slideshow's transition view, on
// the slideshow's current card.
- (void)unmountSlideshow
{
    if (_slideshowScrollView != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:[[self presentationView] window]];
        [[[self slideshow] transitionView] removeFromSuperview];
    } else if (_slideshowContentView != nil) {
        NSView *transitionView = [self presentationView];
        [transitionView retain];
        [transitionView removeFromSuperview];
        [_slideshowContentView addSubview:_cardView];
        [_cardView setAutoresizingMask:_cardViewAutoresizingMask];
        // The original kept both views' extra retains; this balances them.
        [_cardView release];
        [transitionView release];
    }
    _slideshowContentView = nil;
    _slideshowScrollView = nil;
    [self setPresentationView:_cardView];
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0) {
        [[[self slideshow] transitionView] stopCapturingForConsumer:self];
        [_cardView startCapturingForConsumer:self];
        [self removeSlideshowBackgroundPixelBuffer];
    }
    if ([[self slideshow] dataSource] == self)
        [self setActiveCard:[_stack hyperChildAtIndex:[[self slideshow] indexOfCurrentSlideshowItem]]];
    [[self window] makeFirstResponder:[self cardView]];
    [[self window] display];
}

// The slideshow's transition view goes over a scroll view's content, or
// replaces the card view.
- (void)mountSlideshow
{
    _cardViewAutoresizingMask = (unsigned int)[(NSView *)[self presentationView] autoresizingMask];
    NSScrollView *scrollView = [[self presentationView] enclosingScrollView];
    NSView *superview = [[self presentationView] superview];
    NSView *transitionView = [[self slideshow] transitionView];
    if ([scrollView contentView] == superview) {
        _slideshowScrollView = scrollView;
        _slideshowContentView = superview;
        [superview addSubview:transitionView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSlideshowSize:) name:NSWindowDidResizeNotification object:[[self presentationView] window]];
    } else {
        // Released when unmounting.
        [[self presentationView] retain];
        [[self presentationView] removeFromSuperview];
        _slideshowScrollView = nil;
        _slideshowContentView = superview;
        [superview addSubview:transitionView];
        [transitionView setAutoresizingMask:_cardViewAutoresizingMask];
    }
    [self setPresentationView:transitionView];
}

- (void)adjustSlideshowSize:(id)aSize
{
    [[[self slideshow] transitionView] setFrame:[self slideshowFrame]];
}

- (BOOL)canExportSlideshowItemAtIndex:(NSUInteger)aIndex toApplication:(id)aApplication
{
    return [[self document] canExportSlideshowItemAtIndex:aIndex toApplication:aApplication];
}

- (id)nameOfSlideshowItemAtIndex:(NSUInteger)aIndex
{
    return [[self document] nameOfSlideshowItemAtIndex:aIndex];
}

- (id)slideshowItemAtIndex:(NSUInteger)aIndex
{
    return [[self document] slideshowItemAtIndex:aIndex];
}

- (NSUInteger)numberOfSlideshowItems
{
    return [[self document] numberOfSlideshowItems];
}

@end
