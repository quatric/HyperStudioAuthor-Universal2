#import "HSBackgroundViewRenderer.h"
#import "HSAttributeNotificationCenter.h"

@implementation HSBackgroundViewRenderer

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

- (id)attributeObservingController
{
    return self;
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    [[HSAttributeNotificationCenter defaultCenter] notifyChange:aChange ofAttribute:aAttribute ofObject:self withUserInfo:aInfo];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"backgroundGraphics"];
}

- (NSRect)backgroundBounds
{
    if (_backgroundView != nil)
        return [_backgroundView bounds];
    return NSZeroRect;
}

- (id)undoManagerForGraphics:(id)aGraphics
{
    return nil;
}

- (void)hyperVisualAttributesChanged:(id)aChanged
{
    [_backgroundView setNeedsDisplay:YES];
}

- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    [self setBackgroundGraphics:aGraphics copyObject:aObject];
}

- (id)backgroundThumbnail
{
    return _backgroundThumbnail;
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
    if (_backgroundThumbnail != aThumbnail) {
        [_backgroundThumbnail autorelease];
        _backgroundThumbnail = [aThumbnail retain];
    }
}

- (id)backgroundGraphics
{
    return _backgroundGraphics;
}

- (void)_setBackgroundGraphics:(id)aGraphics
{
    if (_backgroundGraphics == aGraphics)
        return;
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics release];
    _backgroundGraphics = [aGraphics retain];
    [_backgroundGraphics setHyperOwner:self];
    [self setBackgroundThumbnail:nil];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)backgroundView
{
    return _backgroundView;
}

- (void)setBackgroundView:(id)aView
{
    // Not retained: the view owns its renderer.
    if (_backgroundView != aView)
        _backgroundView = aView;
}

- (void)dealloc
{
    [_backgroundThumbnail autorelease];
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics autorelease];
    [super dealloc];
}

- (id)initWithBackgroundView:(id)aView
{
    self = [super init];
    if (self != nil)
        _backgroundView = aView;
    return self;
}

- (id)init
{
    return [self initWithBackgroundView:nil];
}

@end
