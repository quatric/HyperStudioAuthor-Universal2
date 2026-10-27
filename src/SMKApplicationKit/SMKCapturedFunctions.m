#import "SMKCapturedFunctions.h"

static CFDictionaryRef createEmpty(void)
{
    return CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFEAlignedPointerDictionaryKeyCallBacks, NULL);
}

CFDictionaryRef CFECopyCapturedFunctions(void)
{
    return createEmpty();
}

void CFERecaptureFunction(void *function, void *newFunction)
{
}

CFDictionaryRef NSECopyCapturedApplicationFunctions(void)
{
    return createEmpty();
}

void NSERecaptureApplicationFunction(void *function, void *newFunction)
{
}

uint32_t OSESystemVersionGetCurrent(void)
{
    static uint32_t version;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSOperatingSystemVersion v = [[NSProcessInfo processInfo] operatingSystemVersion];
        version = (uint32_t)v.majorVersion << 24 | ((uint32_t)v.minorVersion & 0xff) << 16 |
                  ((uint32_t)v.patchVersion & 0xffff);
    });
    return version;
}
