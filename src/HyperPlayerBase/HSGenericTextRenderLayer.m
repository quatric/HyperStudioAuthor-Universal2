#import "HSGenericTextRenderLayer.h"
// Render layer drawing a text object's Cocoa text storage. All text
// layers share one layout manager and text container, attached to the
// storage only while it is drawn.

static HSLayoutManager *HSGenericTextRenderLayerLayoutManager = nil;
static NSTextContainer *HSGenericTextRenderLayerTextContainer = nil;

@implementation HSGenericTextRenderLayer

+ (void)didFinishRenderingTextStorage
{
    id layoutManager = [self sharedRenderingLayoutManager];
    [[layoutManager textStorage] removeLayoutManager:layoutManager];
}

+ (void)prepareForRenderingTextStorage:(id)aStorage enclosedByRect:(NSRect)aRect layoutManager:(id *)aManager textContainer:(id *)aContainer
{
    id layoutManager = nil;
    id textContainer = nil;
    [self getSharedRenderingLayoutManager:&layoutManager textContainer:&textContainer];
    [textContainer setContainerSize:NSMakeSize(aRect.size.width, FLT_MAX)];
    [aStorage addLayoutManager:layoutManager];
    if (aManager)
        *aManager = layoutManager;
    if (aContainer)
        *aContainer = textContainer;
}

+ (id)sharedRenderingLayoutManager
{
    id layoutManager = nil;
    [self getSharedRenderingLayoutManager:&layoutManager textContainer:NULL];
    return layoutManager;
}

+ (void)getSharedRenderingLayoutManager:(id *)aManager textContainer:(id *)aContainer
{
    if (!HSGenericTextRenderLayerLayoutManager) {
        NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1000000, 1000000)] autorelease];
        [textContainer setWidthTracksTextView:NO];
        [textContainer setHeightTracksTextView:NO];
        HSGenericTextRenderLayerLayoutManager = [[HSLayoutManager alloc] init];
        [HSGenericTextRenderLayerLayoutManager addTextContainer:textContainer];
        HSGenericTextRenderLayerTextContainer = textContainer;
    }
    if (aManager)
        *aManager = HSGenericTextRenderLayerLayoutManager;
    if (aContainer)
        *aContainer = HSGenericTextRenderLayerTextContainer;
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness)
        *aValidness = 1.0;
    if (aEvaluator)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:YES rotation:YES offset:YES];
    if (aScaling)
        *aScaling = YES;
    if (aSkewing)
        *aSkewing = aIntent == NULL || aIntent->f2 != 1;
    if (aRotation)
        *aRotation = aIntent == NULL || aIntent->f1 != 3;
    if (aAligning)
        *aAligning = YES;
}

- (id)calculateBoundingRegion
{
    if ([[_cocoaTextStorageAccessing cocoaTextStorage] length])
        return [HSRegion regionWithRect:[_textLayoutAttributes maximumVisibleBoundsForText]];
    return [HSRegion region];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSTextAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTextLayoutAttribute) forObject:object];
}

- (BOOL)requiresTransparencyLayer
{
    return [[_cocoaTextStorageAccessing cocoaTextStorage] length] != 0;
}

- (BOOL)isEmpty
{
    return [[_cocoaTextStorageAccessing cocoaTextStorage] length] == 0;
}

- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    [self renderTextInRegion:aRegion enclosedByRect:[_textLayoutAttributes maximumVisibleBoundsForText]];
}

- (void)renderTextInRegion:(id)aRegion enclosedByRect:(NSRect)aRect
{
    NSTextStorage *storage = [_cocoaTextStorageAccessing cocoaTextStorage];
    if (![storage length])
        return;
    NSLayoutManager *layoutManager = nil;
    NSTextContainer *textContainer = nil;
    [[self class] prepareForRenderingTextStorage:storage enclosedByRect:aRect layoutManager:&layoutManager textContainer:&textContainer];
    NSRect textRect = NSZeroRect;
    NSRange glyphRange = NSMakeRange(0, 0);
    [self calculateLayoutInfoForTextContainer:textContainer enclosedByRect:aRect verticalAlignment:[_textLayoutAttributes textBlockVerticalAlignment] visibleTextRect:&textRect visibleGlyphRange:&glyphRange];
    if (glyphRange.length) {
        [NSBezierPath clipRect:textRect];
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textRect.origin];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textRect.origin];
    }
    [[self class] didFinishRenderingTextStorage];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSTextAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTextLayoutAttribute) forObject:object];
}

// Lays out line fragments until the text ends or a fragment runs below the
// enclosing rect. The visible rect is the union of the fragments (clipped
// to the rect on overflow), moved to the rect's origin; text that fits
// is aligned to the bottom (2) or the middle (1) of the rect.
- (void)calculateLayoutInfoForTextContainer:(id)aContainer enclosedByRect:(NSRect)aRect verticalAlignment:(NSInteger)aAlignment visibleTextRect:(NSRect *)aRect2 visibleGlyphRange:(NSRange *)aRange
{
    NSLayoutManager *layoutManager = [aContainer layoutManager];
    NSTextStorage *storage = [layoutManager textStorage];
    NSRect usedRect = NSZeroRect;
    NSRect bounds = {NSZeroPoint, aRect.size};
    NSUInteger glyphIndex = 0;
    NSUInteger glyphEnd;
    BOOL fits;
    for (;;) {
        NSRange range = NSMakeRange(0, 0);
        NSRect fragment = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&range];
        glyphEnd = NSMaxRange(range);
        usedRect = NSUnionRect(usedRect, fragment);
        glyphIndex = NSMaxRange(range);
        float fragmentMaxY = fragment.origin.y + fragment.size.height;
        float boundsMaxY = bounds.origin.y + bounds.size.height;
        float tolerance = MAX(fragmentMaxY != 0 ? fabsf(fragmentMaxY) : 1.0f, boundsMaxY != 0 ? fabsf(boundsMaxY) : 1.0f);
        if (fragmentMaxY > boundsMaxY + tolerance * 0.0005f) {
            usedRect = NSIntersectionRect(usedRect, bounds);
            fits = NO;
            break;
        }
        NSRange characterRange = [layoutManager characterRangeForGlyphRange:range actualGlyphRange:NULL];
        if (NSMaxRange(characterRange) >= [storage length]) {
            fits = fragmentMaxY < boundsMaxY + tolerance * -0.0005f;
            break;
        }
    }

    NSRect textRect = NSOffsetRect(usedRect, aRect.origin.x, aRect.origin.y);
    if (fits && aAlignment == 2)
        textRect.origin.y = (aRect.origin.y + aRect.size.height) - textRect.size.height;
    else if (fits && aAlignment == 1)
        // (The original leaves out textRect's own origin here, which only
        // matters when the enclosing rect is not at the origin.)
        textRect.origin.y += (aRect.origin.y + aRect.size.height * 0.5) - (textRect.origin.y + textRect.size.height * 0.5);
    if (aRect2)
        *aRect2 = textRect;
    if (aRange)
        *aRange = NSMakeRange(0, glyphEnd);
}

- (void)dealloc
{
    [_textLayoutAttributes release];
    [_textObjectAttributes release];
    [_cocoaTextStorageAccessing release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (!self)
        return nil;
    _textLayoutAttributes = [[aObject queryHyperInterface:@protocol(HSTextLayoutAttributes)] retain];
    if (_textLayoutAttributes)
        _cocoaTextStorageAccessing = [[aObject queryHyperInterface:@protocol(HSCocoaTextStorageAccessing)] retain];
    if (_cocoaTextStorageAccessing)
        _textObjectAttributes = [[aObject queryHyperInterface:@protocol(HSTextObjectAttributes)] retain];
    if (!_textObjectAttributes) {
        [self release];
        return nil;
    }
    return self;
}

@end
