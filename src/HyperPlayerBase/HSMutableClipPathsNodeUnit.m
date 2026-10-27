#import "HSMutableClipPathsNodeUnit.h"
#import "HSMutableClipPathsAttributesImplementation.h"

// Node unit storing an object's clip paths (CGPaths). Crop paths are kept
// apart and stored after the clip paths; the first initialClipPathsCount clip
// paths are the ones a reset goes back to.
@implementation HSMutableClipPathsNodeUnit

- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform
{
    [_clipPathsContainer applyPathsAffineTransform:aTransform];
    [_cropPathsContainer applyPathsAffineTransform:aTransform];
}

- (void)addClipPath:(id)aPath
{
    [_clipPathsContainer addPath:aPath];
}

- (void)addCropPath:(id)aPath
{
    [_cropPathsContainer addPath:aPath];
}

// The crop paths become clip paths too.
- (void)setAllClipPathsAsInitial
{
    NSArray *paths = [self allPaths];
    [_clipPathsContainer setHyperPaths:paths];
    [_cropPathsContainer setHyperPaths:nil];
    [self setHyperInitialClipPathsCount:[paths count]];
}

- (void)removeAllClipPaths
{
    [_cropPathsContainer setHyperPaths:nil];
    [_clipPathsContainer setHyperPaths:nil];
    [self setHyperInitialClipPathsCount:0];
}

- (void)removeNonInitialClipPaths
{
    if ([_clipPathsContainer pathsCount] > _initialClipPathsCount)
        [_clipPathsContainer setHyperPaths:[self initialClipPaths]];
}

- (id)initialClipPaths
{
    return [[_clipPathsContainer pathsCreateIfNeeded:NO] subarrayWithRange:NSMakeRange(0, _initialClipPathsCount)];
}

- (id)allPaths
{
    NSMutableArray *paths = [NSMutableArray array];
    [paths addObjectsFromArray:[_clipPathsContainer pathsCreateIfNeeded:NO]];
    [paths addObjectsFromArray:[_cropPathsContainer pathsCreateIfNeeded:NO]];
    return paths;
}

- (void)setHyperInitialClipPathsCount:(NSUInteger)aCount
{
    if ([self initialClipPathsCount] == aCount)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperInitialClipPathsCount:[self initialClipPathsCount]];
    [self setInitialClipPathsCount:aCount];
}

- (void)setInitialClipPathsCount:(NSUInteger)aCount
{
    if ([self initialClipPathsCount] != aCount)
        _initialClipPathsCount = aCount;
}

- (NSUInteger)initialClipPathsCount
{
    return _initialClipPathsCount;
}

- (id)cropPathsContainer
{
    return _cropPathsContainer;
}

- (id)clipPathsContainer
{
    return _clipPathsContainer;
}

// Stored count; the loaded paths are split by convertOldFormatCropPathIfNeeded.
- (void)setCropPathsCount:(NSUInteger)aCount
{
    _cropPathsCount = aCount;
}

- (NSUInteger)cropPathsCount
{
    return [_cropPathsContainer pathsCount];
}

- (void)setBinaryClipPaths:(id)aPaths
{
    [_clipPathsContainer setPaths:[NSBezierPath hyperCGPathsFromBinaryStoredDataArray:aPaths]];
}

- (id)binaryClipPaths
{
    return [NSBezierPath hyperBinaryDataArrayForStoringFromCGPaths:[self allPaths]];
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSMutableClipPathsAttributes), aInterface))
        return [HSMutableClipPathsAttributesImplementation class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSMutableClipPathsAttributes), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableClipPathsAttributes)], nil];
}

- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSClipPathsAttribute), nil];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self convertOldFormatCropPathIfNeeded];
}

// All paths are stored as clip paths; the last cropPathsCount of them move
// to the crop paths.
- (void)convertOldFormatCropPathIfNeeded
{
    if (_cropPathsCount == 0 || _cropPathsCount > [_clipPathsContainer pathsCount])
        return;
    NSUInteger clipCount = [_clipPathsContainer pathsCount] - _cropPathsCount;
    NSArray *clipPaths = [[_clipPathsContainer pathsCreateIfNeeded:NO] subarrayWithRange:NSMakeRange(0, clipCount)];
    NSArray *cropPaths = [[_clipPathsContainer pathsCreateIfNeeded:NO] subarrayWithRange:NSMakeRange(clipCount, _cropPathsCount)];
    [_clipPathsContainer setPaths:clipPaths];
    [_cropPathsContainer setPaths:cropPaths];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"binaryClipPaths"];
    [keys addObject:@"initialClipPathsCount"];
    [keys addObject:@"cropPathsCount"];
    return keys;
}

- (void)dealloc
{
    [_clipPathsContainer release];
    [_cropPathsContainer release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSMutableClipPathsNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    [[copy clipPathsContainer] setPaths:[[self clipPathsContainer] pathsCreateIfNeeded:NO]];
    [[copy cropPathsContainer] setPaths:[[self cropPathsContainer] pathsCreateIfNeeded:NO]];
    [copy setInitialClipPathsCount:_initialClipPathsCount];
    return copy;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _clipPathsContainer = [[HSMutableClipPathsNodeUnitPathsContainer alloc] initWithNodeUnit:self];
        _cropPathsContainer = [[HSMutableClipPathsNodeUnitPathsContainer alloc] initWithNodeUnit:self];
    }
    return self;
}

@end

// A list of paths with undoable changes, notified through the node unit.
// The node unit owns it and isn't retained.
@implementation HSMutableClipPathsNodeUnitPathsContainer

- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform
{
    if ([_paths count] != 0)
        [self setHyperPaths:[self transformedPaths:aTransform]];
}

- (id)transformedPaths:(CGAffineTransform)aPaths
{
    NSMutableArray *paths = [NSMutableArray array];
    NSEnumerator *enumerator = [_paths objectEnumerator];
    id path;
    while ((path = [enumerator nextObject]) != nil) {
        CGMutablePathRef transformed = CGPathCreateMutable();
        CGPathAddPath(transformed, &aPaths, (CGPathRef)path);
        [paths addObject:(id)transformed];
        CGPathRelease(transformed);
    }
    return paths;
}

- (void)addPath:(id)aPath
{
    if ([[self pathsCreateIfNeeded:YES] containsObject:aPath] || CGPathIsEmpty((CGPathRef)aPath))
        return;
    [[[_nodeUnit undoManager] prepareWithInvocationTarget:self] removePathAtIndex:[_paths count]];
    [_nodeUnit notifyChange:1 ofAttribute:@protocol(HSClipPathsAttribute) withUserInfo:nil];
    [_paths addObject:aPath];
    [_nodeUnit notifyChange:2 ofAttribute:@protocol(HSClipPathsAttribute) withUserInfo:nil];
}

- (void)removePathAtIndex:(NSUInteger)aIndex
{
    if (aIndex >= [_paths count])
        return;
    [[[_nodeUnit undoManager] prepareWithInvocationTarget:self] addPath:[_paths objectAtIndex:aIndex]];
    [_nodeUnit notifyChange:1 ofAttribute:@protocol(HSClipPathsAttribute) withUserInfo:nil];
    [_paths removeObjectAtIndex:aIndex];
    [_nodeUnit notifyChange:2 ofAttribute:@protocol(HSClipPathsAttribute) withUserInfo:nil];
}

- (void)setHyperPaths:(id)aPaths
{
    if (_paths == aPaths)
        return;
    [[[_nodeUnit undoManager] prepareWithInvocationTarget:self] setHyperPaths:_paths];
    [_nodeUnit notifyChange:1 ofAttribute:@protocol(HSClipPathsAttribute) withUserInfo:nil];
    [self setPaths:aPaths];
    [_nodeUnit notifyChange:2 ofAttribute:@protocol(HSClipPathsAttribute) withUserInfo:nil];
}

- (void)setPaths:(id)aPaths
{
    if (_paths == aPaths)
        return;
    [_paths release];
    _paths = [aPaths mutableCopy];
}

- (NSUInteger)pathsCount
{
    return [_paths count];
}

- (id)pathsCreateIfNeeded:(BOOL)aNeeded
{
    if (aNeeded && _paths == nil)
        _paths = [NSMutableArray new];
    return _paths;
}

- (void)dealloc
{
    [_paths release];
    [super dealloc];
}

- (id)initWithNodeUnit:(id)aUnit
{
    self = [super init];
    if (self != nil)
        _nodeUnit = aUnit;
    return self;
}

@end
