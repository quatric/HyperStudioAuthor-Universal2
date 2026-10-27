#import "BTCGImageSaver.h"

// The saver that writes purgeable images' bitmap data to temporary files. The
// original vended a BTCGImageSaver over an NSConnection to a thread of its
// own and sent it oneway messages; a serial queue does the same now.

static dispatch_queue_t saverQueue;
static BTCGImageSaver *saver;

static void StartSaver(void)
{
    saverQueue = dispatch_queue_create("BTCGImageSaver", DISPATCH_QUEUE_SERIAL);
    saver = [[BTCGImageSaver alloc] init];
}

@implementation BTCGImageSaver

// The original's thread entry point: serves a new saver on the given ports
// (receive, send) until the thread exits.
+ (void)connectWithPorts:(id)aPorts
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSConnection *connection = [NSConnection connectionWithReceivePort:[aPorts objectAtIndex:0]
                                                              sendPort:[aPorts objectAtIndex:1]];
    BTCGImageSaver *root = [[self alloc] init];
    [connection setRootObject:root];
    [root release];
    [[NSRunLoop currentRunLoop] run];
    [pool release];
}

- (void)removeFileAtPath:(id)aPath
{
    [[NSFileManager defaultManager] removeItemAtPath:aPath error:NULL];
}

// Takes over the image's retain.
- (void)storeImage:(NSUInteger)aImage
{
    BTCGImage *image = (BTCGImage *)aImage;
    [image BTCGImage_writeDataToFileInSeparateThread];
    [image release];
}

@end

@implementation BTCGImage

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithCGImage:(struct CGImage *)aImage
{
    self = [super init];
    if (!self)
        return nil;
    _image = CGImageRetain(aImage);
    if (_image) {
        _width = (unsigned int)CGImageGetWidth(_image);
        _height = (unsigned int)CGImageGetHeight(_image);
        _colorSpace = CGColorSpaceRetain(CGImageGetColorSpace(_image));
    }
    return self;
}

- (id)initWithBitmapData:(id)aData width:(NSUInteger)aWidth height:(NSUInteger)aHeight bitsPerComponent:(NSUInteger)aComponent bitsPerPixel:(NSUInteger)aPixel bytesPerRow:(NSUInteger)aRow colorSpace:(struct CGColorSpace *)aSpace bitmapInfo:(NSUInteger)aInfo decode:(const CGFloat *)aDecode shouldInterpolate:(BOOL)aInterpolate intent:(NSInteger)aIntent
{
    self = [super init];
    if (!self)
        return nil;
    _bitmapData = [aData retain];
    _width = (unsigned int)aWidth;
    _height = (unsigned int)aHeight;
    _bitsPerComponent = (unsigned int)aComponent;
    _bitsPerPixel = (unsigned int)aPixel;
    _bytesPerRow = (unsigned int)aRow;
    _shouldInterpolate = aInterpolate ? 1 : 0;
    _intent = (int)aIntent;
    _colorSpace = CGColorSpaceRetain(aSpace);
    _bitmapInfo = (unsigned int)aInfo;
    if (aDecode) {
        size_t components = CGColorSpaceGetNumberOfComponents(_colorSpace);
        size_t alpha;
        switch (_bitmapInfo & kCGBitmapAlphaInfoMask) {
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaLast:
        case kCGImageAlphaFirst:
        case kCGImageAlphaOnly:
            alpha = 1;
            break;
        case kCGImageAlphaNone:
        case kCGImageAlphaNoneSkipLast:
        case kCGImageAlphaNoneSkipFirst:
            alpha = 0;
            break;
        default:
            CFShow(CFSTR("Invalid unsupported image alpha info"));
            alpha = 0;
            break;
        }
        size_t size = (components + alpha) * 2 * sizeof(CGFloat);
        if (size) {
            _decode = malloc(size);
            if (!_decode)
                goto fail;
            memcpy(_decode, aDecode, size);
        }
    }
    _imageLock = [[NSRecursiveLock alloc] init];
    if (!_imageLock)
        goto fail;
    _fileNameLock = [[NSRecursiveLock alloc] init];
    if (!_fileNameLock)
        goto fail;
    return self;
fail:
    [self release];
    return nil;
}

- (void)dealloc
{
    if (_fileName) {
        NSString *fileName = _fileName;
        dispatch_async(saverQueue, ^{
            [saver removeFileAtPath:fileName];
            [fileName release];
        });
    }
    [_imageLock release];
    [_fileNameLock release];
    CGImageRelease(_image);
    CGColorSpaceRelease(_colorSpace);
    [_bitmapData release];
    if (_decode)
        free(_decode);
    [super dealloc];
}

// Re-reads the bitmap data from the file it was saved to if it was purged.
- (struct CGImage *)image
{
    [_imageLock lock];
    if (!_image) {
        if (!_bitmapData && _fileName)
            _bitmapData = [[NSData allocWithZone:[self zone]] initWithContentsOfFile:_fileName
                                                                             options:NSDataReadingMappedIfSafe
                                                                               error:NULL];
        if (_bitmapData) {
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)_bitmapData);
            if (provider) {
                _image = CGImageCreate(_width, _height, _bitsPerComponent, _bitsPerPixel, _bytesPerRow, _colorSpace,
                                       _bitmapInfo, provider, _decode, _shouldInterpolate, _intent);
                CGDataProviderRelease(provider);
            }
        }
    }
    _isPurgePending = 0;
    [_imageLock unlock];
    return _image;
}

- (CGSize)imageSize
{
    return CGSizeMake(_width, _height);
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return _colorSpace;
}

- (struct CGImage *)coreGraphicsImage
{
    return [self image];
}

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    if (!BTIsImagePoint(self, aPoint))
        return NULL;
    return (CGColorRef)CFAutorelease(BTCopyColorFromCGImage(self, aPoint));
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGContextDrawImage(aContext, aRect, [self image]);
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGImageRef image = [self image];
    CGSize size = [self imageSize];
    CGContextDrawImage(aContext, CGRectMake(aPoint.x, aPoint.y, size.width, size.height), image);
}

- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] inRect:NSRectToCGRect(aRect)];
}

- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] atPoint:NSPointToCGPoint(aPoint)];
}

// Hands the image to the saver, which writes its data to a temporary file
// and then purges it if -purge was called in the meantime.
- (void)prepareToPurge
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        StartSaver();
    });
    BTCGImage *image = [self retain];
    dispatch_async(saverQueue, ^{
        [saver storeImage:(NSUInteger)image];
    });
}

- (void)BTCGImage_purgeIfNeeded
{
    [_imageLock lock];
    if (_fileName && _isPurgePending) {
        CGImageRelease(_image);
        _image = NULL;
        [_bitmapData release];
        _bitmapData = nil;
    }
    [_imageLock unlock];
}

- (void)purge
{
    _isPurgePending = 1;
    [self BTCGImage_purgeIfNeeded];
}

- (void)BTCGImage_writeDataToFileInSeparateThread
{
    [_fileNameLock lock];
    if (!_fileName && _bitmapData) {
        NSString *path = [[self class] BTCGImage_uniqueFileNameInTempFolder];
        if ([_bitmapData writeToFile:path atomically:NO])
            _fileName = [path retain];
    }
    [_fileNameLock unlock];
    [self BTCGImage_purgeIfNeeded];
}

+ (id)BTCGImage_uniqueFileNameInTempFolder
{
    const char *pattern = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"hsundoXXXXXXXXXXXXXXXXXXXX"]
        cStringUsingEncoding:NSUTF8StringEncoding];
    char *path = malloc(strlen(pattern) + 1);
    if (!path)
        return nil;
    strcpy(path, pattern);
    NSString *result = nil;
    int fd = mkstemp(path);
    if (fd != -1) {
        result = [NSString stringWithUTF8String:path];
        close(fd);
    }
    free(path);
    return result;
}

@end
