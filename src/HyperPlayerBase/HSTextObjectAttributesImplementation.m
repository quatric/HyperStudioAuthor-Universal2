#import "HSTextObjectAttributesImplementation.h"
#import "HSProtocolIdentifier.h"

static NSString *HSTextObjectUndoName(NSString *aKey)
{
    return [[NSBundle mainBundle] localizedStringForKey:aKey value:@"" table:@"UndoManager"];
}

// The text attributes of a text object, applied through its core text with
// undo names. Getters record whether the text holds several values. With an
// interface set, other interfaces are answered by the text object itself.
@implementation HSTextObjectAttributesImplementation

- (id)attributeObservingController
{
    return [_hyperObject attributeObservingController];
}

- (void)textDidChangeAttributes:(id)aAttributes
{
    [_hyperObject notifyChange:2 ofAttribute:@protocol(HSTextAttribute) withUserInfo:nil];
}

- (void)textDidChangeText:(id)aText
{
    [_hyperObject notifyChange:2 ofAttribute:@protocol(HSTextAttribute) withUserInfo:nil];
}

// The generic solid color is the text color.
- (void)setHyperDroppedSolidColor:(id)aColor
{
    _lastAccessMultipleValues = NO;
    [self setHyperTextColor:aColor];
}

- (void)setHyperSolidColor:(id)aColor
{
    _lastAccessMultipleValues = NO;
    [self setHyperTextColor:aColor];
}

- (id)hyperSolidColor
{
    _lastAccessMultipleValues = NO;
    return [[self coreTextInterface] hyperTextColor];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] applyCharacterAttributesWithAttributesConverter:aConverter undoActionName:HSTextObjectUndoName(@"Change Text Attributes")];
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] applyFontWithFontConverter:aConverter undoActionName:HSTextObjectUndoName(@"Change Text Font")];
}

- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    _lastAccessMultipleValues = NO;
    id font = nil;
    [[self coreTextInterface] getHyperFont:&font multipleValues:aMultiple];
    return font;
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
    _lastAccessMultipleValues = NO;
}

- (id)hyperTextAttributes
{
    _lastAccessMultipleValues = NO;
    return [[self coreTextInterface] hyperTextAttributesDictionary];
}

- (void)setHyperFont:(id)aFont
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperFont:aFont undoActionName:HSTextObjectUndoName(@"Change Text Font")];
}

- (id)hyperFont
{
    _lastAccessMultipleValues = NO;
    id font = nil;
    [[self coreTextInterface] getHyperFont:&font multipleValues:&_lastAccessMultipleValues];
    return font;
}

- (BOOL)isHyperEmpty
{
    _lastAccessMultipleValues = NO;
    return [[self coreTextInterface] isHyperEmpty];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperSpaceBetweenCharacters:aCharacters undoActionName:HSTextObjectUndoName(@"Change Space Between Characters")];
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    _lastAccessMultipleValues = NO;
    float space = 0.0f;
    [[self coreTextInterface] getHyperSpaceBetweenCharacters:&space multipleValues:&_lastAccessMultipleValues];
    return space;
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperSpaceBetweenLines:aLines undoActionName:HSTextObjectUndoName(@"Change Line Spacing")];
}

- (CGFloat)hyperSpaceBetweenLines
{
    _lastAccessMultipleValues = NO;
    float space = 0.0f;
    [[self coreTextInterface] getHyperSpaceBetweenLines:&space multipleValues:&_lastAccessMultipleValues];
    return space;
}

- (void)setHyperTextAlignment:(NSUInteger)aAlignment
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperTextAlignment:aAlignment undoActionName:HSTextObjectUndoName(@"Text Alignment")];
}

- (NSUInteger)hyperTextAlignment
{
    _lastAccessMultipleValues = NO;
    unsigned int alignment = 0;
    [[self coreTextInterface] getHyperTextAlignment:&alignment multipleValues:&_lastAccessMultipleValues];
    return alignment;
}

- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] hyperReplaceTextWithString:aString inRange:aRange undoActionName:HSTextObjectUndoName(@"Change Text")];
}

- (void)hyperReplaceTextWithString:(id)aString
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] hyperReplaceTextWithString:aString undoActionName:HSTextObjectUndoName(@"Change Text")];
}

- (void)hyperReplaceText:(id)aText
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] hyperReplaceText:aText undoActionName:HSTextObjectUndoName(@"Change Text")];
}

// The core text itself stands for the text.
- (id)hyperText
{
    _lastAccessMultipleValues = NO;
    return [self coreTextInterface];
}

- (void)setHyperTextColor:(id)aColor
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperTextColor:aColor undoActionName:HSTextObjectUndoName(@"Change Text Color")];
}

- (id)hyperTextColor
{
    _lastAccessMultipleValues = NO;
    id color = nil;
    [[self coreTextInterface] getHyperTextColor:&color multipleValues:&_lastAccessMultipleValues];
    return color;
}

- (void)finishOutlineMutating:(BOOL)aMutating
{
    [[self coreTextInterface] finishOutlineMutating:aMutating undoActionName:HSTextObjectUndoName(@"Outline Change")];
}

- (void)startOutlineMutating
{
    [[self coreTextInterface] startOutlineMutating];
}

- (void)setHyperOutlineColor:(id)aColor
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperOutlineColor:aColor undoActionName:HSTextObjectUndoName(@"Outline Color")];
}

- (id)hyperOutlineColor
{
    _lastAccessMultipleValues = NO;
    id color = nil;
    [[self coreTextInterface] getHyperOutlineColor:&color multipleValues:&_lastAccessMultipleValues];
    return color;
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperOutlineWidth:aWidth undoActionName:HSTextObjectUndoName(@"Outline Width")];
}

- (CGFloat)hyperOutlineWidth
{
    _lastAccessMultipleValues = NO;
    float width = 0.0f;
    [[self coreTextInterface] getHyperOutlineWidth:&width multipleValues:&_lastAccessMultipleValues];
    return width;
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperOutlineEnabled:aEnabled undoActionName:HSTextObjectUndoName(@"Outline")];
}

- (BOOL)isHyperOutlineEnabled
{
    _lastAccessMultipleValues = NO;
    BOOL enabled = NO;
    [[self coreTextInterface] getHyperOutlineEnabled:&enabled multipleValues:&_lastAccessMultipleValues];
    return enabled;
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperUnderlined:aUnderlined undoActionName:HSTextObjectUndoName(@"Underline")];
}

- (BOOL)isHyperUnderlined
{
    _lastAccessMultipleValues = NO;
    BOOL underlined = NO;
    [[self coreTextInterface] getHyperUnderlined:&underlined multipleValues:&_lastAccessMultipleValues];
    return underlined;
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperCondensed:aCondensed undoActionName:HSTextObjectUndoName(@"Condensed")];
}

- (BOOL)isHyperCondensed
{
    _lastAccessMultipleValues = NO;
    BOOL condensed = NO;
    [[self coreTextInterface] getHyperCondensed:&condensed multipleValues:&_lastAccessMultipleValues];
    return condensed;
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperExpanded:aExpanded undoActionName:HSTextObjectUndoName(@"Expanded")];
}

- (BOOL)isHyperExpanded
{
    _lastAccessMultipleValues = NO;
    BOOL expanded = NO;
    [[self coreTextInterface] getHyperExpanded:&expanded multipleValues:&_lastAccessMultipleValues];
    return expanded;
}

- (void)setHyperItalic:(BOOL)aItalic
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperItalic:aItalic undoActionName:HSTextObjectUndoName(@"Italic")];
}

- (BOOL)isHyperItalic
{
    _lastAccessMultipleValues = NO;
    BOOL italic = NO;
    [[self coreTextInterface] getHyperItalic:&italic multipleValues:&_lastAccessMultipleValues];
    return italic;
}

- (void)setHyperBold:(BOOL)aBold
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperBold:aBold undoActionName:HSTextObjectUndoName(@"Bold")];
}

- (BOOL)isHyperBold
{
    _lastAccessMultipleValues = NO;
    BOOL bold = NO;
    [[self coreTextInterface] getHyperBold:&bold multipleValues:&_lastAccessMultipleValues];
    return bold;
}

- (void)setHyperFontSize:(CGFloat)aSize
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperFontSize:aSize undoActionName:HSTextObjectUndoName(@"Change Font Size")];
}

- (CGFloat)hyperFontSize
{
    _lastAccessMultipleValues = NO;
    float size = 0.0f;
    [[self coreTextInterface] getHyperFontSize:&size multipleValues:&_lastAccessMultipleValues];
    return size;
}

- (void)setHyperFontFamilyWithFont:(id)aFont
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperFontFamilyWithFont:aFont undoActionName:HSTextObjectUndoName(@"Change Text Font")];
}

- (void)setHyperFontFamily:(id)aFamily
{
    _lastAccessMultipleValues = NO;
    [[self coreTextInterface] setHyperFontFamily:aFamily undoActionName:HSTextObjectUndoName(@"Change Text Font")];
}

- (id)hyperFontFamily
{
    _lastAccessMultipleValues = NO;
    id family = nil;
    [[self coreTextInterface] getHyperFontFamily:&family multipleValues:&_lastAccessMultipleValues];
    return family;
}

// Fetched once from the text object, observing its text changes.
- (id)coreTextInterface
{
    if (_text != nil)
        return _text;
    _text = [[_hyperObject coreTextInterface] retain];
    if (_text == nil)
        return nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeText:) name:@"HSCoreTextDidChangeTextNotification" object:_text];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeAttributes:) name:@"HSCoreTextDidChangeAttributesNotification" object:_text];
    _didRegisterForTextNotifications = YES;
    return _text;
}

- (BOOL)lastHyperAccessDidReturnMultipleValues
{
    return _lastAccessMultipleValues;
}

- (id)queryHyperInterface:(id)aInterface
{
    _lastAccessMultipleValues = NO;
    if (_allowedInterfaces != nil && ![_allowedInterfaces containsObject:[HSProtocolIdentifier identifierForProtocol:aInterface]])
        return [[self hyperObject] queryHyperInterface:aInterface];
    return [super queryHyperInterface:aInterface];
}

- (id)hyperObject
{
    _lastAccessMultipleValues = NO;
    return _hyperObject;
}

- (void)dealloc
{
    if (_didRegisterForTextNotifications)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_text release];
    [_allowedInterfaces release];
    [_hyperObject release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject
{
    return [self initWithHyperObject:aObject interfaces:nil];
}

- (id)initWithHyperObject:(id)aObject interfaces:(id)aInterfaces
{
    self = [super init];
    if (self != nil) {
        _hyperObject = [aObject retain];
        _allowedInterfaces = [aInterfaces retain];
    }
    return self;
}

@end
