#import "HSImageObject.h"
#import "HyperPlayerBaseData.h"
#import "HSGenericImageRenderLayer.h"

static BOOL HSImageObjectFloatsAreEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f;
    float mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}

// Maps paths in object coordinates into the unit square of the image rect.
static CGAffineTransform HSImageObjectObjectToImageTransform(NSRect aRelativeImageRect)
{
    CGFloat scaleX = aRelativeImageRect.size.width != 0.0 ? 1.0f / aRelativeImageRect.size.width : 1.0f;
    CGFloat scaleY = aRelativeImageRect.size.height != 0.0 ? 1.0f / aRelativeImageRect.size.height : 1.0f;
    return CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, 0.0 - aRelativeImageRect.origin.x * scaleX, 0.0 - aRelativeImageRect.origin.y * scaleY);
}

@implementation HSImageObject

+ (Class)nodeDataClass
{
    return [HSImageObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        @"HSGeometryNodeUnit", @"Geometry Unit",
        @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
        @"HSSizeNodeUnit", @"Size Unit",
        @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
        @"HSShowHideTransitionNodeUnit", @"Transition Unit",
        @"HSMutableClipPathsNodeUnit", @"Border Unit",
        @"HSTransparentColorNodeUnit", @"Transparent Color Unit",
        @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit", nil];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveGraphicObject alloc] initWithNode:self] autorelease];
}

// The original media wins over the cropped one; border paths come as path
// media.
- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *mediaUID = [[[[aRepresentation elementsForName:@"originalMediaRef"] extraFirstObject] attributeForName:HSXMLStoringRefIdString] stringValue];
    if (mediaUID == nil)
        mediaUID = [[[[aRepresentation elementsForName:@"mediaRef"] extraFirstObject] attributeForName:HSXMLStoringRefIdString] stringValue];
    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[HSUID UIDWithString:mediaUID]];
    if (media != nil)
        [self setMedia:media];
    id settings = [[aRepresentation elementsForName:@"imageSettings"] extraFirstObject];
    if (settings != nil) {
        for (id pathElement in [settings elementsForName:@"borderPath"]) {
            id UID = [HSUID UIDWithString:[[pathElement attributeForName:HSXMLStoringRefIdString] stringValue]];
            if (UID == nil)
                continue;
            NSData *data = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID] mediaData];
            if (data != nil) {
                NSBezierPath *path = [NSBezierPath hyperBezierPathWithBinaryStoredData:data];
                [[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] addObjectClipPath:(id)[path hyperCGPath]];
            }
        }
        [self setCanBeHighlighted:[[[settings attributeForName:@"canBeHighlighted"] stringValue] hyperBoolValue]];
        [self setBordered:[[[settings attributeForName:@"isBordered"] stringValue] hyperBoolValue]];
        if ([self isBordered]) {
            [self setBorderWidth:[[[settings attributeForName:@"borderWidth"] stringValue] floatValue]];
            NSArray *components = [[[settings attributeForName:@"borderColor"] stringValue] componentsSeparatedByString:@","];
            if ([components count] > 2) {
                float red = [[components objectAtIndex:0] floatValue];
                float green = [[components objectAtIndex:1] floatValue];
                float blue = [[components objectAtIndex:2] floatValue];
                float alpha = [components count] == 4 ? [[components objectAtIndex:3] floatValue] : 1.0f;
                [self setBorderColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
            }
        }
    }
    [pool release];
    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
}

// Clip paths are stored as one archived path array media, shared by all
// objects with the same paths.
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    id media = [self media];
    if (media == nil)
        return;
    NSXMLElement *mediaElement = [NSXMLElement elementWithName:@"originalMediaRef"];
    [mediaElement addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
    [aRepresentation addChild:mediaElement];
    NSArray *clipPaths = [[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] clipPaths];
    if ([clipPaths count] < 2)
        return;
    NSArray *pathsData = [NSBezierPath hyperBinaryDataArrayForStoringFromCGPaths:clipPaths];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:pathsData forKey:@"clipPaths"];
    [archiver finishEncoding];
    // The original leaked the archiver.
    [archiver release];
    id pathMedia = [aContext mediaForPathData:data];
    if (pathMedia == nil) {
        pathMedia = [HSNewMedia mediaWithData:data name:[[media mediaName] stringByAppendingString:@"pathArray"] type:@"pathArray"];
        if (pathMedia != nil)
            [aContext setPathMedia:pathMedia forData:data];
    }
    if (pathMedia != nil) {
        NSXMLElement *pathElement = [NSXMLElement elementWithName:@"pathArrayMediaRef"];
        [pathElement addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[pathMedia mediaUID] stringValue]]];
        [aRepresentation addChild:pathElement];
        [aContext addMedia:pathMedia];
    }
}

// The stored bounds are those of the visible image within the object.
- (NSRect)boundsForXMLStoring
{
    NSRect imageBounds = [[HSCurrentImageDrawing drawingForImageObject:self] imageBoundingRect];
    NSRect bounds = [super boundsForXMLStoring];
    return NSMakeRect(bounds.origin.x + imageBounds.origin.x, bounds.origin.y + imageBounds.origin.y, imageBounds.size.width, imageBounds.size.height);
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)shouldBeExportedAsImage
{
    return YES;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (void)imageTransparentAttributeDidChange:(id)aChange
{
    [self refreshCachedImageIncludingTransparentCache:YES];
}

// The bordered cache when enabled, otherwise the image without its
// transparent colour (made on first use).
- (id)cachedImage
{
    if (_isEnableCache)
        return _cachedImageWithAppliedBorderAndTransparentColor;
    if (_cachedImageWithAppliedTransparentColor == nil) {
        id transparentColor = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
        id color = [transparentColor transparentColor];
        double hue = [transparentColor hueTolerance];
        double chroma = [transparentColor chromaTolerance];
        double lightness = [transparentColor lightnessTolerance];
        _cachedImageWithAppliedTransparentColor = [HSGenericImageRenderLayerRemovingColorFromCelImage([[(HSImageObjectData *)[self nodeData] currentImage] hyperImage], color, hue, chroma, lightness) retain];
    }
    return _cachedImageWithAppliedTransparentColor;
}

// A new effect re-renders the effected image.
- (void)setHyperEffectName:(id)aName settings:(id)aSettings
{
    if (aName != nil && [(HSImageObjectData *)[self nodeData] effectName] != nil && ![aName isEqualTo:[(HSImageObjectData *)[self nodeData] effectName]]) {
        HSImageCropApplier *cropApplier = [[HSImageCropApplier alloc] initWithImageObject:self];
        [cropApplier updateEffectedImageObject];
        [cropApplier release];
    }
    [super setHyperEffectName:aName settings:aSettings];
}

- (void)effectAttributeDidChange:(id)aChange
{
    _canBeOptimized = YES;
}

- (void)sizeAttributeDidEndContinouslyChange:(id)aChange
{
    _needRefreshCacheIfSizeChanged = YES;
}

- (void)sizeAttributeWillBeginContinouslyChange:(id)aChange
{
    _needRefreshCacheIfSizeChanged = NO;
}

- (void)refreshCachedImageAfterResize
{
    [self refreshCachedImageIncludingTransparentCache:NO];
}

// Resizes are coalesced; the cache is rebuilt 0.05 s after the last one.
- (void)imageGeometryDidChange:(id)aChange
{
    _shouldResizeForNewImage = NO;
    _canBeOptimized = YES;
    if (_needRefreshCacheIfSizeChanged) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(refreshCachedImageAfterResize) withObject:nil afterDelay:0.05];
    }
}

- (void)didConnectToSupport
{
    [super didConnectToSupport];
    if (_shouldResizeForNewImage) {
        NSImage *image = [[(HSImageObjectData *)[self nodeData] currentImage] hyperImage];
        [[self undoManager] disableUndoRegistration];
        if (image != nil)
            [(id<HSMutableSizeAttributes>)[self queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:[image size]];
        [[self undoManager] enableUndoRegistration];
        _shouldResizeForNewImage = NO;
    }
    [self convertAdvanceReleaseFormatClipPathsIfNeeded];
}

// Modes against the card size: 1 fit, 2 fill, 3 and 4 shrink to fit only
// when larger; other modes resize to an empty size.
- (void)resizeWithMode:(NSInteger)aMode
{
    if (aMode == 0)
        return;
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil)
        return;
    NSSize frameSize = [[applier mutableGeometryAttributes] affineFrameSize];
    NSSize cardSize = [[self stack] hyperCardSize];
    float width = frameSize.width, height = frameSize.height;
    float cardWidth = cardSize.width, cardHeight = cardSize.height;
    NSSize size = NSZeroRect.size;
    BOOL fit = NO, fill = NO;
    if (aMode == 1)
        fit = YES;
    else if (aMode == 2)
        fill = YES;
    else if (aMode == 3 || aMode == 4) {
        if (width > cardWidth || height > cardHeight)
            fit = YES;
        else
            size = NSMakeSize(width, height);
    }
    if (fit || fill) {
        float ratio = width / height;
        float cardRatio = cardWidth / cardHeight;
        if (fit ? ratio > cardRatio : cardRatio > ratio)
            size = NSMakeSize(cardWidth, cardWidth / ratio);
        else
            size = NSMakeSize(ratio * cardHeight, cardHeight);
    }
    [applier resizeFrameTo:size aboutRelativePoint:NSMakePoint(0.5, 0.5) followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
}

- (BOOL)isEnabledCacheImage
{
    return _isEnableCache;
}

// An enabled cache borrows the image of another object sharing the node
// data whose cache is on, or renders its own.
- (void)setEnabledCacheImage:(BOOL)aImage
{
    if (_isEnableCache == aImage)
        return;
    if (!aImage) {
        [_cachedImageWithAppliedBorderAndTransparentColor release];
        _cachedImageWithAppliedBorderAndTransparentColor = nil;
        _isEnableCache = NO;
        return;
    }
    id sharer = nil;
    for (id object in [[(HSImageObjectData *)[self nodeData] owner] objectsWithNodeDataUID:[(HSImageObjectData *)[self nodeData] nodeDataUID]]) {
        if ([object isEnabledCacheImage]) {
            sharer = object;
            break;
        }
    }
    id image = [sharer image];
    if (image != nil)
        _cachedImageWithAppliedBorderAndTransparentColor = [image retain];
    else
        [self HSImageObject_createCachedImageWithBorderAndTransparentColor];
    _isEnableCache = _cachedImageWithAppliedBorderAndTransparentColor != nil;
}

- (void)setEnabledCacheImageForAllGroupObjects:(BOOL)aObjects setUpUndoManager:(BOOL)aManager
{
    if (_isEnableCache == aObjects)
        return;
    if (aManager)
        [[[self undoManager] prepareWithInvocationTarget:self] setEnabledCacheImageForAllGroupObjects:_isEnableCache setUpUndoManager:aManager];
    [self setEnabledCacheImage:aObjects];
    for (id object in [[(HSImageObjectData *)[self nodeData] owner] objectsWithNodeDataUID:[(HSImageObjectData *)[self nodeData] nodeDataUID]])
        [object setEnabledCacheImage:aObjects];
}

// With aOnly, only group objects shared by several objects are re-cached.
- (void)forceRecacheIfNeededForGroupObjectsOnly:(BOOL)aOnly
{
    BOOL skip = NO;
    if (aOnly) {
        skip = YES;
        if ([self isGroupObject] && [[[(HSImageObjectData *)[self nodeData] owner] objectsWithNodeDataUID:[(HSImageObjectData *)[self nodeData] nodeDataUID]] count] > 1)
            skip = NO;
    }
    if ([self isEnabledCacheImage] && !skip)
        [self refreshCachedImageIncludingTransparentCache:NO];
}

- (void)refreshCachedImageIncludingTransparentCache:(BOOL)aCache
{
    if (_isEnableCache) {
        [_cachedImageWithAppliedBorderAndTransparentColor release];
        _cachedImageWithAppliedBorderAndTransparentColor = nil;
        [self HSImageObject_createCachedImageWithBorderAndTransparentColor];
    }
    BOOL droppedTransparentCache = NO;
    if (aCache) {
        id cache = _cachedImageWithAppliedTransparentColor;
        [cache release];
        _cachedImageWithAppliedTransparentColor = nil;
        droppedTransparentCache = cache != nil;
    }
    if (droppedTransparentCache || _isEnableCache)
        [self notifyChange:2 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
}

// Slow caches (over 0.05 s) and new group objects are uncropped first.
// The image (without its transparent colour) drawn at the object size with
// the clip paths stroked as the border, shared with the other objects of the
// group.
- (void)HSImageObject_createCachedImageWithBorderAndTransparentColor
{
    float outlineWidth = [self hyperOutlineWidth];
    if (![self isHyperOutlineEnabled] || outlineWidth <= 0.0f)
        return;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSSize objectSize = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    float height = roundf(objectSize.height);
    float width = roundf(objectSize.width);
    _cachedImageWithAppliedBorderAndTransparentColor = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    NSImage *image = [[(HSImageObjectData *)[self nodeData] currentImage] hyperImage];
    NSSize imageSize = [[(HSImageObjectData *)[self nodeData] currentImage] hyperImageSize];
    id transparentColor = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
    id color = [transparentColor transparentColor];
    if ([transparentColor isTransparentColorEnabled] && color != nil)
        image = HSGenericImageRenderLayerRemovingColorFromCelImage(image, color, [transparentColor hueTolerance], [transparentColor chromaTolerance], [transparentColor lightnessTolerance]);
    [_cachedImageWithAppliedBorderAndTransparentColor lockFocus];
    id clipPaths = [self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)];
    CGAffineTransform transform = [clipPaths relativeToObjectAffineTransform];
    transform.a = roundf(transform.a);
    transform.d = roundf(transform.d);
    NSRect relativeRect = [self relativeImageRect];
    CGRect drawn = CGRectApplyAffineTransform(CGRectMake(relativeRect.origin.x, 1.0f - (float)CGRectGetMaxY(NSRectToCGRect(relativeRect)), relativeRect.size.width, relativeRect.size.height), transform);
    float x = roundf(drawn.origin.x);
    float drawWidth = roundf((x - (float)drawn.origin.x) + (float)drawn.size.width);
    float y = roundf(drawn.origin.y);
    float drawHeight = roundf((y - (float)drawn.origin.y) + (float)drawn.size.height);
    [image drawInRect:NSMakeRect(x, y, drawWidth, drawHeight) fromRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) operation:NSCompositingOperationCopy fraction:1.0];
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSaveGState(context);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextSetShouldAntialias(context, false);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetMiterLimit(context, 0.1f);
    NSAffineTransform *flip = [NSAffineTransform transform];
    [flip hyperPreflipYInRect:NSMakeRect(0.0, 0.0, width, height)];
    [flip concat];
    CGContextConcatCTM(context, transform);
    CGMutablePathRef unitPath = CGPathCreateMutable();
    if (unitPath == NULL) {
        CGContextRestoreGState(context);
        [_cachedImageWithAppliedBorderAndTransparentColor unlockFocus];
    } else {
        CGPathAddRect(unitPath, NULL, CGRectMake(0.0, 0.0, 1.0, 1.0));
        CGContextAddPath(context, unitPath);
        for (id path in [clipPaths clipPaths])
            CGContextAddPath(context, (CGPathRef)path);
        // The stroke is made in object space.
        CGContextConcatCTM(context, CGAffineTransformInvert(transform));
        CGContextSetLineWidth(context, outlineWidth + outlineWidth);
        [(NSColor *)[self borderColor] set];
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        [_cachedImageWithAppliedBorderAndTransparentColor unlockFocus];
        CGPathRelease(unitPath);
    }
    _isEnableCache = YES;
    _timeForRecache = CFAbsoluteTimeGetCurrent() - start;
    if ([self isGroupObject]) {
        // Turning the other caches off and on again makes them borrow this
        // image.
        NSArray *objects = [[(HSImageObjectData *)[self nodeData] owner] objectsWithNodeDataUID:[(HSImageObjectData *)[self nodeData] nodeDataUID]];
        for (id object in objects) {
            if (object != self)
                [object setEnabledCacheImage:NO];
        }
        for (id object in objects) {
            if (object != self)
                [object setEnabledCacheImage:YES];
        }
    }
}

// Outline attributes are the border attributes; a change toggles or
// rebuilds the shared caches.
- (void)setHyperOutlineColor:(id)aColor
{
    BOOL same = [[self borderColor] isEqual:aColor];
    [self setBorderColor:aColor];
    if ([self isBordered] && !same && [self borderWidth] > 0.0) {
        if (![self isEnabledCacheImage])
            [self setEnabledCacheImage:YES];
        else
            [self refreshCachedImageIncludingTransparentCache:NO];
    }
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    float oldWidth = [self borderWidth];
    [self setBorderWidth:aWidth];
    if (oldWidth == (float)aWidth)
        return;
    NSArray *objects = [[(HSImageObjectData *)[self nodeData] owner] objectsWithNodeDataUID:[(HSImageObjectData *)[self nodeData] nodeDataUID]];
    if (![self isBordered] || aWidth <= 0.0) {
        for (id object in objects)
            [object setEnabledCacheImage:NO];
    } else if (![self isEnabledCacheImage]) {
        for (id object in objects)
            [object setEnabledCacheImage:YES];
    } else
        [self refreshCachedImageIncludingTransparentCache:NO];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    BOOL notify = NO;
    if ([self isBordered] != aEnabled && [self borderWidth] != 0.0)
        notify = YES;
    [self setBordered:aEnabled];
    for (id object in [[(HSImageObjectData *)[self nodeData] owner] objectsWithNodeDataUID:[(HSImageObjectData *)[self nodeData] nodeDataUID]])
        [object setEnabledCacheImage:aEnabled];
    if (notify)
        [self notifyChange:2 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
}

- (id)hyperOutlineColor
{
    return [self borderColor];
}

- (CGFloat)hyperOutlineWidth
{
    return [self borderWidth];
}

- (BOOL)isHyperOutlineEnabled
{
    return [self isBordered];
}

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    if ((float)[(HSImageObjectData *)[self nodeData] opacity] == (float)aOpacity)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:[self hyperOpacity]];
    [self setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}

- (void)setOpacity:(CGFloat)aOpacity
{
    [(HSImageObjectData *)[self nodeData] setOpacity:aOpacity];
}

- (CGFloat)hyperOpacity
{
    return [self opacity];
}

- (CGFloat)opacity
{
    return [(HSImageObjectData *)[self nodeData] opacity];
}

- (id)ownedMediaUIDs
{
    id UIDs = [super ownedMediaUIDs];
    [UIDs unionSet:[[(HSImageObjectData *)[self nodeData] originalImage] ownedMediaUIDs]];
    [UIDs unionSet:[[(HSImageObjectData *)[self nodeData] effectedImage] ownedMediaUIDs]];
    id legacyUID = [[(HSImageObjectData *)[self nodeData] legacyCroppedImageMedia] mediaUID];
    if (legacyUID != nil)
        [UIDs addObject:legacyUID];
    return UIDs;
}

- (void)setCurrentClipPathsAreInitial:(BOOL)aInitial
{
    if (!aInitial)
        [self setupInitialClipPaths];
    [self setCanRestoreToInitialClipPaths:aInitial];
}

- (void)setCanRestoreToInitialClipPaths:(BOOL)aPaths
{
    if ([self canRestoreToInitialClipPaths] == aPaths)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setCanRestoreToInitialClipPaths:[self canRestoreToInitialClipPaths]];
    [(HSImageObjectData *)[self nodeData] setCanRestoreToInitialClipPaths:aPaths];
    _canBeOptimized = YES;
}

- (BOOL)canRestoreToInitialClipPaths
{
    return [(HSImageObjectData *)[self nodeData] canRestoreToInitialClipPaths];
}

- (void)dropInitialClipPaths
{
    [self setInitialClipPaths:nil];
}

- (void)setInitialClipPaths:(id)aPaths
{
    if ([self initialClipPaths] == aPaths)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setInitialClipPaths:[self initialClipPaths]];
    [self notifyChange:1 ofAttribute:@protocol(HSInitialClipPathsAttribute) withUserInfo:nil];
    [(HSImageObjectData *)[self nodeData] setInitialClipPaths:aPaths];
    [self notifyChange:2 ofAttribute:@protocol(HSInitialClipPathsAttribute) withUserInfo:nil];
}

- (id)initialClipPaths
{
    return [(HSImageObjectData *)[self nodeData] initialClipPaths];
}

- (void)setupInitialClipPaths
{
    NSArray *clipPaths = [[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] clipPaths];
    if ([clipPaths count] != 0)
        [self setInitialClipPaths:[self convetPathsFromObjectRelatedToImageRelatedCoordinates:clipPaths]];
}

- (void)setupBorderPathIfNeeded
{
    if ([[[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] clipPaths] count] == 0)
        [[HSImageCropApplier cropApplierForImageObject:self] updateCurrentBorderPath];
}

- (id)convetPathsFromObjectRelatedToImageRelatedCoordinates:(id)aCoordinates
{
    NSUInteger count = [aCoordinates count];
    if (count == 0)
        return nil;
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:count];
    CGAffineTransform transform = HSImageObjectObjectToImageTransform([self relativeImageRect]);
    for (id path in aCoordinates) {
        CGMutablePathRef converted = CGPathCreateMutable();
        CGPathAddPath(converted, &transform, (CGPathRef)path);
        [paths addObject:(id)converted];
        CGPathRelease(converted);
    }
    return paths;
}

- (void)setHyperEffectedMedia:(id)aMedia refreshName:(BOOL)aName
{
    [self setHyperEffectedMedia:aMedia refreshName:aName error:NULL];
}

- (void)setHyperEffectedMedia:(id)aMedia refreshName:(BOOL)aName error:(id *)aError
{
    id media = [[(HSImageObjectData *)[self nodeData] effectedImage] media];
    if ([media isEqual:aMedia])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Insert Image" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEffectedMedia:media refreshName:aName];
    [self notifyChange:1 ofAttribute:@protocol(HSEffectedMediaAttribute) withUserInfo:nil];
    [self setEffectedMedia:aMedia refreshName:aName];
    [self notifyChange:2 ofAttribute:@protocol(HSEffectedMediaAttribute) withUserInfo:nil];
}

- (void)setEffectedMedia:(id)aMedia refreshName:(BOOL)aName
{
    if ([[[(HSImageObjectData *)[self nodeData] effectedImage] media] isEqual:aMedia])
        return;
    [self refreshCachedImageIncludingTransparentCache:YES];
    [[(HSImageObjectData *)[self nodeData] effectedImage] setMedia:aMedia];
    if ([self hyperParent] != nil)
        [self resizeWithMode:4];
    [self refreshCachedImageIncludingTransparentCache:YES];
    if (aName)
        [self userObjectNameBaseTemplateDidChange];
}

- (id)hyperEffectedMedia
{
    return [[(HSImageObjectData *)[self nodeData] effectedImage] media];
}

- (void)HSImageObject_mediaDidChangeDataSource:(id)aSource
{
    [self HSImageObject_setMedia:[aSource object]];
}

- (void)setMedia:(id)aMedia error:(id *)aError
{
    [self setMedia:aMedia];
}

- (void)setMedia:(id)aMedia
{
    id media = [self media];
    if (media == aMedia || [media isEqual:aMedia])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Insert Image" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMedia:media];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (media != nil)
        [center removeObserver:self name:@"HSMediaDidChangeDataSourceNotification" object:media];
    [self HSImageObject_setMedia:aMedia];
    if (aMedia != nil)
        [center addObserver:self selector:@selector(HSImageObject_mediaDidChangeDataSource:) name:@"HSMediaDidChangeDataSourceNotification" object:aMedia];
}

// New media drops the effect and the crop, and resizes the object to the
// card when it is on one.
- (void)HSImageObject_setMedia:(id)aMedia
{
    HSImageCropApplier *cropApplier = [[HSImageCropApplier alloc] initWithImageObject:self];
    [cropApplier updateEffectedImageObject];
    [cropApplier updateCurrentBorderPath];
    [cropApplier release];
    [self setHyperEffectedMedia:nil refreshName:YES];
    [self notifyChange:1 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
    _canBeOptimized = YES;
    [[(HSImageObjectData *)[self nodeData] originalImage] setMedia:aMedia];
    [self refreshCachedImageIncludingTransparentCache:YES];
    if ([self hyperParent] != nil)
        [self resizeWithMode:4];
    [self userObjectNameBaseTemplateDidChange];
    if ([[(HSImageObjectData *)[self nodeData] originalImage] hyperImage] == nil)
        _shouldResizeForNewImage = YES;
    [self notifyChange:2 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
}

- (id)mediaUID
{
    return [[(HSImageObjectData *)[self nodeData] currentImage] imageUID];
}

- (id)media
{
    return [[(HSImageObjectData *)[self nodeData] currentImage] media];
}

- (void)setCanBeOptimized:(BOOL)aOptimized
{
    _canBeOptimized = aOptimized;
}

- (BOOL)canBeOptimized
{
    return _canBeOptimized;
}

- (void)setHyperImageObject:(id)aObject
{
    if ([(HSImageObjectData *)[self nodeData] originalImage] == aObject)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Insert Image" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperImageObject:[self hyperImageObject]];
    [self notifyChange:1 ofAttribute:@protocol(HSImageObjectAttribute) withUserInfo:nil];
    [self setImageObject:aObject];
    [self notifyChange:2 ofAttribute:@protocol(HSImageObjectAttribute) withUserInfo:nil];
}

- (void)setImageObject:(id)aObject
{
    if ([(HSImageObjectData *)[self nodeData] originalImage] == aObject)
        return;
    if ([self isInDocument])
        [[(HSImageObjectData *)[self nodeData] originalImage] willRemoveFromDocument];
    [(HSImageObjectData *)[self nodeData] setOriginalImage:aObject];
    [self refreshCachedImageIncludingTransparentCache:YES];
    if ([self isInDocument])
        [[(HSImageObjectData *)[self nodeData] originalImage] didAddToDocument];
}

- (id)hyperImageObject
{
    return [(HSImageObjectData *)[self nodeData] currentImage];
}

- (BOOL)isImageComposite
{
    return NO;
}

- (void)setImageRect:(NSRect)aRect
{
    [self setImageRect:aRect updateClipPaths:YES];
}

- (void)setImageRect:(NSRect)aRect updateClipPaths:(BOOL)aPaths
{
    if (NSEqualRects(aRect, [self imageRect]))
        return;
    CGAffineTransform transform = [[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] relativeToObjectAffineTransform];
    CGRect relativeRect = CGRectApplyAffineTransform(NSRectToCGRect(aRect), CGAffineTransformInvert(transform));
    [self setRelativeImageRect:NSRectFromCGRect(relativeRect) updateClipPaths:aPaths];
}

- (void)setRelativeImageRect:(NSRect)aRect
{
    [self setRelativeImageRect:aRect updateClipPaths:YES];
}

// The clip paths follow the image rect.
- (void)setRelativeImageRect:(NSRect)aRect updateClipPaths:(BOOL)aPaths
{
    NSRect oldRect = [self relativeImageRect];
    if (NSEqualRects(aRect, oldRect))
        return;
    [self setRelativeImageRectWithoutClipPathsUpdate:aRect];
    if (!aPaths)
        return;
    id clipPaths = [self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)];
    CGFloat scaleX = oldRect.size.width != 0.0 ? aRect.size.width / oldRect.size.width : 1.0;
    CGFloat scaleY = oldRect.size.height != 0.0 ? aRect.size.height / oldRect.size.height : 1.0;
    [clipPaths applyPathsAffineTransform:CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, aRect.origin.x - oldRect.origin.x * scaleX, aRect.origin.y - oldRect.origin.y * scaleY)];
}

- (void)setRelativeImageRectWithoutClipPathsUpdate:(NSRect)aUpdate
{
    NSRect oldRect = [self relativeImageRect];
    if (NSEqualRects(aUpdate, oldRect))
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setRelativeImageRectWithoutClipPathsUpdate:oldRect];
    [self notifyChange:1 ofAttribute:@protocol(HSRelativeImageRectAttribute) withUserInfo:nil];
    [(HSImageObjectData *)[self nodeData] setRelativeImageRect:aUpdate];
    [self notifyChange:2 ofAttribute:@protocol(HSRelativeImageRectAttribute) withUserInfo:nil];
    _canBeOptimized = YES;
}

// The cached image already covers the whole object.
- (NSRect)imageRect
{
    NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    if (_isEnableCache)
        return NSMakeRect(0.0, 0.0, size.width, size.height);
    return NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect([self relativeImageRect]), CGAffineTransformMakeScale(size.width, size.height)));
}

- (NSRect)relativeImageRect
{
    return [(HSImageObjectData *)[self nodeData] relativeImageRect];
}

- (id)image
{
    if (_isEnableCache)
        return _cachedImageWithAppliedBorderAndTransparentColor;
    return [[(HSImageObjectData *)[self nodeData] currentImage] hyperImage];
}

- (id)mediaUIDsForOptimization
{
    return [NSSet setWithObject:[[self media] mediaUID]];
}

- (void)setShouldUseCurrentMediaAsLegacyCroppedImageMedia:(BOOL)aMedia
{
    [(HSImageObjectData *)[self nodeData] setLegacyCroppedImageMedia:aMedia ? [self media] : nil];
}

- (void)setEnabledCacheImageNumber:(id)aNumber
{
    [self setEnabledCacheImage:[aNumber boolValue]];
}

// Bordered images get their cache a second after loading.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self convertOldFormatBorderPathIfNeeded];
    [self dropOldFormatBorderPath];
    if ([self isBordered] && [self borderWidth] > 0.0)
        [self performSelector:@selector(setEnabledCacheImageNumber:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0];
}

// The old format border path is stored alongside for older readers.
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    [self createOldFormatRelativeBorderPath];
    id representation = [super extraDictionaryRepresentationWithCodingContext:aContext];
    [self dropOldFormatBorderPath];
    return representation;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"sizeAsString"];
    [keys addObject:@"image"];
    [keys addObject:@"opacity"];
    [keys addObject:@"bordered"];
    [keys addObject:@"borderColor"];
    [keys addObject:@"borderWidth"];
    [keys addObject:@"borderPath"];
    return keys;
}

- (void)createOldFormatRelativeBorderPath
{
    NSBezierPath *path = [NSBezierPath hyperBezierPathWithCGPath:(CGMutablePathRef)[[HSImageCropApplier cropApplierForImageObject:self] calculateBorderPath]];
    [path transformUsingAffineTransform:[NSAffineTransform hyperYFlipWithHeight:1.0]];
    [(HSImageObjectData *)[self nodeData] setRelativeBorderPath:path];
}

- (void)dropOldFormatBorderPath
{
    [[self nodeData] setBorderPath:nil];
    [[self nodeData] setRelativeBorderPath:nil];
}

// An old format border path becomes a clip path once the border unit has
// none.
- (void)convertOldFormatBorderPathIfNeeded
{
    if ([[[self unitForRole:@"Border Unit"] allPaths] count] != 0)
        return;
    id nodeData = [self nodeData];
    NSBezierPath *borderPath = [nodeData borderPath];
    if (borderPath != nil && ![borderPath isEmpty]) {
        CGPathRef path = CGPathRetain([borderPath hyperCGPath]);
        if ([nodeData owner] == self)
            [nodeData setBorderPath:nil];
        [[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] addObjectClipPath:(id)path];
        CGPathRelease(path);
        return;
    }
    NSBezierPath *relativePath = [(HSImageObjectData *)[self nodeData] relativeBorderPath];
    if (relativePath == nil || [relativePath isEmpty])
        return;
    CGPathRef path = CGPathRetain([relativePath hyperCGPath]);
    if ([nodeData owner] == self)
        [nodeData setRelativeBorderPath:nil];
    [[self queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] addRelativeClipPath:(id)path];
    CGPathRelease(path);
}

// Earlier releases kept the initial clip paths in the border unit, in object
// coordinates.
- (void)convertAdvanceReleaseFormatClipPathsIfNeeded
{
    [[self undoManager] disableUndoRegistration];
    id unit = [self unitForRole:@"Border Unit"];
    if ([self initialClipPaths] == nil) {
        NSArray *unitPaths = [unit initialClipPaths];
        NSUInteger count = [unitPaths count];
        if (count != 0) {
            NSMutableArray *paths = [NSMutableArray arrayWithCapacity:count];
            CGAffineTransform transform = HSImageObjectObjectToImageTransform([self relativeImageRect]);
            for (id unitPath in unitPaths) {
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddPath(path, &transform, (CGPathRef)unitPath);
                [paths addObject:(id)path];
                CGPathRelease(path);
            }
            [self setInitialClipPaths:paths];
        }
    }
    [[self undoManager] enableUndoRegistration];
}

- (id)undoManagerForGraphics:(id)aGraphics
{
    return [self undoManager];
}

- (void)hyperVisualAttributesChanged:(id)aChanged
{
    if ([self hyperName] == nil)
        [self userObjectNameBaseTemplateDidChange];
    [self notifyChange:2 ofAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSMediaAttribute), @protocol(HSOpacityAttribute), nil] withUserInfo:nil];
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
}

- (BOOL)canMoveVertically
{
    return YES;
}

- (BOOL)canMoveHorizontally
{
    return YES;
}

- (BOOL)canRotate
{
    return YES;
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return YES;
}

- (BOOL)canFlipHorizontally
{
    return YES;
}

- (BOOL)canScaleVertically
{
    return YES;
}

- (BOOL)canScaleHorizontally
{
    return YES;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
}

- (BOOL)canResizeVertically
{
    return YES;
}

- (BOOL)canResizeHorizontally
{
    return YES;
}

- (BOOL)canBreakSizeAspectRatio
{
    return YES;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return YES;
}

- (NSSize)defaultSize
{
    NSImage *image = [[(HSImageObjectData *)[self nodeData] originalImage] hyperImage];
    if (image == nil)
        return NSMakeSize(320.0, 240.0);
    return [image size];
}

- (id)queryImageObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryEditorHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorHitTestingVisualization)] autorelease];
}

- (id)queryInteractiveHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSPlayerHitTestingVisualization)] autorelease];
}

- (id)queryDefaultHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self] autorelease];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    Class visualizationClass = Nil;
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        visualizationClass = [HSImageObjectVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface))
        visualizationClass = [HSImageObjectPlayerVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface))
        visualizationClass = [HSHitTestingImageObjectVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSImageObjectCropVisualization), aInterface))
        visualizationClass = [HSImageObjectCropVisualization class];
    else
        return [super queryNewHyperInterface:aInterface];
    return [[[visualizationClass alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
}

- (id)nameBaseTemplates
{
    if ([(HSImageObjectData *)[self nodeData] currentImage] == nil)
        return nil;
    return [NSArray arrayWithObjects:[[self media] mediaName], nil];
}

// BMP, SGI, ICO and CUR are converted on import.
- (BOOL)canCreateImageFromMedia:(id)aMedia
{
    if (aMedia == nil)
        return NO;
    NSString *type = [aMedia mediaType];
    if (type == nil)
        return NO;
    if ([type isEqualToString:@"'BMP '"] || [type isEqualToString:@"'SGI '"] || [type isEqualToString:@"'ICO '"] || [type isEqualToString:@"'CUR '"])
        return YES;
    return [[NSImage imageFileTypes] containsObject:type];
}

- (void)setHighlightedInInteractiveMode:(BOOL)aMode
{
    if ((BOOL)_isHighlightedInInteractiveMode == aMode)
        return;
    [self notifyChange:aMode ? 4 : 0x10 ofAttribute:@protocol(HSInteractiveHighlightAttribute) withUserInfo:nil];
    _isHighlightedInInteractiveMode = aMode ? 1 : 0;
    [self notifyChange:aMode ? 8 : 0x20 ofAttribute:@protocol(HSInteractiveHighlightAttribute) withUserInfo:nil];
}

- (BOOL)isHighlightedInInteractiveMode
{
    return _isHighlightedInInteractiveMode != 0;
}

- (void)setCanBeHighlighted:(BOOL)aHighlighted
{
    if ([(HSImageObjectData *)[self nodeData] canBeHighlighted] == aHighlighted)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Toggle Image Highlight" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setCanBeHighlighted:[self canBeHighlighted]];
    [self notifyChange:1 ofAttribute:@protocol(HSHighlightSupportAttribute) withUserInfo:nil];
    [(HSImageObjectData *)[self nodeData] setCanBeHighlighted:aHighlighted];
    [self notifyChange:2 ofAttribute:@protocol(HSHighlightSupportAttribute) withUserInfo:nil];
}

- (BOOL)canBeHighlighted
{
    return [(HSImageObjectData *)[self nodeData] canBeHighlighted];
}

// Undo goes through the outline setters so the caches follow.
- (void)setBorderWidth:(CGFloat)aWidth
{
    if ((float)[(HSImageObjectData *)[self nodeData] borderWidth] == (float)aWidth)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Image Border Width" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineWidth:[(HSImageObjectData *)[self nodeData] borderWidth]];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderWidthAttribute) withUserInfo:nil];
    [(HSImageObjectData *)[self nodeData] setBorderWidth:aWidth];
    [self notifyChange:2 ofAttribute:@protocol(HSBorderWidthAttribute) withUserInfo:nil];
}

- (CGFloat)borderWidth
{
    return [(HSImageObjectData *)[self nodeData] borderWidth];
}

- (void)setBorderColor:(id)aColor
{
    if ([[(HSImageObjectData *)[self nodeData] borderColor] isEqual:aColor])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Image Border Color" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineColor:[(HSImageObjectData *)[self nodeData] borderColor]];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderColorAttribute) withUserInfo:nil];
    [(HSImageObjectData *)[self nodeData] setBorderColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSBorderColorAttribute) withUserInfo:nil];
}

- (id)borderColor
{
    return [(HSImageObjectData *)[self nodeData] borderColor];
}

- (void)setIsBorderless:(BOOL)aBorderless
{
    [self setBordered:!aBorderless];
}

- (BOOL)isBorderless
{
    return ![self isBordered];
}

- (void)setBordered:(BOOL)aBordered
{
    if ([(HSImageObjectData *)[self nodeData] isBordered] == aBordered)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Image Bordered" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineEnabled:[(HSImageObjectData *)[self nodeData] isBordered]];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderlessAttribute) withUserInfo:nil];
    if (aBordered)
        [self setupBorderPathIfNeeded];
    [(HSImageObjectData *)[self nodeData] setBordered:aBordered];
    [self notifyChange:2 ofAttribute:@protocol(HSBorderlessAttribute) withUserInfo:nil];
}

- (BOOL)isBordered
{
    return [(HSImageObjectData *)[self nodeData] isBordered];
}

// Image objects of the same class are equal with the same image rect, image
// object, media, effected media, border and initial clip paths.
- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    BOOL equal = [super isHyperEqual:aEqual] && NSEqualRects([aEqual relativeImageRect], [self relativeImageRect]);
    if ([self hyperImageObject] != nil || [aEqual hyperImageObject] != nil)
        equal = equal && [[self hyperImageObject] isEqual:[aEqual hyperImageObject]];
    if ([[self media] mediaUID] != nil || [[aEqual media] mediaUID] != nil)
        equal = equal && [[[self media] mediaUID] isEqual:[[aEqual media] mediaUID]];
    if ([[self hyperEffectedMedia] mediaUID] != nil || [[aEqual hyperEffectedMedia] mediaUID] != nil)
        equal = equal && [[[self hyperEffectedMedia] mediaUID] isEqual:[[aEqual hyperEffectedMedia] mediaUID]];
    equal = equal && [self isBorderless] == [aEqual isBorderless];
    if (![self isBorderless] && ![aEqual isBorderless])
        equal = equal && [[self borderColor] isEqual:[(HSImageObject *)aEqual borderColor]] && HSImageObjectFloatsAreEqual([self borderWidth], [(HSImageObject *)aEqual borderWidth]);
    if ([self initialClipPaths] != nil || [aEqual initialClipPaths] != nil)
        equal = equal && [[self initialClipPaths] isEqualToArray:[aEqual initialClipPaths]];
    return equal;
}

// The last owner drops its observers before the object goes away.
- (oneway void)release
{
    if ([self retainCount] == 1) {
        id media = [self media];
        if (media != nil)
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSMediaDidChangeDataSourceNotification" object:media];
        [self removeObserver:self selector:@selector(imageGeometryDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSizeAttributes)];
        [super removeObserver:self selector:@selector(imageTransparentAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSTransparentColorAttributes)];
        [super removeObserver:self selector:@selector(effectAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSEffectAttributes)];
        [super removeObserver:self selector:@selector(sizeAttributeWillBeginContinouslyChange:) ofChanges:0x40 ofAttributesOfHyperInterface:@protocol(HSSizeAttributes)];
        [super removeObserver:self selector:@selector(sizeAttributeDidEndContinouslyChange:) ofChanges:0x80 ofAttributesOfHyperInterface:@protocol(HSSizeAttributes)];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    [super release];
}

- (void)dealloc
{
    [_cachedImageWithAppliedTransparentColor release];
    [_cachedImageWithAppliedBorderAndTransparentColor release];
    [super dealloc];
}

- (id)initWithMedia:(id)aMedia
{
    return [self initWithMedia:aMedia error:NULL];
}

// Media without an image fails with a file error.
- (id)initWithMedia:(id)aMedia error:(id *)aError
{
    self = [self init];
    if (self == nil || aMedia == nil || ![self canCreateImageFromMedia:aMedia]) {
        [self release];
        return nil;
    }
    id currentImage = [(HSImageObjectData *)[self nodeData] currentImage];
    [currentImage setMedia:aMedia];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSImageObject_mediaDidChangeDataSource:) name:@"HSMediaDidChangeDataSourceNotification" object:aMedia];
    NSImage *image = [currentImage hyperImage];
    if (image == nil) {
        if (aError != NULL)
            *aError = [HSError fileErrorWithHSCode:0x103 filePath:[aMedia fullPathToMediaFile]];
        [self release];
        return nil;
    }
    [(id<HSMutableSizeAttributes>)[self queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:[image size]];
    if ([self hyperParent] != nil)
        [self resizeWithMode:4];
    [self userObjectNameBaseTemplateDidChange];
    return self;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    [super linkAttribute:@protocol(HSOutlineAvailabilityAttribute) toAttribute:@protocol(HSBorderlessAttribute)];
    [super linkAttribute:@protocol(HSOutlineWidthAttribute) toAttribute:@protocol(HSBorderWidthAttribute)];
    [super linkAttribute:@protocol(HSOutlineColorAttribute) toAttribute:@protocol(HSBorderColorAttribute)];
    [super linkAttribute:@protocol(HSImageAttribute) toAttribute:@protocol(HSMediaAttribute)];
    [super linkAttribute:@protocol(HSImageRectAttribute) toAttribute:@protocol(HSSizeAttribute)];
    [super linkAttribute:@protocol(HSMediaAttribute) toAttribute:@protocol(HSEffectedMediaAttribute)];
    [super addObserver:self selector:@selector(imageGeometryDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSizeAttributes) withPriority:0.75f];
    [super addObserver:self selector:@selector(imageTransparentAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSTransparentColorAttributes) withPriority:0.75f];
    [super addObserver:self selector:@selector(effectAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSEffectAttributes) withPriority:0.75f];
    [super addObserver:self selector:@selector(sizeAttributeWillBeginContinouslyChange:) ofChanges:0x40 ofAttributesOfHyperInterface:@protocol(HSSizeAttributes) withPriority:0.75f];
    [super addObserver:self selector:@selector(sizeAttributeDidEndContinouslyChange:) ofChanges:0x80 ofAttributesOfHyperInterface:@protocol(HSSizeAttributes) withPriority:0.75f];
    _needRefreshCacheIfSizeChanged = YES;
    _canBeOptimized = YES;
    return self;
}

- (id)nodeData
{
    return [super nodeData];
}

@end
