#import "HSSystemBox.h"
#import "HSExecutableResourceProvider.h"
#import "HSSystemBoxData.h"
#import "HSSystemObjectVisualization.h"
#import "HSValueConstraints.h"

// A group box (NSBox) with an optional title at the top. It can't be moved,
// resized or rotated on its own.
@implementation HSSystemBox

+ (Class)nodeDataClass
{
    return [HSSystemBoxData class];
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureGroupBox" value:@"" table:@"Export"];
}

// The title is the box's searchable text.
- (id)valuesForMDAttribute:(id)aAttribute
{
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent]) {
        id string = [self objectString];
        if (string != nil)
            return [[super valuesForMDAttribute:aAttribute] arrayByAddingObject:string];
    }
    return [super valuesForMDAttribute:aAttribute];
}

- (id)supportedMDAttributes
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super supportedMDAttributes]];
    if (![attributes containsObject:(NSString *)kMDItemTextContent])
        [attributes addObject:(NSString *)kMDItemTextContent];
    return attributes;
}

- (void)setObjectString:(id)aString
{
    [self setTitle:aString];
}

- (id)objectString
{
    return [self title];
}

- (id)hyperSizeMinValue
{
    return [[HSValueConstraints sharedConstraints] constraintForKey:@"HSSystemBoxSizeMinValue"];
}

- (NSSize)defaultSize
{
    return NSMakeSize(89, 72);
}

- (void)hyperAutoSizeToFitTitle
{
}

- (NSUInteger)hyperTitleAlignment
{
    return 0;
}

- (BOOL)hasHyperTitle
{
    return [self isHyperTitleVisible];
}

- (void)setHyperTitleVisible:(BOOL)aVisible
{
    BOOL visible = [self isTitleVisible];
    if (visible == aVisible)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Title Visibility" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperTitleVisible:visible];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemBoxTitleVisibilityAttribute) withUserInfo:nil];
    [self setTitleVisible:aVisible];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemBoxTitleVisibilityAttribute) withUserInfo:nil];
}

- (BOOL)canToggleTitleVisibility
{
    return [[[self nodeData] systemBoxForGetAccessor] canToggleTitleVisibility];
}

- (BOOL)isHyperTitleVisible
{
    return [self isTitleVisible];
}

// The box's title rect, flipped to the object's top-left origin.
- (NSRect)untransformedTitleRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    NSRect bounds = [geometry boundingRect];
    [(NSBox *)[[self nodeData] systemBoxForSetAccessor] setFrame:bounds];
    NSRect titleRect = [(NSBox *)[[self nodeData] systemBoxForGetAccessor] titleRect];
    titleRect.origin.y = bounds.size.height - NSMaxY(titleRect);
    return titleRect;
}

- (void)setHyperBorderType:(NSUInteger)aType
{
    if ([self borderType] == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Border Type" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperBorderType:[self borderType]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemBoxBorderTypeAttribute) withUserInfo:nil];
    [self setBorderType:aType];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemBoxBorderTypeAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperBorderType
{
    return [self borderType];
}

- (NSUInteger)hyperTitlePosition
{
    NSUInteger position = [[self nodeData] boxTitlePosition];
    return [self canToggleTitleVisibility] ? position : 0;
}

- (void)setTitleFont:(id)aFont
{
    if ([self titleFont] == aFont)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Title Font" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleFont:[self titleFont]];
    [self notifyChange:1 ofAttribute:@protocol(HSTitleFontAttribute) withUserInfo:nil];
    [[self nodeData] setTitleFont:aFont];
    [self notifyChange:2 ofAttribute:@protocol(HSTitleFontAttribute) withUserInfo:nil];
}

- (id)titleFont
{
    return [[self nodeData] titleFont];
}

- (void)setTitle:(id)aTitle
{
    NSString *title = [self title];
    if (aTitle == nil)
        aTitle = [NSString string];
    if ([title isEqualToString:aTitle])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Title" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitle:title];
    [self notifyChange:1 ofAttribute:@protocol(HSTitleStringAttribute) withUserInfo:nil];
    [[self nodeData] setTitle:aTitle];
    [self userObjectNameBaseTemplateDidChange];
    [self notifyChange:2 ofAttribute:@protocol(HSTitleStringAttribute) withUserInfo:nil];
}

- (id)title
{
    return [[self nodeData] title];
}

- (id)nameBaseTemplates
{
    return [NSArray arrayWithObjects:[self title], nil];
}

- (id)queryGroupBoxObjectHitTester
{
    return [self queryDefaultHitTester];
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

- (BOOL)canBeDraggable
{
    return NO;
}

- (BOOL)canBeResizable
{
    return NO;
}

- (BOOL)canBeRotatable
{
    return NO;
}

- (void)setBorderType:(NSUInteger)aType
{
    [[self nodeData] setBorderType:aType];
}

- (NSUInteger)borderType
{
    return [[self nodeData] borderType];
}

// Title position 2 is NSAtTop.
- (void)setTitleVisible:(BOOL)aVisible
{
    [self setBoxTitlePosition:aVisible ? NSAtTop : NSNoTitle];
}

- (BOOL)isTitleVisible
{
    return [self boxTitlePosition] != NSNoTitle;
}

- (void)setBoxTitlePosition:(NSUInteger)aPosition
{
    [[self nodeData] setBoxTitlePosition:aPosition];
}

- (NSUInteger)boxTitlePosition
{
    return [[self nodeData] boxTitlePosition];
}

- (void)didCreateSystemView
{
    [super didCreateSystemView];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemBoxTitleVisibilityAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemObjectTitleAvailabilityAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSTitleAttribute)];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"title"];
    [keys addObject:[@"titleFont" extraKeyForMultiRepresentations]];
    [keys addObject:@"boxTitlePosition"];
    [keys addObject:@"borderType"];
    return keys;
}

@end
