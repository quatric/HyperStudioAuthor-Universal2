#import "HSButtonObjectData.h"
#import "EXCodingContext.h"
#import "HSButtonObjectBackground.h"
#import "HSButtonObjectSystemBackground.h"
#import "HSButtonObjectShapeBackground.h"

static BOOL HSButtonObjectDataFloatsAreEqual(float aValue1, float aValue2)
{
    float scale1 = aValue1 != 0.0f ? fabsf(aValue1) : 1.0f;
    float scale2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue1 - aValue2) <= MAX(scale1, scale2) * 0.0005f;
}

static BOOL HSButtonObjectDataSizesAreEqual(NSSize aSize1, NSSize aSize2)
{
    return HSButtonObjectDataFloatsAreEqual(aSize1.width, aSize2.width) && HSButtonObjectDataFloatsAreEqual(aSize1.height, aSize2.height);
}

// A button object's data. The size is the background's, taken from the
// background of the current style (system or shape). Highlight and title
// visibility are kept as flags per button type: bit 0 highlight, bit 1
// title, and set for all types at once.
@implementation HSButtonObjectData

+ (id)nodeDataKeysToNodeKeysMap
{
    NSMutableDictionary *map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"titleColor" forKey:[@"titleColor" extraKeyForMultiRepresentations]];
    [map setObject:@"backgroundStyleToBackroundDictionary" forKey:[@"backgroundStyleToBackroundDictionary" extraKeyForCollection]];
    return map;
}

+ (id)allButtonTypes
{
    return [NSArray arrayWithObjects:@"HSRegularSystemButtonType", @"HSDefaultSystemButtonType", @"HSRectangleSystemButtonType",
            @"HSDropShadowRectangleSystemButtonType", @"HSTexturedBackgroundSystemButtonType", @"HSInvisibleShapeButtonType",
            @"HSFreehandAreaShapeButtonType", @"HSExpandingAreaShapeButtonType", @"HSLassoAreaShapeButtonType",
            @"HSRoundedOldstyleButtonType", @"HSRoundedDefaultOldstyleButtonType", @"HSRectangleOldstyleButtonType",
            @"HSDropShadowRectangleOldstyleButtonType", nil];
}

- (NSUInteger)buttonFlagsMaskForButtonType:(id)aType
{
    return [[[self buttonTypeToButtonFlagsMaskDictionary] objectForKey:aType] unsignedIntValue];
}

- (id)buttonTypeToButtonFlagsMaskDictionary
{
    if (!_buttonTypeToButtonFlagsMaskDictionary) {
        _buttonTypeToButtonFlagsMaskDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  [NSNumber numberWithUnsignedInt:0], @"HSRegularSystemButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSDefaultSystemButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSRectangleSystemButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSDropShadowRectangleSystemButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSTexturedBackgroundSystemButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSInvisibleShapeButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSFreehandAreaShapeButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSExpandingAreaShapeButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSLassoAreaShapeButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSRoundedOldstyleButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSRoundedDefaultOldstyleButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSRectangleOldstyleButtonType",
                                                  [NSNumber numberWithUnsignedInt:0], @"HSDropShadowRectangleOldstyleButtonType",
                                                  nil];
    }
    return _buttonTypeToButtonFlagsMaskDictionary;
}

- (id)buttonType
{
    return [[self background] buttonType];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:[@"titleColor" extraKeyForMultiRepresentations]];
    [keys addObject:@"hyperUnderlined"];
    [keys addObject:@"hyperOutlineEnabled"];
    [keys addObject:@"hyperOutlineColor"];
    [keys addObject:@"hyperOutlineWidth"];
    [keys addObject:@"titleShadowEnabled"];
    [keys addObject:@"titleShadowOffsetAsString"];
    [keys addObject:@"titleShadowBlurRadius"];
    [keys addObject:@"titleVisible"];
    [keys addObject:@"iconVisible"];
    [keys addObject:@"hasHighlight"];
    [keys addObject:@"opacity"];
    [keys addObject:[@"backgroundStyleToBackroundDictionary" extraKeyForCollection]];
    [keys addObject:@"backgroundStyle"];
    [keys addObject:@"sizeAsString"];
    [keys addObject:@"contentOverlapsBackground"];
    [keys addObject:@"hyperSpaceBetweenCharacters"];
    return keys;
}

- (void)setHiddenIEditor:(BOOL)aEditor
{
    _hiddenIEditor = aEditor;
}

- (BOOL)isHiddenInEditor
{
    return _hiddenIEditor;
}

- (void)setSizeAsString:(id)aString
{
    [self setSize:NSSizeFromString(aString)];
}

- (id)sizeAsString
{
    return NSStringFromSize([self size]);
}

- (void)setSize:(NSSize)aSize
{
    if (HSButtonObjectDataSizesAreEqual([self size], aSize))
        return;
    [(HSButtonObjectSystemBackground *)[self background] setSize:aSize];
}

- (NSSize)size
{
    return [self backgroundSize];
}

// The background and content laid over each other from the origin, or
// nothing without a background size.
- (NSSize)sizeIncludingContent
{
    NSSize backgroundSize = [(HSButtonObjectBackground *)[self background] size];
    if (NSEqualSizes(backgroundSize, NSZeroSize))
        return NSZeroSize;
    NSRect backgroundRect = { NSZeroPoint, backgroundSize };
    NSRect contentRect = { NSZeroPoint, [self contentSize] };
    return NSUnionRect(contentRect, backgroundRect).size;
}

- (NSSize)backgroundSize
{
    return [(HSButtonObjectBackground *)[self background] size];
}

// The size of the system button's cell showing the icon where it is seen.
- (NSSize)contentSize
{
    NSButtonCell *cell = [[[[self systemButtonForGetAccessor] cell] copy] autorelease];
    [cell setImagePosition:[self visualIconPosition]];
    return [cell cellSize];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    if (_hyperSpaceBetweenCharacters != aCharacters) {
        _hyperSpaceBetweenCharacters = aCharacters;
        [self setCachedAttributedTitle:nil];
    }
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    return _hyperSpaceBetweenCharacters;
}

// NSNoImage without the icon, NSImageOnly with just the icon.
- (NSUInteger)visualIconPosition
{
    BOOL iconVisible = [self isIconVisible];
    BOOL titleVisible = [self isTitleVisible];
    if (iconVisible && titleVisible)
        return [self imagePosition];
    return iconVisible && !titleVisible;
}

- (void)setContentOverlapsBackground:(BOOL)aBackground
{
    if (_contentOverlapsBackground != aBackground)
        _contentOverlapsBackground = aBackground;
}

- (BOOL)contentOverlapsBackground
{
    return _contentOverlapsBackground;
}

- (id)buttonObjectForButtonObjectBackground:(id)aBackground
{
    return [[self owner] anyOwningObjectForNodeData:self];
}

- (id)background
{
    return [[self backgroundStyleToBackroundDictionary] objectForKey:[self backgroundStyle]];
}

- (void)setBackgroundStyleToBackroundDictionary:(id)aDictionary
{
    [[_backgroundStyleToBackroundDictionary objectForKey:@"HSButtonObjectSystemBackgroundStyle"] setOwner:nil];
    [[_backgroundStyleToBackroundDictionary objectForKey:@"HSButtonObjectShapeBackgroundStyle"] setOwner:nil];
    [aDictionary retain];
    [_backgroundStyleToBackroundDictionary release];
    _backgroundStyleToBackroundDictionary = aDictionary;
    [[aDictionary objectForKey:@"HSButtonObjectSystemBackgroundStyle"] setOwner:self];
    [[_backgroundStyleToBackroundDictionary objectForKey:@"HSButtonObjectShapeBackgroundStyle"] setOwner:self];
}

- (id)backgroundStyleToBackroundDictionary
{
    if (!_backgroundStyleToBackroundDictionary) {
        HSButtonObjectSystemBackground *systemBackground = [[HSButtonObjectSystemBackground alloc] initWithOwner:self];
        HSButtonObjectShapeBackground *shapeBackground = [[HSButtonObjectShapeBackground alloc] initWithOwner:self];
        _backgroundStyleToBackroundDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:systemBackground, @"HSButtonObjectSystemBackgroundStyle",
                                                 shapeBackground, @"HSButtonObjectShapeBackgroundStyle", nil];
        [systemBackground release];
        [shapeBackground release];
    }
    return _backgroundStyleToBackroundDictionary;
}

- (void)setBackgroundStyle:(id)aStyle
{
    [aStyle retain];
    [_backgroundStyle release];
    _backgroundStyle = aStyle;
}

- (id)backgroundStyle
{
    return _backgroundStyle;
}

- (void)setHasHighlight:(BOOL)aHighlight
{
    if ([self hasHighlight] == aHighlight)
        return;
    NSEnumerator *types = [[[self class] allButtonTypes] objectEnumerator];
    id type;
    while ((type = [types nextObject])) {
        NSUInteger mask = [self buttonFlagsMaskForButtonType:type];
        mask = aHighlight ? mask | 1 : mask & ~1u;
        [[self buttonTypeToButtonFlagsMaskDictionary] setObject:[NSNumber numberWithUnsignedInt:(unsigned int)mask] forKey:type];
    }
}

- (BOOL)hasHighlightForButtonType:(id)aType
{
    return [self buttonFlagsMaskForButtonType:aType] & 1;
}

- (BOOL)hasHighlight
{
    return [self hasHighlightForButtonType:[self buttonType]];
}

- (void)setIconVisible:(BOOL)aVisible
{
    _iconVisible = aVisible;
}

- (BOOL)isIconVisible
{
    return _iconVisible;
}

- (void)setTitleVisible:(BOOL)aVisible
{
    if ([self isTitleVisible] == aVisible)
        return;
    NSEnumerator *types = [[[self class] allButtonTypes] objectEnumerator];
    id type;
    while ((type = [types nextObject])) {
        NSUInteger mask = [self buttonFlagsMaskForButtonType:type];
        mask = aVisible ? mask | 2 : mask & ~2u;
        [[self buttonTypeToButtonFlagsMaskDictionary] setObject:[NSNumber numberWithUnsignedInt:(unsigned int)mask] forKey:type];
    }
}

- (BOOL)isTitleVisibleForButtonType:(id)aType
{
    return ([self buttonFlagsMaskForButtonType:aType] >> 1) & 1;
}

- (BOOL)isTitleVisible
{
    return [self isTitleVisibleForButtonType:[self buttonType]];
}

- (void)setCachedAttributedTitle:(id)aTitle
{
    if (![aTitle isEqual:_cachedAttributedTitle]) {
        [_cachedAttributedTitle release];
        _cachedAttributedTitle = [aTitle retain];
    }
}

- (id)cachedAttributedTitle
{
    return _cachedAttributedTitle;
}

- (void)setIconPosition:(NSUInteger)aPosition
{
    _iconPosition = (int)aPosition;
}

- (NSUInteger)iconPosition
{
    return _iconPosition;
}

- (void)setTitleShadowBlurRadius:(CGFloat)aRadius
{
    if (_titleShadowBlurRadius != aRadius) {
        _titleShadowBlurRadius = aRadius;
        [self setCachedAttributedTitle:nil];
    }
}

- (CGFloat)titleShadowBlurRadius
{
    return _titleShadowBlurRadius;
}

- (void)setTitleShadowOffsetAsString:(id)aString
{
    [self setTitleShadowOffset:NSSizeFromString(aString)];
}

- (id)titleShadowOffsetAsString
{
    return NSStringFromSize([self titleShadowOffset]);
}

- (void)setTitleShadowOffset:(NSSize)aOffset
{
    if (HSButtonObjectDataSizesAreEqual(_titleShadowOffset, aOffset))
        return;
    _titleShadowOffset = aOffset;
    [self setCachedAttributedTitle:nil];
}

- (NSSize)titleShadowOffset
{
    return _titleShadowOffset;
}

- (void)setTitleShadowEnabled:(BOOL)aEnabled
{
    if (_titleShadowEnabled != aEnabled) {
        _titleShadowEnabled = aEnabled;
        [self setCachedAttributedTitle:nil];
    }
}

- (BOOL)isTitleShadowEnabled
{
    return _titleShadowEnabled;
}

- (void)setCachedUnusedOutlineWidthValue:(id)aValue
{
    if (_cachedUnusedOutlineWidthValue != aValue) {
        [_cachedUnusedOutlineWidthValue release];
        _cachedUnusedOutlineWidthValue = [aValue retain];
    }
}

- (id)cachedUnusedOutlineWidthValue
{
    return _cachedUnusedOutlineWidthValue;
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    if (_hyperOutlineWidth != aWidth) {
        _hyperOutlineWidth = aWidth;
        [self setCachedAttributedTitle:nil];
    }
}

- (CGFloat)hyperOutlineWidth
{
    return _hyperOutlineWidth;
}

- (void)setHyperOutlineColor:(id)aColor
{
    if (![_hyperOutlineColor isEqual:aColor]) {
        [_hyperOutlineColor release];
        _hyperOutlineColor = [aColor retain];
        [self setCachedAttributedTitle:nil];
    }
}

- (id)hyperOutlineColor
{
    return _hyperOutlineColor;
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    if (_hyperOutline != aEnabled) {
        _hyperOutline = aEnabled;
        [self setCachedAttributedTitle:nil];
    }
}

- (BOOL)isHyperOutlineEnabled
{
    return _hyperOutline;
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    if (_hyperUnderlined != aUnderlined) {
        _hyperUnderlined = aUnderlined;
        [self setCachedAttributedTitle:nil];
    }
}

- (BOOL)isHyperUnderlined
{
    return _hyperUnderlined;
}

- (void)setTitleColor:(id)aColor
{
    if (![_titleColor isEqual:aColor]) {
        [aColor retain];
        [_titleColor release];
        _titleColor = aColor;
        [self setCachedAttributedTitle:nil];
    }
}

- (id)titleColor
{
    if (!_titleColor)
        _titleColor = [[NSColor blackColor] retain];
    return _titleColor;
}

- (void)dealloc
{
    [[_backgroundStyleToBackroundDictionary objectForKey:@"HSButtonObjectSystemBackgroundStyle"] setOwner:nil];
    [[_backgroundStyleToBackroundDictionary objectForKey:@"HSButtonObjectShapeBackgroundStyle"] setOwner:nil];
    [_backgroundStyleToBackroundDictionary release];
    [_backgroundStyle release];
    [_cachedAttributedTitle release];
    [_titleColor release];
    // The original leaked the outline color.
    [_hyperOutlineColor release];
    [_cachedUnusedOutlineWidthValue release];
    [_buttonTypeToButtonFlagsMaskDictionary release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _hyperUnderlined = NO;
        _hyperOutline = NO;
        _iconVisible = NO;
    }
    return self;
}

@end
