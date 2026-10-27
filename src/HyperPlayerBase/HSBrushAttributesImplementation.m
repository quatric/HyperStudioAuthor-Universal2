#import "HSBrushAttributesImplementation.h"
// Brush attributes of a node with a vector brush node unit, stored in the
// unit's tool settings: "drawColor" and "size" (thickness is its width;
// changing it keeps the width-to-height ratio). Brushes have no name.

@implementation HSBrushAttributesImplementation

+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSVectorBrushNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}

- (id)attributeObservingController
{
    return _node;
}

- (void)setHyperDroppedSolidColor:(id)aColor
{
    [self setBrushColor:aColor];
}

- (void)setHyperSolidColor:(id)aColor
{
    [self setBrushColor:aColor];
}

- (id)hyperSolidColor
{
    return [self brushColor];
}

// Pattern colors are drawn without padding.
- (void)setBrushColor:(id)aColor
{
    [[_nodeUnit toolSettingsWrapper] setSetting:aColor forKey:@"drawColor"];
    BOOL isPattern = [[aColor colorSpaceName] isEqualToString:NSPatternColorSpace];
    [[_nodeUnit toolSettingsWrapper] setSetting:[NSNumber numberWithBool:!isPattern] forKey:kToolPaddingKey];
}

- (void)setBrushThickness:(CGFloat)aThickness
{
    NSSize size = [[[_nodeUnit toolSettingsWrapper] settings] extraSizeForKey:@"size"];
    float ratio = size.width != 0 ? size.height / size.width : 1.0f;
    [[_nodeUnit toolSettingsWrapper] setSetting:[NSDictionary extraDictionaryWithSize:NSMakeSize(aThickness, ratio * aThickness)] forKey:@"size"];
}

- (void)setBrushName:(id)aName
{
}

- (id)brushColor
{
    return [[[_nodeUnit toolSettingsWrapper] settings] objectForKey:@"drawColor"];
}

- (CGFloat)brushThickness
{
    return [[[_nodeUnit toolSettingsWrapper] settings] extraSizeForKey:@"size"].width;
}

- (id)brushName
{
    return @"";
}

- (id)toolSettingsWrapper
{
    return [_nodeUnit toolSettingsWrapper];
}

- (id)hyperObject
{
    return _node;
}

- (id)node
{
    return _node;
}

- (void)dealloc
{
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}

- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self) {
        _node = [aNode retain];
        _nodeUnit = [aUnit retain];
    }
    return self;
}

@end
