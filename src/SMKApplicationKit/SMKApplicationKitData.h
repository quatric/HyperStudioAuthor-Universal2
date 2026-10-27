// SMKApplicationKit's exported constants: string keys and names, and
// CFArray/CFDictionary/CFSet callbacks for non-object values.
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

extern NSString * const NSEDefaultOpenGLContextShareCategory;
extern NSString * const NSEFileManagerErrorDomain;
extern NSString * const NSEOpenGLCGContextDestination;
extern NSString * const NSEWorkspaceLaunchConfigurationAppleEvent;
extern NSString * const NSEWorkspaceLaunchConfigurationArguments;
extern NSString * const NSEWorkspaceLaunchConfigurationEnvironment;
extern NSString * const QTECaptureDeviceListDidUpdateNotification;
extern NSString * const QTECaptureDeviceListUpdatedElementIndexKey;
extern NSString * const QTECaptureMultisessionPrimaryDeviceDidBecomeAvailableNotification;
extern NSString * const QTECaptureMultisessionPrimaryDeviceKey;
extern NSString * const QTESampleConsumerOptionsCGBitmapContextCompatibilityKey;
extern NSString * const QTESampleConsumerOptionsCGImageCompatibilityKey;
extern NSString * const QTESampleConsumerOptionsOpenGLCompatibilityKey;
extern NSString * const QTESampleConsumerOptionsPixelFormatTypesKey;
extern NSString * const kCGEColorSpaceSRGB;
extern NSString * const kCGEContextAlphaAttachmentKey;
extern NSString * const kCGEContextColorSpaceAttachmentKey;
extern NSString * const kCGEContextColorSyncProfileAttachmentKey;
extern NSString * const kCGEContextDestinationBitmapData;
extern NSString * const kCGEContextFillColorAttachmentKey;
extern NSString * const kCGEContextFillColorBoundsAttachmentKey;
extern NSString * const kCGEContextFontAttachmentKey;
extern NSString * const kCGEContextLineCapAttachmentKey;
extern NSString * const kCGEContextLineDashLengthsAttachmentKey;
extern NSString * const kCGEContextLineDashPhaseAttachmentKey;
extern NSString * const kCGEContextLineJoinAttachmentKey;
extern NSString * const kCGEContextLineWidthAttachmentKey;
extern NSString * const kCGEContextMiterLimitAttachmentKey;
extern NSString * const kCGEContextStrokeColorAttachmentKey;
extern NSString * const kCGEContextStrokeColorBoundsAttachmentKey;
extern NSString * const kCGEContextTextDrawingModeAttachmentKey;
extern NSString * const kCGEContextTextStrokingModeAttachmentKey;
extern NSString * const kCSEsRGBProfile;
extern NSString * const kCVEImageBufferChangedRegionKey;
extern NSString * const kCVEImageBufferOpaquenessKey;
extern NSString * const kCVEPixelBufferAlphaInfoKey;

// integers, unsigned integers and OSTypes (described as such)
extern const CFArrayCallBacks kCFEIntegerArrayCallBacks;
extern const CFArrayCallBacks kCFEUnsignedIntegerArrayCallBacks;
extern const CFArrayCallBacks kCFEOSTypeArrayCallBacks;
extern const CFDictionaryKeyCallBacks kCFEIntegerDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks kCFEIntegerDictionaryValueCallBacks;
extern const CFDictionaryKeyCallBacks kCFEUnsignedIntegerDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks kCFEUnsignedIntegerDictionaryValueCallBacks;
extern const CFDictionaryKeyCallBacks kCFEOSTypeDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks kCFEOSTypeDictionaryValueCallBacks;
extern const CFSetCallBacks kCFEIntegerSetCallBacks;
extern const CFSetCallBacks kCFEUnsignedIntegerSetCallBacks;
extern const CFSetCallBacks kCFEOSTypeSetCallBacks;
// pointers compared by identity (hashed without their low two bits)
extern const CFDictionaryKeyCallBacks kCFEAlignedPointerDictionaryKeyCallBacks;
extern const CFSetCallBacks kCFEAlignedPointerSetCallBacks;
// objects compared by identity, retained or not
extern const CFArrayCallBacks kCFEObjectPointerArrayCallBacks;
extern const CFArrayCallBacks kCFEWeakObjectPointerArrayCallBacks;
extern const CFDictionaryKeyCallBacks kCFEObjectPointerDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks kCFEObjectPointerDictionaryValueCallBacks;
extern const CFDictionaryKeyCallBacks kCFEWeakObjectPointerDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks kCFEWeakObjectPointerDictionaryValueCallBacks;
extern const CFSetCallBacks kCFEObjectPointerSetCallBacks;
extern const CFSetCallBacks kCFEWeakObjectPointerSetCallBacks;
// selectors and classes
extern const CFArrayCallBacks NSESelectorArrayCallBacks;
extern const CFArrayCallBacks NSEClassArrayCallBacks;
extern const CFDictionaryKeyCallBacks NSESelectorDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks NSESelectorDictionaryValueCallBacks;
extern const CFDictionaryKeyCallBacks NSEClassDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks NSEClassDictionaryValueCallBacks;
extern const CFSetCallBacks NSESelectorSetCallBacks;
extern const CFSetCallBacks NSEClassSetCallBacks;

// "'abcd'" for an OSType of four printable-ish characters, else the number.
CFStringRef CFECopyOSTypeDescription(OSType type);
