#import "HyperPlayerBasePrefix.h"
#import "HSCanvasRootLayerImplementationData.h"


@interface HSCompositeCanvasLayer : HSCanvasRootLayerMixin
{
    NSMutableArray *_sublayers;
}
- (void)setReorderedSublayers:(id)aSublayers;
- (void)removeSublayerFromStorage:(id)aStorage atIndex:(NSUInteger)aIndex;
- (void)insertSublayerInStorage:(id)aStorage atIndex:(NSUInteger)aIndex;
- (NSUInteger)indexOfSublayer:(id)aSublayer;
- (id)sublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSublayers;
- (id)allSublayers;
- (id)sublayers;
- (void)dealloc;
@end

