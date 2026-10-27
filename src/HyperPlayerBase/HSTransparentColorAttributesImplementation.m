#import "HSTransparentColorAttributesImplementation.h"

@implementation HSTransparentColorAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSTransparentColorNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (id)cachedImage
{
    return nil;
}
- (void)setLightnessTolerance:(double)aTolerance
{
    [_nodeUnit setLightnessTolerance:aTolerance];
}
- (double)lightnessTolerance
{
    return [_nodeUnit lightnessTolerance];
}
- (void)setChromaTolerance:(double)aTolerance
{
    [_nodeUnit setChromaTolerance:aTolerance];
}
- (double)chromaTolerance
{
    return [_nodeUnit chromaTolerance];
}
- (void)setHueTolerance:(double)aTolerance
{
    [_nodeUnit setHueTolerance:aTolerance];
}
- (double)hueTolerance
{
    return [_nodeUnit hueTolerance];
}
- (void)setTransparentColor:(id)aColor
{
    [_nodeUnit setTransparentColor:aColor];
}
- (id)transparentColor
{
    return [_nodeUnit transparentColor];
}
- (void)setTransparentColorEnabled:(BOOL)aEnabled
{
    [_nodeUnit setTransparentColorEnabled:aEnabled];
}
- (BOOL)isTransparentColorEnabled
{
    return [_nodeUnit isTransparentColorEnabled];
}
- (id)hyperObject
{
    return _node;
}
- (id)nodeUnit
{
    return _nodeUnit;
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
- (id)init
{
    [self release];
    return nil;
}
@end
