// Pixel buffer and pixel format helpers (SMKApplicationKit's CVE functions).
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>
#import <OpenGL/gl.h>

// The bytes of a chunky buffer (rows × height), or of all planes.
size_t CVEPixelBufferGetDataSize(CVPixelBufferRef buffer);
// GL_UNPACK_ROW_LENGTH (pixels) and GL_UNPACK_ALIGNMENT for the buffer's rows,
// if OpenGL can read them as they are.
Boolean CVEPixelBufferGetOpenGLRowLengthAndAlignment(CVPixelBufferRef buffer, GLint *rowLength, GLint *alignment);
// The glTexImage2D formats and unpack row length / alignment of a chunky buffer.
Boolean CVEPixelBufferIsOpenGLCompatible(CVPixelBufferRef buffer, GLint *internalFormat, GLenum *format, GLenum *type,
                                         GLint *rowLength, GLint *alignment);
// "Name ('code')".
CFStringRef CVEPixelFormatTypeCopyDescription(OSType type);
// How CGBitmapContextCreate takes the format. alphaMode: 1 premultiplied,
// -1 alpha ignored, 0 alpha as is (which bitmap contexts can't do).
Boolean CVEPixelFormatTypeIsCGBitmapContextCompatible(OSType type, int alphaMode, size_t *bitsPerComponent,
                                                      CGColorSpaceModel *model, CGBitmapInfo *bitmapInfo,
                                                      Boolean *invertedDecode);
// How CGImageCreate takes the format (alphaMode as above).
Boolean CVEPixelFormatTypeIsCGImageCompatible(OSType type, int alphaMode, size_t *bitsPerComponent,
                                              size_t *bitsPerPixel, CGColorSpaceModel *model,
                                              CGBitmapInfo *bitmapInfo, Boolean *invertedDecode);
// The glTexImage2D formats of the format, and its bits per block and block
// width (pixels).
Boolean CVEPixelFormatTypeIsOpenGLCompatible(OSType type, GLint *internalFormat, GLenum *format, GLenum *type2,
                                             int *bitsPerBlock, int *blockWidth);
