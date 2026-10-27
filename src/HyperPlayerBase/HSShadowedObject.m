#import "HSShadowedObject.h"
#import "HSShadowedObjectData.h"
#import "HSProtocolIdentifier.h"
#import "NSShadow+HSExtensions.h"

// Relative comparison used by the shadow setters: values within 0.05% of the
// larger magnitude (zero counting as 1) are equal.
static BOOL HSShadowValuesDiffer(float a, float b)
{
    float magnitudeA = a != 0.0f ? fabsf(a) : 1.0f;
    float magnitudeB = b != 0.0f ? fabsf(b) : 1.0f;
    float magnitude = magnitudeB <= magnitudeA ? magnitudeA : magnitudeB;
    return magnitude * 0.0005f < fabsf(a - b);
}

@implementation HSShadowedObject

// Note: the blur inset is computed and then dropped, so only the offset is
// applied (original behaviour).
+ (NSRect)shadowRectFor:(NSRect)aFor withOffset:(NSSize)aOffset andBlurRadius:(CGFloat)aRadius isFlipped:(BOOL)aFlipped
{
    NSRect rect = aFor;
    rect.origin.x = (float)(aFor.origin.x + aOffset.width);
    if (aFlipped)
        rect.origin.y = (float)(aFor.origin.y - aOffset.height);
    else
        rect.origin.y = (float)(aFor.origin.y + aOffset.height);
    (void)NSInsetRect(rect, aRadius, aRadius);
    return rect;
}

+ (Class)nodeDataClass
{
    return [HSShadowedObjectData class];
}

- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSXMLElement *shadow = [[aRepresentation elementsForName:@"shadow"] extraFirstObject];
    [self setHyperShadowEnabled:[[[shadow attributeForName:@"enabled"] stringValue] hyperBoolValue]];
    [self setHyperShadowAngle:(float)(([[[shadow attributeForName:@"angle"] stringValue] floatValue] * M_PI) / 180.0)];
    [self setHyperShadowDistance:[[[shadow attributeForName:@"distance"] stringValue] floatValue]];
    [self setHyperShadowBlurRadius:[[[shadow attributeForName:@"blur"] stringValue] floatValue]];
}

- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
}

- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeSharedPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    NSXMLElement *shadow = [NSXMLElement elementWithName:@"shadow"];
    [shadow addAttribute:[NSXMLNode attributeWithName:@"enabled" stringValue:[self isHyperShadowEnabled] ? HSXMLStoring1String : HSXMLStoring0String]];
    [shadow addAttribute:[NSXMLNode attributeWithName:@"angle" stringValue:[NSString stringWithFormat:@"%.1f", ([self hyperShadowAngle] * 180.0) / M_PI]]];
    [shadow addAttribute:[NSXMLNode attributeWithName:@"distance" stringValue:[NSString stringWithFormat:@"%.1f", [self hyperShadowDistance]]]];
    [shadow addAttribute:[NSXMLNode attributeWithName:@"blur" stringValue:[NSString stringWithFormat:@"%.1f", [self hyperShadowBlurRadius]]]];
    [aRepresentation addChild:shadow];
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    if ([self shouldBeExportedAsImage]) {
        [dictionary setObject:@"0" forKey:@"hasShadow"];
    } else if ([self isHyperShadowEnabled]) {
        [dictionary setObject:@"1" forKey:@"hasShadow"];
        NSSize offset = [self hyperShadowOffset];
        NSDictionary *shadow = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%.1f", (double)offset.width], @"xOffset",
                                [NSString stringWithFormat:@"%.1f", (double)-offset.height], @"yOffset",
                                [NSString stringWithFormat:@"%.1f", [self hyperShadowBlurRadius]], @"blur",
                                [NSString stringWithFormat:@"%.1f", [self hyperShadowAngle]], @"shadowAngle",
                                [NSString stringWithFormat:@"%.1f", [self hyperShadowOpacity]], @"shadowOpacity",
                                [NSString stringWithFormat:@"%.1f", [self hyperShadowDistance]], @"shadowDistance", nil];
        [dictionary setObject:shadow forKey:@"shadow"];
        [shadow release];
    }
    return dictionary;
}

- (id)hyperShadow
{
    return [self shadow];
}

- (void)setHyperShadowOpacity:(CGFloat)aOpacity
{
    if ((float)[self hyperShadowOpacity] == (float)aOpacity)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Shadow Opacity" value:@"" table:@"UndoManager"]];
    [(HSShadowedObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperShadowOpacity:[self hyperShadowOpacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSShadowOpacityAttribute) withUserInfo:nil];
    [[self shadow] setShadowColor:[[[self shadow] shadowColor] colorWithAlphaComponent:aOpacity]];
    [self notifyChange:2 ofAttribute:@protocol(HSShadowOpacityAttribute) withUserInfo:nil];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled
{
    if ([self isShadowEnabled] == aEnabled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:aEnabled ? @"Enable Shadow" : @"Disable Shadow" value:@"" table:@"UndoManager"]];
    [(HSShadowedObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperShadowEnabled:[self isHyperShadowEnabled]];
    [self notifyChange:1 ofAttribute:@protocol(HSShadowEnabledAttribute) withUserInfo:nil];
    [self setShadowEnabled:aEnabled];
    [self notifyChange:2 ofAttribute:@protocol(HSShadowEnabledAttribute) withUserInfo:nil];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius
{
    if ([self shadow] == nil)
        return;
    float current = [[self shadow] shadowBlurRadius];
    if (!HSShadowValuesDiffer(aRadius, current))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Shadow Radius" value:@"" table:@"UndoManager"]];
    [(HSShadowedObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperShadowBlurRadius:[self hyperShadowBlurRadius]];
    [self notifyChange:1 ofAttribute:@protocol(HSShadowBlurRadiusAttribute) withUserInfo:nil];
    [[self shadow] setShadowBlurRadius:aRadius];
    [self notifyChange:2 ofAttribute:@protocol(HSShadowBlurRadiusAttribute) withUserInfo:nil];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    [self setHyperShadowOffset:[NSShadow hyperShadowOffsetWithShadowDistance:aDistance currentOffset:[self hyperShadowOffset]]];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    [self setHyperShadowOffset:[NSShadow hyperShadowOffsetWithShadowAngle:aAngle currentOffset:[self hyperShadowOffset]]];
}

- (void)setHyperVerticalShadowOffset:(CGFloat)aOffset
{
    [self setHyperShadowOffset:NSMakeSize([self hyperShadowOffset].width, aOffset)];
}

- (void)setHyperHorizontalShadowOffset:(CGFloat)aOffset
{
    [self setHyperShadowOffset:NSMakeSize(aOffset, [self hyperShadowOffset].height)];
}

- (void)setHyperShadowOffset:(NSSize)aOffset
{
    if ([self shadow] == nil)
        return;
    NSSize current = [[self shadow] shadowOffset];
    if (!HSShadowValuesDiffer(aOffset.width, current.width) && !HSShadowValuesDiffer(aOffset.height, current.height))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Shadow Offset" value:@"" table:@"UndoManager"]];
    [(HSShadowedObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperShadowOffset:[self hyperShadowOffset]];
    [self notifyChange:1 ofAttribute:@protocol(HSShadowOffsetAttribute) withUserInfo:nil];
    [[self shadow] setShadowOffset:aOffset];
    [self notifyChange:2 ofAttribute:@protocol(HSShadowOffsetAttribute) withUserInfo:nil];
}

- (CGFloat)hyperShadowOpacity
{
    if ([[self shadow] shadowColor] == nil)
        return 0.0f;
    return (float)[[[self shadow] shadowColor] alphaComponent];
}

- (BOOL)isHyperShadowEnabled
{
    return [self isShadowEnabled];
}

- (BOOL)hasMultipleShadowStyles
{
    return NO;
}

- (CGFloat)hyperShadowBlurRadius
{
    if ([self shadow] == nil)
        return 0.0f;
    return (float)[[self shadow] shadowBlurRadius];
}

- (CGFloat)hyperShadowDistance
{
    return (float)[NSShadow hyperShadowDistanceWithShadowOffset:[self hyperShadowOffset]];
}

- (CGFloat)hyperShadowAngle
{
    return (float)[NSShadow hyperShadowAngleWithShadowOffset:[self hyperShadowOffset]];
}

- (CGFloat)hyperVerticalShadowOffset
{
    return [self hyperShadowOffset].height;
}

- (CGFloat)hyperHorizontalShadowOffset
{
    return [self hyperShadowOffset].width;
}

- (NSSize)hyperShadowOffset
{
    if ([self shadow] == nil)
        return NSZeroSize;
    return [[self shadow] shadowOffset];
}

- (id)attributeToNotificationMapForCodingOperation:(id)aOperation
{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:[super attributeToNotificationMapForCodingOperation:aOperation]];
    if ([aOperation isEqual:@"HSObjectStyleCodingOperation"]) {
        [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSShadowAttribute)] forKey:@"shadow"];
        [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSShadowEnabledAttribute)] forKey:@"shadowEnabled"];
    }
    return map;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"shadow"];
    [keys addObject:@"shadowEnabled"];
    return keys;
}

- (void)setShadowEnabled:(BOOL)aEnabled
{
    [(HSShadowedObjectData *)[self nodeData] setShadowEnabled:aEnabled];
}

- (BOOL)isShadowEnabled
{
    return [(HSShadowedObjectData *)[self nodeData] isShadowEnabled];
}

- (void)setShadow:(id)aShadow
{
    [(HSShadowedObjectData *)[self nodeData] setShadow:aShadow];
}

- (id)shadow
{
    return [(HSShadowedObjectData *)[self nodeData] shadow];
}

- (void)dealloc
{
    [super dealloc];
}

@end
