#import "NSEOpenGLContext.h"
int main(void) {
  @autoreleasepool {
    NSOpenGLPixelFormatAttribute a[] = { NSOpenGLPFAAccelerated, NSOpenGLPFAAllowOfflineRenderers, 0 };
    NSEOpenGLContext *c1 = [NSEOpenGLContext contextWithFormatAttributes:(unsigned *)a shareCategory:@"t"];
    NSEOpenGLContext *c2 = [NSEOpenGLContext contextWithFormatAttributes:(unsigned *)a shareCategory:@"t"];
    printf("c1 %p c2 %p shares %d cat %s\n", c1, c2, [c1 sharesContext:c2], [[c2 shareCategory] UTF8String]);
    size_t w = 0, h = 0;
    unsigned rowL = 0; (void)rowL;
    CVPixelBufferRef pb = NULL;
    CVPixelBufferCreate(NULL, 37, 20, kCVPixelFormatType_32BGRA, NULL, &pb);
    GLint ifmt, rl, al; GLenum f, t;
    printf("compat %d rl %d al %d bpr %zu\n", CVEPixelBufferIsOpenGLCompatible(pb, &ifmt, &f, &t, &rl, &al), rl, al, CVPixelBufferGetBytesPerRow(pb));
    CFStringRef d = CVEPixelFormatTypeCopyDescription(kCVPixelFormatType_32BGRA); NSLog(@"%@", d); CFRelease(d);
    [c1 makeCurrentContext];
    id tex;
    @autoreleasepool {
      tex = [[c1 bindTextureForPixelBuffer:pb target:GL_TEXTURE_RECTANGLE_ARB border:0 specifyingIfNeeded:YES withOptions:4] retain];
      printf("tex %p name %lu valid %d inc2 %d\n", tex, (unsigned long)[(id<NSEOpenGLTexture>)tex name], [tex isValid], [tex isInContext:c2]);
      id tex2 = [c2 bindTextureForPixelBuffer:pb target:GL_TEXTURE_RECTANGLE_ARB border:0 specifyingIfNeeded:NO withOptions:0];
      printf("same from c2 %d\n", tex2 == tex);
      id tex3 = [c1 bindTextureForPixelBuffer:pb target:GL_TEXTURE_2D border:0 specifyingIfNeeded:YES withOptions:1];
      printf("tex3 %p name %lu\n", tex3, (unsigned long)[(id<NSEOpenGLTexture>)tex3 name]);
      id tex4 = [c1 bindTextureForPixelBuffer:pb target:GL_TEXTURE_2D border:0 specifyingIfNeeded:NO withOptions:1];
      printf("tex4 same %d\n", tex4 == tex3);
    }
    [tex release];
    CVPixelBufferRelease(pb);
    printf("released ok\n");
  }
  return 0;
}
