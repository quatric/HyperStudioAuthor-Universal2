#import "HSGenericVideoStreamRenderLayer.h"
// Draws a live video stream's current frame: with OpenGL enabled, the native
// OpenGL frame (a pixel buffer bound as a rectangle texture) straight into
// the destination OpenGL context when the drawing is pixel-aligned, else
// through an offscreen OpenGL layer; otherwise (or when that fails) the
// Quartz frame image.
@implementation HSGenericVideoStreamRenderLayer
- (id)validationAttributesForBitmapRenderCache
{
    HSMutableMultipleObjectsAttributeSet *set = [[HSMutableMultipleObjectsAttributeSet alloc] init];
    [set addAttribute:@protocol(HSVideoFrameAttribute) forObject:[self hyperObject]];
    id result = [[set copy] autorelease];
    [set release];
    return result;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (_isOpenGLEnabled) {
        id frame = [[_videoStreamAttributes videoFrameForVideoFrameProcessorClass:[HSNativeOpenGLVideoFrameProcessor class]]
            frameRepresentation];
        if (frame != nil
            && [self drawOpenGLTextureBuffer:(CVBufferRef)frame
                                      toRect:[_videoStreamAttributes videoRect]
                              withClipRegion:aRegion
                                    delegate:aDelegate])
            return;
    }
    CGImageRef image = (CGImageRef)[[_videoStreamAttributes
        videoFrameForVideoFrameProcessorClass:[HSQuartzVideoFrameProcessor class]] frameRepresentation];
    if (image == NULL)
        return;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return;
    CGImageRef copy = CGImageCreateCopyWithColorSpace(image, colorSpace);
    CGColorSpaceRelease(colorSpace);
    if (copy == NULL)
        return;
    [self drawQuartzFrameImage:copy toRect:[_videoStreamAttributes videoRect] withClipRegion:aRegion delegate:aDelegate];
    CGImageRelease(copy);
}
// Flipped vertically within the rect.
- (BOOL)drawQuartzFrameImage:(struct CGImage *)aImage toRect:(NSRect)aRect withClipRegion:(id)aRegion delegate:(id)aDelegate
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0,
                                                      (float)(aRect.size.height + aRect.origin.y + aRect.origin.y)));
    CGContextDrawImage(context, NSRectToCGRect(aRect), aImage);
    return YES;
}
// Direct drawing needs a multisampled destination, or a CTM that is a
// multiple of 90° with no shear and puts the rect's corners on device
// pixels (within 1/512).
static BOOL HSIsNearMultiple(float value, float step, float tolerance)
{
    float remainder = remainderf(value, step);
    return remainder >= -tolerance && remainder <= tolerance;
}
- (BOOL)drawOpenGLTextureBuffer:(struct __CVBuffer *)aBuffer toRect:(NSRect)aRect withClipRegion:(id)aRegion delegate:(id)aDelegate
{
    CGContextRef cgContext = [[NSGraphicsContext currentContext] CGContext];
    float opacity = 1.0f;
    CFNumberRef alpha = CGEContextGetAttachmentForKey(cgContext, (CFStringRef)kCGEContextAlphaAttachmentKey);
    if (alpha != NULL)
        CFNumberGetValue(alpha, kCFNumberFloatType, &opacity);

    id destination = (id)CGEContextGetDestination(cgContext, (CFStringRef)NSEOpenGLCGContextDestination);
    id destinationContext = [destination destinationOpenGLContext];
    if (destinationContext != nil) {
        GLint sampleBuffers = 0;
        [(NSOpenGLPixelFormat *)[(NSEOpenGLContext *)destinationContext format] getValues:&sampleBuffers
                                  forAttribute:NSOpenGLPFASampleBuffers
                              forVirtualScreen:[destinationContext currentVirtualScreen]];
        BOOL direct = YES;
        if (sampleBuffers == 0) {
            CGAffineTransform m = CGContextGetCTM(cgContext);
            float a = m.a, b = m.b, c = m.c, d = m.d;
            float x = aRect.origin.x, y = aRect.origin.y, w = aRect.size.width, h = aRect.size.height;
            float deviceX = c * y + a * x + (float)m.tx;
            float deviceY = d * y + b * x + (float)m.ty;
            float rotation;
            if (a == 0 && b == 0)
                rotation = (float)(atan2f(d, c) - M_PI_2);
            else
                rotation = atan2f(b, a);
            if (rotation < 0)
                rotation = (float)(rotation + 2 * M_PI);
            double shear = atan2(a * c + b * d, a * d - b * c);
            if (shear < -M_PI_2)
                shear += M_PI;
            else if (shear > M_PI_2)
                shear -= M_PI;
            float shearNear = nextafterf((float)shear, 0);
            direct = HSIsNearMultiple(rotation, (float)M_PI_2, 5e-05f)
                && shearNear >= -5e-05f && shearNear <= 5e-05f
                && HSIsNearMultiple(deviceX, 1, 1.0f / 512)
                && HSIsNearMultiple(deviceY, 1, 1.0f / 512)
                && HSIsNearMultiple(c * h + a * w + deviceX, 1, 1.0f / 512)
                && HSIsNearMultiple(d * h + b * w + deviceY, 1, 1.0f / 512);
        }
        if (direct) {
            id context = [destination flushCGContext];
            if (context != nil
                && [context bindTextureForPixelBuffer:aBuffer
                                               target:GL_TEXTURE_RECTANGLE_EXT
                                               border:0
                                   specifyingIfNeeded:YES
                                          withOptions:4] != nil) {
                [self HSGenericVideoStreamRenderLayer_drawBindedOpenGLTextureForPixelBuffer:aBuffer
                                                                                withOpacity:opacity
                                                                                     inRect:aRect];
                return YES;
            }
        }
    }

    if (_offscreenOpenGLDrawable == nil) {
        // Multisampled (6 samples) if possible, else plain; both accelerated.
        unsigned int attributes[] = {
            NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFASampleBuffers, 1, NSOpenGLPFASamples, 6, 0,
            NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, 0,
            0
        };
        id context = [NSEOpenGLContext contextWithFormatAttributesSequence:attributes
                                                             shareCategory:NSEDefaultOpenGLContextShareCategory];
        if (context == nil)
            return NO;
        _offscreenOpenGLDrawable = [[NSEPixelBufferOpenGLDrawable alloc] initWithOpenGLContext:context];
        if (_offscreenOpenGLDrawable == nil)
            return NO;
    }
    if (![_offscreenOpenGLDrawable beginOpenGLLayerForCGContext:cgContext rect:NSRectToCGRect(aRect) opacity:opacity])
        return NO;
    if (!_isOpenGLPrepared) {
        glClearColor(0, 0, 0, 0);
        _isOpenGLPrepared = 1;
    }
    glClear(GL_COLOR_BUFFER_BIT);
    id texture = [[_offscreenOpenGLDrawable openGLContext] bindTextureForPixelBuffer:aBuffer
                                                                              target:GL_TEXTURE_RECTANGLE_EXT
                                                                              border:0
                                                                  specifyingIfNeeded:YES
                                                                         withOptions:4];
    if (texture != nil)
        [self HSGenericVideoStreamRenderLayer_drawBindedOpenGLTextureForPixelBuffer:aBuffer
                                                                        withOpacity:opacity
                                                                             inRect:aRect];
    [_offscreenOpenGLDrawable endOpenGLLayerForCGContext];
    return texture != nil;
}
// The bound rectangle texture as a quad. Blends (premultiplied when the
// buffer's alpha info is 1) unless the buffer is opaque (alpha info −1) and
// fully visible; GL state is restored afterwards.
- (void)HSGenericVideoStreamRenderLayer_drawBindedOpenGLTextureForPixelBuffer:(struct __CVBuffer *)aBuffer withOpacity:(CGFloat)aOpacity inRect:(NSRect)aRect
{
    int alphaInfo = [(id)CVBufferGetAttachment(aBuffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL) intValue];
    size_t width = CVPixelBufferGetWidth(aBuffer);
    size_t height = CVPixelBufferGetHeight(aBuffer);
    GLboolean textureEnabled = glIsEnabled(GL_TEXTURE_RECTANGLE_EXT);
    if (!textureEnabled)
        glEnable(GL_TEXTURE_RECTANGLE_EXT);
    BOOL blends = alphaInfo != -1 || aOpacity < 0.9980469f;
    GLboolean blendEnabled;
    GLint equationRGB = 0, equationAlpha = 0, sourceRGB = 0, destinationRGB = 0, sourceAlpha = 0, destinationAlpha = 0;
    GLenum source = alphaInfo == 1 ? GL_ONE : GL_SRC_ALPHA;
    if (!blends) {
        blendEnabled = glIsEnabled(GL_BLEND);
        if (blendEnabled)
            glDisable(GL_BLEND);
    } else {
        blendEnabled = glIsEnabled(GL_BLEND);
        glGetIntegerv(GL_BLEND_EQUATION_RGB, &equationRGB);
        glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &equationAlpha);
        glGetIntegerv(GL_BLEND_SRC_RGB, &sourceRGB);
        glGetIntegerv(GL_BLEND_DST_RGB, &destinationRGB);
        glGetIntegerv(GL_BLEND_SRC_ALPHA, &sourceAlpha);
        glGetIntegerv(GL_BLEND_DST_ALPHA, &destinationAlpha);
        if (equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD)
            glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
        if ((GLenum)sourceRGB != source || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE
            || destinationAlpha != GL_ONE_MINUS_SRC_ALPHA)
            glBlendFuncSeparate(source, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        if (!blendEnabled)
            glEnable(GL_BLEND);
    }
    float x = aRect.origin.x, y = aRect.origin.y;
    float maxX = aRect.size.width + x, maxY = aRect.size.height + y;
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex2f(x, y);
    glTexCoord2f(0, (float)height);
    glVertex2f(x, maxY);
    glTexCoord2f((float)width, (float)height);
    glVertex2f(maxX, maxY);
    glTexCoord2f((float)width, 0);
    glVertex2f(maxX, y);
    glEnd();
    if (!textureEnabled)
        glDisable(GL_TEXTURE_RECTANGLE_EXT);
    if (!blends) {
        if (blendEnabled)
            glEnable(GL_BLEND);
    } else {
        if (!blendEnabled)
            glDisable(GL_BLEND);
        if (equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD)
            glBlendEquationSeparate(equationRGB, equationAlpha);
        if ((GLenum)sourceRGB != source || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE
            || destinationAlpha != GL_ONE_MINUS_SRC_ALPHA)
            glBlendFuncSeparate(sourceRGB, destinationRGB, sourceAlpha, destinationAlpha);
    }
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_videoStreamAttributes videoRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSVideoRectAttribute) forObject:[self hyperObject]];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSVideoRectAttribute) forObject:[self hyperObject]];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSVideoRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVideoFrameAttribute) forObject:object];
}
- (BOOL)isEmpty
{
    return [_videoStreamAttributes videoFrameForVideoFrameProcessorClass:[HSQuartzVideoFrameProcessor class]] == nil;
}
- (id)videoStreamAttributes
{
    return _videoStreamAttributes;
}
- (void)dealloc
{
    [_offscreenOpenGLDrawable release];
    if (_isOpenGLEnabled)
        [_videoStreamAttributes removeVideoFrameProcessorClass:[HSNativeOpenGLVideoFrameProcessor class]];
    [_videoStreamAttributes removeVideoFrameProcessorClass:[HSQuartzVideoFrameProcessor class]];
    [_videoStreamAttributes release];
    [super dealloc];
}
// Needs the video stream interface; asks it for Quartz frames, and for
// native OpenGL frames when OpenGL is enabled.
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _videoStreamAttributes = [[aObject queryHyperInterface:@protocol(HSVideoStreamAttributes)] retain];
    if (_videoStreamAttributes == nil) {
        [self release];
        return nil;
    }
    _isOpenGLEnabled = [[HSSystem sharedSystem] isOpenGLEnabled] ? 1 : 0;
    if (_isOpenGLEnabled)
        [_videoStreamAttributes addVideoFrameProcessorClass:[HSNativeOpenGLVideoFrameProcessor class]];
    [_videoStreamAttributes addVideoFrameProcessorClass:[HSQuartzVideoFrameProcessor class]];
    return self;
}
@end
