#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSMutableClipPathsNodeUnit : HSNodeUnit
{
    HSMutableClipPathsNodeUnitPathsContainer *_cropPathsContainer;
    HSMutableClipPathsNodeUnitPathsContainer *_clipPathsContainer;
    unsigned int _cropPathsCount;
    unsigned int _initialClipPathsCount;
}
- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform;
- (void)addClipPath:(id)aPath;
- (void)addCropPath:(id)aPath;
- (void)setAllClipPathsAsInitial;
- (void)removeAllClipPaths;
- (void)removeNonInitialClipPaths;
- (id)initialClipPaths;
- (id)allPaths;
- (void)setHyperInitialClipPathsCount:(NSUInteger)aCount;
- (void)setInitialClipPathsCount:(NSUInteger)aCount;
- (NSUInteger)initialClipPathsCount;
- (id)cropPathsContainer;
- (id)clipPathsContainer;
- (void)setCropPathsCount:(NSUInteger)aCount;
- (NSUInteger)cropPathsCount;
- (void)setBinaryClipPaths:(id)aPaths;
- (id)binaryClipPaths;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)convertOldFormatCropPathIfNeeded;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
@end

@interface HSMutableClipPathsNodeUnitPathsContainer : NSObject
{
    HSMutableClipPathsNodeUnit *_nodeUnit;
    NSMutableArray *_paths;
}
- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform;
- (id)transformedPaths:(CGAffineTransform)aPaths;
- (void)addPath:(id)aPath;
- (void)removePathAtIndex:(NSUInteger)aIndex;
- (void)setHyperPaths:(id)aPaths;
- (void)setPaths:(id)aPaths;
- (NSUInteger)pathsCount;
- (id)pathsCreateIfNeeded:(BOOL)aNeeded;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit;
@end

