#import "SMKApplicationKitPrefix.h"


@interface NSEOffscreenWindowOpenGLDrawable : NSObject
{
    unsigned int _width;
    unsigned int _height;
    NSEOpenGLContext *_openGLContext;
    struct _CGLContextObject *_coreGLContext;
    NSWindow *_window;
    NSOpenGLContext *_previousOpenGLContext;
    unsigned int _isStaticSize:1;
    unsigned int _isViewportValidated:1;
}
- (void)unlockOpenGLFocus;
- (id)lockOpenGLFocus;
- (id)openGLContext;
- (void)setWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight statically:(BOOL)aStatically;
- (NSUInteger)height;
- (NSUInteger)width;
- (void)dealloc;
- (id)initWithOpenGLContext:(id)aContext;
- (id)init;
@end

