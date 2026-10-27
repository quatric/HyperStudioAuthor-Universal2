#import "HSMutableClipPathsAttributesImplementation.h"

@implementation HSMutableClipPathsAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (void)setAllClipPathsAsInitial
{
    [_nodeUnit setAllClipPathsAsInitial];
}
- (void)removeAllClipPaths
{
    [_nodeUnit removeAllClipPaths];
}
- (void)removeNonInitialClipPaths
{
    [_nodeUnit removeNonInitialClipPaths];
}
- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform
{
    [_nodeUnit applyPathsAffineTransform:aTransform];
}
- (void)addObjectClipPath:(id)aPath
{
    [self addObjectClipPath:aPath transform:CGAffineTransformIdentity];
}
// Object paths are in object points; stored paths are relative to the size.
- (void)addObjectClipPath:(id)aPath transform:(CGAffineTransform)aTransform
{
    [self addRelativeClipPath:aPath transform:CGAffineTransformConcat(aTransform, CGAffineTransformInvert([self relativeToObjectAffineTransform]))];
}
- (void)addRelativeClipPath:(id)aPath
{
    [self addRelativeClipPath:aPath transform:CGAffineTransformIdentity];
}
- (void)addRelativeClipPath:(id)aPath transform:(CGAffineTransform)aTransform
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, &aTransform, (CGPathRef)aPath);
    [_nodeUnit addClipPath:(id)path];
    CGPathRelease(path);
}
- (CGAffineTransform)relativeToObjectAffineTransform
{
    NSSize size = [_sizeAttributes size];
    return CGAffineTransformMake(size.width, 0, 0, size.height, 0, 0);
}
- (void)addObjectCropPath:(id)aPath transform:(CGAffineTransform)aTransform
{
    [self addRelativeCropPath:aPath transform:CGAffineTransformConcat(aTransform, CGAffineTransformInvert([self relativeToObjectAffineTransform]))];
}
- (void)addRelativeCropPath:(id)aPath transform:(CGAffineTransform)aTransform
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, &aTransform, (CGPathRef)aPath);
    [_nodeUnit addCropPath:(id)path];
    CGPathRelease(path);
}
- (id)clipPaths
{
    return [_nodeUnit allPaths];
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
    [_node release];
    [_nodeUnit release];
    [_sizeAttributes release];
    [super dealloc];
}
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self) {
        _node = [aNode retain];
        _nodeUnit = [aUnit retain];
        _sizeAttributes = [[aNode queryHyperInterface:@protocol(HSSizeAttributes)] retain];
        if (_sizeAttributes)
            return self;
    }
    [self release];
    return nil;
}
@end
