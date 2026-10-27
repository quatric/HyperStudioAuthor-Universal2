#import "HSFontComboboxDataSource.h"

// The font family combo box items: each family's name drawn in its own
// font (16 points high), made when first shown; a singleton never released.

static NSLayoutManager *sDrawingLayoutManager;
static HSFontComboboxDataSource *sSharedDataSource;

@implementation HSFontComboboxDataSource

+ (id)sharedDrawingLayoutManager
{
    if (sDrawingLayoutManager == nil) {
        NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1e6, 1e6)];
        sDrawingLayoutManager = [[NSLayoutManager alloc] init];
        [container setWidthTracksTextView:NO];
        [container setHeightTracksTextView:NO];
        [sDrawingLayoutManager addTextContainer:container];
        [container release];
    }
    return sDrawingLayoutManager;
}

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedDataSource == nil) {
            sSharedDataSource = [super allocWithZone:aZone];
            return sSharedDataSource;
        }
    }
    return nil;
}

+ (id)sharedFontDataSource
{
    @synchronized(self) {
        if (sSharedDataSource == nil)
            [[self alloc] init];
    }
    return sSharedDataSource;
}

// The family name of a sample image.
- (id)fontNameKeyForItem:(id)aItem
{
    return [[self fontSamplesTable] objectForKey:aItem];
}

- (id)keyValueForItemAtIndex:(NSInteger)aIndex
{
    return [[self sortedFontNames] objectAtIndex:aIndex];
}

- (id)comboBox:(id)aBox completedString:(id)aString
{
    for (NSString *name in [self sortedFontNames]) {
        if ([name compare:aString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [aString length])] == NSOrderedSame)
            return name;
    }
    return @"";
}

- (NSUInteger)comboBox:(id)aBox indexOfItemWithStringValue:(id)aValue
{
    return [[self sortedFontNames] indexOfObject:aValue];
}

- (id)comboBox:(id)aBox objectValueForItemAtIndex:(NSInteger)aIndex
{
    NSString *name = [[self sortedFontNames] objectAtIndex:aIndex];
    if ([[self fonts] objectForKey:name] == nil)
        [self prerareImageForFontName:name];
    return [[self fonts] objectForKey:name];
}

- (NSInteger)numberOfItemsInComboBox:(id)aBox
{
    return [[self sortedFontNames] count];
}

- (void)prerareImageForFontName:(id)aName
{
    NSFont *font = [NSFont fontWithName:aName size:[NSFont systemFontSizeForControlSize:NSControlSizeRegular]];
    if (font == nil)
        return;
    NSAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:aName attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]] autorelease];
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withAttributedString:string];
    if ([string length] == 0) {
        [storage release];
        return;
    }
    NSLayoutManager *layoutManager = [HSFontComboboxDataSource sharedDrawingLayoutManager];
    NSTextContainer *container = [[layoutManager textContainers] objectAtIndex:0];
    [container setContainerSize:NSMakeSize(1e6, 1e6)];
    [storage addLayoutManager:layoutManager];
    NSRange glyphs = [layoutManager glyphRangeForTextContainer:container];
    NSRect used = [layoutManager usedRectForTextContainer:container];
    NSImage *sample = nil;
    if (glyphs.length != 0) {
        // Tall fonts are halved (and drawn lower); the baseline sits about
        // half way, a little higher for Hiragino.
        CGFloat height = used.size.height;
        CGFloat divisor = 2.0;
        if (height > 40.0) {
            height *= 0.5;
            divisor = 1.15;
        }
        if ([aName hasPrefix:@"Hiragino"])
            divisor = 2.6;
        sample = [[NSImage alloc] initWithSize:NSMakeSize(used.size.width, height)];
        [sample lockFocus];
        NSPoint point = NSMakePoint(0, -height / divisor);
        [layoutManager drawBackgroundForGlyphRange:glyphs atPoint:point];
        [layoutManager drawGlyphsForGlyphRange:glyphs atPoint:point];
        [sample unlockFocus];
    }
    [storage removeLayoutManager:layoutManager];
    [storage release];
    if (sample == nil)
        return;
    NSSize size = [sample size];
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(size.width, 16.0)];
    CGFloat height = MIN([image size].height, size.height);
    [image lockFocus];
    NSRect rect = NSMakeRect(0, 0, size.width, height);
    [sample drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:1.0];
    [image unlockFocus];
    [[self fonts] setObject:image forKey:aName];
    if (image != nil && aName != nil)
        [[self fontSamplesTable] setObject:aName forKey:image];
    [image release];
    [sample release];
}

- (id)fontSamplesTable
{
    if (_fontSamplesTable == nil)
        _fontSamplesTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:[[self sortedFontNames] count]];
    return _fontSamplesTable;
}

- (id)fonts
{
    if (_fonts == nil)
        _fonts = [[NSMutableDictionary alloc] init];
    return _fonts;
}

- (id)sortedFontNames
{
    if (_sortedFontNames == nil)
        _sortedFontNames = [[[[NSFontManager sharedFontManager] availableFontFamilies] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
    return _sortedFontNames;
}

- (void)dealloc
{
    [_sortedFontNames release];
    [_fonts release];
    [_fontSamplesTable release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
