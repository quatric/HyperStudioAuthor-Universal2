#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSTransparentColorAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSTransparentColorAttributes, HSAttributes, HyperInterface, NSObject, HSTransparentColorEnabledAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSTransparentColorAttribute, HSTransparentColorCachedImageAttribute, HSTransparentColorHueToleranceAttribute, HSTransparentColorChromaToleranceAttribute, HSTransparentColorLightnessToleranceAttribute>
{
    HSNode *_node;
    HSTransparentColorNodeUnit *_nodeUnit;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (id)cachedImage;
- (void)setLightnessTolerance:(double)aTolerance;
- (double)lightnessTolerance;
- (void)setChromaTolerance:(double)aTolerance;
- (double)chromaTolerance;
- (void)setHueTolerance:(double)aTolerance;
- (double)hueTolerance;
- (void)setTransparentColor:(id)aColor;
- (id)transparentColor;
- (void)setTransparentColorEnabled:(BOOL)aEnabled;
- (BOOL)isTransparentColorEnabled;
- (id)hyperObject;
- (id)nodeUnit;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
- (id)init;
@end

