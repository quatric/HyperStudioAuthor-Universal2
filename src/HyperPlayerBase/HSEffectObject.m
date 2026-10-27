#import "HSEffectObject.h"
#import "EXCodingContext.h"
#import "HSCIEffect.h"
#import "HSEffect.h"
#import "HSEffectObjectData.h"
#import "HSEffectObjectVisualization.h"
#import "HSEffectSettings.h"
#import "HSFunctions.h"
#import "HSQTEffect.h"
#import <QuartzCore/QuartzCore.h>

// A card object applying a Core Image or QuickTime effect to what lies under
// it. The effect and its attributes live in the node data.
@implementation HSEffectObject

+ (Class)nodeDataClass
{
    return [HSEffectObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSSizeNodeUnit", @"Size Unit", @"HSGeometryNodeUnit", @"Geometry Unit", @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit", @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit", nil];
}

- (id)queryEffectObjectHitTester
{
    return [self queryDefaultHitTester];
}

// Effect center inputs are set to the middle of the object for a new effect
// (unless the stored attributes already have them), and otherwise clamped into
// the object when it gets smaller.
- (void)adjustEffectCenters:(BOOL)aCenters
{
    HSEffectObjectData *data = (HSEffectObjectData *)[self nodeData];
    NSEnumerator *enumerator = [[[data effect] inputKeys] objectEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil) {
        Class vectorClass;
        if (![key hasPrefix:kCIInputCenterKey] || (vectorClass = NSClassFromString(@"CIVector")) == Nil)
            continue;
        NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
        CGFloat x, y;
        if (aCenters) {
            x = size.width * 0.5f;
            y = size.height * 0.5f;
        } else {
            CIVector *center = [[data effect] valueForKey:key];
            x = (float)[center X];
            y = (float)[center Y];
            if (x <= size.width && y <= size.height)
                continue;
            x = MAX(MIN(x, size.width), 0.0f);
            y = MAX(MIN(y, size.height), 0.0f);
        }
        CIVector *vector = [vectorClass vectorWithX:x Y:y];
        if (vector == nil)
            continue;
        [[data effect] setValue:vector forKey:key];
        NSMutableDictionary *attributes = [data attributes];
        if (!aCenters || [attributes objectForKey:key] == nil)
            [attributes setObject:vector forKey:key];
    }
}

- (void)setEffectName:(id)aName
{
    if ([aName isEqualToString:[(HSEffectObjectData *)[self nodeData] effectName]])
        return;
    [(HSEffectObjectData *)[self nodeData] setEffectName:[[aName copy] autorelease]];
    [self createEffect];
    [self userObjectNameBaseTemplateDidChange];
}

- (id)effectName
{
    return [(HSEffectObjectData *)[self nodeData] effectName];
}

- (void)createEffect
{
    HSEffectObjectData *data = (HSEffectObjectData *)[self nodeData];
    if ([[(HSEffect *)[data effect] name] isEqualToString:[data effectName]])
        return;
    [data setEffect:[HSEffect effectWithName:[data effectName]]];
    [[data effect] setDefaults];
    [self adjustEffectCenters:YES];
}

- (void)HSEffectObject_sizeDidChange:(id)aChange
{
    [self adjustEffectCenters:NO];
}

// The effect accessing interfaces answer only for the matching effect kind;
// actors are not supported.
- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSCoreImageEffectAccessing))
        && ![[(HSEffectObjectData *)[self nodeData] effect] isKindOfClass:[HSCIEffect class]])
        return nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSQuickTimeEffectAccessing))
        && ![[(HSEffectObjectData *)[self nodeData] effect] isKindOfClass:[HSQTEffect class]])
        return nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSVisualization)) || HSProtocolsAreEqual(aInterface, @protocol(HSEditorVisualization))
        || HSProtocolsAreEqual(aInterface, @protocol(HSPlayerVisualization)) || HSProtocolsAreEqual(aInterface, @protocol(HSObjectListPaletteVisualization)))
        return [[[HSEffectObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (protocol_conformsToProtocol(aInterface, @protocol(HSActor)))
        return nil;
    return [super queryNewHyperInterface:aInterface];
}

- (id)quickTimeEffectAdjustedToSize:(NSSize)aSize
{
    if ([self quickTimeEffect] == nil)
        return nil;
    return [self effectPerObjectAdjustedToSize:aSize];
}

- (id)coreImageEffectAdjustedToSize:(NSSize)aSize
{
    if ([self coreImageEffect] == nil)
        return nil;
    return [self effectPerObjectAdjustedToSize:aSize];
}

- (id)effectPerObjectAdjustedToSize:(NSSize)aSize
{
    HSEffect *effect = [(HSEffectObjectData *)[self nodeData] effect];
    id settings = [[HSEffectSettings sharedSettings] adjustedSettings:[(HSEffectObjectData *)[self nodeData] effectSettings] forName:[effect name] category:[effect category] frameSize:aSize];
    [effect setAttributes:settings];
    return effect;
}

- (id)quickTimeEffect
{
    HSEffect *effect = [(HSEffectObjectData *)[self nodeData] effect];
    return [effect isKindOfClass:[HSQTEffect class]] ? effect : nil;
}

- (id)coreImageEffect
{
    HSEffect *effect = [(HSEffectObjectData *)[self nodeData] effect];
    return [effect isKindOfClass:[HSCIEffect class]] ? effect : nil;
}

- (struct CGPath *)effectSourceAreaBoundingPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, NSRectToCGRect([self HSEffectObject_boundingRect]));
    return (CGMutablePathRef)[(id)path autorelease];
}

- (NSRect)HSEffectObject_boundingRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    return [geometry boundingRect];
}

- (void)setHyperEffectName:(id)aName settings:(id)aSettings
{
    [self setHyperEffectName:aName];
    NSEnumerator *enumerator = [[aSettings allKeys] objectEnumerator];
    id key;
    while ((key = [enumerator nextObject]) != nil)
        [self setHyperValue:[aSettings objectForKey:key] forKey:key];
}

- (id)effectSettings
{
    return [self hyperAttributes];
}

- (void)setHyperValue:(id)aValue forKey:(id)aKey
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"ChangeEffectAttributes" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperValue:[self hyperValueForKey:aKey] forKey:aKey];
    [self notifyChange:1 ofAttribute:@protocol(HSEffectVisualAttribute) withUserInfo:nil];
    HSEffectObjectData *data = (HSEffectObjectData *)[self nodeData];
    [[data attributes] setObject:aValue forKey:aKey];
    [[data effect] setValue:aValue forKey:aKey];
    [self notifyChange:2 ofAttribute:@protocol(HSEffectVisualAttribute) withUserInfo:nil];
}

- (id)hyperValueForKey:(id)aKey
{
    return [[(HSEffectObjectData *)[self nodeData] effect] valueForKey:aKey];
}

- (id)hyperAttributes
{
    return [[(HSEffectObjectData *)[self nodeData] effect] attributes];
}

- (id)hyperInputKeys
{
    return [[(HSEffectObjectData *)[self nodeData] effect] inputKeys];
}

- (void)setHyperEffectName:(id)aName
{
    if ([aName isEqualToString:[self effectName]])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"ChangeEffectName" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEffectName:[self effectName]];
    [self notifyChange:1 ofAttribute:@protocol(HSEffectNameAttribute) withUserInfo:nil];
    [self setEffectName:aName];
    [self notifyChange:2 ofAttribute:@protocol(HSEffectNameAttribute) withUserInfo:nil];
}

- (id)nameBaseTemplates
{
    NSString *name = [self effectName];
    return [NSArray arrayWithObjects:name != nil ? [HSEffect localizedNameForEffectName:name] : nil, nil];
}

- (id)hyperEffectName
{
    return [self effectName];
}

- (BOOL)canMoveVertically
{
    return YES;
}

- (BOOL)canMoveHorizontally
{
    return YES;
}

- (BOOL)canRotate
{
    return NO;
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return NO;
}

- (BOOL)canFlipHorizontally
{
    return NO;
}

- (BOOL)canScaleVertically
{
    return NO;
}

- (BOOL)canScaleHorizontally
{
    return NO;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
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

- (id)effectForRender
{
    return [(HSEffectObjectData *)[self nodeData] effect];
}

- (id)queryInteractivePlayerItem
{
    return nil;
}

- (BOOL)canSendActionsOnDrop
{
    return NO;
}

- (BOOL)canBeGrouped
{
    return NO;
}

- (void)setAttributes:(id)aAttributes
{
    [(HSEffectObjectData *)[self nodeData] setAttributes:aAttributes];
}

- (id)attributes
{
    return [(HSEffectObjectData *)[self nodeData] attributes];
}

// Object styles keep the effect name of the object they are applied to.
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        [keys addObject:@"effectName"];
    [keys addObject:[@"attributes" extraKeyForCollection]];
    return keys;
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self createEffect];
    HSEffectObjectData *data = (HSEffectObjectData *)[self nodeData];
    [[data effect] setAttributes:[data attributes]];
}

- (void)dealloc
{
    [super removeObserver:self selector:@selector(HSEffectObject_sizeDidChange:) ofChanges:2 ofAttribute:@protocol(HSSizeAttribute)];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [super linkAttribute:@protocol(HSEffectSourceAreaAttribute) toAttribute:@protocol(HSGeometryAttribute)];
        [super addObserver:self selector:@selector(HSEffectObject_sizeDidChange:) ofChanges:2 ofAttribute:@protocol(HSSizeAttribute) withPriority:0.75];
    }
    return self;
}

@end
