#import "HSText.h"
#import "HSCoreText.h"
#import "HSNode.h"

@implementation HSText

/* i386 ivar offsets: _text=0x4, _font=0x8, _textAttributesBackup=0xc, _owner=0x10, _lastAccessMultipleValues=0x14 */

// Most attributes are forwarded to the core text, which registers the undo
// action under the given name.
- (void)setHyperSpaceBetweenLines:(CGFloat)aLines
{
    [_text setHyperSpaceBetweenLines:aLines undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Line Spacing" value:@"" table:@"UndoManager"]];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    [_text setHyperSpaceBetweenCharacters:aCharacters undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Space Between Characters" value:@"" table:@"UndoManager"]];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius
{
    [_text setHyperShadowBlurRadius:aRadius undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Shadow Blur Radius" value:@"" table:@"UndoManager"]];
}

- (void)setHyperShadowOffset:(NSSize)aOffset
{
    [_text setHyperShadowOffset:aOffset undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Shadow Offset" value:@"" table:@"UndoManager"]];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    [_text setHyperShadowAngle:aAngle undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Shadow Angle" value:@"" table:@"UndoManager"]];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    [_text setHyperShadowDistance:aDistance undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Shadow Distance" value:@"" table:@"UndoManager"]];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled
{
    [_text setHyperShadowEnabled:aEnabled undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Shadow" value:@"" table:@"UndoManager"]];
}

- (void)setHyperAlignment:(NSInteger)aAlignment
{
    [_text setHyperTextAlignment:aAlignment undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Text Alignment" value:@"" table:@"UndoManager"]];
}

- (void)finishOutlineMutating:(BOOL)aMutating
{
    [_text finishOutlineMutating:aMutating undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Outline Change" value:@"" table:@"UndoManager"]];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    [_text setHyperOutlineWidth:aWidth undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Outline Width" value:@"" table:@"UndoManager"]];
}

- (void)setHyperOutlineColor:(id)aColor
{
    [_text setHyperOutlineColor:aColor undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Outline Color" value:@"" table:@"UndoManager"]];
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    [_text setHyperExpanded:aExpanded undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Expanded" value:@"" table:@"UndoManager"]];
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    [_text setHyperCondensed:aCondensed undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Condensed" value:@"" table:@"UndoManager"]];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    [_text setHyperItalic:aItalic undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Italic" value:@"" table:@"UndoManager"]];
}

- (void)setHyperBold:(BOOL)aBold
{
    [_text setHyperBold:aBold undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Bold" value:@"" table:@"UndoManager"]];
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    [_text setHyperUnderlined:aUnderlined undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Underline" value:@"" table:@"UndoManager"]];
}

- (void)setHyperFontSize:(CGFloat)aSize
{
    [_text setHyperFontSize:aSize undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Font Size" value:@"" table:@"UndoManager"]];
}

- (void)setHyperFontFamily:(id)aFamily
{
    [_text setHyperFontFamily:aFamily undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"]];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    [_text applyCharacterAttributesWithAttributesConverter:aConverter undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text Attributes" value:@"" table:@"UndoManager"]];
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    [_text applyFontWithFontConverter:aConverter undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"]];
}

- (void)setBackgroundColor:(id)aColor
{
    [_text setHyperTextBackgroundColor:aColor undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Background Color" value:@"" table:@"UndoManager"]];
}

- (void)setTextColor:(id)aColor
{
    [_text setHyperTextColor:aColor undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text Color" value:@"" table:@"UndoManager"]];
}

- (CGFloat)hyperSpaceBetweenLines
{
    return [_text hyperSpaceBetweenLines];
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    return [_text hyperSpaceBetweenCharacters];
}

- (CGFloat)hyperShadowDistance
{
    return [_text hyperShadowDistance];
}

- (CGFloat)hyperShadowBlurRadius
{
    return [_text hyperShadowBlurRadius];
}

- (NSSize)hyperShadowOffset
{
    return [_text hyperShadowOffset];
}

- (CGFloat)hyperShadowAngle
{
    return [_text hyperShadowAngle];
}

- (BOOL)isHyperShadowEnabled
{
    return [_text isHyperShadowEnabled];
}

- (NSInteger)hyperAlignment
{
    return [_text hyperTextAlignment];
}

- (CGFloat)hyperOutlineWidth
{
    return [_text hyperOutlineWidth];
}

- (id)hyperOutlineColor
{
    return [_text hyperOutlineColor];
}

- (BOOL)isHyperOutlineEnabled
{
    return [_text isHyperOutlineEnabled];
}

- (BOOL)isHyperExpanded
{
    return [_text isHyperExpanded];
}

- (BOOL)isHyperCondensed
{
    return [_text isHyperCondensed];
}

- (BOOL)isHyperItalic
{
    return [_text isHyperItalic];
}

- (BOOL)isHyperBold
{
    return [_text isHyperBold];
}

- (BOOL)isHyperUnderlined
{
    return [_text isHyperUnderlined];
}

- (CGFloat)hyperFontSize
{
    return [_text hyperFontSize];
}

- (id)hyperFontFamily
{
    return [_text hyperFontFamily];
}

- (id)hyperFont
{
    return [_text hyperFont];
}

- (id)hyperPlainText
{
    return [_text hyperString];
}

- (id)hyperText
{
    return [_text hyperText];
}

- (id)backgroundColor
{
    return [_text hyperTextBackgroundColor];
}

- (id)textColor
{
    return [_text hyperTextColor];
}

- (id)hyperString
{
    return [_text hyperString];
}

- (BOOL)hasMultipleShadowStyles
{
    BOOL multipleValues = NO;
    id shadow = nil;
    [_text getHyperShadow:&shadow multipleValues:&multipleValues];
    return multipleValues;
}

- (void)startOutlineMutating
{
    [_text startOutlineMutating];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    if ([self isHyperOutlineEnabled] != aEnabled)
        [_text setHyperOutlineEnabled:aEnabled undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Outline" value:@"" table:@"UndoManager"]];
}

- (id)attributeObservingController
{
    return _owner;
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (id)hyperTextAttributes
{
    return [[[_text hyperTextAttributesDictionary] retain] autorelease];
}

- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    id font = nil;
    [_text getHyperFont:&font multipleValues:aMultiple];
    return font;
}

- (void)setHyperTextAttributes:(id)aAttributes
{
    [self setHyperTextAttributes:aAttributes range:NSMakeRange(0, [[_text hyperString] length])];
}

// Undo restores the attributes found at the start of the range.
- (void)setHyperTextAttributes:(id)aAttributes range:(NSRange)aRange
{
    if ([[self hyperTextAttributes] isEqual:aAttributes])
        return;
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSDictionary *attributes = [[_text textStorage] attributesAtIndex:aRange.location effectiveRange:NULL];
        NSDictionary *previous = nil;
        if (attributes != nil)
            previous = [NSDictionary dictionaryWithDictionary:attributes];
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text Attributes" value:@"" table:@"UndoManager"]];
        [[undoManager prepareWithInvocationTarget:self] setHyperTextAttributes:previous range:aRange];
        [pool release];
    }
    id object = [self hyperObject];
    // Quirk kept: both notifications announce the change as "will change".
    [object notifyChange:1 ofAttribute:@protocol(HSGenericFontAttributesAttribute) withUserInfo:nil];
    [[_text textStorage] setAttributes:aAttributes range:aRange];
    [object notifyChange:1 ofAttribute:@protocol(HSGenericFontAttributesAttribute) withUserInfo:nil];
}

- (void)setHyperFont:(id)aFont
{
    if (![[self font] isEqual:aFont])
        [_text setHyperFont:aFont undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"]];
}

- (void)applyHyperTextAttributesDictionary:(id)aDictionary
{
    [self setHyperTextAttributes:aDictionary range:NSMakeRange(0, [[_text textStorage] length])];
    [(id)_owner textDidChange:self];
}

- (void)setHyperPlainText:(id)aText
{
    if ([[self hyperPlainText] isEqualToString:aText])
        return;
    [_text hyperReplaceTextWithString:aText undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"]];
    [(id)_owner textDidChange:self];
}

- (void)replaceTextInRange:(NSRange)aRange withAttributedString:(id)aString
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[self hyperText]];
    [text replaceCharactersInRange:aRange withAttributedString:aString];
    if (![text isEqualToAttributedString:[self hyperText]]) {
        [_text hyperReplaceText:text undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"]];
        [(id)_owner textDidChange:self];
    }
    [text release];
}

// A text that cannot be set is replaced by an empty one.
- (void)setHyperText:(id)aText
{
    if ([[self hyperText] isEqualToAttributedString:aText])
        return;
    NSString *actionName = [[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"];
    @try {
        [_text hyperReplaceText:aText undoActionName:actionName];
    } @catch (NSException *exception) {
        NSAttributedString *empty = [[NSAttributedString alloc] initWithString:@""];
        [_text hyperReplaceText:empty undoActionName:actionName];
        [empty release];
    }
    [(id)_owner textDidChange:self];
}

- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName
{
    [[self hyperObject] notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
    [(id)_owner textDidChange:self];
}

- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName
{
    [[self hyperObject] notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
    [(id)_owner textDidChange:self];
}

- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName
{
    if (aName != nil)
        [[self undoManager] setActionName:aName];
}

- (void)textDidChangeAttributes:(id)aAttributes
{
    [[self hyperObject] notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
    [(id)_owner textDidChange:self];
}

- (void)textWillChangeAttributes:(id)aAttributes
{
    [[self hyperObject] notifyChange:1 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)textDidChangeText:(id)aText
{
    [[self hyperObject] notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
    [(id)_owner textDidChange:self];
}

- (void)textWillChangeText:(id)aText
{
    [[self hyperObject] notifyChange:1 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (id)undoManager
{
    return [_owner undoManager];
}

// The font is also applied to all of the current text.
- (void)setFont:(id)aFont
{
    if ([_font isEqual:aFont])
        return;
    [_font release];
    _font = [aFont retain];
    if (_font != nil && _text != nil && [[_text hyperString] length] != 0)
        [[_text textStorage] addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, [[_text hyperString] length])];
    [(id)_owner textDidChange:self];
}

// The font of the first character, else the stored font (the system font by
// default), else the owner's default text font.
- (id)font
{
    NSAttributedString *text = [self hyperText];
    NSFont *font = nil;
    if (text != nil && [text length] != 0)
        font = [[text fontAttributesInRange:NSMakeRange(0, 1)] objectForKey:NSFontAttributeName];
    if (font == nil) {
        font = _font;
        if (font == nil) {
            [self setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
            font = _font;
        }
    }
    if (font == nil && [_owner respondsToSelector:@selector(defaultTextFont)])
        font = [_owner defaultTextFont];
    return font;
}

- (void)backupTextAttributes
{
    if ([[_text hyperString] length] != 0) {
        [_textAttributesBackup release];
        _textAttributesBackup = [[_text hyperTextAttributesDictionary] copy];
    }
}

- (void)restoreTextAttributes
{
    if ([[_text hyperString] length] != 0 && _textAttributesBackup != nil)
        [[_text textStorage] addAttributes:_textAttributesBackup range:NSMakeRange(0, [[_text hyperString] length])];
}

- (void)dealloc
{
    [_text release];
    [_textAttributesBackup release];
    [_font release];
    [super dealloc];
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)initWithOwner:(id)aOwner
{
    self = [super init];
    if (self != nil) {
        _owner = aOwner;
        _text = [[HSCoreText alloc] init];
        [_text setParent:self];
        [_owner linkAttribute:@protocol(HSStringValueAttribute) toAttribute:@protocol(HSTextViewTextAttribute)];
    }
    return self;
}

- (id)hyperObject
{
    return _owner;
}

@end
