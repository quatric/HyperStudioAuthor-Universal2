#import "SMKApplicationKitData.h"
#import <objc/runtime.h>

NSString * const NSEDefaultOpenGLContextShareCategory = @"NSEDefaultOpenGLContextShareCategory";
NSString * const NSEFileManagerErrorDomain = @"NSEFileManagerErrorDomain";
NSString * const NSEOpenGLCGContextDestination = @"NSEOpenGLCGContextDestination";
NSString * const NSEWorkspaceLaunchConfigurationAppleEvent = @"NSWorkspaceLaunchConfigurationAppleEvent";
NSString * const NSEWorkspaceLaunchConfigurationArguments = @"NSWorkspaceLaunchConfigurationArguments";
NSString * const NSEWorkspaceLaunchConfigurationEnvironment = @"NSWorkspaceLaunchConfigurationEnvironment";
NSString * const QTECaptureDeviceListDidUpdateNotification = @"QTECaptureDeviceListDidUpdateNotification";
NSString * const QTECaptureDeviceListUpdatedElementIndexKey = @"QTECaptureDeviceListUpdatedElementIndexKey";
NSString * const QTECaptureMultisessionPrimaryDeviceDidBecomeAvailableNotification = @"QTECaptureMultisessionPrimaryDeviceDidBecomeAvailableNotification";
NSString * const QTECaptureMultisessionPrimaryDeviceKey = @"QTECaptureMultisessionPrimaryDeviceKey";
NSString * const QTESampleConsumerOptionsCGBitmapContextCompatibilityKey = @"QTESampleConsumerOptionsCGBitmapContextCompatibilityKey";
NSString * const QTESampleConsumerOptionsCGImageCompatibilityKey = @"QTESampleConsumerOptionsCGImageCompatibilityKey";
NSString * const QTESampleConsumerOptionsOpenGLCompatibilityKey = @"QTESampleConsumerOptionsOpenGLCompatibilityKey";
NSString * const QTESampleConsumerOptionsPixelFormatTypesKey = @"QTESampleConsumerOptionsPixelFormatTypesKey";
NSString * const kCGEColorSpaceSRGB = @"kCGColorSpaceSRGB";
NSString * const kCGEContextAlphaAttachmentKey = @"CGEContextAlphaAttachmentKey";
NSString * const kCGEContextColorSpaceAttachmentKey = @"kCGEContextColorSpaceAttachmentKey";
NSString * const kCGEContextColorSyncProfileAttachmentKey = @"kCGEContextColorSyncProfileAttachmentKey";
NSString * const kCGEContextDestinationBitmapData = @"CGEContextDestinationBitmapData";
NSString * const kCGEContextFillColorAttachmentKey = @"CGEContextFillColorAttachmentKey";
NSString * const kCGEContextFillColorBoundsAttachmentKey = @"CGEContextFillColorBoundsAttachmentKey";
NSString * const kCGEContextFontAttachmentKey = @"CGEContextFontAttachmentKey";
NSString * const kCGEContextLineCapAttachmentKey = @"CGEContextLineCapAttachmentKey";
NSString * const kCGEContextLineDashLengthsAttachmentKey = @"CGEContextLineDashLengthsAttachmentKey";
NSString * const kCGEContextLineDashPhaseAttachmentKey = @"CGEContextLineDashPhaseAttachmentKey";
NSString * const kCGEContextLineJoinAttachmentKey = @"CGEContextLineJoinAttachmentKey";
NSString * const kCGEContextLineWidthAttachmentKey = @"CGEContextLineWidthAttachmentKey";
NSString * const kCGEContextMiterLimitAttachmentKey = @"CGEContextMiterLimitAttachmentKey";
NSString * const kCGEContextStrokeColorAttachmentKey = @"CGEContextStrokeColorAttachmentKey";
NSString * const kCGEContextStrokeColorBoundsAttachmentKey = @"CGEContextStrokeColorBoundsAttachmentKey";
NSString * const kCGEContextTextDrawingModeAttachmentKey = @"CGEContextTextDrawingModeAttachmentKey";
NSString * const kCGEContextTextStrokingModeAttachmentKey = @"CGEContextTextStrokingModeAttachmentKey";
NSString * const kCSEsRGBProfile = @"com.apple.ColorSync.sRGB";
NSString * const kCVEImageBufferChangedRegionKey = @"CVEImageBufferChangedRegionKey";
NSString * const kCVEImageBufferOpaquenessKey = @"CVEImageBufferOpaquenessKey";
NSString * const kCVEPixelBufferAlphaInfoKey = @"CVEPixelBufferAlphaInfoKey";

CFStringRef CFECopyOSTypeDescription(OSType type)
{
    if (!(type & 0xff) || !(type >> 8 & 0xff) || !(type >> 16 & 0xff) || type < 0x1000000)
        return CFStringCreateWithFormat(NULL, NULL, CFSTR("%u"), (unsigned)type);
    CFStringRef code = UTCreateStringForOSType(type);
    if (!code)
        return NULL;
    CFStringRef description = CFStringCreateWithFormat(NULL, NULL, CFSTR("'%@'"), code);
    CFRelease(code);
    return description;
}

static CFStringRef copyIntegerDescription(const void *value)
{
    return CFStringCreateWithFormat(NULL, NULL, CFSTR("%ld"), (long)(intptr_t)value);
}

static CFStringRef copyUnsignedIntegerDescription(const void *value)
{
    return CFStringCreateWithFormat(NULL, NULL, CFSTR("%lu"), (unsigned long)(uintptr_t)value);
}

static CFStringRef copyOSTypeDescription(const void *value)
{
    return CFECopyOSTypeDescription((OSType)(uintptr_t)value);
}

static CFHashCode alignedPointerHash(const void *value)
{
    return (uintptr_t)value >> 2;
}

static const void *retainObject(CFAllocatorRef allocator, const void *value)
{
    return CFRetain(value);
}

static void releaseObject(CFAllocatorRef allocator, const void *value)
{
    CFRelease(value);
}

// "<Class: 0x…>" for Objective-C objects, "<CFType: 0x…>" for the others.
static CFStringRef copyObjectPointerDescription(const void *value)
{
    CFTypeID type = CFGetTypeID(value);
    if (type == 1)
        return CFStringCreateWithFormat(NULL, NULL, CFSTR("<%s: %p>"), object_getClassName((id)value), value);
    CFStringRef name = CFCopyTypeIDDescription(type);
    CFStringRef description = CFStringCreateWithFormat(NULL, NULL, CFSTR("<%@: %p>"), name, value);
    if (name)
        CFRelease(name);
    return description;
}

static CFStringRef copySelectorDescription(const void *value)
{
    return (CFStringRef)[NSStringFromSelector((SEL)value) copy];
}

static CFStringRef copyClassDescription(const void *value)
{
    return (CFStringRef)[NSStringFromClass((Class)value) copy];
}

const CFArrayCallBacks kCFEIntegerArrayCallBacks = { 0, NULL, NULL, copyIntegerDescription, NULL };
const CFArrayCallBacks kCFEUnsignedIntegerArrayCallBacks = { 0, NULL, NULL, copyUnsignedIntegerDescription, NULL };
const CFArrayCallBacks kCFEOSTypeArrayCallBacks = { 0, NULL, NULL, copyOSTypeDescription, NULL };
const CFDictionaryKeyCallBacks kCFEIntegerDictionaryKeyCallBacks = { 0, NULL, NULL, copyIntegerDescription, NULL, NULL };
const CFDictionaryValueCallBacks kCFEIntegerDictionaryValueCallBacks = { 0, NULL, NULL, copyIntegerDescription, NULL };
const CFDictionaryKeyCallBacks kCFEUnsignedIntegerDictionaryKeyCallBacks = { 0, NULL, NULL, copyUnsignedIntegerDescription, NULL, NULL };
const CFDictionaryValueCallBacks kCFEUnsignedIntegerDictionaryValueCallBacks = { 0, NULL, NULL, copyUnsignedIntegerDescription, NULL };
const CFDictionaryKeyCallBacks kCFEOSTypeDictionaryKeyCallBacks = { 0, NULL, NULL, copyOSTypeDescription, NULL, NULL };
const CFDictionaryValueCallBacks kCFEOSTypeDictionaryValueCallBacks = { 0, NULL, NULL, copyOSTypeDescription, NULL };
const CFSetCallBacks kCFEIntegerSetCallBacks = { 0, NULL, NULL, copyIntegerDescription, NULL, NULL };
const CFSetCallBacks kCFEUnsignedIntegerSetCallBacks = { 0, NULL, NULL, copyUnsignedIntegerDescription, NULL, NULL };
const CFSetCallBacks kCFEOSTypeSetCallBacks = { 0, NULL, NULL, copyOSTypeDescription, NULL, NULL };
const CFDictionaryKeyCallBacks kCFEAlignedPointerDictionaryKeyCallBacks = { 0, NULL, NULL, NULL, NULL, alignedPointerHash };
const CFSetCallBacks kCFEAlignedPointerSetCallBacks = { 0, NULL, NULL, NULL, NULL, alignedPointerHash };
const CFArrayCallBacks kCFEObjectPointerArrayCallBacks = { 0, retainObject, releaseObject, copyObjectPointerDescription, NULL };
const CFArrayCallBacks kCFEWeakObjectPointerArrayCallBacks = { 0, NULL, NULL, copyObjectPointerDescription, NULL };
const CFDictionaryKeyCallBacks kCFEObjectPointerDictionaryKeyCallBacks = { 0, retainObject, releaseObject, copyObjectPointerDescription, NULL, alignedPointerHash };
const CFDictionaryValueCallBacks kCFEObjectPointerDictionaryValueCallBacks = { 0, retainObject, releaseObject, copyObjectPointerDescription, NULL };
const CFDictionaryKeyCallBacks kCFEWeakObjectPointerDictionaryKeyCallBacks = { 0, NULL, NULL, copyObjectPointerDescription, NULL, alignedPointerHash };
const CFDictionaryValueCallBacks kCFEWeakObjectPointerDictionaryValueCallBacks = { 0, NULL, NULL, copyObjectPointerDescription, NULL };
const CFSetCallBacks kCFEObjectPointerSetCallBacks = { 0, retainObject, releaseObject, copyObjectPointerDescription, NULL, alignedPointerHash };
const CFSetCallBacks kCFEWeakObjectPointerSetCallBacks = { 0, NULL, NULL, copyObjectPointerDescription, NULL, alignedPointerHash };
const CFArrayCallBacks NSESelectorArrayCallBacks = { 0, NULL, NULL, copySelectorDescription, NULL };
const CFArrayCallBacks NSEClassArrayCallBacks = { 0, NULL, NULL, copyClassDescription, NULL };
const CFDictionaryKeyCallBacks NSESelectorDictionaryKeyCallBacks = { 0, NULL, NULL, copySelectorDescription, NULL, alignedPointerHash };
const CFDictionaryValueCallBacks NSESelectorDictionaryValueCallBacks = { 0, NULL, NULL, copySelectorDescription, NULL };
const CFDictionaryKeyCallBacks NSEClassDictionaryKeyCallBacks = { 0, NULL, NULL, copyClassDescription, NULL, alignedPointerHash };
const CFDictionaryValueCallBacks NSEClassDictionaryValueCallBacks = { 0, NULL, NULL, copyClassDescription, NULL };
const CFSetCallBacks NSESelectorSetCallBacks = { 0, NULL, NULL, copySelectorDescription, NULL, alignedPointerHash };
const CFSetCallBacks NSEClassSetCallBacks = { 0, NULL, NULL, copyClassDescription, NULL, alignedPointerHash };
