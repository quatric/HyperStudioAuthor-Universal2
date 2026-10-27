#import "NSEOffscreenWindowOpenGLDrawable.h"
#import "NSEOpenGLContext.h"
#import <OpenGL/CGLMacro.h>

// An OpenGL context drawing into an offscreen window of a given size.

@implementation NSEOffscreenWindowOpenGLDrawable

- (id)init
{
    // Multisampled if it can be, then accelerated, then anything.
    unsigned int attributes[] = {
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFASampleBuffers, 1, NSOpenGLPFASamples, 6,
        NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8, 0,
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8, 0,
        NSOpenGLPFAWindow, NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8, 0,
        0
    };
    NSOpenGLPixelFormat *format = [NSOpenGLPixelFormat NSE_pixelFormatWithAttributesSequence:attributes];
    NSEOpenGLContext *context;
    if (format &&
        (context = [NSEOpenGLContext contextWithFormat:format shareCategory:NSEDefaultOpenGLContextShareCategory]))
        return [self initWithOpenGLContext:context];
    [self release];
    return nil;
}

- (id)initWithOpenGLContext:(id)aContext
{
    _openGLContext = [aContext retain];
    _coreGLContext = [aContext CGLContextObj];
    return self;
}

- (void)dealloc
{
    if (_window) {
        [_openGLContext clearDrawable];
        [_window release];
    }
    [_openGLContext release];
    [super dealloc];
}

- (NSUInteger)width
{
    return _width;
}

- (NSUInteger)height
{
    return _height;
}

// Statically sized windows are kept that size; others only grow.
- (void)setWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight statically:(BOOL)aStatically
{
    if (_width == aWidth && _height == aHeight && _isStaticSize == (aStatically != NO))
        return;
    _width = (unsigned int)aWidth;
    _height = (unsigned int)aHeight;
    _isStaticSize = aStatically != NO;
    _isViewportValidated = 0;
}

- (id)openGLContext
{
    return _openGLContext;
}

- (id)lockOpenGLFocus
{
    if (!_width || !_height)
        return nil;
    BOOL setViewport;
    if (!_window) {
        NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, _width, _height)
                                                       styleMask:NSWindowStyleMaskBorderless
                                                         backing:NSBackingStoreNonretained
                                                           defer:NO];
        if (window) {
            [window setReleasedWhenClosed:NO];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [window useOptimizedDrawing:YES];
#pragma clang diagnostic pop
            NSView *view = [window contentView];
            if (view) {
                [_openGLContext setView:view];
                if ([_openGLContext view] == view) {
                    _window = window;
                    window = nil;
                }
            }
        }
        [window release];
        if (!_window)
            return nil;
        setViewport = YES;
    }
    else if (_isViewportValidated)
        setViewport = NO;
    else {
        NSSize size = [[_openGLContext view] frame].size;
        float width = _width, height = _height;
        BOOL fits;
        if (!_isStaticSize)
            fits = width - 0.001953125f <= size.width && height - 0.001953125f <= size.height;
        else
            fits = width - 0.001953125f <= size.width && size.width <= width + 0.001953125f &&
                   height - 0.001953125f <= size.height && size.height <= height + 0.001953125f;
        if (!fits) {
            [_window setContentSize:NSMakeSize(_width, _height)];
            [_openGLContext update];
        }
        setViewport = YES;
    }
    _isViewportValidated = 1;
    if (CGLLockContext(_coreGLContext) != kCGLNoError)
        return nil;
    NSOpenGLContext *current = [NSOpenGLContext currentContext];
    if (current != _openGLContext) {
        _previousOpenGLContext = [current retain];
        [_openGLContext makeCurrentContext];
    }
    if (setViewport) {
        CGLContextObj cgl_ctx = _coreGLContext;
        glViewport(0, 0, _width, _height);
    }
    return _openGLContext;
}

- (void)unlockOpenGLFocus
{
    CGLUnlockContext(_coreGLContext);
    if ([NSOpenGLContext currentContext] == _openGLContext) {
        if (_previousOpenGLContext)
            [_previousOpenGLContext makeCurrentContext];
        else
            [NSOpenGLContext clearCurrentContext];
    }
    [_previousOpenGLContext release];
    _previousOpenGLContext = nil;
}

@end
