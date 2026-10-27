#import "HSTextPortionSerialization.h"
#import "HSAlert.h"
#import "HSScrollView.h"
#import "NSAffineTransform+HSKeyValueCoding.h"

// The text of a text view is limited to this many characters.
#define HSNonOpaqueTextViewMaximumLength 32000

// Relative tolerance comparison used throughout: values are equal when they
// differ by at most 0.05% of the larger magnitude (a zero magnitude counting
// as one).
static BOOL HSNonOpaqueTextViewValuesDiffer(float a, float b)
{
    float magnitudeA = a != 0.0f ? fabsf(a) : 1.0f;
    float magnitudeB = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) > fmaxf(magnitudeA, magnitudeB) * 0.0005f;
}

@implementation HSTextPortionSerialization

/* i386 ivar offsets: _attributedString=0x4, _attributesDictionary=0x8 */

+ (BOOL)writeAttributesDictionary:(id)aDictionary toPasteboard:(id)aPasteboard type:(id)aType
{
    HSTextPortionSerialization *portion = [[[HSTextPortionSerialization alloc] init] autorelease];
    [portion setAttributesDictionary:aDictionary];
    return [portion writeToPasteboard:aPasteboard type:aType];
}

+ (BOOL)writeAttributedString:(id)aString toPasteboard:(id)aPasteboard type:(id)aType
{
    HSTextPortionSerialization *portion = [[[HSTextPortionSerialization alloc] init] autorelease];
    [portion setAttributedString:aString];
    return [portion writeToPasteboard:aPasteboard type:aType];
}

+ (id)attributesDictionaryWithPasteboard:(id)aPasteboard type:(id)aType
{
    return [[self textPortionWithPasteboard:aPasteboard type:aType] attributesDictionary];
}

+ (id)attributedStringWithPasteboard:(id)aPasteboard type:(id)aType
{
    return [[self textPortionWithPasteboard:aPasteboard type:aType] attributedString];
}

+ (id)textPortionWithPasteboard:(id)aPasteboard type:(id)aType
{
    id propertyList = [aPasteboard propertyListForType:aType];
    if (propertyList == nil)
        return nil;
    return [HSTextPortionSerialization objectWithExtraDictionary:propertyList];
}

- (BOOL)writeToPasteboard:(id)aPasteboard type:(id)aType
{
    id representation = [self extraDictionaryRepresentation];
    if (representation == nil)
        return NO;
    return [aPasteboard setPropertyList:representation forType:aType];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:[@"attributedString" extraKeyForMultiRepresentations], [@"attributesDictionary" extraKeyForMultiRepresentations], nil];
}

- (id)attributesDictionary
{
    return _attributesDictionary;
}

- (void)setAttributesDictionary:(id)aDictionary
{
    if (_attributesDictionary != aDictionary) {
        [_attributesDictionary autorelease];
        _attributesDictionary = [aDictionary retain];
    }
}

- (id)attributedString
{
    return _attributedString;
}

- (void)setAttributedString:(id)aString
{
    if (_attributedString != aString) {
        [_attributedString autorelease];
        _attributedString = [aString retain];
    }
}

- (void)dealloc
{
    [_attributedString release];
    [_attributesDictionary autorelease];
    [super dealloc];
}

@end

@implementation HSNonOpaqueTextView

/* i386 ivar offsets: _inited=0x54, _neverDrawsBackground=0x55, _scaleFactor=0x58, _scrollsHorizontally=0x60, _clippedImage=0x64, _drawsBorderRect=0x68, _borderRect=0x6c, _borderRectColor=0x7c, _borderRectThickness=0x80, _horizontalScrollPosition=0x84, _isWithinDefaultKeyDownImplementation=0x88, _isRotatableText=0x89 */

+ (id)nativelySerializedAttributedStringWithPasteboard:(id)aPasteboard
{
    if (![[aPasteboard types] containsObject:@"HSSerializedRichTextPasteboardType"])
        return nil;
    return [HSTextPortionSerialization attributedStringWithPasteboard:aPasteboard type:@"HSSerializedRichTextPasteboardType"];
}

// Keeps the link, paragraph style and attachment of the dictionary and takes
// everything else from the font attributes.
+ (id)applyHyperFontAttributes:(id)aAttributes toDictionary:(id)aDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSSet *nonFontAttributes = [self hyperNonFontAttributes];
    NSEnumerator *keys = [aDictionary keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        if ([nonFontAttributes containsObject:key])
            [result setObject:[aDictionary objectForKey:key] forKey:key];
    }
    [result addEntriesFromDictionary:aAttributes];
    [pool release];
    return result;
}

+ (id)hyperNonFontAttributes
{
    static NSSet *nonFontAttributes = nil;
    if (nonFontAttributes == nil)
        nonFontAttributes = [[NSSet alloc] initWithObjects:NSLinkAttributeName, NSParagraphStyleAttributeName, NSAttachmentAttributeName, nil];
    return nonFontAttributes;
}

- (void)insertText:(id)aText
{
    if ([[self textStorage] length] >= HSNonOpaqueTextViewMaximumLength) {
        NSBeep();
        return;
    }
    if ([[self delegate] respondsToSelector:@selector(textView:willInsertText:)])
        [(id)[self delegate] textView:self willInsertText:aText];
    [super insertText:aText];
}

// Never shorter than the visible part of the enclosing scroll view.
- (void)setConstrainedFrameSize:(NSSize)aSize
{
    float height = aSize.height;
    HSScrollView *scrollView = [self hyperEnclosingScrollView];
    if (scrollView != nil) {
        NSRect visible = [scrollView documentVisibleRect];
        float requested = aSize.height, visibleHeight = visible.size.height;
        float magnitude = fmaxf(requested != 0.0f ? fabsf(requested) : 1.0f, visibleHeight != 0.0f ? fabsf(visibleHeight) : 1.0f);
        if (requested < magnitude * -0.0005f + visibleHeight)
            height = visibleHeight;
    }
    [super setConstrainedFrameSize:NSMakeSize(aSize.width, height)];
}

- (void)modifyFont:(id)aFont
{
    [[NSFontManager sharedFontManager] modifyFont:aFont];
}

// Pastes the font as serialized attributes when the font pasteboard has them.
- (void)pasteFont:(id)aFont
{
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFontPboard];
    if ([[pasteboard types] containsObject:@"HSSerializedFontAttributesPasteboardType"])
        [self readSelectionFromPasteboard:pasteboard type:@"HSSerializedFontAttributesPasteboardType"];
    else
        [super pasteFont:aFont];
}

// Serialized rich text, plain text and RTF flavours go through the length
// limit; serialized font attributes are applied to the selection.
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard type:(id)aType
{
    id string;
    if ([aType isEqualToString:@"HSSerializedRichTextPasteboardType"]) {
        string = [HSTextPortionSerialization attributedStringWithPasteboard:aPasteboard type:aType];
    } else if ([aType isEqualToString:@"HSSerializedFontAttributesPasteboardType"]) {
        NSDictionary *fontAttributes = [HSTextPortionSerialization attributesDictionaryWithPasteboard:aPasteboard type:aType];
        if (fontAttributes == nil)
            return NO;
        NSArray *ranges = [self rangesForUserCharacterAttributeChange];
        if ([ranges count] == 0)
            return NO;
        if (![self shouldChangeTextInRanges:ranges replacementStrings:nil])
            return NO;
        [[self textStorage] beginEditing];
        NSUInteger count = [ranges count];
        for (NSUInteger i = 0; i < count; i++) {
            NSRange range = [[ranges objectAtIndex:i] rangeValue];
            if (range.length == 0) {
                // Quirk kept: an insertion point updates the typing attributes
                // and ends the loop.
                [self setTypingAttributes:[[self class] applyHyperFontAttributes:fontAttributes toDictionary:[self typingAttributes]]];
                break;
            }
            NSUInteger position = range.location;
            do {
                NSRange effective = NSMakeRange(0, 0);
                NSDictionary *attributes = [[self textStorage] attributesAtIndex:position effectiveRange:&effective];
                NSRange intersection = NSIntersectionRange(effective, range);
                if (intersection.length != 0)
                    [[self textStorage] setAttributes:[[self class] applyHyperFontAttributes:fontAttributes toDictionary:attributes] range:intersection];
                position = effective.location + effective.length;
            } while (position - range.location < range.length);
        }
        [[self textStorage] endEditing];
        [self didChangeText];
        return YES;
    } else if ([aType isEqualToString:NSStringPboardType]) {
        string = [aPasteboard stringForType:aType];
    } else if ([aType isEqualToString:NSRTFPboardType] || [aType isEqualToString:NSRTFDPboardType] ||
               [aType isEqualToString:NSHTMLPboardType] || [aType isEqualToString:NSTabularTextPboardType]) {
        // Quirk kept: every one of these flavours is read as RTF.
        string = [[[NSAttributedString alloc] initWithRTF:[aPasteboard dataForType:aType] documentAttributes:NULL] autorelease];
    } else {
        return [super readSelectionFromPasteboard:aPasteboard type:aType];
    }
    if (string == nil)
        return NO;
    return [self performInsertionOfString:string];
}

// Inserts a plain or attributed string into the selection (and empties the
// other selected ranges). When the text would grow past the limit the user
// may insert only what fits.
- (BOOL)performInsertionOfString:(id)aString
{
    id string = aString;
    BOOL attributed = [aString isKindOfClass:[NSAttributedString class]];
    NSInteger length = [aString length];
    NSInteger textLength = [[self textStorage] length];
    BOOL result;
    if ((NSUInteger)(textLength + length - [self selectedRange].length) <= HSNonOpaqueTextViewMaximumLength) {
        result = NO;
    } else {
        BOOL insert = [self showAlert];
        if (insert) {
            NSInteger available = (NSInteger)[self selectedRange].length - (NSInteger)[[self textStorage] length] + HSNonOpaqueTextViewMaximumLength;
            if (available < length)
                length = available;
            if (length > 0)
                string = attributed ? [aString attributedSubstringFromRange:NSMakeRange(0, length)] : [aString substringWithRange:NSMakeRange(0, length)];
            else
                insert = NO;
        }
        if (!insert)
            return YES;
        result = YES;
    }
    NSArray *ranges = [self rangesForUserTextChange];
    NSMutableArray *replacements = [NSMutableArray array];
    if ([ranges count] == 0)
        return result;
    NSUInteger count = [ranges count];
    [replacements addObject:attributed ? [string string] : string];
    for (NSUInteger i = 1; i < count; i++)
        [replacements addObject:@""];
    if (![self shouldChangeTextInRanges:ranges replacementStrings:replacements])
        return result;
    if ([[self delegate] respondsToSelector:@selector(textView:willInsertText:)])
        [(id)[self delegate] textView:self willInsertText:string];
    [[self textStorage] beginEditing];
    NSRange first = [[ranges objectAtIndex:0] rangeValue];
    NSInteger delta = (NSInteger)[string length] - (NSInteger)first.length;
    if (attributed)
        [[self textStorage] replaceCharactersInRange:first withAttributedString:string];
    else
        [[self textStorage] replaceCharactersInRange:first withString:string];
    for (NSUInteger i = 1; i < count; i++) {
        NSRange range = [[ranges objectAtIndex:i] rangeValue];
        range.location += delta;
        delta -= range.length;
        [[self textStorage] replaceCharactersInRange:range withString:@""];
    }
    [[self textStorage] endEditing];
    [self didChangeText];
    return YES;
}

- (BOOL)showAlert
{
    HSAlert *alert = [HSAlert new];
    NSString *message = [[NSBundle mainBundle] localizedStringForKey:@"Do you want to insert what will fit?" value:@"" table:@"Alerts"];
    NSString *information = [[NSBundle mainBundle] localizedStringForKey:@"The text file you selected to insert will cause the text object to exceed the 32,000 character limit." value:@"" table:@"Alerts"];
    [alert setMessageText:message];
    [alert setInformativeText:information];
    [alert addButtonWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Insert" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    NSInteger response = [alert runModal];
    [alert release];
    return response == NSAlertFirstButtonReturn;
}

- (id)preferredPasteboardTypeFromArray:(id)aArray restrictedToTypesFromArray:(id)aArray2
{
    // Quirk kept: the first array is checked twice, the restriction never.
    if ([aArray containsObject:@"HSSerializedRichTextPasteboardType"] && [aArray containsObject:@"HSSerializedRichTextPasteboardType"])
        return @"HSSerializedRichTextPasteboardType";
    return [super preferredPasteboardTypeFromArray:aArray restrictedToTypesFromArray:aArray2];
}

// Serialized rich text joins multiple selections with newlines; serialized
// font attributes come from the selection (font plus ruler attributes) or the
// typing attributes without the non-font ones.
- (BOOL)writeSelectionToPasteboard:(id)aPasteboard type:(id)aType
{
    if ([aType isEqualToString:@"HSSerializedRichTextPasteboardType"]) {
        NSAttributedString *selection = nil;
        if ([[self selectedRanges] count] < 2) {
            NSRange range = [self selectedRange];
            if (range.length != 0)
                selection = [[self textStorage] attributedSubstringFromRange:range];
        } else {
            NSEnumerator *ranges = [[self selectedRanges] objectEnumerator];
            NSMutableAttributedString *joined = [[[NSMutableAttributedString alloc] init] autorelease];
            id value;
            while ((value = [ranges nextObject]) != nil) {
                NSRange range = [value rangeValue];
                if (range.length == 0)
                    continue;
                if ([joined length] != 0)
                    [[joined mutableString] appendString:@"\n"];
                [joined appendAttributedString:[[self textStorage] attributedSubstringFromRange:range]];
            }
            selection = joined;
        }
        if (selection == nil)
            return NO;
        return [HSTextPortionSerialization writeAttributedString:selection toPasteboard:aPasteboard type:aType];
    }
    if (![aType isEqualToString:@"HSSerializedFontAttributesPasteboardType"])
        return [super writeSelectionToPasteboard:aPasteboard type:aType];
    NSRange range = [self selectedRange];
    NSMutableDictionary *attributes;
    if (range.length == 0) {
        attributes = [NSMutableDictionary dictionaryWithDictionary:[self typingAttributes]];
        NSEnumerator *nonFontAttributes = [[[self class] hyperNonFontAttributes] objectEnumerator];
        id key;
        while ((key = [nonFontAttributes nextObject]) != nil)
            [attributes removeObjectForKey:key];
    } else {
        // The original added the ruler attributes to the returned dictionary
        // directly; a mutable copy is made since it may be immutable.
        attributes = [[[[self textStorage] fontAttributesInRange:range] mutableCopy] autorelease];
        [attributes setValuesForKeysWithDictionary:[[self textStorage] rulerAttributesInRange:range]];
    }
    return [HSTextPortionSerialization writeAttributesDictionary:attributes toPasteboard:aPasteboard type:aType];
}

// Copying a font also puts serialized font attributes on the font pasteboard.
- (BOOL)writeSelectionToPasteboard:(id)aPasteboard types:(id)aTypes
{
    if ([NSPasteboard pasteboardWithName:NSFontPboard] == aPasteboard && [aTypes containsObject:NSFontPboardType])
        aTypes = [aTypes arrayByAddingObject:@"HSSerializedFontAttributesPasteboardType"];
    return [super writeSelectionToPasteboard:aPasteboard types:aTypes];
}

- (id)acceptableDragTypes
{
    return [[super acceptableDragTypes] arrayByAddingObject:@"HSSerializedRichTextPasteboardType"];
}

- (id)readablePasteboardTypes
{
    return [[super readablePasteboardTypes] arrayByAddingObject:@"HSSerializedRichTextPasteboardType"];
}

- (id)writablePasteboardTypes
{
    return [[super writablePasteboardTypes] arrayByAddingObject:@"HSSerializedRichTextPasteboardType"];
}

- (void)outline:(id)aOutline
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(toggleOutlineInTextView:)])
        [delegate toggleOutlineInTextView:self];
    else
        [super outline:aOutline];
}

- (void)performFindPanelAction:(id)aAction
{
    [super performFindPanelAction:aAction];
    if ([aAction tag] == NSFindPanelActionSetFindString)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSFindPanelActionSetFindStringNotification" object:self];
}

- (void)ignoreSpelling:(id)aSpelling
{
    [super ignoreSpelling:aSpelling];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSIgnoreMisspelledWordNotification" object:aSpelling];
}

- (void)changeSpelling:(id)aSpelling
{
    [super changeSpelling:aSpelling];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCorrectMisspelledWordNotification" object:nil];
}

// Renders the visible glyphs into an image used while scrolling horizontally.
- (void)createImageFromVisibleText
{
    [_clippedImage release];
    NSRect visible = [[[self enclosingScrollView] contentView] bounds];
    NSRange glyphs = [[self layoutManager] glyphRangeForBoundingRect:visible inTextContainer:[self textContainer]];
    _clippedImage = [[NSImage alloc] initWithSize:visible.size];
    [_clippedImage setFlipped:YES];
    [_clippedImage lockFocus];
    if ([self drawsBackground] && !_scrollsHorizontally) {
        [[self backgroundColor] set];
        NSSize size = [_clippedImage size];
        NSRectFillUsingOperation(NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height), NSCompositingOperationSourceOver);
    }
    [[self layoutManager] drawBackgroundForGlyphRange:glyphs atPoint:NSMakePoint(-visible.origin.x, -visible.origin.y)];
    [[self layoutManager] drawGlyphsForGlyphRange:glyphs atPoint:NSMakePoint(-visible.origin.x, -visible.origin.y)];
    [_clippedImage unlockFocus];
}

- (void)setRotatableText:(BOOL)aText
{
    _isRotatableText = aText;
}

- (BOOL)isRotatableText
{
    return _isRotatableText;
}

- (void)setScrollsHorizontally:(BOOL)aHorizontally
{
    if ((_scrollsHorizontally != 0) != (aHorizontally != NO)) {
        _scrollsHorizontally = aHorizontally != NO;
        if (aHorizontally)
            [self createImageFromVisibleText];
    }
}

- (BOOL)scrollsHorizontally
{
    return _scrollsHorizontally;
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    BOOL result = [super validateUserInterfaceItem:aItem];
    if (action == @selector(performFindPanelAction:))
        return YES;
    return result;
}

- (id)hyperEnclosingScrollView
{
    NSScrollView *scrollView = [self enclosingScrollView];
    return [scrollView isKindOfClass:[HSScrollView class]] ? scrollView : nil;
}

- (void)setHorizontalScrollPosition:(CGFloat)aPosition
{
    if (_horizontalScrollPosition != (float)aPosition) {
        _horizontalScrollPosition = aPosition;
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat)hyperHorizontalScrollPosition
{
    return _horizontalScrollPosition;
}

// Scrolls to a fraction of the scrollable height, unless already there.
- (void)hyperSafeSetScrollPosition:(CGFloat)aPosition
{
    NSClipView *contentView = [[self enclosingScrollView] contentView];
    if (contentView == nil)
        return;
    NSRect bounds = [contentView bounds];
    float target = ([self frame].size.height - [contentView bounds].size.height) * aPosition;
    if (HSNonOpaqueTextViewValuesDiffer(bounds.origin.y, target))
        [contentView setBoundsOrigin:NSMakePoint(bounds.origin.x, ([self frame].size.height - [contentView bounds].size.height) * aPosition)];
}

- (CGFloat)hyperScrollPosition
{
    NSView *contentView = [[self hyperEnclosingScrollView] hyperContentView];
    if (contentView != nil) {
        float scrollable = [self frame].size.height - [contentView bounds].size.height;
        if (scrollable > 0.0f)
            return [contentView bounds].origin.y / scrollable;
    }
    return 0.0;
}

- (void)hyperSafeSetSelectedRange:(NSRange)aRange
{
    if (aRange.location + aRange.length > [[self textStorage] length])
        return;
    if (!NSEqualRanges([self selectedRange], aRange))
        [self setSelectedRange:aRange];
}

- (void)changeAttributes:(id)aAttributes
{
    if ([[self delegate] respondsToSelector:@selector(textView:shouldHyperChangeAttributes:)] &&
        ![(id)[self delegate] textView:self shouldHyperChangeAttributes:aAttributes])
        return;
    [super changeAttributes:aAttributes];
}

// The delegate hears about colour changes that actually changed the text.
- (void)changeColor:(id)aColor
{
    if ([[self delegate] respondsToSelector:@selector(textView:shouldHyperChangeColor:)] &&
        ![(id)[self delegate] textView:self shouldHyperChangeColor:aColor])
        return;
    NSAttributedString *before = [[self textStorage] mutableCopy];
    [super changeColor:aColor];
    if (![before isEqual:[self textStorage]] && [[self delegate] respondsToSelector:@selector(textView:hyperColorDidChange:)])
        [(id)[self delegate] textView:self hyperColorDidChange:aColor];
    [before release];
}

- (void)changeFont:(id)aFont
{
    if ([[self delegate] respondsToSelector:@selector(textView:shouldHyperChangeFont:)] &&
        ![(id)[self delegate] textView:self shouldHyperChangeFont:aFont])
        return;
    [super changeFont:aFont];
}

- (void)changeDocumentBackgroundColor:(id)aColor
{
    if ([[self delegate] respondsToSelector:@selector(textView:shouldHyperDocumentBackgroundColor:)] &&
        ![(id)[self delegate] textView:self shouldHyperDocumentBackgroundColor:aColor])
        return;
    [self setBackgroundColor:[aColor color]];
}

- (CGFloat)borderRectThickness
{
    return _borderRectThickness;
}

- (void)setBorderRectThickness:(CGFloat)aThickness
{
    if (HSNonOpaqueTextViewValuesDiffer(_borderRectThickness, aThickness)) {
        _borderRectThickness = aThickness;
        [self setNeedsDisplay:YES];
    }
}

- (id)borderRectColor
{
    return _borderRectColor != nil ? _borderRectColor : [NSColor grayColor];
}

- (void)setBorderRectColor:(id)aColor
{
    if (_borderRectColor != aColor) {
        [_borderRectColor release];
        _borderRectColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (NSRect)borderRect
{
    return _borderRect;
}

// Compared with a tolerance based on |origin| + size per axis.
- (void)setBorderRect:(NSRect)aRect
{
    float oldX = _borderRect.origin.x, oldY = _borderRect.origin.y, oldW = _borderRect.size.width, oldH = _borderRect.size.height;
    float newX = aRect.origin.x, newY = aRect.origin.y, newW = aRect.size.width, newH = aRect.size.height;
    float oldSpanX = fabsf(oldX) + oldW, oldSpanY = fabsf(oldY) + oldH;
    float newSpanX = fabsf(newX) + newW, newSpanY = fabsf(newY) + newH;
    float magnitudeX = fmaxf(oldSpanX != 0.0f ? fabsf(oldSpanX) : 1.0f, newSpanX != 0.0f ? fabsf(newSpanX) : 1.0f);
    float magnitudeY = fmaxf(oldSpanY != 0.0f ? fabsf(oldSpanY) : 1.0f, newSpanY != 0.0f ? fabsf(newSpanY) : 1.0f);
    if (magnitudeX * 0.0005f < fabsf(oldX - newX) || magnitudeY * 0.0005f < fabsf(oldY - newY) ||
        magnitudeX * 0.0005f < fabsf(oldW - newW) || magnitudeY * 0.0005f < fabsf(oldH - newH)) {
        _borderRect = aRect;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)drawsBorderRect
{
    return _drawsBorderRect;
}

- (void)setDrawsBorderRect:(BOOL)aRect
{
    if ((_drawsBorderRect != NO) != (aRect != NO)) {
        _drawsBorderRect = aRect != NO;
        [self setNeedsDisplay:YES];
    }
}

- (NSSize)scaleFactor
{
    return _scaleFactor;
}

// Undoes the previous unit square scale before applying the new one.
- (void)setScaleFactor:(NSSize)aFactor
{
    if (!HSNonOpaqueTextViewValuesDiffer(_scaleFactor.width, aFactor.width) && !HSNonOpaqueTextViewValuesDiffer(_scaleFactor.height, aFactor.height))
        return;
    [self scaleUnitSquareToSize:[[NSAffineTransform hyperScalingBy:_scaleFactor] hyperInverseScaleFactor]];
    _scaleFactor = aFactor;
    [self scaleUnitSquareToSize:aFactor];
    [self setNeedsDisplay:YES];
}

- (void)continuousSpellCheckingDidChange:(id)aChange
{
    [self setContinuousSpellCheckingEnabled:(char)[[[NSUserDefaults standardUserDefaults] objectForKey:@"HSTextViewContinuousSpellCheckingKeyString"] intValue]];
}

- (void)toggleContinuousSpellChecking:(id)aChecking
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[aChecking state] == NSControlStateValueOff]
                                              forKey:@"HSTextViewContinuousSpellCheckingKeyString"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSTextViewContinuousSpellCheckingNotification" object:nil userInfo:nil];
}

- (void)setNeverDrawsBackground:(BOOL)aBackground
{
    if (_neverDrawsBackground != aBackground) {
        _neverDrawsBackground = aBackground;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)neverDrawsBackground
{
    return _neverDrawsBackground;
}

- (BOOL)isOpaque
{
    if (_neverDrawsBackground)
        return NO;
    return [super isOpaque];
}

// Outside of keyDown the delegate may keep key equivalents from the text.
- (BOOL)performKeyEquivalent:(id)aEquivalent
{
    if (!_isWithinDefaultKeyDownImplementation &&
        [[self delegate] respondsToSelector:@selector(textView:shouldHandlePerformKeyEquivalentOutsideOfKeyDown:)] &&
        ![(id)[self delegate] textView:self shouldHandlePerformKeyEquivalentOutsideOfKeyDown:aEquivalent])
        return YES;
    return [super performKeyEquivalent:aEquivalent];
}

- (void)keyDown:(id)aDown
{
    if ([[self delegate] respondsToSelector:@selector(textView:shouldHandleRawKeyDownEvent:)] &&
        ![(id)[self delegate] textView:self shouldHandleRawKeyDownEvent:aDown])
        return;
    _isWithinDefaultKeyDownImplementation = YES;
    [super keyDown:aDown];
    _isWithinDefaultKeyDownImplementation = NO;
}

- (void)mouseDown:(id)aDown
{
    [[self retain] autorelease];
    [super mouseDown:aDown];
    if ([[self delegate] respondsToSelector:@selector(textView:didPerformClick:)])
        [(id)[self delegate] textView:self didPerformClick:aDown];
}

- (void)setPostsBoundsChangedNotifications:(BOOL)aNotifications
{
    [super setPostsBoundsChangedNotifications:aNotifications];
}

// While scrolling horizontally the cached image of the visible text is drawn
// instead of the text. The border rect always follows the bounds.
- (void)drawRect:(NSRect)aRect
{
    if (![self drawsBackground] && ![self neverDrawsBackground]) {
        [[self backgroundColor] set];
        NSRectFillUsingOperation(aRect, NSCompositingOperationSourceOver);
    }
    if (_scrollsHorizontally) {
        [self drawViewBackgroundInRect:aRect];
        NSRect first = [[[self enclosingScrollView] contentView] bounds];
        float position = _horizontalScrollPosition;
        NSRect second = [[[self enclosingScrollView] contentView] bounds];
        float offset = position * second.size.width;
        NSRect imageRect = NSOffsetRect([[[self enclosingScrollView] contentView] bounds], first.size.width - offset, 0.0);
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:imageRect.origin.x yBy:imageRect.origin.y + imageRect.size.height];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform translateXBy:-imageRect.origin.x yBy:-imageRect.origin.y];
        [transform concat];
        [_clippedImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    } else {
        [super drawRect:aRect];
    }
    _borderRect = [self bounds];
    if (!_drawsBorderRect)
        return;
    float thickness = _borderRectThickness;
    float magnitude = thickness != 0.0f ? fabsf(thickness) : 1.0f;
    float tolerance = magnitude < 1.0f ? 0.0005f : magnitude * 0.0005f;
    if (thickness > tolerance + 0.0f && !NSIsEmptyRect(_borderRect)) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:_borderRect];
        [path setLineWidth:_borderRectThickness];
        [(NSColor *)[self borderRectColor] set];
        [path stroke];
    }
}

- (NSRect)containerRect
{
    NSPoint origin = [self textContainerOrigin];
    NSSize size = [[self textContainer] containerSize];
    return NSMakeRect(origin.x, origin.y, size.width, size.height);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_clippedImage release];
    [_borderRectColor release];
    [super dealloc];
}

- (void)onceInit
{
    if (_inited)
        return;
    _inited = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continuousSpellCheckingDidChange:)
                                                 name:@"HSTextViewContinuousSpellCheckingNotification" object:nil];
    [self continuousSpellCheckingDidChange:nil];
    _scaleFactor = [[NSAffineTransform transform] hyperScaleFactor];
}

- (BOOL)becomeFirstResponder
{
    if ([self window] == nil)
        return NO;
    return [super becomeFirstResponder];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        [self setTypingAttributes:[aCoder decodeObjectForKey:@"hyperTypingAttributes"]];
        [self onceInit];
    }
    return self;
}

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self typingAttributes] forKey:@"hyperTypingAttributes"];
}

- (id)initWithFrame:(NSRect)aFrame textContainer:(id)aContainer
{
    self = [super initWithFrame:aFrame textContainer:aContainer];
    if (self != nil)
        [self onceInit];
    return self;
}

@end
