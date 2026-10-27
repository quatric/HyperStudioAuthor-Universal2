#import "HSCFAllocatorHandleContext.h"
// A CFAllocator over one Memory Manager handle, so CFData can wrap a
// handle's bytes without copying (the data then owns the handle).
static const void *HSCFAllocatorHandleContextRetain(const void *aInfo)
{
    [(id)aInfo retain];
    return aInfo;
}
static void HSCFAllocatorHandleContextRelease(const void *aInfo)
{
    [(id)aInfo release];
}
static void *HSCFAllocatorHandleContextAllocate(CFIndex aSize, CFOptionFlags aHint, void *aInfo)
{
    [(HSCFAllocatorHandleContext *)aInfo setHandle:NewHandle(aSize)];
    return *[(HSCFAllocatorHandleContext *)aInfo handle];
}
static void *HSCFAllocatorHandleContextReallocate(void *aPointer, CFIndex aSize, CFOptionFlags aHint, void *aInfo)
{
    SetHandleSize([(HSCFAllocatorHandleContext *)aInfo handle], aSize);
    return *[(HSCFAllocatorHandleContext *)aInfo handle];
}
static void HSCFAllocatorHandleContextDeallocate(void *aPointer, void *aInfo)
{
    [(HSCFAllocatorHandleContext *)aInfo setHandle:NULL];
}
@implementation HSCFAllocatorHandleContext
- (void)setHandle:(char **)aHandle
{
    if (_handle != aHandle) {
        DisposeHandle(_handle);
        _handle = aHandle;
    }
}
- (char **)handle
{
    return _handle;
}
- (struct HyperPlayerBase_anon4 *)context
{
    return _context;
}
- (void)dealloc
{
    DisposeHandle(_handle);
    free(_context);
    [super dealloc];
}
- (id)initWithHandle:(char **)aHandle
{
    self = [super init];
    if (self != nil) {
        _handle = aHandle;
        CFAllocatorContext *context = malloc(sizeof(CFAllocatorContext));
        context->version = 0;
        context->info = self;
        context->retain = HSCFAllocatorHandleContextRetain;
        context->release = HSCFAllocatorHandleContextRelease;
        context->copyDescription = NULL;
        context->allocate = HSCFAllocatorHandleContextAllocate;
        context->reallocate = HSCFAllocatorHandleContextReallocate;
        context->deallocate = HSCFAllocatorHandleContextDeallocate;
        context->preferredSize = NULL;
        _context = (struct HyperPlayerBase_anon4 *)context;
    }
    return self;
}
@end
@implementation NSData (HSExtension)
+ (id)hyperDataWithHyperHandleNoCopy:(char **)aCopy
{
    HSCFAllocatorHandleContext *handleContext = [[HSCFAllocatorHandleContext alloc] initWithHandle:aCopy];
    CFAllocatorRef allocator = CFAllocatorCreate(NULL, (CFAllocatorContext *)[handleContext context]);
    CFDataRef data = CFDataCreateWithBytesNoCopy(NULL, (const UInt8 *)*aCopy, GetHandleSize(aCopy), allocator);
    CFRelease(allocator);
    [handleContext release];
    return [(id)data autorelease];
}
@end
