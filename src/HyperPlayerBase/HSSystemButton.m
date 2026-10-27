#import "HSSystemButton.h"
#import "HSSystemButtonData.h"
#import "HSSystemObjectVisualization.h"
#import "HSInteractiveButtonObject.h"
#import "HSProtocolIdentifier.h"
#import "EXCodingContext.h"
#import "NSCharacterSet+HSExtentions.h"
#import "NSFont+HSFont.h"

// A push button (NSButton). Its title is a single line and its font the
// title font; changes are undoable and notified as attribute changes. It
// can be dragged but not resized or rotated.
@implementation HSSystemButton

+ (Class)nodeDataClass
{
    return [HSSystemButtonData class];
}

- (id)valuesForMDAttribute:(id)aAttribute
{
    id title;
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent] && (title = [self title]))
        return [[super valuesForMDAttribute:aAttribute] arrayByAddingObject:title];
    return [super valuesForMDAttribute:aAttribute];
}

- (id)supportedMDAttributes
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super supportedMDAttributes]];
    if (![attributes containsObject:(NSString *)kMDItemTextContent])
        [attributes addObject:(NSString *)kMDItemTextContent];
    return attributes;
}

- (void)setObjectName:(id)aName
{
    [self setTitle:aName];
}

- (id)objectName
{
    return [self title];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    NSDictionary *attributes = [self hyperTextAttributes];
    NSDictionary *converted = [aConverter convertAttributes:attributes];
    if ([attributes isEqual:converted])
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSGenericFontAttributesAttribute) withUserInfo:nil];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self title] attributes:converted];
    [[[self nodeData] systemButtonForSetAccessor] setAttributedTitle:title];
    [title release];
    [self notifyChange:2 ofAttribute:@protocol(HSGenericFontAttributesAttribute) withUserInfo:nil];
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    [self setTitleFont:[aConverter convertFont:[self titleFont]]];
}

- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    if (aMultiple)
        *aMultiple = NO;
    return [self titleFont];
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
}

- (BOOL)isHyperExpanded
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSExpandedFontMask) != 0;
}

- (BOOL)isHyperCondensed
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSCondensedFontMask) != 0;
}

- (BOOL)isHyperItalic
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSItalicFontMask) != 0;
}

- (BOOL)isHyperBold
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSBoldFontMask) != 0;
}

- (CGFloat)hyperFontSize
{
    return [[self titleFont] pointSize];
}

- (id)hyperFontFamily
{
    return [[self titleFont] familyName];
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    NSFont *font = [self titleFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aExpanded ? [manager convertFont:font toHaveTrait:NSExpandedFontMask] : [manager convertFont:font toNotHaveTrait:NSExpandedFontMask];
    [self setTitleFont:font];
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    NSFont *font = [self titleFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aCondensed ? [manager convertFont:font toHaveTrait:NSCondensedFontMask] : [manager convertFont:font toNotHaveTrait:NSCondensedFontMask];
    [self setTitleFont:font];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    NSFont *font = [self titleFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aItalic ? [manager convertFont:font toHaveTrait:NSItalicFontMask] : [manager convertFont:font toNotHaveTrait:NSItalicFontMask];
    [self setTitleFont:font];
}

- (void)setHyperBold:(BOOL)aBold
{
    NSFont *font = [self titleFont];
    NSFontManager *manager = [NSFontManager sharedFontManager];
    font = aBold ? [manager convertFont:font toHaveTrait:NSBoldFontMask] : [manager convertFont:font toNotHaveTrait:NSBoldFontMask];
    [self setTitleFont:font];
}

- (void)setHyperFontSize:(CGFloat)aSize
{
    [self setTitleFont:[[NSFontManager sharedFontManager] convertFont:[self titleFont] toSize:aSize]];
}

- (void)setHyperFontFamily:(id)aFamily
{
    [self setTitleFont:[[NSFontManager sharedFontManager] convertFont:[self titleFont] toFamily:aFamily]];
}

- (void)setHyperFont:(id)aFont
{
    [self setTitleFont:aFont];
}

// The attributes at the start of the title.
- (id)hyperTextAttributes
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *attributes = [[[[self nodeData] systemButtonForGetAccessor] attributedTitle] attributesAtIndex:0 effectiveRange:NULL];
    NSDictionary *copy = attributes ? [[NSDictionary alloc] initWithDictionary:attributes] : nil;
    [pool release];
    return [copy autorelease];
}

- (id)hyperFont
{
    return [self titleFont];
}

- (NSSize)defaultSize
{
    return NSMakeSize(89, 29);
}

- (void)setSpecialAccessHighlightActive:(BOOL)aActive
{
    if ([self isSpecialAccessHighlightActive] == aActive)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute) withUserInfo:nil];
    _isSpecialAccessHighlightActive = aActive;
    [self notifyChange:2 ofAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute) withUserInfo:nil];
}

- (BOOL)isSpecialAccessHighlightActive
{
    return _isSpecialAccessHighlightActive;
}

// Highlighting is a temporary change, undone by restoring.
- (void)setHyperHighlightedInInteractiveMode:(BOOL)aMode
{
    if ([self isHyperHighlightedInInteractiveMode] == aMode)
        return;
    [self notifyChange:aMode ? 4 : 0x10 ofAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute) withUserInfo:nil];
    [[[[self nodeData] systemButtonForSetAccessor] cell] setHighlighted:aMode];
    [self notifyChange:aMode ? 8 : 0x20 ofAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute) withUserInfo:nil];
}

- (BOOL)isHyperHighlightedInInteractiveMode
{
    return [[[[self nodeData] systemButtonForGetAccessor] cell] isHighlighted];
}

- (void)hyperAutoSizeToFitTitle
{
    [self hyperSizeToFitContentHorizontally:YES vertically:NO];
}

- (NSUInteger)hyperTitleAlignment
{
    return NSTextAlignmentCenter;
}

- (void)setTitleFont:(id)aFont
{
    if ([[self titleFont] isEqual:aFont])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Title Font" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleFont:[self titleFont]];
    [self notifyChange:1 ofAttribute:@protocol(HSTitleFontAttribute) withUserInfo:nil];
    [[self nodeData] setFont:aFont];
    [self notifyChange:2 ofAttribute:@protocol(HSTitleFontAttribute) withUserInfo:nil];
}

- (id)titleFont
{
    return [[self nodeData] font];
}

- (BOOL)hasHyperTitle
{
    return YES;
}

- (BOOL)canBeDraggable
{
    return YES;
}

- (BOOL)canBeResizable
{
    return NO;
}

- (BOOL)canBeRotatable
{
    return NO;
}

- (void)setEnabled:(BOOL)aEnabled
{
    if ([self isEnabled] == aEnabled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Button Enabling" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setEnabled:[self isEnabled]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemEnabledAttribute) withUserInfo:nil];
    [[[self nodeData] systemButtonForSetAccessor] setEnabled:aEnabled];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemEnabledAttribute) withUserInfo:nil];
}

- (BOOL)isEnabled
{
    return [[[self nodeData] systemButtonForGetAccessor] isEnabled];
}

- (void)setContinuous:(BOOL)aContinuous
{
    if ([self isContinuous] == aContinuous)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Button's Continuesly" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setContinuous:[self isContinuous]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemButtonContinuousAttribute) withUserInfo:nil];
    [[[self nodeData] systemButtonForSetAccessor] setContinuous:aContinuous];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemButtonContinuousAttribute) withUserInfo:nil];
}

- (BOOL)isContinuous
{
    return [[[self nodeData] systemButtonForGetAccessor] isContinuous];
}

- (void)setTransparent:(BOOL)aTransparent
{
    if ([self isTransparent] == aTransparent)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Button's Transparency" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTransparent:[self isTransparent]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTransparencyAttribute) withUserInfo:nil];
    [[[self nodeData] systemButtonForSetAccessor] setTransparent:aTransparent];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTransparencyAttribute) withUserInfo:nil];
}

- (BOOL)isTransparent
{
    return [[[self nodeData] systemButtonForGetAccessor] isTransparent];
}

- (void)setBordered:(BOOL)aBordered
{
    if ([self isBordered] == aBordered)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setBordered:[self isBordered]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemButtonBorderAttribute) withUserInfo:nil];
    [[[self nodeData] systemButtonForSetAccessor] setBordered:aBordered];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemButtonBorderAttribute) withUserInfo:nil];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Button's Border" value:@"" table:@"UndoManager"]];
}

- (BOOL)isBordered
{
    return [[[self nodeData] systemButtonForGetAccessor] isBordered];
}

// Sizes to the cell along the directions given, about the center.
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically
{
    id<HSMutableGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    if (!geometry)
        return;
    NSSize size = [geometry size];
    NSSize cellSize = [[[[self nodeData] systemButtonForGetAccessor] cell] cellSize];
    if (aHorizontally)
        size.width = cellSize.width;
    if (aVertically)
        size.height = cellSize.height;
    [geometry setSize:size aboutRelativePoint:NSMakePoint(0.5f, 0.5f)];
}

- (void)hyperSizeToFitContent
{
    [self hyperSizeToFitContentHorizontally:YES vertically:YES];
}

// An empty title is measured as a space.
- (NSRect)untransformedTitleRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (!geometry)
        return NSZeroRect;
    NSRect bounds = [geometry boundingRect];
    NSString *title = [[self nodeData] title];
    if ([title isEqualToString:@""])
        [[self nodeData] setTitle:@" "];
    NSRect rect = [[[[self nodeData] systemButtonForGetAccessor] cell] titleRectForBounds:bounds];
    [[self nodeData] setTitle:title];
    return rect;
}

- (void)setControlSize:(NSUInteger)aSize
{
    if ([self controlSize] == aSize)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Button Size" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setControlSize:[self controlSize]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemControlSizeAttribute) withUserInfo:nil];
    [[[[self nodeData] systemButtonForSetAccessor] cell] setControlSize:aSize];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemControlSizeAttribute) withUserInfo:nil];
}

- (NSUInteger)controlSize
{
    return [[[[self nodeData] systemButtonForGetAccessor] cell] controlSize];
}

// Only the first line of the title is kept.
- (void)setTitle:(id)aTitle
{
    NSString *oldTitle = [self title];
    if (aTitle) {
        NSUInteger newline = [aTitle rangeOfCharacterFromSet:[NSCharacterSet hyperNewlineCharacterSet]].location;
        if (newline != NSNotFound)
            aTitle = [aTitle substringToIndex:newline];
    }
    if ([oldTitle isEqualToString:aTitle])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Title" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitle:oldTitle];
    [self notifyChange:1 ofAttribute:@protocol(HSTitleStringAttribute) withUserInfo:nil];
    [[self nodeData] setTitle:aTitle];
    [self userObjectNameBaseTemplateDidChange];
    [self notifyChange:2 ofAttribute:@protocol(HSTitleStringAttribute) withUserInfo:nil];
}

- (id)title
{
    return [[self nodeData] title];
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

- (void)setSelected:(BOOL)aSelected
{
    [[self nodeData] setSelected:aSelected];
}

- (BOOL)isSelected
{
    return [[self nodeData] isSelected];
}

- (CGFloat)fontSize
{
    return [NSFont systemHyperFontSizeForControlSize:[self controlSize]];
}

- (id)nameBaseTemplates
{
    return [NSArray arrayWithObjects:[self title], nil];
}

- (id)queryButtonObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveButtonObject alloc] initWithNode:self] autorelease];
}

- (id)attributeToNotificationMapForCodingOperation:(id)aOperation
{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:[super attributeToNotificationMapForCodingOperation:aOperation]];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemControlSizeAttribute)] forKey:@"controlSize"];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemButtonBorderAttribute)] forKey:@"bordered"];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSCardObjectHiddenAttribute)] forKey:@"hidden"];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemTransparencyAttribute)] forKey:@"transparent"];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemEnabledAttribute)] forKey:@"enabled"];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemButtonContinuousAttribute)] forKey:@"continuous"];
    return map;
}

// An object style keeps only the look.
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:[@"titleFont" extraKeyForMultiRepresentations]];
    [keys addObject:@"bordered"];
    [keys addObject:@"transparent"];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"controlSize"];
        [keys addObject:@"enabled"];
        [keys addObject:@"selected"];
        [keys addObject:@"continuous"];
        [keys addObject:@"title"];
    }
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:[@"titleFont" extraKeyForMultiRepresentations]];
        [keys addObject:@"bordered"];
        [keys addObject:@"transparent"];
    }
    return keys;
}

@end
