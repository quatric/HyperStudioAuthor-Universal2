#import "HSSystemTextField.h"
#import "HSSystemTextFieldData.h"
#import "HSSystemObjectVisualization.h"
#import "HSInteractiveTextFieldObject.h"
#import "HSProtocolIdentifier.h"
#import "EXCodingContext.h"
#import "NSFont+HSFont.h"

// A text field (NSTextField). Its string is the title; changes are undoable
// and notified as attribute changes. An editable or selectable field can't be
// dragged, resized or rotated.
@implementation HSSystemTextField

+ (Class)nodeDataClass
{
    return [HSSystemTextFieldData class];
}

- (id)valuesForMDAttribute:(id)aAttribute
{
    id string;
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent] && (string = [self objectString]))
        return [[super valuesForMDAttribute:aAttribute] arrayByAddingObject:string];
    return [super valuesForMDAttribute:aAttribute];
}

- (id)supportedMDAttributes
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super supportedMDAttributes]];
    if (![attributes containsObject:(NSString *)kMDItemTextContent])
        [attributes addObject:(NSString *)kMDItemTextContent];
    return attributes;
}

- (void)replaceObjectString:(id)aString inRanges:(id)aRanges
{
    NSMutableString *string = [NSMutableString stringWithString:[self hyperStringValue]];
    NSInteger count = [aRanges count];
    for (NSInteger index = 0; index < count; index++)
        [string replaceCharactersInRange:[[aRanges objectAtIndex:index] rangeValue] withString:aString];
    [self setHyperStringValue:string];
}

- (void)setObjectString:(id)aString
{
    [self setHyperStringValue:aString];
}

- (id)objectString
{
    return [self hyperStringValue];
}

- (id)hyperSizeMinValue
{
    CGFloat miniHeight = [[self textFieldSizesInfo] extraFloatForKey:@"mini"];
    NSSize cellSize = [[[[self nodeData] systemTextFieldForGetAccessor] cell] cellSize];
    // The original takes the cell height as the minimum width.
    return NSStringFromSize(NSMakeSize(cellSize.height, miniHeight));
}

- (id)textFieldBorderTypesInfo
{
    if ([[self nodeData] textFieldBorderTypes] == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"HSSystemTextFieldBorders" ofType:@"plist"];
        if (path != nil)
            [[self nodeData] setTextFieldBorderTypes:[NSDictionary dictionaryWithContentsOfFile:path]];
    }
    return [[self nodeData] textFieldBorderTypes];
}

- (id)textFieldSizesInfo
{
    if ([[self nodeData] textFieldSizes] == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"HSSystemTextFieldSizes" ofType:@"plist"];
        if (path != nil)
            [[self nodeData] setTextFieldSizes:[NSDictionary dictionaryWithContentsOfFile:path]];
    }
    return [[self nodeData] textFieldSizes];
}

- (void)hyperAutoSizeToFitTitle
{
    [self hyperSizeToFitContentHorizontally:YES vertically:NO];
}

- (NSUInteger)hyperTitleAlignment
{
    return [self hyperTextAlignment];
}

- (void)setTitleFont:(id)aFont
{
}

- (id)titleFont
{
    return [NSFont fontWithName:[[self font] fontName] size:[self fontSize]];
}

- (void)setTitle:(id)aTitle
{
    [self setHyperStringValue:aTitle];
}

- (id)title
{
    return [self hyperStringValue];
}

- (BOOL)hasHyperTitle
{
    return YES;
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
}

- (id)hyperTextAttributes
{
    return nil;
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    [self setHyperFont:[aConverter convertFont:[self font]]];
}

- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    if (aMultiple)
        *aMultiple = NO;
    return [self hyperFont];
}

- (BOOL)isHyperExpanded
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSExpandedFontMask) != 0;
}

- (BOOL)isHyperCondensed
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSCondensedFontMask) != 0;
}

- (BOOL)isHyperItalic
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSItalicFontMask) != 0;
}

- (BOOL)isHyperBold
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSBoldFontMask) != 0;
}

- (id)hyperFontFamily
{
    return [[self hyperFont] familyName];
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    NSFont *font = [self hyperFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aExpanded ? [manager convertFont:font toHaveTrait:NSExpandedFontMask] : [manager convertFont:font toNotHaveTrait:NSExpandedFontMask];
    [self setHyperFont:font];
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    NSFont *font = [self hyperFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aCondensed ? [manager convertFont:font toHaveTrait:NSCondensedFontMask] : [manager convertFont:font toNotHaveTrait:NSCondensedFontMask];
    [self setHyperFont:font];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    NSFont *font = [self hyperFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aItalic ? [manager convertFont:font toHaveTrait:NSItalicFontMask] : [manager convertFont:font toNotHaveTrait:NSItalicFontMask];
    [self setHyperFont:font];
}

- (void)setHyperBold:(BOOL)aBold
{
    NSFont *font = [self hyperFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aBold ? [manager convertFont:font toHaveTrait:NSBoldFontMask] : [manager convertFont:font toNotHaveTrait:NSBoldFontMask];
    [self setHyperFont:font];
}

// The size follows the control size.
- (void)setHyperFontSize:(CGFloat)aSize
{
}

- (void)setHyperFontFamily:(id)aFamily
{
    [self setHyperFont:[[NSFontManager sharedFontManager] convertFont:[self hyperFont] toFamily:aFamily]];
}

// The font keeps the size of the control size.
- (void)setHyperFont:(id)aFont
{
    NSFont *oldFont = [self font];
    NSFont *font = [NSFont fontWithName:[aFont fontName] size:[self fontSize]];
    if (oldFont == font || (font != nil && [oldFont isEqual:font]))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Placeholder String Font" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperFont:oldFont];
    [self notifyChange:1 ofAttribute:@protocol(HSGenericFontAttribute) withUserInfo:nil];
    [self setFont:font];
    [self notifyChange:2 ofAttribute:@protocol(HSGenericFontAttribute) withUserInfo:nil];
}

- (id)hyperFont
{
    return [NSFont fontWithName:[[self font] fontName] size:[self fontSize]];
}

- (NSSize)defaultSize
{
    return NSMakeSize(89.0, 22.0);
}

- (BOOL)canResizeVertically
{
    return NO;
}

- (BOOL)canResizeHorizontally
{
    return YES;
}

- (BOOL)canBreakSizeAspectRatio
{
    return YES;
}

- (void)setHyperBezeled:(BOOL)aBezeled
{
    if ([self isBezeled] == aBezeled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Bezel Style" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperBezeled:[self isBezeled]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextFieldBezeledAttribute) withUserInfo:nil];
    [self setBezeled:aBezeled];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextFieldBezeledAttribute) withUserInfo:nil];
}

- (BOOL)isHyperBezeled
{
    return [self isBezeled];
}

- (void)setHyperBordered:(BOOL)aBordered
{
    if ([self isBordered] == aBordered)
        return;
    // "Boreder" is the original's undo key.
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Boreder Type" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperBordered:[self isBordered]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextFieldBorderedAttribute) withUserInfo:nil];
    [self setBordered:aBordered];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextFieldBorderedAttribute) withUserInfo:nil];
}

- (BOOL)isHyperBordered
{
    return [self isBordered];
}

// Editing and selecting change whether the field can be dragged, resized or
// rotated, so those are notified too when they change.
- (void)HSSystemTextField_notifyCardObjectAbilitiesChangedFromDraggable:(BOOL)aDraggable resizable:(BOOL)aResizable rotatable:(BOOL)aRotatable
{
    if ([self canBeDraggable] != aDraggable)
        [self notifyChange:2 ofAttribute:@protocol(HSCardObjectDraggableAttribute) withUserInfo:nil];
    if ([self canBeResizable] != aResizable)
        [self notifyChange:2 ofAttribute:@protocol(HSCardObjectResizableAttribute) withUserInfo:nil];
    if ([self canBeRotatable] != aRotatable)
        [self notifyChange:2 ofAttribute:@protocol(HSCardObjectRotatableAttribute) withUserInfo:nil];
}

- (void)setEditable:(BOOL)aEditable
{
    BOOL editable = [self isEditable];
    if (editable == (aEditable != NO))
        return;
    BOOL draggable = [self canBeDraggable];
    BOOL resizable = [self canBeResizable];
    BOOL rotatable = [self canBeRotatable];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Editabling" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setEditable:editable];
    [[[self undoManager] prepareWithInvocationTarget:self] setSelectable:[self isSelectable]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemEditableAttribute) withUserInfo:nil];
    [[self nodeData] setEditable:aEditable];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemEditableAttribute) withUserInfo:nil];
    [self HSSystemTextField_notifyCardObjectAbilitiesChangedFromDraggable:draggable resizable:resizable rotatable:rotatable];
}

- (BOOL)isEditable
{
    return [[self nodeData] isEditable];
}

- (void)setSelectable:(BOOL)aSelectable
{
    BOOL selectable = [self isSelectable];
    if (selectable == (aSelectable != NO))
        return;
    BOOL draggable = [self canBeDraggable];
    BOOL resizable = [self canBeResizable];
    BOOL rotatable = [self canBeRotatable];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Selectabling" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSelectable:selectable];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextFieldSelectableAttribute) withUserInfo:nil];
    [[self nodeData] setSelectable:aSelectable];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextFieldSelectableAttribute) withUserInfo:nil];
    [self HSSystemTextField_notifyCardObjectAbilitiesChangedFromDraggable:draggable resizable:resizable rotatable:rotatable];
}

- (BOOL)isSelectable
{
    return [[self nodeData] isSelectable];
}

- (BOOL)canBeDraggable
{
    return [super canBeDraggable] && ![self isEditable] && ![self isSelectable];
}

- (BOOL)canBeResizable
{
    return [super canBeResizable] && ![self isEditable] && ![self isSelectable];
}

- (BOOL)canBeRotatable
{
    return [super canBeRotatable] && ![self isEditable] && ![self isSelectable];
}

- (id)nameBaseTemplates
{
    NSMutableArray *templates = [NSMutableArray array];
    id string = [self hyperStringValue];
    if (string != nil)
        [templates addObject:string];
    id placeholder = [self placeholderString];
    if (placeholder != nil)
        [templates addObject:placeholder];
    return templates;
}

- (void)hyperSizeToFitContent
{
    [self hyperSizeToFitContentHorizontally:YES vertically:YES];
}

// Sizes to the cell along the directions given, keeping the edge the text
// is aligned to in place.
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically
{
    id<HSMutableGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    if (!geometry)
        return;
    NSSize size = [[[[self nodeData] systemTextFieldForGetAccessor] cell] cellSize];
    CGFloat anchorX = 0.0;
    if (aHorizontally) {
        NSUInteger alignment = [self textAlignment];
        if (alignment == NSTextAlignmentRight)
            anchorX = 1.0;
        else if (alignment == NSTextAlignmentCenter || alignment == NSTextAlignmentJustified)
            anchorX = 0.5;
    } else {
        size.width = [geometry width];
    }
    if (!aVertically)
        size.height = [geometry height];
    [geometry setSize:size aboutRelativePoint:NSMakePoint(anchorX, 0.5)];
}

- (NSRect)untransformedTitleRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (!geometry)
        return NSZeroRect;
    NSRect bounds = [geometry boundingRect];
    return [[[[self nodeData] systemTextFieldForGetAccessor] cell] titleRectForBounds:bounds];
}

- (void)setHyperAttributedStringValue:(id)aValue
{
    [self setHyperStringValue:[aValue string]];
}

- (id)hyperAttributedStringValue
{
    return [[[NSAttributedString alloc] initWithString:[self stringValue]] autorelease];
}

- (void)setHyperStringValue:(id)aValue
{
    NSString *oldValue = [self stringValue];
    if ([oldValue isEqualToString:aValue])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperStringValue:oldValue];
    [self notifyChange:1 ofAttribute:@protocol(HSTitleStringAttribute) withUserInfo:nil];
    [self setStringValue:aValue];
    [self notifyChange:2 ofAttribute:@protocol(HSTitleStringAttribute) withUserInfo:nil];
}

- (id)hyperStringValue
{
    return [self stringValue];
}

- (void)setControlSize:(NSUInteger)aSize
{
    if ([self controlSize] == aSize)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Control Size" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setControlSize:[self controlSize]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemControlSizeAttribute) withUserInfo:nil];
    [[(NSTextField *)[[self nodeData] systemTextFieldForSetAccessor] cell] setControlSize:(NSControlSize)aSize];
    [self setSizeForControlSize];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemControlSizeAttribute) withUserInfo:nil];
}

- (NSUInteger)controlSize
{
    return [[(NSTextField *)[[self nodeData] systemTextFieldForGetAccessor] cell] controlSize];
}

- (void)setHyperTextAlignment:(NSUInteger)aAlignment
{
    if ([self textAlignment] == aAlignment)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Text Alignment" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperTextAlignment:[self textAlignment]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextFieldAlignmentAttribute) withUserInfo:nil];
    [self setTextAlignment:aAlignment];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextFieldAlignmentAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperTextAlignment
{
    return [self textAlignment];
}

- (void)setHyperTextFieldBezelStyle:(NSUInteger)aStyle
{
    if ([self bezelStyle] == aStyle)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Bezel Style" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperTextFieldBezelStyle:[self bezelStyle]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextFieldBezelStyleAttribute) withUserInfo:nil];
    [self setBezelStyle:aStyle];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextFieldBezelStyleAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperTextFieldBezelStyle
{
    return [self bezelStyle];
}

- (void)setHyperBorderType:(NSUInteger)aType
{
    if ([self borderType] == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Border Type" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperBorderType:[self borderType]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextFieldBorderTypeAttribute) withUserInfo:nil];
    [self setBorderType:aType];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextFieldBorderTypeAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperBorderType
{
    return [self borderType];
}

- (void)setBackgroundColor:(id)aColor
{
    if ([self backgroundColor] == aColor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Background Color" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setBackgroundColor:[self backgroundColor]];
    [self notifyChange:1 ofAttribute:@protocol(HSBackgroundColorAttribute) withUserInfo:nil];
    [(NSTextField *)[[self nodeData] systemTextFieldForSetAccessor] setBackgroundColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSBackgroundColorAttribute) withUserInfo:nil];
}

- (id)backgroundColor
{
    return [(NSTextField *)[[self nodeData] systemTextFieldForGetAccessor] backgroundColor];
}

- (void)setHyperSolidColor:(id)aColor
{
    [self setTextColor:aColor];
}

- (id)hyperSolidColor
{
    return [self textColor];
}

- (void)setTextColor:(id)aColor
{
    if ([self textColor] == aColor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Text Color" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextColor:[self textColor]];
    [self notifyChange:1 ofAttribute:@protocol(HSTextColorAttribute) withUserInfo:nil];
    [(NSTextField *)[[self nodeData] systemTextFieldForSetAccessor] setTextColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSTextColorAttribute) withUserInfo:nil];
}

- (id)textColor
{
    return [(NSTextField *)[[self nodeData] systemTextFieldForGetAccessor] textColor];
}

- (CGFloat)hyperFontSize
{
    return [self fontSize];
}

// The placeholder is visible only while the field is empty.
- (void)setHyperPlaceholderString:(id)aString
{
    NSString *oldString = [self placeholderString];
    if ([oldString isEqualToString:aString])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Placeholder String" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperPlaceholderString:oldString];
    Protocol *attribute = [[self stringValue] length] == 0 ? @protocol(HSSystemTextFieldVisualPlaceholderAttribute) : @protocol(HSSystemTextFieldPlaceholderAttribute);
    [self notifyChange:1 ofAttribute:attribute withUserInfo:nil];
    [self setPlaceholderString:aString];
    attribute = [[self stringValue] length] == 0 ? @protocol(HSSystemTextFieldVisualPlaceholderAttribute) : @protocol(HSSystemTextFieldPlaceholderAttribute);
    [self notifyChange:2 ofAttribute:attribute withUserInfo:nil];
}

- (id)hyperPlaceholderString
{
    return [self placeholderString];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSSystemObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (void)setBezeled:(BOOL)aBezeled
{
    [(NSTextField *)[[self nodeData] systemTextFieldForSetAccessor] setBezeled:aBezeled];
}

- (BOOL)isBezeled
{
    return [(NSTextField *)[[self nodeData] systemTextFieldForGetAccessor] isBezeled];
}

- (void)setBordered:(BOOL)aBordered
{
    [(NSTextField *)[[self nodeData] systemTextFieldForSetAccessor] setBordered:aBordered];
}

- (BOOL)isBordered
{
    return [(NSTextField *)[[self nodeData] systemTextFieldForGetAccessor] isBordered];
}

- (id)queryTextViewObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveTextFieldObject alloc] initWithNode:self] autorelease];
}

- (void)setTextAlignment:(NSUInteger)aAlignment
{
    [[self nodeData] setTextAlignment:aAlignment];
}

- (NSUInteger)textAlignment
{
    return [[self nodeData] textAlignment];
}

- (void)setBezelStyle:(NSUInteger)aStyle
{
    [[self nodeData] setBezelStyle:aStyle];
    [self setSizeForControlSize];
}

- (NSUInteger)bezelStyle
{
    return [[self nodeData] bezelStyle];
}

// The border type picks the bordered/bezeled combination from the borders
// resource.
- (void)setBorderType:(NSUInteger)aType
{
    [[self nodeData] setBorderType:aType];
    NSString *key;
    switch (aType) {
    case 0:
        key = @"HSNoSystemBorder";
        break;
    case 1:
        key = @"HSLineSystemBorder";
        break;
    case 2:
        key = @"HSBezelSystemBorder";
        break;
    case 3:
        key = @"HSGrooveSystemBorder";
        break;
    default:
        key = @"HSUnknownSystemBorderType";
        break;
    }
    id info = [[self textFieldBorderTypesInfo] objectForKey:key];
    BOOL bordered = [info extraBoolForKey:@"bordered"];
    BOOL bezeled = [info extraBoolForKey:@"bezeled"];
    [self setBordered:NO];
    [self setBezeled:NO];
    if (bordered)
        [self setBordered:YES];
    else if (bezeled)
        [self setBezeled:YES];
}

- (NSUInteger)borderType
{
    return [[self nodeData] borderType];
}

- (void)setHyperDroppedSolidColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (CGFloat)fontSize
{
    return [NSFont systemHyperFontSizeForControlSize:[self controlSize]];
}

- (void)setFont:(id)aFont
{
    [[self nodeData] setFont:aFont];
}

- (id)font
{
    return [[self nodeData] font];
}

- (void)setStringValue:(id)aValue
{
    if (aValue == nil)
        aValue = [NSString string];
    if ([[self stringValue] isEqualToString:aValue])
        return;
    [[self nodeData] setStringValue:aValue];
    [self userObjectNameBaseTemplateDidChange];
}

- (id)stringValue
{
    return [[self nodeData] stringValue];
}

- (void)setPlaceholderString:(id)aString
{
    if ([[self placeholderString] isEqualToString:aString])
        return;
    [[self nodeData] setPlaceholderString:aString];
    [self userObjectNameBaseTemplateDidChange];
}

- (id)placeholderString
{
    return [[self nodeData] placeholderString];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self setSizeForControlSize];
}

- (BOOL)canRotate
{
    return NO;
}

// The height is the one for the control size; the font is resized to match.
- (void)setSizeForControlSize
{
    id<HSMutableSizeAttributes> sizeAttributes = [self queryHyperInterface:@protocol(HSMutableSizeAttributes)];
    if (sizeAttributes == nil)
        return;
    CGFloat width = [sizeAttributes width];
    NSString *key = nil;
    switch ([self controlSize]) {
    case NSControlSizeMini:
        key = @"mini";
        break;
    case NSControlSizeSmall:
        key = @"small";
        break;
    case NSControlSizeRegular:
        key = @"regular";
        break;
    }
    if (key != nil)
        [sizeAttributes setSize:NSMakeSize(width, [[self textFieldSizesInfo] extraFloatForKey:key])];
    [self setFont:[NSFont fontWithName:[[self font] fontName] size:[self fontSize]]];
}

- (void)didCreateSystemView
{
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldVisualPlaceholderAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldBorderTypeAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldBezelStyleAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldAlignmentAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldSelectableAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldBorderedAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextFieldBezeledAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSBackgroundColorAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSTextColorAttribute)];
    [self linkAttribute:@protocol(HSStringValueAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"borderType"];
    [keys addObject:@"placeholderString"];
    [keys addObject:@"stringValue"];
    [keys addObject:@"font"];
    [keys addObject:[@"textColor" extraKeyForMultiRepresentations]];
    [keys addObject:[@"backgroundColor" extraKeyForMultiRepresentations]];
    [keys addObject:@"bezelStyle"];
    [keys addObject:@"textAlignment"];
    [keys addObject:@"controlSize"];
    [keys addObject:@"selectable"];
    [keys addObject:@"editable"];
    return keys;
}

@end
