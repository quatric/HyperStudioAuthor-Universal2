#import "HSOldFormatDocument+HSTextRecreation.h"
// Old-format import: text items, rebuilt as system text views. The view
// being rebuilt is kept in the parser's values buffer under "~TextView";
// its text, font and style runs ("scrp" records) come in separately and are
// collected there too.

static id HSTextRecreationParserObject(HSOldFormatDocument *aDocument, NSString *aKey)
{
    return [[aDocument parser] valuesBufferObjectForKey:aKey];
}

static void HSTextRecreationSetParserObject(HSOldFormatDocument *aDocument, id aObject, NSString *aKey)
{
    [[aDocument parser] setValuesBufferObject:aObject forKey:aKey];
}

// HyperStudio's justification: 0 / -2 left, 1 centre, -1 right, otherwise
// natural. (NSTextAlignment's values differ by architecture: use the names.)
static NSTextAlignment HSTextRecreationAlignment(int aJustification)
{
    switch (aJustification) {
    case 0:
    case -2:
        return NSTextAlignmentLeft;
    case 1:
        return NSTextAlignmentCenter;
    case -1:
        return NSTextAlignmentRight;
    default:
        return NSTextAlignmentNatural;
    }
}

// A font's ascender, or 1 for none, as the size search compares them.
static float HSTextRecreationMagnitude(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

@implementation HSOldFormatDocument (HSTextRecreation)
// A style run ends with its colour: applies the collected font, underline,
// justification and shadow from the run's start character to the end of the
// text, and stores the result under the text item's keys (the text view's,
// its card's and the stack's, where the card has none yet or the same text).
- (void)processBy_tbAttributes_scrpColor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id textView = HSTextRecreationParserObject(self, @"~TextView");
    int attributesCount = [[self parser] intEvaluate:@"tbItem.type.attributesCount"];
    NSFont *font = HSTextRecreationParserObject(self, @"~TextViewFont");
    NSFontTraitMask traits = (NSFontTraitMask)[[self parser] intEvaluate:@"~HTextViewAttributesTraitMask"];
    NSFont *styledFont = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:traits];
    if (styledFont == nil) {
        [self setFontWarning:YES];
        styledFont = font;
    }
    NSAttributedString *text = HSTextRecreationParserObject(self, @"~TextViewText");
    NSMutableAttributedString *clearText = [[[NSMutableAttributedString alloc] initWithAttributedString:HSTextRecreationParserObject(self, @"~ClearTextViewText")] autorelease];
    NSUInteger start = (NSUInteger)[[self parser] intEvaluate:@"~HTextViewAttributesStartChar"];
    if (attributesCount > 0 && start <= [clearText length] - 1) {
        NSUInteger length = [clearText length];
        NSAttributedString *head = [text attributedSubstringFromRange:NSMakeRange(0, start)];
        NSRange range = NSMakeRange(start, length - start);
        [clearText beginEditing];
        [clearText addAttribute:NSForegroundColorAttributeName value:aValue range:range];
        [clearText addAttribute:NSFontAttributeName value:styledFont range:range];
        BOOL underline = [HSTextRecreationParserObject(self, @"~HTextViewAttributesUnderlineStyle") isEqualToString:@"YES"];
        [clearText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:underline] range:range];
        NSTextAlignment alignment = HSTextRecreationAlignment([[self parser] intEvaluate:@"itemTextStackHeader.type.just"]);
        [textView setHyperAlignment:alignment];
        NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
        [style setAlignment:alignment];
        [clearText addAttribute:NSParagraphStyleAttributeName value:style range:range];
        if ([HSTextRecreationParserObject(self, @"~HTextViewAttributesShadowStyle") isEqualToString:@"YES"]) {
            NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
            [shadow setShadowOffset:NSMakeSize(3, 3)];
            [shadow setShadowBlurRadius:7];
            [shadow setShadowColor:[NSColor blackColor]];
            [clearText addAttribute:NSShadowAttributeName value:shadow range:range];
            HSTextRecreationSetParserObject(self, @"NO", @"~HTextViewAttributesShadowStyle");
        }
        [clearText endEditing];
        [clearText replaceCharactersInRange:NSMakeRange(0, start) withAttributedString:head];
    }
    int itemID = [HSTextRecreationParserObject(self, @"itemTextStackHeader.type.id") intValue];
    NSString *textKey = [NSString stringWithFormat:@"~TextViewTextByID_%d", itemID];
    NSString *outlineKey = [NSString stringWithFormat:@"~TextViewOutlineByID_%d", itemID];
    HSTextRecreationSetParserObject(self, clearText, textKey);
    HSTextRecreationSetParserObject(self, HSTextRecreationParserObject(self, @"~HTextViewAttributesOutlineStyle"), outlineKey);
    HSTextRecreationSetParserObject(self, clearText, @"~TextViewText");
    [textView setUserInfo:clearText forKey:textKey];
    NSString *textBoxKey = [NSString stringWithFormat:@"~TextViewTextByTextBoxID_%d", (int)[[self parser] intEvaluate:@"itemTextStackHeader.type.id"]];
    [textView setHyperText:[[[NSAttributedString alloc] initWithString:textBoxKey] autorelease]];
    int cardID = [[self parser] intEvaluate:@"~TextViewTBCardId"];
    id card = [[[self cardsById] objectForKey:[NSString stringWithFormat:@"%d", cardID]] recreatedCard];
    NSString *cardText = [[card userInfoForKey:textBoxKey] string];
    if ([cardText length] == 0 || [cardText isEqualToString:[clearText string]]) {
        [card setUserInfo:clearText forKey:textBoxKey];
        [[self stack] setUserInfo:clearText forKey:textBoxKey];
    }
    if ([HSTextRecreationParserObject(self, @"~HTextViewAttributesOutlineStyle") isEqualToString:@"YES"])
        [[textView queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)] setHyperOutlineEnabled:YES];
}
// Condensed and expanded faces are remembered per item for later.
- (void)processBy_tbAttributes_scrpFace_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSUInteger face = [aValue intValue];
    int itemID = [HSTextRecreationParserObject(self, @"itemTextStackHeader.type.id") intValue];
    id textView = HSTextRecreationParserObject(self, [NSString stringWithFormat:@"~TextViewByID_%d", itemID]);
    NSUInteger traits = [self fontTraitMaskForFaceStyle:face applyToObject:textView];
    if (traits & NSCondensedFontMask)
        HSTextRecreationSetParserObject(self, @"YES", [NSString stringWithFormat:@"~TextViewCondensedByID_%d", itemID]);
    if (traits & NSExpandedFontMask)
        HSTextRecreationSetParserObject(self, @"YES", [NSString stringWithFormat:@"~TextViewExpandedByID_%d", itemID]);
}
// The run's font (Arial if unknown, then the 12-pt system font), resized
// until its ascender matches the run's recorded ascent: up while it's
// smaller, then down while it's larger. A new size is only taken when it
// moves the (relative) ascender the right way, as in the original.
- (void)processBy_tbAttributes_scrpFont_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *name = HSTextRecreationParserObject(self, [NSString stringWithFormat:@"~fontByID_%d", [aValue unsignedIntValue]]);
    if (name == nil || [name isEqualToString:@""])
        name = @"Arial";
    float size = [HSTextRecreationParserObject(self, @"~TextViewFontSize") floatValue];
    NSFont *font = [NSFont fontWithName:name size:size];
    if (font == nil) {
        font = [NSFont fontWithName:@"Arial" size:size];
        [self setFontWarning:YES];
    }
    if (font == nil) {
        size = 12;
        font = [NSFont systemFontOfSize:12];
    }
    if (font == nil)
        return;
    float ascent = [HSTextRecreationParserObject(self, @"~TextViewFontSize1") floatValue];
    float ascender = [font ascender];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    do {
        size += 1;
        NSFont *resized = [manager convertFont:font toSize:size];
        float current = fmaxf(HSTextRecreationMagnitude(ascent), HSTextRecreationMagnitude(ascender)) * 0.0005f;
        float candidate = fmaxf(HSTextRecreationMagnitude(ascent), HSTextRecreationMagnitude([resized ascender])) * 0.0005f;
        if (candidate >= current) {
            ascender = [resized ascender];
            font = resized;
        }
    } while (ascender < ascent);
    do {
        size -= 1;
        if (size <= 0)
            break;
        NSFont *resized = [manager convertFont:font toSize:size];
        float current = fmaxf(HSTextRecreationMagnitude(ascent), HSTextRecreationMagnitude(ascender)) * 0.0005f;
        float candidate = fmaxf(HSTextRecreationMagnitude(ascent), HSTextRecreationMagnitude([resized ascender])) * 0.0005f;
        if (current >= candidate) {
            ascender = [resized ascender];
            font = resized;
        }
    } while (ascender > ascent);
    HSTextRecreationSetParserObject(self, font, @"~TextViewFont");
}
- (void)processBy_tbAttributes_scrpAscent_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSTextRecreationSetParserObject(self, aValue, @"~TextViewFontSize1");
}
- (void)processBy_tbAttributes_scrpHeight_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSTextRecreationSetParserObject(self, aValue, @"~TextViewFontSize");
}
- (void)processBy_tbAttributes_scrpStartChar_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSTextRecreationSetParserObject(self, aValue, @"~HTextViewAttributesStartChar");
}
// The item's text; flag 0x40 means it's the Mac Roman file at that path
// (after a leading marker character).
- (void)processBy_tbItem_tbTextText_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aParser intEvaluate:@"itemTextStackHeader.type.itemstatflags"] & 0x40) {
        NSString *path = [self actionObjectPathForApplePath:[aValue substringFromIndex:1]];
        aValue = [NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:NULL];
    }
    if (aValue == nil)
        return;
    NSAttributedString *text = [[[NSAttributedString alloc] initWithString:aValue] autorelease];
    HSTextRecreationSetParserObject(self, text, @"~ClearTextViewText");
    HSTextRecreationSetParserObject(self, text, @"~TextViewText");
}
- (void)processBy_tbTextHeader_TBcard_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSTextRecreationSetParserObject(self, aValue, @"~TextViewTBCardId");
}
- (void)processBy_itemTextStackHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self setOldCursorForObject:HSTextRecreationParserObject(self, @"~TextView") withOldCursorId:[aValue intValue]];
}
// Registers the text view as the object of its click action.
- (void)processBy_itemTextStackHeader_actionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] == 0)
        return;
    id textView = HSTextRecreationParserObject(self, @"~TextView");
    id itemID = HSTextRecreationParserObject(self, @"itemTextStackHeader.type.id");
    HSTextRecreationSetParserObject(self, textView, [NSString stringWithFormat:@"~clickingActionObjectByID_%@_%@", itemID, aValue]);
    HSTextRecreationSetParserObject(self, textView, [NSString stringWithFormat:@"~clickingActionObjectOnlyByID_%@", aValue]);
    HSTextRecreationSetParserObject(self, textView, [NSString stringWithFormat:@"~clickingActionObjectOnlyWinByID_%@", itemID]);
}
- (void)processBy_defaultTS_tsSize_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSTextRecreationSetParserObject(self, aValue, @"~TextViewDefaultFontSize");
}
// Names the text view and registers it under its old name (first one wins
// on the card) for actions that refer to fields by name.
- (void)processBy_itemTextStackHeader_name_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *name = aValue;
    if ([aValue isKindOfClass:[NSData class]])
        name = [self stringForImportedData:aValue];
    id textView = HSTextRecreationParserObject(self, @"~TextView");
    id card = HSTextRecreationParserObject(self, @"~Card");
    NSString *itemName = [HSOldFormatDocument recreationItemNameFromString:name];
    NSString *byNameKey = [NSString stringWithFormat:@"~textBoxByName_%@", itemName];
    if ([card userInfoForKey:byNameKey] == nil)
        [card setUserInfo:textView forKey:byNameKey];
    if (HSTextRecreationParserObject(self, byNameKey) == nil)
        HSTextRecreationSetParserObject(self, textView, byNameKey);
    HSTextRecreationSetParserObject(self, textView, [NSString stringWithFormat:@"~itemName_%@_type_%@_%@", itemName, @"FIELD", [self uniqueImportedIndexString]]);
    NSString *shortNameKey = [NSString stringWithFormat:@"~itemShortName_%@_type_%@", itemName, @"FIELD"];
    if ([card userInfoForKey:shortNameKey] == nil)
        [card setUserInfo:textView forKey:shortNameKey];
    [textView setUserInfo:textView forKey:shortNameKey];
    [textView setUserInfo:itemName forKey:@"~itemNameOld"];
    [textView setUserInfo:@"FIELD" forKey:@"~itemTypeOld"];
    [textView setHyperName:name];
}
// A colour index into the stack's palette, unless the item is transparent.
- (void)processBy_itemTextStackHeader_contentcolor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id textView = HSTextRecreationParserObject(self, @"~TextView");
    int index = [aValue intValue];
    if (![[textView backgroundColor] isEqualTo:[NSColor clearColor]])
        [textView setBackgroundColor:[[self graphicsImport] backgroundColorAtIndex:index]];
}
// Flags: 2 read-only, 1 scroll bar, 0x80 not scrollable, 8 border. Plain
// transparent read-only text without border or scroller can be rotated.
- (void)processBy_itemTextStackHeader_textflags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int flags = [[self parser] intEvaluate:aValue];
    id textView = HSTextRecreationParserObject(self, @"~TextView");
    [textView setEditable:(flags & 2) == 0];
    [textView setHasVerticalScroller:(flags & 1) != 0];
    [[textView queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setScrollable:(flags & 0x80) == 0];
    [textView setBorderType:(flags & 8) != 0];
    BOOL rotatable = ![textView isEditable] && [textView borderType] == 0 && ![textView hasVerticalScroller] && [[textView backgroundColor] isEqualTo:[NSColor clearColor]];
    [textView setRotatableText:rotatable];
}
// Flag 0x80: transparent background.
- (void)processBy_itemTextStackHeader_itemstatflags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id textView = HSTextRecreationParserObject(self, @"~TextView");
    if ([[self parser] intEvaluate:aValue] & 0x80)
        [textView setBackgroundColor:[NSColor clearColor]];
}
// The item's rectangle starts a new text item: a default text view (black
// 12-pt Arial, not rotatable, a blank text), with the item's hidden /
// locked / shared state, added to the card at that frame.
- (void)processBy_itemTextStackHeader_rect_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSTextRecreationSetParserObject(self, nil, @"~TextViewFontSize1");
    HSTextRecreationSetParserObject(self, nil, @"~TextViewFontSize");
    id textView = [HSSystemTextView defaultObject];
    [textView setRotatableText:NO];
    [textView setTextColor:[NSColor blackColor]];
    [textView setFont:[NSFont fontWithName:@"Arial" size:12]];
    [textView setHyperText:[[[NSAttributedString alloc] initWithString:@" "] autorelease]];
    [textView setScrollBarSize:0];
    [textView setHidden:_isHiddenItem];
    [textView setLocked:_isLocked];
    if (_isSharedItem) {
        if (!_isMasterCardIdExists)
            [textView setUserInfo:@"YES" forKey:@"~MasterObject"];
        if (![textView isGroupObject])
            [textView makeGroupObject];
    }
    [HSTextRecreationParserObject(self, @"~Card") addHyperChild:textView];
    HSTextRecreationSetParserObject(self, textView, @"~TextView");
    NSRect frame = NSRectFromString(aValue);
    id applier = [[textView queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier moveFrameBoundingRectOriginTo:frame.origin withLayoutGuidingContext:nil];
    [applier resizeFrameTo:frame.size aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
    id itemID = HSTextRecreationParserObject(self, @"itemTextStackHeader.type.id");
    HSTextRecreationSetParserObject(self, textView, [NSString stringWithFormat:@"~hyperlinkObjectByID_%@_%@", itemID, itemID]);
    HSTextRecreationSetParserObject(self, textView, [NSString stringWithFormat:@"~TextViewByID_%d", [itemID intValue]]);
}
@end
