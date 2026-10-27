#import "HSControlObjectView.h"
#import <objc/message.h>

// A ready-made control shown as it will look (its node rendered into
// an image), to be dragged onto a card.

@implementation HSControlObjectView

// The attributes each control view class sets over the defaults.
+ (id)controlsDescription
{
    static NSDictionary *controlsDescription;
    if (controlsDescription == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"DefaultControls" ofType:@"plist"];
        if (path != nil)
            controlsDescription = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return controlsDescription;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityUnknownRole;
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute])
        return [self accessibilityDescriptionValue];
    return [super accessibilityAttributeValue:aValue];
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

#pragma clang diagnostic pop

- (id)accessibilityDescriptionValue
{
    return @"";
}

- (void)windowDidResignKey:(id)aKey
{
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
}

- (void)windowDidBecomeKey:(id)aKey
{
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
}

// The object's default attributes, with this class's over them (the
// local node data and each unit's attributes merged).
- (id)objectDescription
{
    NSString *className;
    if (_objectDescription != nil || (className = [self objectClassName]) == nil)
        return _objectDescription;
    _objectDescription = [[[HSUserObjectDefaultAttributesProvider sharedInstance] defaultAttributesForUserObjectClassName:className] mutableCopy];
    if (_objectDescription == nil)
        return nil;
    NSDictionary *overrides = [[HSControlObjectView controlsDescription] objectForKey:NSStringFromClass([self class])];
    for (id key in [overrides keyEnumerator]) {
        id current = [_objectDescription objectForKey:key];
        id value = [overrides objectForKey:key];
        if (current != nil) {
            if ([key isEqualToString:@"localNodeData"]) {
                NSMutableDictionary *merged = [[current mutableCopy] autorelease];
                [merged addEntriesFromDictionary:value];
                value = merged;
            } else if ([key isEqualToString:[@"units" extraKeyForCollection]]) {
                NSMutableDictionary *units = [[current mutableCopy] autorelease];
                for (id unitKey in [value keyEnumerator]) {
                    id unit = [units objectForKey:unitKey];
                    id unitValue = [value objectForKey:unitKey];
                    if (unit != nil) {
                        NSMutableDictionary *merged = [[unit mutableCopy] autorelease];
                        [merged addEntriesFromDictionary:unitValue];
                        unitValue = merged;
                    }
                    [units setObject:unitValue forKey:unitKey];
                }
                value = units;
            }
        }
        [_objectDescription setObject:value forKey:key];
    }
    return _objectDescription;
}

- (id)nodeForRender
{
    if (_renderNode == nil) {
        _renderNode = [[HSNode nodeWithDictionary:[self objectDescription]] retain];
        [_renderNode setSupport:self];
        if (_renderNode != nil)
            [self initializeRenderNode:_renderNode];
        [self subscribeToNotifications];
    }
    return _renderNode;
}

- (id)nodeForPasteboard
{
    if (_nodeForPasteboard == nil) {
        _nodeForPasteboard = [[self nodeForRender] copy];
        [_nodeForPasteboard setSupport:self];
    }
    return _nodeForPasteboard;
}

- (void)unsubscribeFromNotifications
{
}

- (void)subscribeToNotifications
{
}

- (void)viewFrameChanged:(id)aChanged
{
    [self frameChanged:[self frame]];
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}

- (id)cardGroupController
{
    return nil;
}

- (id)delegate
{
    return _delegate;
}

- (id)scriptController
{
    return nil;
}

- (id)undoManager
{
    return nil;
}

// The node fills the view, without shadow.
- (void)initializeRenderNode:(id)aNode
{
    id applier = [[aNode queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier resizeFrameTo:[self bounds].size aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
    [applier moveFrameBoundingRectOriginTo:NSZeroPoint withLayoutGuidingContext:nil];
    [[aNode queryHyperInterface:@protocol(HSShadowAttributes)] setHyperShadowEnabled:NO];
}

- (id)toolTipString
{
    return nil;
}

// The node rendered at its size; the offset places it at its frame.
- (id)objectImage
{
    if (_objectImage != nil)
        return _objectImage;
    id geometry = [[self nodeForRender] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return nil;
    id renderer = [[_renderNode queryHyperInterface:[self visualizationProtocol]] queryRenderer];
    if (renderer == nil)
        return nil;
    NSRect bounds = [[renderer boundingRegion] boundingRect];
    CGAffineTransform transform = [geometry affineTransform];
    CGRect rect = CGRectIntegral(CGRectApplyAffineTransform(NSRectToCGRect(bounds), transform));
    NSRect frame = NSIntegralRect([geometry frameBoundingRect]);
    _renderOffset.x = rect.origin.x - frame.origin.x;
    _renderOffset.y = (frame.origin.y + frame.size.height) - (rect.origin.y + rect.size.height);
    _objectImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(rect.size)];
    if (_objectImage != nil) {
        // setFlipped: and lockFocus in the original.
        [_objectImage lockFocusFlipped:YES];
        transform.tx -= rect.origin.x;
        transform.ty -= rect.origin.y;
        CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], transform);
        [renderer drawRegion:[HSRegion regionWithRect:bounds] withDelegate:[HSGenericRenderDelegate delegateWithDrawable:nil]];
        [_objectImage unlockFocus];
    }
    return _objectImage;
}

- (id)objectClassName
{
    return nil;
}

- (void)frameChanged:(NSRect)aChanged
{
    [self initializeRenderNode:_renderNode];
    [_objectImage release];
    _objectImage = nil;
}

- (id)visualizationProtocol
{
    return @protocol(HSPlayerVisualization);
}

// With a focus ring when it's the key window's first responder.
- (void)drawQuartzRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    BOOL isFirstResponder = [[NSApp keyWindow] firstResponder] == self;
    if (isFirstResponder) {
        [NSGraphicsContext saveGraphicsState];
        [self setFocusRingType:NSFocusRingTypeExterior];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSSetFocusRingStyle(NSFocusRingBelow);
#pragma clang diagnostic pop
    }
    NSImage *image = [self objectImage];
    // compositeToPoint:operation: in the original.
    NSSize size = [image size];
    NSPoint point = NSMakePoint(bounds.origin.x + _renderOffset.x, bounds.origin.y + _renderOffset.y);
    if ([self isFlipped])
        point.y -= size.height;
    [image drawInRect:NSMakeRect(point.x, point.y, size.width, size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:nil];
    if (isFirstResponder)
        [NSGraphicsContext restoreGraphicsState];
}

- (BOOL)needsPanelToBecomeKey
{
    return NO;
}

- (BOOL)resignFirstResponder
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
    [center removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
    return YES;
}

// The focus ring follows the window being key.
- (BOOL)becomeFirstResponder
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:[self window]];
    [center addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:[self window]];
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    [[self window] makeKeyWindow];
    return YES;
}

- (id)view:(id)aView stringForToolTip:(NSInteger)aTip point:(NSPoint)aPoint userData:(void *)aData
{
    return [self toolTipString];
}

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    if ([aType isEqualToString:@"HSLibraryObjectsPasteboardType"])
        [aPasteboard setPropertyList:[NSArray arrayWithObject:[[self nodeForPasteboard] extraDictionaryRepresentation]] forType:@"HSLibraryObjectsPasteboardType"];
}

// Return and enter go to the delegate.
- (void)keyDown:(id)aDown
{
    unsigned short keyCode = [(NSEvent *)aDown keyCode];
    if ((keyCode == 0x24 || keyCode == 0x4c || keyCode == 0x34) && [_delegate respondsToSelector:@selector(keyDownWithEvent:inControlObjectView:)]) {
        ((void (*)(id, SEL, id, id))objc_msgSend)(_delegate, @selector(keyDownWithEvent:inControlObjectView:), aDown, self);
        return;
    }
    [super keyDown:aDown];
}

- (void)mouseDown:(id)aDown
{
    NSInteger clickCount = [(NSEvent *)aDown clickCount];
    if (clickCount == 2) {
        if ([_delegate respondsToSelector:@selector(doubleClickWithEvent:inControlObjectView:)])
            ((void (*)(id, SEL, id, id))objc_msgSend)(_delegate, @selector(doubleClickWithEvent:inControlObjectView:), aDown, self);
    } else if (clickCount == 1)
        [[self window] makeFirstResponder:self];
}

// Drags the object (half transparent) to the library objects pasteboard.
- (void)mouseDragged:(id)aDragged
{
    NSImage *objectImage = [self objectImage];
    if (objectImage == nil)
        return;
    NSImage *image = [[NSImage alloc] initWithSize:[objectImage size]];
    if ([image isValid]) {
        [image lockFocus];
        // dissolveToPoint:fraction: in the original.
        [objectImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:0.5];
        [image unlockFocus];
    }
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardNameDrag];
    [pasteboard declareTypes:[NSArray arrayWithObject:@"HSLibraryObjectsPasteboardType"] owner:self];
    CGFloat y = _renderOffset.y;
    if ([self isFlipped])
        y += [image size].height;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self dragImage:image at:NSMakePoint(_renderOffset.x, y) offset:NSZeroSize event:aDragged pasteboard:pasteboard source:self slideBack:YES];
#pragma clang diagnostic pop
    [image release];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeFromNotifications];
    [_renderNode setSupport:nil];
    [_renderNode release];
    [_nodeForPasteboard setSupport:nil];
    [_nodeForPasteboard release];
    [_objectDescription release];
    [_objectImage release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    if ((self = [super initWithFrame:aFrame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameChanged:) name:NSViewFrameDidChangeNotification object:self];
        [self addToolTipRect:[self bounds] owner:self userData:NULL];
    }
    return self;
}

@end
