#import "HSCaptureView.h"
#import "HSCaptureDeviceSession.h"
#import "HSNativeOpenGLVideoPreviewFrameProcessor.h"
#import "HSVideoCaptureDevicePlaceholderRenderer.h"
#import "NSEOpenGLContext.h"
#import "QTCaptureDevice+QTECaptureDevice.h"
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>

// Shows the video of a capture device session in its OpenGL surface, frames
// coming from the session's native OpenGL frame processor and drawn by a
// display link of the view's display. Without a usable video device the
// Quartz surface shows the device's placeholder. The video devices are
// watched for going in use elsewhere, being suspended or disconnected.
//
// The bit fields: _isPreviewing, _isActive (the session is active for the
// view), _isDisplayLinkUpdateScheduled and _isNewFrameCaptured.

static BOOL HSCaptureViewIsVideoDevice(QTCaptureDevice *aDevice)
{
    return [aDevice hasMediaType:QTMediaTypeVideo] || [aDevice hasMediaType:QTMediaTypeMuxed];
}

static void HSCaptureViewFindVideoDevice(const void *aDevice, void *aResult)
{
    if (*(id *)aResult == nil && HSCaptureViewIsVideoDevice((QTCaptureDevice *)aDevice))
        *(id *)aResult = (id)aDevice;
}

static void HSCaptureViewFindActiveVideoDevice(const void *aDevice, void *aResult)
{
    QTCaptureDevice *device = (QTCaptureDevice *)aDevice;
    if (*(id *)aResult == nil && HSCaptureViewIsVideoDevice(device) && [device isConnected] && ![device QTE_isInUseByAnotherApplication]
        && ![[device attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue])
        *(id *)aResult = device;
}

static void HSCaptureViewStartObservingDevice(const void *aDevice, void *aView)
{
    QTCaptureDevice *device = (QTCaptureDevice *)aDevice;
    if (!HSCaptureViewIsVideoDevice(device))
        return;
    [device addObserver:(id)aView forKeyPath:@"inUseByAnotherApplication" options:0 context:NULL];
    [device addObserver:(id)aView forKeyPath:@"suspended" options:0 context:NULL];
    [device addObserver:(id)aView forKeyPath:@"connected" options:0 context:NULL];
}

static void HSCaptureViewStopObservingDevice(const void *aDevice, void *aView)
{
    QTCaptureDevice *device = (QTCaptureDevice *)aDevice;
    if (!HSCaptureViewIsVideoDevice(device))
        return;
    [device removeObserver:(id)aView forKeyPath:@"inUseByAnotherApplication"];
    [device removeObserver:(id)aView forKeyPath:@"suspended"];
    [device removeObserver:(id)aView forKeyPath:@"connected"];
}

static CVReturn HSCaptureViewDisplayLinkOutput(CVDisplayLinkRef aDisplayLink, const CVTimeStamp *aNow, const CVTimeStamp *aOutputTime,
                                               CVOptionFlags aFlagsIn, CVOptionFlags *aFlagsOut, void *aView)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(HSCaptureView *)aView HSCaptureView_displayFrame];
    [pool release];
    return kCVReturnSuccess;
}

@implementation HSCaptureView

// Synchronized to the display.
+ (id)createDefaultOpenGLContext
{
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, 0,
        NSOpenGLPFAWindow, 0, 0
    };
    NSEOpenGLContext *context = [[NSEOpenGLContext contextWithFormatAttributesSequence:(unsigned int *)attributes
                                                                         shareCategory:NSEDefaultOpenGLContextShareCategory] retain];
    if (context != nil) {
        GLint swapInterval = 1;
        [context setValues:&swapInterval forParameter:NSOpenGLContextParameterSwapInterval];
    }
    return context;
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if (_isActive) {
        if ([self window] == nil) {
            if (aWindow != nil)
                CVDisplayLinkStart(_displayLink);
        } else if (aWindow == nil) {
            if (CVDisplayLinkIsRunning(_displayLink))
                CVDisplayLinkStop(_displayLink);
        } else {
            [self HSCaptureView_updateDisplayLink];
        }
    }
    [super viewWillMoveToWindow:aWindow];
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (![aPath isEqualToString:@"inUseByAnotherApplication"] && ![aPath isEqualToString:@"suspended"] && ![aPath isEqualToString:@"connected"])
        return;
    [self performSelectorOnMainThread:@selector(HSCaptureView_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
}

- (void)HSCaptureView_captureDeviceDidChangeState:(id)aState
{
    if (![[_captureDeviceSession captureDeviceSet] containsObject:aState])
        return;
    if (![self HSCaptureView_hasActiveVideoDevice]) {
        if (_isActive) {
            [self HSCaptureView_deactivateCaptureDeviceSession];
            if (CVDisplayLinkIsRunning(_displayLink))
                CVDisplayLinkStop(_displayLink);
        }
        [self HSCaptureView_invalidateCurrentFrame];
    } else if (_isPreviewing && !_isActive && [self HSCaptureView_activateCaptureDeviceSession]) {
        [self HSCaptureView_startDisplayLink];
    }
    [self setNeedsDisplay:YES];
}

- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
    if (_placeholderRenderer == nil) {
        id device = nil;
        NSSet *devices = [_captureDeviceSession captureDeviceSet];
        if (devices != nil)
            CFSetApplyFunction((CFSetRef)devices, HSCaptureViewFindVideoDevice, &device);
        _placeholderRenderer = [[HSVideoCaptureDevicePlaceholderRenderer placeholderRendererForVideoCaptureDevice:device] retain];
        if (_placeholderRenderer == nil)
            return;
    }
    [_placeholderRenderer drawRect:aRect withBounds:[self bounds]];
}

// The current frame fitted to the bounds, blended by its alpha (premultiplied
// or not) or drawn opaque.
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect
{
    [_currentFrameLock lock];
    _isNewFrameCaptured = 0;
    CVPixelBufferRef frame = CVPixelBufferRetain((CVPixelBufferRef)[_currentFrame frameRepresentation]);
    [_currentFrameLock unlock];
    if (frame == NULL)
        return NO;
    [_currentFrameTexture release];
    _currentFrameTexture = [[[self openGLContext] bindTextureForPixelBuffer:frame target:GL_TEXTURE_RECTANGLE_EXT border:0
                                                         specifyingIfNeeded:YES withOptions:4] retain];
    if (_currentFrameTexture == nil) {
        CVPixelBufferRelease(frame);
        return NO;
    }
    int alphaInfo = [(NSNumber *)CVBufferGetAttachment(frame, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL) intValue];
    size_t frameWidth = CVPixelBufferGetWidth(frame);
    size_t frameHeight = CVPixelBufferGetHeight(frame);
    CVPixelBufferRelease(frame);

    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    BOOL wasTextureEnabled = glIsEnabled(GL_TEXTURE_RECTANGLE_EXT);
    if (!wasTextureEnabled)
        glEnable(GL_TEXTURE_RECTANGLE_EXT);
    BOOL blends = alphaInfo != -1;
    GLboolean wasBlendEnabled;
    GLint sourceFactor = 0, equationRGB = 0, equationAlpha = 0, sourceRGB = 0, destinationRGB = 0, sourceAlpha = 0, destinationAlpha = 0;
    if (!blends) {
        wasBlendEnabled = glIsEnabled(GL_BLEND);
        if (wasBlendEnabled)
            glDisable(GL_BLEND);
    } else {
        sourceFactor = alphaInfo == 1 ? GL_ONE : GL_SRC_ALPHA;
        wasBlendEnabled = glIsEnabled(GL_BLEND);
        glGetIntegerv(GL_BLEND_EQUATION_RGB, &equationRGB);
        glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &equationAlpha);
        glGetIntegerv(GL_BLEND_SRC_RGB, &sourceRGB);
        glGetIntegerv(GL_BLEND_DST_RGB, &destinationRGB);
        glGetIntegerv(GL_BLEND_SRC_ALPHA, &sourceAlpha);
        glGetIntegerv(GL_BLEND_DST_ALPHA, &destinationAlpha);
        if (equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD)
            glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
        if (sourceFactor != sourceRGB || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE || destinationAlpha != GL_ONE_MINUS_SRC_ALPHA)
            glBlendFuncSeparate(sourceFactor, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        if (!wasBlendEnabled)
            glEnable(GL_BLEND);
    }

    glBegin(GL_QUADS);
    float width = frameWidth, height = frameHeight;
    NSRect bounds = [self bounds];
    float aspect = width / height;
    float left = bounds.origin.x, bottom = bounds.origin.y, right, top;
    float fittedWidth = bounds.size.height * aspect;
    if (bounds.size.width < fittedWidth) {
        float fittedHeight = bounds.size.width / aspect;
        bottom = bounds.origin.y + (bounds.size.height - fittedHeight) * 0.5f;
        top = fittedHeight + bottom;
        right = bounds.size.width + bounds.origin.x;
    } else {
        top = bounds.size.height + bounds.origin.y;
        left = bounds.origin.x + (bounds.size.width - fittedWidth) * 0.5f;
        right = fittedWidth + left;
    }
    glTexCoord2f(0, 0);
    glVertex2f(left, top);
    glTexCoord2f(0, height);
    glVertex2f(left, bottom);
    glTexCoord2f(width, height);
    glVertex2f(right, bottom);
    glTexCoord2f(width, 0);
    glVertex2f(right, top);
    glEnd();

    if (!wasTextureEnabled)
        glDisable(GL_TEXTURE_RECTANGLE_EXT);
    if (!blends) {
        if (wasBlendEnabled)
            glEnable(GL_BLEND);
    } else {
        if (!wasBlendEnabled)
            glDisable(GL_BLEND);
        if (equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD)
            glBlendEquationSeparate(equationRGB, equationAlpha);
        if (sourceRGB != sourceFactor || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE || destinationAlpha != GL_ONE_MINUS_SRC_ALPHA)
            glBlendFuncSeparate(sourceRGB, destinationRGB, sourceAlpha, destinationAlpha);
    }
    return YES;
}

- (BOOL)shouldDisplayOpenGLSurface
{
    return _currentFrame != nil;
}

- (BOOL)isOpenGLSurfaceOpaque
{
    return YES;
}

// From the display link's thread.
- (void)HSCaptureView_displayFrame
{
    if (_isNewFrameCaptured)
        [self displayOpenGLSurface];
}

- (void)updateOpenGLContext
{
    [super updateOpenGLContext];
    if (!_isDisplayLinkUpdateScheduled) {
        _isDisplayLinkUpdateScheduled = 1;
        [self performSelectorOnMainThread:@selector(HSCaptureView_updateDisplayLink) withObject:nil waitUntilDone:NO];
    }
}

- (void)disassociateOpenGLContext
{
    [_currentFrameTexture release];
    _currentFrameTexture = nil;
    [super disassociateOpenGLContext];
}

- (BOOL)associateOpenGLContext
{
    if (![super associateOpenGLContext])
        return NO;
    if (!_isDisplayLinkUpdateScheduled) {
        _isDisplayLinkUpdateScheduled = 1;
        [self performSelectorOnMainThread:@selector(HSCaptureView_updateDisplayLink) withObject:nil waitUntilDone:NO];
    }
    return YES;
}

- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    [aFrame retain];
    [_currentFrameLock lock];
    _isNewFrameCaptured = 1;
    id previous = _currentFrame;
    _currentFrame = aFrame;
    [_currentFrameLock unlock];
    [previous release];
}

- (void)stopPreviewing
{
    if (!_isPreviewing)
        return;
    if (_isActive) {
        [self HSCaptureView_deactivateCaptureDeviceSession];
        if (CVDisplayLinkIsRunning(_displayLink))
            CVDisplayLinkStop(_displayLink);
    }
    _isPreviewing = 0;
}

- (void)startPreviewing
{
    if (_isPreviewing)
        return;
    _isPreviewing = 1;
    if ([self HSCaptureView_hasActiveVideoDevice] && [self HSCaptureView_activateCaptureDeviceSession])
        [self HSCaptureView_startDisplayLink];
}

- (BOOL)isPreviewing
{
    return _isPreviewing;
}

// Original quirk kept: while the old session has no device set the new one
// isn't taken, and a new session with a usable video device isn't
// redisplayed (if activating it fails the display link is just stopped).
- (void)setCaptureDeviceSession:(id)aSession
{
    if (_captureDeviceSession == aSession)
        return;
    if (_captureDeviceSession != nil) {
        NSSet *devices = [_captureDeviceSession captureDeviceSet];
        if (devices == nil)
            return;
        if (_isActive)
            [self HSCaptureView_deactivateCaptureDeviceSession];
        else
            [self setNeedsDisplay:YES];
        CFSetApplyFunction((CFSetRef)devices, HSCaptureViewStopObservingDevice, self);
        [_placeholderRenderer release];
        _placeholderRenderer = nil;
        [_captureDeviceSession release];
        _captureDeviceSession = nil;
    }
    NSSet *devices = [aSession captureDeviceSet];
    if (devices == nil) {
        if (CVDisplayLinkIsRunning(_displayLink))
            CVDisplayLinkStop(_displayLink);
        [self HSCaptureView_invalidateCurrentFrame];
    } else {
        CFSetApplyFunction((CFSetRef)devices, HSCaptureViewStartObservingDevice, self);
        _captureDeviceSession = [aSession retain];
        if ([self HSCaptureView_hasActiveVideoDevice]) {
            if (!_isPreviewing)
                return;
            if ([self HSCaptureView_activateCaptureDeviceSession])
                return;
            if (CVDisplayLinkIsRunning(_displayLink))
                CVDisplayLinkStop(_displayLink);
            return;
        }
        if (CVDisplayLinkIsRunning(_displayLink))
            CVDisplayLinkStop(_displayLink);
        [self HSCaptureView_invalidateCurrentFrame];
    }
    [self setNeedsDisplay:YES];
}

- (id)captureDeviceSession
{
    return _captureDeviceSession;
}

- (BOOL)HSCaptureView_hasActiveVideoDevice
{
    NSSet *devices = [_captureDeviceSession captureDeviceSet];
    if (devices == nil)
        return NO;
    id device = nil;
    CFSetApplyFunction((CFSetRef)devices, HSCaptureViewFindActiveVideoDevice, &device);
    return device != nil;
}

- (void)HSCaptureView_invalidateCurrentFrame
{
    [_currentFrameLock lock];
    _isNewFrameCaptured = 0;
    id previous = _currentFrame;
    _currentFrame = nil;
    [_currentFrameLock unlock];
    [previous release];
}

- (void)HSCaptureView_deactivateCaptureDeviceSession
{
    [_captureDeviceSession deactivateForClient:self withFrameProcessorClass:[HSNativeOpenGLVideoFrameProcessor class]];
    _isActive = 0;
}

- (BOOL)HSCaptureView_activateCaptureDeviceSession
{
    if (_captureDeviceSession != nil) {
        if (_currentFrameLock == nil)
            _currentFrameLock = [[NSLock alloc] init];
        if (_currentFrameLock != nil) {
            [_captureDeviceSession activateForClient:self withFrameProcessorClass:[HSNativeOpenGLVideoFrameProcessor class]];
            _isActive = 1;
        }
    }
    return _isActive;
}

- (void)HSCaptureView_startDisplayLink
{
    if ([self window] == nil)
        return;
    if (_displayLink == NULL) {
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        if (_displayLink == NULL)
            return;
        CVDisplayLinkSetOutputCallback(_displayLink, HSCaptureViewDisplayLinkOutput, self);
    }
    [self HSCaptureView_updateDisplayLink];
    CVDisplayLinkStart(_displayLink);
}

// The display link follows the display of the view's OpenGL context, or of
// its window's screen.
- (void)HSCaptureView_updateDisplayLink
{
    _isDisplayLinkUpdateScheduled = 0;
    if ([self lockAssociatedOpenGLContext]) {
        NSOpenGLContext *context = [[self openGLContext] retain];
        [self unlockAssociatedOpenGLContext];
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, [context CGLContextObj], [[context pixelFormat] CGLPixelFormatObj]);
        [context release];
    } else {
        NSNumber *screenNumber = [[[[self window] screen] deviceDescription] objectForKey:@"NSScreenNumber"];
        CGDirectDisplayID display = (CGDirectDisplayID)[screenNumber unsignedIntValue];
        if (display != 0)
            CVDisplayLinkSetCurrentCGDisplay(_displayLink, display);
    }
}

// The session keeps its clients, so previewing stops when only the session
// is left holding the view.
- (void)release
{
    while ([self retainCount] <= 1) {
        [self stopPreviewing];
        if (!_isPreviewing)
            break;
    }
    [super release];
}

- (void)dealloc
{
    [_currentFrameTexture release];
    [_currentFrame release];
    if (_displayLink != NULL) {
        CVDisplayLinkSetOutputCallback(_displayLink, NULL, NULL);
        CVDisplayLinkRelease(_displayLink);
    }
    if (_captureDeviceSession != nil) {
        NSSet *devices = [_captureDeviceSession captureDeviceSet];
        if (devices != nil)
            CFSetApplyFunction((CFSetRef)devices, HSCaptureViewStopObservingDevice, self);
        [_placeholderRenderer release];
        [_captureDeviceSession release];
    }
    [_currentFrameLock release];
    [super dealloc];
}

@end
