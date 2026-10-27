#import "HSContentCellRenderLayer.h"
// Render layer drawing a button's content (icon and title) through an
// NSButtonCell in an offscreen cell view. The cell is centred in the
// object; system and invisible-shape backgrounds clip it to their
// content area. The cell is refreshed lazily when the icon or the
// title/highlight attributes change.

@implementation HSContentCellRenderLayer

- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aForce && !aCache)
        return YES;
    NSRect sourceRect = NSZeroRect;
    NSRect destinationRect = NSZeroRect;
    if (![self HSContentCellRenderLayer_prepareContentCellVisualizationViewToDrawRegion:aRegion sourceRect:&sourceRect destinationRect:&destinationRect])
        return NO;
    float scaleY = hypotf(aTransform.c, aTransform.d);
    float scaleX = hypotf(aTransform.a, aTransform.b);
    if (!aForce) {
        NSSize scale = [_contentCellVisualizationView hyperIntegralScaleFactorForScaleFactor:NSMakeSize(scaleX, scaleY)];
        float area = scale.width * destinationRect.size.width * destinationRect.size.height * scale.height;
        BOOL fits = area <= [[self class] maxBitmapCacheArea];
        if (!fits || !aCache)
            return fits;
    }

    id imageRep = nil;
    id cacheTransform = nil;
    [_contentCellVisualizationView hyperCacheInSize:NSMakeSize(destinationRect.size.width * scaleX, destinationRect.size.height * scaleY) fromRect:sourceRect flipped:YES withIntegralScaling:NO resultCacheImageRep:&imageRep resultCacheTransform:&cacheTransform];
    // The cache is drawn unrotated and unskewed at the destination rect.
    CGAffineTransform transform = CGAffineTransformMake(scaleX, 0, 0, scaleY,
                                                        aTransform.tx - destinationRect.origin.x * scaleX,
                                                        aTransform.ty - destinationRect.origin.y * scaleY);
    transform = CGAffineTransformConcat(transform, CGAffineTransformInvert([cacheTransform hyperCGAffineTransform]));
    id cache = [[[HSGenericImageRenderCache alloc] initWithImageRep:imageRep renderLayer:self affineTransform:transform temporaryValidness:aValidness persistentValidness:[self persistentValidnessForTemporaryValidness:aValidness region:aRegion] validnessEvaluator:aEvaluator] autorelease];
    *aCache = cache;
    if (aShare && cache)
        [self shareRenderCache:*aCache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return YES;
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness)
        *aValidness = 1.0;
    if (aEvaluator)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:NO rotation:NO offset:NO];
    if (aScaling)
        *aScaling = YES;
    if (aSkewing)
        *aSkewing = NO;
    if (aRotation)
        *aRotation = NO;
    if (aAligning)
        *aAligning = NO;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

- (id)calculateBoundingRegion
{
    if ([_buttonAttributes isHiddenInEditor])
        return [HSRegion region];
    return [HSRegion regionWithRect:[self HSContentCellRenderLayer_viewDestinationRectAndContentCellFrame:NULL]];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSTitleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectTitleVisibilityAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectIconAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButonObjectContentOverlapsBackgroundAtrribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectBackgroundStyleIdentifierAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute) forObject:object];
}

- (BOOL)isEmpty
{
    return [_buttonAttributes isHiddenInEditor];
}

// Draws the cell view unscaled by the context, at the scaled destination.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect sourceRect = NSZeroRect;
    NSRect destinationRect = NSZeroRect;
    if (![self HSContentCellRenderLayer_prepareContentCellVisualizationViewToDrawRegion:aRegion sourceRect:&sourceRect destinationRect:&destinationRect])
        return;
    NSAffineTransform *transform = [[NSGraphicsContext currentContext] currentHyperTransform];
    NSSize scale = [transform hyperRemoveScale];
    [transform set];
    NSRect rect = NSMakeRect(scale.width * destinationRect.origin.x, scale.height * destinationRect.origin.y,
                             destinationRect.size.width * scale.width, destinationRect.size.height * scale.height);
    [_contentCellVisualizationView hyperDrawInRect:rect fromRect:sourceRect flipped:YES withIntegralScaling:NO];
}

// Sizes the cell view for the visible part of the cell inside aRegion's
// bounds; returns the part in object space and in cell view space.
- (BOOL)HSContentCellRenderLayer_prepareContentCellVisualizationViewToDrawRegion:(id)aRegion sourceRect:(NSRect *)aRect destinationRect:(NSRect *)aRect2
{
    if ([_buttonAttributes isHiddenInEditor])
        return NO;
    NSRect cellFrame;
    NSRect destination = [self HSContentCellRenderLayer_viewDestinationRectAndContentCellFrame:&cellFrame];
    NSRect visible = NSIntersectionRect([aRegion boundingRect], destination);
    if (NSIsEmptyRect(visible))
        return NO;
    [_contentCellVisualizationView setCellFrame:cellFrame];
    [_contentCellVisualizationView setFrameSize:destination.size];
    if (aRect) {
        NSRect frame = [_contentCellVisualizationView frame];
        float scaleX = frame.size.width / destination.size.width;
        float scaleY = frame.size.height / destination.size.height;
        aRect->origin.x = (visible.origin.x - destination.origin.x) * scaleX + frame.origin.x;
        aRect->origin.y = (visible.origin.y - destination.origin.y) * scaleY + frame.origin.y;
        aRect->size.width = scaleX * visible.size.width;
        aRect->size.height = scaleY * visible.size.height;
    }
    if (aRect2)
        *aRect2 = visible;
    return YES;
}

// The cell view's rect in object space (origin floored) and the cell's
// frame inside the view. The cell is centred in the object; a system
// background clips it to its title area, an invisible shape to the
// object. (The original leaves the rect empty when the content overlaps
// a non-system background.)
- (NSRect)HSContentCellRenderLayer_viewDestinationRectAndContentCellFrame:(NSRect *)aFrame
{
    NSRect destination = NSZeroRect;
    [self HSContentCellRenderLayer_validateContentCell];
    NSRect bounds = [_geometryAttributes boundingRect];
    NSRect cellRect = NSMakeRect((bounds.size.width - _contentCellSize.width) * 0.5f,
                                 (bounds.size.height - _contentCellSize.height) * 0.5f,
                                 _contentCellSize.width, _contentCellSize.height);
    if (aFrame)
        *aFrame = (NSRect){NSZeroPoint, _contentCellSize};
    if ([[_buttonAttributes backgroundStyle] isEqual:@"HSButtonObjectSystemBackgroundStyle"]) {
        float extraSpace = 0;
        if ([[_systemStyleBackgroundAttributes systemButtonType] isEqualToString:@"HSTexturedBackgroundSystemButtonType"])
            extraSpace = [_systemStyleBackgroundAttributes additionalHorizontalTitleSpace];
        NSRect titleRect = bounds;
        titleRect.origin.x += extraSpace * 0.5f + 4;
        titleRect.origin.y += 1;
        titleRect.size.width -= extraSpace + 8;
        titleRect.size.height += -2;
        destination = NSIntersectionRect(cellRect, titleRect);
        if (aFrame) {
            aFrame->origin.x = cellRect.origin.x - destination.origin.x;
            aFrame->origin.y = cellRect.origin.y - destination.origin.y;
        }
    } else if (![_buttonAttributes contentOverlapsBackground]) {
        if ([[_shapeBackgroundAttributes shapeButtonType] isEqualToString:@"HSInvisibleShapeButtonType"]) {
            destination = NSIntersectionRect(cellRect, bounds);
            if (aFrame) {
                aFrame->origin.x = cellRect.origin.x - destination.origin.x;
                aFrame->origin.y = cellRect.origin.y - destination.origin.y;
            }
        } else {
            destination = cellRect;
        }
    }
    return NSMakeRect(floorf(destination.origin.x), floorf(destination.origin.y), destination.size.width, destination.size.height);
}

- (void)HSContentCellRenderLayer_validateContentCell
{
    NSButtonCell *cell = [_contentCellVisualizationView cell];
    BOOL changed = NO;
    if (!_areContentCellIconAttributesValid) {
        [cell setImage:[_buttonAttributes isIconVisible] ? [_buttonAttributes icon] : nil];
        [cell setImagePosition:[_buttonAttributes visualIconPosition]];
        _areContentCellIconAttributesValid = 1;
        changed = YES;
    }
    if (!_areContentCellTitleAndHighlightAttributesValid) {
        BOOL highlighted = ([_highlightingAttributes isHyperHighlightedInInteractiveMode] && [_buttonAttributes hasHighlight] && ![_cardObjectAttributes isDropOffOnly])
            || [[_highlightingAttributes queryHyperInterface:@protocol(HSSystemButtonSpecialAccessHighlightAttributes)] isSpecialAccessHighlightActive];
        [cell setHighlighted:highlighted];
        if ([_buttonAttributes isTitleVisible]) {
            NSMutableAttributedString *title = [[[_textAttributes hyperText] mutableCopy] autorelease];
            NSUInteger length = [title length];
            NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
            [style setAlignment:NSCenterTextAlignment];
            [title addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, length)];
            if (highlighted) {
                BOOL oldStyle = [_systemStyleBackgroundAttributes isKindOfClass:[HSButtonObjectSystemBackground class]]
                    && [_systemStyleBackgroundAttributes hasOldstyleButtonType];
                if (oldStyle || [[_buttonAttributes backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"]) {
                    NSColor *color = nil;
                    if (![_systemStyleBackgroundAttributes ignoreTintColor])
                        color = [_systemStyleBackgroundAttributes tintColor];
                    if (!color)
                        color = [NSColor whiteColor];
                    [title addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, length)];
                }
            }
            [cell setAttributedTitle:title];
        } else {
            [cell setTitle:nil];
        }
        _areContentCellTitleAndHighlightAttributesValid = 1;
        changed = YES;
    }
    if (changed)
        _contentCellSize = [cell cellSize];
}

- (void)HSContentCellRenderLayer_buttonTitleAndHighlightAttributeDidChange:(id)aChange
{
    _areContentCellTitleAndHighlightAttributesValid = 0;
}

- (void)HSContentCellRenderLayer_buttonIconAttributeDidChange:(id)aChange
{
    _areContentCellIconAttributesValid = 0;
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSTitleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectTitleVisibilityAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectIconAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectHighlightAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButonObjectContentOverlapsBackgroundAtrribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectBackgroundStyleIdentifierAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute) forObject:object];
}

- (void)dealloc
{
    id controller = [_buttonAttributes attributeObservingController];
    id iconAttributes[] = {@protocol(HSButtonObjectIconAttribute), @protocol(HSButtonObjectTitleVisibilityAttribute), nil};
    [controller removeObserver:self selector:@selector(HSContentCellRenderLayer_buttonIconAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributes:iconAttributes];
    id titleAttributes[] = {@protocol(HSTitleAttribute), @protocol(HSButtonObjectTitleVisibilityAttribute),
        @protocol(HSSystemButtonInteractiveHighlightAttribute), @protocol(HSSystemButtonSpecialAccessHighlightAttribute),
        @protocol(HSButtonObjectHighlightAttribute), @protocol(HSButtonObjectSystemButtonTypeAttribute),
        @protocol(HSButtonObjectBackgroundStyleAttribute), @protocol(HSButtonObjectShapeButtonTypeAttribute), nil};
    [controller removeObserver:self selector:@selector(HSContentCellRenderLayer_buttonTitleAndHighlightAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributes:titleAttributes];
    [_contentCellVisualizationView release];
    [_geometryAttributes release];
    [_buttonAttributes release];
    [_textAttributes release];
    [_highlightingAttributes release];
    [_cardObjectAttributes release];
    [_systemStyleBackgroundAttributes release];
    [_shapeBackgroundAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (!self)
        return nil;
    if (!(_geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain])
        || !(_buttonAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectAttributes)] retain])
        || !(_textAttributes = [[aObject queryHyperInterface:@protocol(HSTextAttributes)] retain])
        || !(_highlightingAttributes = [[aObject queryHyperInterface:@protocol(HSSystemButtonInteractiveModeAttributes)] retain])
        || !(_systemStyleBackgroundAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] retain])
        || !(_shapeBackgroundAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] retain])
        || !(_cardObjectAttributes = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] retain])) {
        [self release];
        return nil;
    }
    id controller = [_buttonAttributes attributeObservingController];
    id iconAttributes[] = {@protocol(HSButtonObjectIconAttribute), @protocol(HSButtonObjectTitleVisibilityAttribute), nil};
    [controller addObserver:self selector:@selector(HSContentCellRenderLayer_buttonIconAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributes:iconAttributes withPriority:0.25];
    id titleAttributes[] = {@protocol(HSTitleAttribute), @protocol(HSButtonObjectTitleVisibilityAttribute),
        @protocol(HSSystemButtonInteractiveHighlightAttribute), @protocol(HSSystemButtonSpecialAccessHighlightAttribute),
        @protocol(HSButtonObjectHighlightAttribute), @protocol(HSButtonObjectSystemButtonTypeAttribute),
        @protocol(HSButtonObjectBackgroundStyleAttribute), @protocol(HSButtonObjectShapeButtonTypeAttribute), nil};
    [controller addObserver:self selector:@selector(HSContentCellRenderLayer_buttonTitleAndHighlightAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributes:titleAttributes withPriority:0.25];
    NSButtonCell *cell = [[[HSContentCellRenderLayer_ButtonCell alloc] init] autorelease];
    if (cell) {
        [cell setBordered:NO];
        [cell setButtonType:NSMomentaryChangeButton];
        _contentCellVisualizationView = [[HSCellVisualizationView alloc] init];
        if (_contentCellVisualizationView) {
            [_contentCellVisualizationView setHyperFlipped:YES];
            [_contentCellVisualizationView setCell:cell];
        }
    }
    return self;
}

@end

@implementation HSContentCellRenderLayer_ButtonCell

// Draws the title with HyperStudio's layout manager, 8 points wider than
// the frame on each side.
- (NSRect)drawTitle:(id)aTitle withFrame:(NSRect)aFrame inView:(id)aView
{
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:aTitle];
    HSLayoutManager *layoutManager = nil;
    if (storage) {
        layoutManager = [[HSLayoutManager alloc] init];
        if (layoutManager) {
            [storage addLayoutManager:layoutManager];
            NSRect rect = NSInsetRect(aFrame, -8, 0);
            NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:rect.size];
            if (container) {
                [layoutManager addTextContainer:container];
                [container release];
                NSRange range = [layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [storage length]) actualCharacterRange:NULL];
                [layoutManager drawGlyphsForGlyphRange:range atPoint:rect.origin];
            }
        }
    }
    [layoutManager release];
    [storage release];
    return aFrame;
}

@end
