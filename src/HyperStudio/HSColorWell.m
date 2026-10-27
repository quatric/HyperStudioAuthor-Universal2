#import "HSColorWell.h"
#import <objc/runtime.h>

@implementation HSColorWell

static NSInteger sActiveColorWellCount = 0;
static id (*sNSColorWellInitWithFrame)(id, SEL, NSRect);
static id (*sNSColorWellInitWithCoder)(id, SEL, NSCoder *);

static id HSColorWellInitWithFrame(id self, SEL _cmd, NSRect aFrame)
{
    self = sNSColorWellInitWithFrame(self, _cmd, aFrame);
    if (self != nil && object_getClass(self) == [NSColorWell class])
        object_setClass(self, [HSColorWell class]);
    return self;
}

static id HSColorWellInitWithCoder(id self, SEL _cmd, NSCoder *aCoder)
{
    self = sNSColorWellInitWithCoder(self, _cmd, aCoder);
    if (self != nil && object_getClass(self) == [NSColorWell class])
        object_setClass(self, [HSColorWell class]);
    return self;
}

+ (BOOL)hasActiveColorWell
{
    return sActiveColorWellCount > 0;
}

+ (void)load
{
    // Fix: +poseAsClass: does not exist in the 64-bit runtime; plain NSColorWell instances are retyped as they are created instead.
    Method initWithFrame = class_getInstanceMethod([NSColorWell class], @selector(initWithFrame:));
    Method initWithCoder = class_getInstanceMethod([NSColorWell class], @selector(initWithCoder:));
    sNSColorWellInitWithFrame = (id (*)(id, SEL, NSRect))method_setImplementation(initWithFrame, (IMP)HSColorWellInitWithFrame);
    sNSColorWellInitWithCoder = (id (*)(id, SEL, NSCoder *))method_setImplementation(initWithCoder, (IMP)HSColorWellInitWithCoder);
}

- (void)drawWellInside:(NSRect)aInside
{
    if (![[[self color] colorSpaceName] isEqualToString:NSPatternColorSpace]) {
        [super drawWellInside:aInside];
        return;
    }
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGAffineTransform ctm = CGContextGetCTM(context);
    CGContextSaveGState(context);
    CGContextSetPatternPhase(context, CGSizeMake(ctm.tx, ctm.ty));
    NSColor *color = [self color];
    if ([[HSSystem sharedSystem] isSnowLeopardOrGreater]) {
        NSImage *patternImage = nil;
        @try {
            patternImage = [[self color] patternImage];
        }
        @catch (NSException *exception) {
        }
        if (patternImage != nil) {
            NSImage *image = [[NSImage alloc] initWithSize:[patternImage size]];
            [image lockFocus];
            [patternImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            [image unlockFocus];
            color = [NSColor colorWithPatternImage:image];
            [image release];
        }
    }
    [color set];
    NSRectFill(aInside);
    CGContextRestoreGState(context);
}

- (void)setColor:(id)aColor
{
    [super setColor:aColor];
    NSColor *color = [self color];
    if ([color isEqual:aColor] && [aColor isEqual:color])
        return;
    // Sets a different color first so the well redraws with the new one.
    NSColor *other = [NSColor whiteColor];
    if ([aColor isEqualTo:other])
        other = [NSColor blackColor];
    [super setColor:other];
    [super setColor:aColor];
}

- (BOOL)isPatternSupportEnabled
{
    return YES;
}

- (BOOL)isGradientSupportEnabled
{
    return YES;
}

- (void)deactivate
{
    BOOL wasActive = [self isActive];
    [super deactivate];
    if (wasActive && ![self isActive])
        [self decrementCounter];
    if (![self isGradientSupportEnabled] && wasActive)
        [[HSGradientPicker sharedGradienPicker] setIsDisabled:NO];
    if (![self isPatternSupportEnabled] && wasActive)
        [[HSPatternPicker sharedPatternPicker] setIsDisabled:NO];
    if (![HSColorWell hasActiveColorWell] && [[NSColorPanel sharedColorPanel] attachedSheet] == nil)
        [[NSColorPanel sharedColorPanel] close];
}

- (void)activate:(BOOL)aActivate
{
    BOOL wasActive = [self isActive];
    [self incrementCounter];
    NSInteger mode = [[NSColorPanel sharedColorPanel] mode];
    NSColor *color = [self color];
    if ([color hyperGradientColor] != nil)
        [NSColorPanel setPickerMode:8];
    else if ([[color colorSpaceName] isEqualToString:NSPatternColorSpace])
        [NSColorPanel setPickerMode:9];
    else if ((NSUInteger)(mode - 8) <= 1)
        [NSColorPanel setPickerMode:NSColorPanelModeWheel];
    [super activate:aActivate];
    if (wasActive)
        [self decrementCounter];
    [[HSGradientPicker sharedGradienPicker] setIsDisabled:![self isGradientSupportEnabled]];
    [[HSPatternPicker sharedPatternPicker] setIsDisabled:![self isPatternSupportEnabled]];
}

- (void)decrementCounter
{
    sActiveColorWellCount--;
}

- (void)incrementCounter
{
    sActiveColorWellCount++;
}

- (void)dealloc
{
    [self deactivate];
    [super dealloc];
}

- (void)drawCustomDisabledColorWeelInside:(NSRect)aRect
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:aRect.origin];
    [path lineToPoint:NSMakePoint(aRect.origin.x, aRect.origin.y + aRect.size.height)];
    [path lineToPoint:NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y + aRect.size.height)];
    [path closePath];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [path setClip];
    [[NSColor blackColor] set];
    NSRectFill(aRect);
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.57] set];
    NSRectFillUsingOperation(aRect, NSCompositingOperationSourceAtop);
}

@end
