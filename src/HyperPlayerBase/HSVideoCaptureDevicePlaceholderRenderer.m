#import "HSVideoCaptureDevicePlaceholderRenderer.h"
// Renderers by device, held weakly (a renderer removes itself when freed).
static CFMutableDictionaryRef HSVideoCaptureDevicePlaceholderRenderers = NULL;
@implementation HSVideoCaptureDevicePlaceholderRenderer
// One shared renderer per video (or muxed) device, and one for no device.
+ (id)placeholderRendererForVideoCaptureDevice:(id)aDevice
{
    if (aDevice != nil && ![aDevice hasMediaType:QTMediaTypeVideo] && ![aDevice hasMediaType:QTMediaTypeMuxed])
        return nil;
    if (HSVideoCaptureDevicePlaceholderRenderers == NULL) {
        HSVideoCaptureDevicePlaceholderRenderers = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
            &HSNonOwnedCFTypePointerOrNullCFDictionaryKeyCallBacks, &kCFEWeakObjectPointerDictionaryValueCallBacks);
        if (HSVideoCaptureDevicePlaceholderRenderers == NULL)
            return nil;
    }
    id renderer = (id)CFDictionaryGetValue(HSVideoCaptureDevicePlaceholderRenderers, aDevice);
    // The original returned a cached renderer retained (leaking it).
    if (renderer != nil)
        return [[renderer retain] autorelease];
    renderer = [[[self alloc] HSVideoCaptureDevicePlaceholderRenderer_initWithVideoCaptureDevice:aDevice] autorelease];
    if (renderer != nil)
        CFDictionaryAddValue(HSVideoCaptureDevicePlaceholderRenderers, aDevice, renderer);
    return renderer;
}
// A translucent blue box with a dark and a light frame, the state icon
// centred above the white bold label.
- (void)drawRect:(NSRect)aRect withBounds:(NSRect)aBounds
{
    [NSBezierPath clipRect:aBounds];
    [[NSColor colorWithCalibratedRed:0.25 green:0.5 blue:0.75 alpha:0.25] set];
    [NSBezierPath fillRect:aBounds];
    NSRect frame = NSMakeRect(aBounds.origin.x, aBounds.origin.y, aBounds.size.width - 0.5f, aBounds.size.height - 0.5f);
    [[NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:0.25] set];
    [NSBezierPath strokeRect:frame];
    [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.25] set];
    [NSBezierPath strokeRect:NSInsetRect(frame, 1.0, 1.0)];
    NSString *labelString = nil;
    NSImage *icon = nil;
    [self HSVideoCaptureDevicePlaceholderRenderer_getPlaceholderLabel:&labelString icon:&icon];
    NSMutableAttributedString *label = nil;
    NSSize labelSize = NSZeroSize;
    if (labelString != nil) {
        NSRange range = NSMakeRange(0, [labelString length]);
        label = [[[NSMutableAttributedString alloc] initWithString:labelString] autorelease];
        [label addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:range];
        [label addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]] range:range];
        if (label != nil)
            labelSize = [label size];
    }
    NSSize iconSize = icon != nil ? [icon size] : NSZeroSize;
    float freeHeight = aBounds.size.height - (iconSize.height + labelSize.height + 10.0);
    float margin = freeHeight > 0 ? freeHeight * 0.5f : 0.0f;
    if (icon != nil) {
        float x = aBounds.origin.x;
        if (iconSize.width < aBounds.size.width)
            x = aBounds.origin.x + (aBounds.size.width - iconSize.width) * 0.5;
        float y = aBounds.origin.y + aBounds.size.height - (iconSize.height + margin);
        [icon drawAtPoint:NSMakePoint(x, y) fromRect:(NSRect){ NSZeroPoint, iconSize }
                operation:NSCompositingOperationSourceOver fraction:1.0];
    }
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    float labelX = aBounds.origin.x;
    float labelY = aBounds.origin.y;
    if ([context isFlipped]) {
        // Draw the label unflipped.
        CGAffineTransform flip = { 1, 0, 0, -1, 0, (CGFloat)(aBounds.origin.y * 2.0 + aBounds.size.height) };
        CGContextConcatCTM([context CGContext], flip);
        margin = aBounds.size.height - (margin + labelSize.height);
    }
    labelY += margin;
    if (labelSize.width < aBounds.size.width)
        labelX = aBounds.origin.x + (aBounds.size.width - labelSize.width) * 0.5;
    [label drawAtPoint:NSMakePoint(labelX, MAX(aBounds.origin.y, labelY))];
}
// "Live Video" unless the device state says otherwise: no capture devices
// at all ("No Camera" without a device, "Camera is In Use" with none of
// either type), in use by another application, or off (disconnected or
// suspended).
- (void)HSVideoCaptureDevicePlaceholderRenderer_getPlaceholderLabel:(id *)aLabel icon:(id *)aIcon
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *labelKey = @"Live Video";
    NSString *iconName = @"LiveObjectIcon";
    if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        BOOL checkDevice = YES;
        if (_videoCaptureDevice == nil) {
            if (_captureVideoDeviceList == nil)
                _captureVideoDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaType:QTMediaTypeVideo] retain];
            if ([_captureVideoDeviceList captureDeviceCount] == 0
                && [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed] count] == 0) {
                labelKey = @"No Camera";
                iconName = @"LiveObjectCameraOffIcon";
                checkDevice = NO;
            }
        }
        if (checkDevice) {
            BOOL inUse;
            // (The original asked its QTE_isInUseByAnotherApplication
            // category, the QTKit method under another name.)
            if (_videoCaptureDevice != nil)
                inUse = [_videoCaptureDevice isInUseByAnotherApplication];
            else
                inUse = [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] count] == 0
                    && [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed] count] == 0;
            if (inUse)
                labelKey = @"Camera is In Use";
            else if (_videoCaptureDevice != nil
                     && (![_videoCaptureDevice isConnected]
                         || [[_videoCaptureDevice attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue])) {
                labelKey = @"Camera Off";
                iconName = @"LiveObjectCameraOffIcon";
            }
        }
    }
    if (aLabel != NULL)
        *aLabel = [bundle localizedStringForKey:labelKey value:@"" table:@"HyperPlayerBase"];
    if (aIcon != NULL) {
        *aIcon = [HSPlayerBaseID imageNamed:iconName];
        [*aIcon setCacheMode:NSImageCacheNever];
    }
}
- (id)videoCaptureDevice
{
    return _videoCaptureDevice;
}
- (void)dealloc
{
    if (HSVideoCaptureDevicePlaceholderRenderers != NULL)
        CFDictionaryRemoveValue(HSVideoCaptureDevicePlaceholderRenderers, _videoCaptureDevice);
    [_videoCaptureDevice release];
    [_captureVideoDeviceList release];
    [super dealloc];
}
- (id)HSVideoCaptureDevicePlaceholderRenderer_initWithVideoCaptureDevice:(id)aDevice
{
    _videoCaptureDevice = [aDevice retain];
    return [self init];
}
@end
