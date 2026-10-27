#import "BTToolView.h"
#import "BTTool.h"
#import "BTCGBitmapLayer.h"
#import "NSWindow+BTEvents.h"
#import "NSEvent_BTKeyBinding_BTKeyEventsInterpreter.h"

@implementation BTToolView

- (NSRect)convertImageRectToViewRect:(NSRect)aRect
{
    return NSMakeRect(aRect.origin.x * _zoomFactor.width, aRect.origin.y * _zoomFactor.height,
                      aRect.size.width * _zoomFactor.width, aRect.size.height * _zoomFactor.height);
}

- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint
{
    return NSMakePoint(aPoint.x * _zoomFactor.width, aPoint.y * _zoomFactor.height);
}

- (CGAffineTransform)imageToViewTransform
{
    return CGAffineTransformMake(_zoomFactor.width, 0, 0, _zoomFactor.height, 0, 0);
}

- (NSRect)convertViewRectToImageRect:(NSRect)aRect
{
    return NSMakeRect(aRect.origin.x / _zoomFactor.width, aRect.origin.y / _zoomFactor.height,
                      aRect.size.width / _zoomFactor.width, aRect.size.height / _zoomFactor.height);
}

- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint
{
    return NSMakePoint(aPoint.x / _zoomFactor.width, aPoint.y / _zoomFactor.height);
}

- (CGAffineTransform)viewToImageTransform
{
    return CGAffineTransformMake(1.0 / _zoomFactor.width, 0, 0, 1.0 / _zoomFactor.height, 0, 0);
}

- (id)layoutGuidingContextForTool:(id)aTool
{
    return nil;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    return _currentTool == aTool ? self : nil;
}

- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    return _currentTool == aTool ? [self undoManager] : nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return _currentTool == aTool ? [self undoManager] : nil;
}

- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
}

- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
    if (_currentTool == aTool)
        [self BTToolView_setNeedsDisplayImageInRect:aRect];
}

- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
    if (_currentTool == aTool)
        [self BTToolView_setNeedsDisplayImageInRect:aRect];
}

- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect
{
    if (_currentTool == aTool)
        [self BTToolView_setNeedsDisplayImageInRect:aRect];
}

- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect
{
}

- (void)toolDidEndChangingImageContinuously:(id)aTool
{
}

- (void)toolWillBeginChangingImageContinuously:(id)aTool
{
}

- (void)BTToolView_setNeedsDisplayImageInRect:(NSRect)aRect
{
    NSRect r = NSRectFromCGRect(CGRectIntegral(NSRectToCGRect(aRect)));
    r = [self convertImageRectToViewRect:r];
    [self setNeedsDisplayInRect:NSRectFromCGRect(CGRectIntegral(NSRectToCGRect(r)))];
}

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    return NO;
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentTool == aTool)
        [self BTToolView_updateCursorWithEvent:aEvent];
}

- (void)forwardInvocation:(id)aInvocation
{
    if (_currentTool == nil)
        [super forwardInvocation:aInvocation];
    else
        [aInvocation invokeWithTarget:_currentTool];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (sig == nil)
        sig = [_currentTool methodSignatureForSelector:aSelector];
    return sig;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    return [_currentTool respondsToSelector:aSelector];
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    if ([super respondsToSelector:action])
        return YES;
    return [_currentTool validateAction:action];
}

- (void)interpretCurrentKeyEventAsCommand:(SEL *)aCommand text:(id *)aText
{
    if (_currentKeyEvent == nil) {
        if (aCommand != NULL)
            *aCommand = NULL;
        if (aText != NULL)
            *aText = nil;
    } else {
        [_currentKeyEvent BT_interpretAsCommand:aCommand text:aText];
    }
}

- (void)scrollWheel:(id)aEvent
{
    if (![_currentTool scrollWheel:aEvent])
        [super scrollWheel:aEvent];
    [self BTToolView_updateCursorWithEvent:aEvent];
}

- (void)mouseExited:(id)aEvent
{
    if (_trackingVisibleZone != nil
        && [aEvent trackingNumber] == [_trackingVisibleZone trackingRectTag]
        && [[self window] isKeyWindow]) {
        if (_currentToolCursor != nil)
            [self BTToolView_popCursor];
        _isInVisibleZoneAndActive = NO;
    }
    [super mouseExited:aEvent];
}

- (void)mouseEntered:(id)aEvent
{
    [super mouseEntered:aEvent];
    if (_trackingVisibleZone != nil
        && [aEvent trackingNumber] == [_trackingVisibleZone trackingRectTag]
        && [[self window] isKeyWindow]) {
        [self BTToolView_updateToolCursorWithEvent:aEvent];
        _isInVisibleZoneAndActive = YES;
    }
}

- (void)mouseMoved:(id)aEvent
{
    if (![_currentTool mouseMoved:aEvent])
        [super mouseMoved:aEvent];
    if (_isInVisibleZoneAndActive)
        [self BTToolView_updateToolCursorWithEvent:aEvent];
}

- (void)mouseDown:(id)aEvent
{
    if (![_currentTool mouseDown:aEvent])
        [super mouseDown:aEvent];
}

- (void)flagsChanged:(id)aEvent
{
    if (![_currentTool flagsChanged:aEvent])
        [super flagsChanged:aEvent];
}

- (void)keyUp:(id)aEvent
{
    if (![_currentTool keyUp:aEvent])
        [super keyUp:aEvent];
}

- (void)keyDown:(id)aEvent
{
    _currentKeyEvent = aEvent;
    if (![_currentTool keyDown:aEvent])
        [super keyDown:aEvent];
    _currentKeyEvent = nil;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)drawRect:(NSRect)aRect
{
    [self drawContentRect:aRect];
    [self drawToolRect:aRect];
}

- (void)drawToolRect:(NSRect)aRect
{
    [_currentTool drawRect:aRect];
}

- (void)drawContentRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    id image = _currentTool != nil ? [_currentTool workImage] : _image;
    if (image == nil)
        return;
    if ([image conformsToProtocol:@protocol(BTCocoaImage)])
        [image drawInCurrentNSGraphicsContextInRect:NSRectToCGRect(bounds)];
    else if ([image conformsToProtocol:@protocol(BTCGImage)])
        [image drawInCGContext:[[NSGraphicsContext currentContext] CGContext] inRect:NSRectToCGRect(bounds)];
}

- (void)resignKeyWindow
{
    if (_currentToolCursor != nil)
        [self BTToolView_popCursor];
    _isInVisibleZoneAndActive = NO;
}

- (void)becomeKeyWindow
{
    NSPoint location = NSZeroPoint;
    NSUInteger flags = 0;
    [self BTToolView_getLocation:&location modifierFlags:&flags forEvent:nil];
    if ([self mouse:location inRect:[self visibleRect]]) {
        [self BTToolView_updateToolCursorWithPoint:location modifierFlags:flags];
        _isInVisibleZoneAndActive = YES;
    }
}

- (BOOL)setCurrentToolByName:(id)aName forceSwitch:(BOOL)aSwitch
{
    return [self setCurrentTool:[self toolForName:aName] forceSwitch:aSwitch];
}

- (BOOL)setCurrentTool:(id)aTool forceSwitch:(BOOL)aSwitch
{
    if (_currentTool == aTool)
        return YES;
    if (_currentTool != nil) {
        [_currentTool deactivate];
        if (_currentToolCursor != nil)
            [self BTToolView_popCursor];
        /* Take the edited image back from the outgoing tool. */
        [(id)_image release];
        [_imageProperties autorelease];
        _imageProperties = nil;
        _image = [[_currentTool workImage] retain];
        [_currentTool autorelease];
    }
    _currentTool = [aTool retain];
    if (![_currentTool activateWithDelegate:self inView:self])
        return NO;
    if (_image != nil)
        [_currentTool setWorkImage:[self BTToolView_mutableImage]];
    if (_trackingVisibleZone == nil)
        [self BTToolView_setupTrackingZone];
    return YES;
}

- (id)currentTool
{
    return _currentTool;
}

- (id)toolForName:(id)aName
{
    return [[self BTToolView_availableTools] objectForKey:aName];
}

- (id)availableToolNames
{
    return [[self BTToolView_availableTools] allKeys];
}

- (id)BTToolView_availableTools
{
    if (_availableTools == nil)
        _availableTools = [[NSDictionary alloc] init];
    return _availableTools;
}

- (void)BTToolView_updateCursorWithEvent:(id)aEvent
{
    NSPoint location = NSZeroPoint;
    NSUInteger flags = 0;
    [self BTToolView_getLocation:&location modifierFlags:&flags forEvent:aEvent];
    if ([self mouse:location inRect:[self visibleRect]]) {
        [self BTToolView_updateToolCursorWithPoint:location modifierFlags:flags];
    } else {
        if (_currentToolCursor != nil)
            [self BTToolView_popCursor];
        _isInVisibleZoneAndActive = NO;
    }
}

- (void)BTToolView_updateToolCursorWithEvent:(id)aEvent
{
    NSUInteger flags = [aEvent modifierFlags];
    NSPoint location = [self convertMouseLocationFromWindow:[aEvent locationInWindow]];
    [self BTToolView_updateToolCursorWithPoint:location modifierFlags:flags];
}

/* Pushes the tool cursor the first time, then swaps it in place; pops when the tool has none. */
- (void)BTToolView_updateToolCursorWithPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    NSCursor *previous = _currentToolCursor;
    [previous autorelease];
    _currentToolCursor = nil;
    _currentToolCursor = [[_currentTool cursorForPoint:aPoint modifierFlags:aFlags] retain];
    if (previous == nil)
        [_currentToolCursor push];
    else if (_currentToolCursor != nil)
        [_currentToolCursor set];
    else
        [NSCursor pop];
}

- (void)BTToolView_popCursor
{
    [NSCursor pop];
    [_currentToolCursor release];
    _currentToolCursor = nil;
}

- (void)BTToolView_getLocation:(NSPoint *)aLocation modifierFlags:(NSUInteger *)aFlags forEvent:(id)aEvent
{
    if (aLocation != NULL)
        *aLocation = [self convertMouseLocationFromWindow:[[self window] BT_effectiveMouseLocationWithEvent:aEvent]];
    if (aFlags != NULL)
        *aFlags = [[self window] BT_effectiveModifierFlagsWithEvent:aEvent];
}

- (void)BTToolView_setupTrackingZone
{
    NSRect visible = [self visibleRect];
    NSPoint mouse = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
    BOOL inside = [self mouse:mouse inRect:visible];
    _trackingVisibleZone = [[self addTrackingZoneForVisibleRectWithOwner:self assumeInside:inside postInitialMouseEntered:YES] retain];
}

- (NSPoint)convertMouseLocationFromWindow:(NSPoint)aPoint
{
    return [self convertPoint:NSMakePoint(aPoint.x + 0.5, aPoint.y + 0.5) fromView:nil];
}

- (void)setImage:(id)aImage imageProperties:(id)aProperties
{
    if (_image == aImage)
        return;
    [(id)_image release];
    [_imageProperties autorelease];
    _image = [aImage retain];
    _imageProperties = [aProperties copy];
    [_currentTool setWorkImage:[self BTToolView_mutableImage]];
    CGSize size = [_image imageSize];
    [self setFrameSize:NSMakeSize(size.width * _zoomFactor.width, size.height * _zoomFactor.height)];
    [self setNeedsDisplay:YES];
}

/* A mutable image is used as is; a plain CG image is copied into a new bitmap layer. */
- (id)BTToolView_mutableImage
{
    if (_image == nil)
        return nil;
    if ([_image conformsToProtocol:@protocol(BTCGMutableImage)])
        return _image;
    if (![_image conformsToProtocol:@protocol(BTCGImage)])
        return nil;

    CGSize size = [_image imageSize];
    long width = size.width > 0.0 ? lround(ceil(size.width)) : 0;
    long height = size.height > 0.0 ? lround(ceil(size.height)) : 0;
    if (width == 0 || height == 0)
        return nil;

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    id layer = nil;
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~15L, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context != NULL) {
        [(id<BTCGImage>)_image drawInCGContext:context atPoint:CGPointZero];
        layer = [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
        CGContextRelease(context);
    }
    CGColorSpaceRelease(space);
    return layer;
}

- (id)imageProperties
{
    return _imageProperties;
}

- (id)image
{
    return _image;
}

- (BOOL)canBecomeKeyView
{
    return YES;
}

/* Discard the tracking zone before the final release so it stops observing the view. */
- (oneway void)release
{
    if ([self retainCount] == 1 && _trackingVisibleZone != nil) {
        [_trackingVisibleZone discard];
        [_trackingVisibleZone release];
        _trackingVisibleZone = nil;
    }
    [super release];
}

- (void)dealloc
{
    [_currentTool deactivate];
    [_currentTool release];
    if (_currentToolCursor != nil) {
        [NSCursor pop];
        [_currentToolCursor release];
    }
    [_availableTools release];
    [(id)_image release];
    [_imageProperties release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil)
        _zoomFactor = NSMakeSize(1.0, 1.0);
    return self;
}

@end
