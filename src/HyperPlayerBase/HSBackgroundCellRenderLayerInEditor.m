#import "HSBackgroundCellRenderLayerInEditor.h"

// Nine-part button images by type index: left/center/right top 0-2,
// center row 3-5, bottom row 6-8.
static NSString * const HSBackgroundCellImageParts[9] = {@"Left_Top", @"Center_Top", @"Right_Top", @"Left_Center", @"Center_Center", @"Right_Center", @"Left_Bottom", @"Center_Bottom", @"Right_Bottom"};

static NSMutableDictionary *HSBackgroundCellLoadImages(NSString *aPrefix)
{
    NSMutableDictionary *images = [NSMutableDictionary new];
    NSUInteger i;
    for (i = 0; i < 9; i++) {
        NSString *name = [aPrefix stringByAppendingString:HSBackgroundCellImageParts[i]];
        [images setValue:[HSPlayerBaseID imageNamed:name] forKey:name];
    }
    return images;
}

static void HSBackgroundCellApplyImages(id aView, NSDictionary *aImages, NSString *aPrefix)
{
    NSUInteger i;
    for (i = 0; i < 9; i++)
        [aView setImage:[aImages valueForKey:[aPrefix stringByAppendingString:HSBackgroundCellImageParts[i]]] forType:i];
}

// Releases the bitmap rep backing a data provider.
static void HSBackgroundCellReleaseBitmapRep(void *aInfo, const void *aData, size_t aSize)
{
    [(id)aInfo release];
}

// Draws a button's background: system-style buttons through a textured
// nine-part view (tinted buttons are drawn into a bitmap and colorized),
// old-style buttons and rectangle system buttons through a drawn view.
@implementation HSBackgroundCellRenderLayer
- (void)interactiveHighlightChanged:(id)aChanged
{
    _isBackgroundViewResourcesValid = NO;
}
- (void)systemButtonTypeChanged:(id)aChanged
{
    _isBackgroundViewResourcesValid = NO;
}
- (void)setUpResourcesForView:(id)aView forButtonType:(id)aType
{
    if ([aType isEqualToString:@"HSRegularSystemButtonType"])
        [self setupRegularSystemButtonResourcesForView:aView];
    else if ([aType isEqualToString:@"HSDefaultSystemButtonType"])
        [self setupDefaultSystemButtonResourcesForView:aView];
    else if ([aType isEqualToString:@"HSRectangleSystemButtonType"])
        [self setupRectangleSystemButtonResourcesForView:aView];
    else if ([aType isEqualToString:@"HSDropShadowRectangleSystemButtonType"])
        [self setupDropShadowSystemButtonResourcesForView:aView];
    else if ([aType isEqualToString:@"HSTexturedBackgroundSystemButtonType"])
        [self setupTexturedBackgroundSystemButtonResourcesForView:aView];
}
- (void)setupTexturedBackgroundSystemButtonResourcesForView:(id)aView
{
    id background = [_buttonAttributes queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    NSUInteger i;
    for (i = 0; i < 9; i++)
        [aView setImage:[background backgroundImagePartForType:i] forType:i];
    [aView setShouldTileMiddleParts:[background shouldTileMiddleBackgroundParts]];
}
- (void)setupDropShadowSystemButtonResourcesForView:(id)aView
{
    static NSMutableDictionary *sImages = nil;
    if (!sImages)
        sImages = HSBackgroundCellLoadImages(@"RB_");
    HSBackgroundCellApplyImages(aView, sImages, @"RB_");
}
- (void)setupRectangleSystemButtonResourcesForView:(id)aView
{
    static NSMutableDictionary *sImages = nil;
    if (!sImages)
        sImages = HSBackgroundCellLoadImages(@"SB_");
    HSBackgroundCellApplyImages(aView, sImages, @"SB_");
}
- (void)setupDefaultSystemButtonResourcesForView:(id)aView
{
    static NSMutableDictionary *sImages = nil;
    if (!sImages)
        sImages = HSBackgroundCellLoadImages(@"BB_");
    HSBackgroundCellApplyImages(aView, sImages, @"BB_");
}
- (void)setupRegularSystemButtonResourcesForView:(id)aView
{
    static NSMutableDictionary *sImages = nil;
    if (!sImages)
        sImages = HSBackgroundCellLoadImages(@"GB_");
    HSBackgroundCellApplyImages(aView, sImages, @"GB_");
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_geometryAttributes boundingRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}
// Draws unscaled into the current context; the view is laid out at the
// rounded-up object size and drawn into the scaled size.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSAffineTransform *transform = [[NSGraphicsContext currentContext] currentHyperTransform];
    NSSize scale = [transform hyperRemoveScale];
    [transform set];
    id specialAccess = [_buttonAttributes queryHyperInterface:@protocol(HSSystemButtonSpecialAccessHighlightAttributes)];
    id background = [_buttonAttributes queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    BOOL isSystemStyle = ![background isKindOfClass:[HSButtonObjectSystemBackground class]] || ![background hasOldstyleButtonType];
    NSString *type = [[[_buttonAttributes background] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] systemButtonType];
    id view = _oldStyleBackgroundView;
    if (isSystemStyle && ![type isEqual:@"HSRectangleSystemButtonType"])
        view = _backgroundView;
    NSSize size = [_geometryAttributes size];
    NSRect frame = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, ceilf((float)size.width), ceilf((float)size.height));
    NSRect drawRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, (float)size.width * (float)scale.width, (float)size.height * (float)scale.height);
    [view setFrame:frame];
    BOOL highlighted = ([_highlightingInterface isHyperHighlightedInInteractiveMode] && [_buttonAttributes hasHighlight] && ![_cardObjectAttributes isDropOffOnly]) || [specialAccess isSpecialAccessHighlightActive];
    NSControlTint controlTint = [NSColor currentControlTint];
    if (!isSystemStyle) {
        [_oldStyleBackgroundView setDrawsBorder:YES];
        [_oldStyleBackgroundView setDrawsFill:YES];
        [_oldStyleBackgroundView setBorderColor:[NSColor blackColor]];
        NSColor *tint = [NSColor whiteColor];
        if (![background ignoreTintColor])
            tint = [background tintColor];
        if (highlighted) {
            tint = [[_buttonAttributes queryHyperInterface:@protocol(HSTextAttributes)] textColor];
            if (!tint)
                tint = [NSColor blackColor];
        }
        [_oldStyleBackgroundView setTintColor:tint];
        if ([type isEqual:@"HSRectangleOldstyleButtonType"] || [type isEqual:@"HSDropShadowRectangleOldstyleButtonType"]) {
            [_oldStyleBackgroundView setBorderStyle:0];
            if ([type isEqual:@"HSDropShadowRectangleOldstyleButtonType"])
                [_oldStyleBackgroundView setRendersAsDefaultButton:YES];
        } else {
            [_oldStyleBackgroundView setCornerRadius:6.0];
            [_oldStyleBackgroundView setBorderThickness:1.5];
            if ([type isEqual:@"HSRoundedDefaultOldstyleButtonType"])
                [_oldStyleBackgroundView setRendersAsDefaultButton:YES];
        }
    } else if ([type isEqual:@"HSRectangleSystemButtonType"]) {
        // Highlighted: the control tint's selection color. The border is dark
        // gray, or the tint's own gray when that is darker.
        [_oldStyleBackgroundView setDrawsBorder:YES];
        [_oldStyleBackgroundView setDrawsFill:YES];
        NSColor *tint = nil;
        if (highlighted) {
            if (controlTint == NSBlueControlTint)
                tint = [NSColor colorWithCalibratedRed:0.45139f green:0.707755f blue:0.927602f alpha:1.0];
            else
                tint = [NSColor colorWithCalibratedRed:0.569f green:0.592f blue:0.624f alpha:1.0];
        } else {
            if (![background ignoreTintColor])
                tint = [background tintColor];
            if (!tint)
                tint = [NSColor whiteColor];
        }
        NSColor *border = [[NSColor darkGrayColor] colorWithAlphaComponent:[tint alphaComponent]];
        NSColor *tintGray = [tint colorUsingColorSpaceName:NSDeviceWhiteColorSpace];
        if (tintGray) {
            float tintWhite = (float)[tintGray whiteComponent];
            float borderWhite = (float)[border whiteComponent];
            float magnitude = fmaxf(tintWhite != 0 ? fabsf(tintWhite) : 1.0f, borderWhite != 0 ? fabsf(borderWhite) : 1.0f);
            if (borderWhite + magnitude * -0.0005f > tintWhite)
                border = [NSColor colorWithDeviceWhite:tintWhite alpha:[tint alphaComponent]];
        }
        [_oldStyleBackgroundView setBorderColor:border];
        [_oldStyleBackgroundView setTintColor:tint];
        [_oldStyleBackgroundView setBorderStyle:0];
    } else if (!_isBackgroundViewResourcesValid) {
        // Regular buttons use the drop shadow images and drop shadow buttons
        // the rectangle ones, as in the original.
        NSString *resourceType = type;
        if ([type isEqual:@"HSRegularSystemButtonType"])
            resourceType = @"HSDropShadowRectangleSystemButtonType";
        else if ([type isEqual:@"HSDropShadowRectangleSystemButtonType"])
            resourceType = @"HSRectangleSystemButtonType";
        [self setUpResourcesForView:_backgroundView forButtonType:resourceType];
        _isBackgroundViewResourcesValid = YES;
    }
    if (!isSystemStyle || [background ignoreTintColor] || [type isEqual:@"HSRectangleSystemButtonType"]) {
        [view hyperDrawInRect:drawRect fromRect:frame flipped:YES withIntegralScaling:YES];
        if (highlighted && [type isEqual:@"HSTexturedBackgroundSystemButtonType"]) {
            [[[NSColor blackColor] colorWithAlphaComponent:0.575f] set];
            NSRectFillUsingOperation(drawRect, NSCompositingOperationSourceAtop);
        }
        return;
    }
    // Tinted system button: render into a bitmap, map its grays onto the
    // tint, and draw the result.
    long pixelsWide = drawRect.size.width > 0 ? lroundf(ceilf((float)drawRect.size.width)) : 0;
    long pixelsHigh = drawRect.size.height > 0 ? lroundf(ceilf((float)drawRect.size.height)) : 0;
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:pixelsWide pixelsHigh:pixelsHigh bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:32];
    if (!bitmap)
        return;
    size_t length = [bitmap bytesPerRow] * pixelsHigh;
    memset([bitmap bitmapData], 0, length);
    NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    if (!bitmapContext)
        return;
    NSGraphicsContext *savedContext = [[[NSGraphicsContext currentContext] retain] autorelease];
    [NSGraphicsContext setCurrentContext:bitmapContext];
    [view hyperDrawInRect:drawRect fromRect:frame flipped:YES withIntegralScaling:YES];
    [NSGraphicsContext setCurrentContext:savedContext];
    NSColor *black = [NSColor blackColor];
    NSColor *white = [NSColor whiteColor];
    NSColor *color;
    float gray;
    if (highlighted) {
        if (controlTint == NSBlueControlTint) {
            color = [NSColor colorWithCalibratedRed:0.45139f green:0.707755f blue:0.927602f alpha:1.0];
            gray = 0.702055f;
        } else {
            color = [NSColor colorForControlTint:NSGraphiteControlTint];
            gray = 0.85f;
        }
    } else {
        color = [background tintColor];
        NSColor *colorGray = [color colorUsingColorSpaceName:NSDeviceWhiteColorSpace];
        if (!colorGray) {
            gray = 0.5f;
        } else {
            gray = (float)[colorGray whiteComponent];
            float magnitude = fmaxf(0.5f, gray != 0 ? fabsf(gray) : 1.0f);
            if (0.5f + magnitude * -0.0005f > gray)
                gray = 1.0f - gray;
            gray = gray * 0.6f + 0.2f;
        }
    }
    [bitmap colorizeByMappingGray:gray toColor:color blackMapping:black whiteMapping:white];
    CGColorSpaceRef colorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB) autorelease];
    if (colorSpace) {
        CGDataProviderRef provider = CGDataProviderCreateWithData(bitmap, [bitmap bitmapData], length, HSBackgroundCellReleaseBitmapRep);
        if (provider) {
            [bitmap retain];
            CGImageRef image = CGImageCreate(pixelsWide, pixelsHigh, [bitmap bitsPerSample], [bitmap bitsPerPixel], [bitmap bytesPerRow], colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast, provider, NULL, true, kCGRenderingIntentDefault);
            CGDataProviderRelease(provider);
            if (image) {
                CGContextDrawImage([savedContext graphicsPort], CGRectMake(0, 0, pixelsWide, pixelsHigh), image);
                CGImageRelease(image);
            }
        }
    }
    [bitmap release];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSButtonObjectSystemBackgroundAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectBackgroundStyleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute) forObject:object];
}
- (id)buttonAttributes
{
    return _buttonAttributes;
}
- (void)dealloc
{
    id controller = [_buttonAttributes attributeObservingController];
    [controller removeObserver:self selector:@selector(systemButtonTypeChanged:) ofChanges:2 ofAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute)];
    [controller removeObserver:self selector:@selector(interactiveHighlightChanged:) ofChanges:HSTemporaryDidAttributeChanges ofAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute)];
    [controller removeObserver:self selector:@selector(interactiveHighlightChanged:) ofChanges:2 ofAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute)];
    [_geometryAttributes release];
    [_buttonAttributes release];
    [_cardObjectAttributes release];
    [_backgroundView release];
    [_oldStyleBackgroundView release];
    [super dealloc];
}
// The highlighting interface is not retained.
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self) {
        _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
        _buttonAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectAttributes)] retain];
        _cardObjectAttributes = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] retain];
        _backgroundView = [[HSTexturedView alloc] init];
        [_backgroundView setScalesTexturesToFit:YES];
        _oldStyleBackgroundView = [[HSOldstyleButtonBackgroundView alloc] init];
        _highlightingInterface = [aObject queryHyperInterface:@protocol(HSSystemButtonInteractiveModeAttributes)];
        id controller = [_buttonAttributes attributeObservingController];
        [controller addObserver:self selector:@selector(systemButtonTypeChanged:) ofChanges:2 ofAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute) withPriority:0.25];
        [controller addObserver:self selector:@selector(interactiveHighlightChanged:) ofChanges:HSTemporaryDidAttributeChanges ofAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute) withPriority:0.25];
        [controller addObserver:self selector:@selector(interactiveHighlightChanged:) ofChanges:2 ofAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute) withPriority:0.25];
    }
    return self;
}
@end

// Draws nothing for buttons hidden in the editor.
@implementation HSBackgroundCellRenderLayerInEditor
- (id)calculateBoundingRegion
{
    if ([[self buttonAttributes] isHiddenInEditor])
        return [HSRegion region];
    return [super calculateBoundingRegion];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [super fillBoundingRegionAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) forObject:object];
}
- (BOOL)requiresTransparencyLayer
{
    if ([[self buttonAttributes] isHiddenInEditor])
        return NO;
    return [super requiresTransparencyLayer];
}
- (BOOL)isEmpty
{
    if ([[self buttonAttributes] isHiddenInEditor])
        return YES;
    return [super isEmpty];
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (![[self buttonAttributes] isHiddenInEditor])
        [super predrawRegion:aRegion withDelegate:aDelegate];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [super fillVisualizationAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) forObject:object];
}
@end
