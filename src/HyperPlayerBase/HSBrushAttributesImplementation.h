#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSBrushAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSBrushMutableAttributes, HSBrushAttributes, HSAttributes, HyperInterface, NSObject, HSBrushNameAttribute, HSAttribute, HSBrushThicknessAttribute, HSBrushVisualAttribute, HSVisualAttribute, HSUndoableAttribute, HSBrushColorAttribute, HSGenericSolidColorAttributes, HSGenericSolidColorAttribute>
{
    HSNode *_node;
    HSVectorBrushNodeUnit *_nodeUnit;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)setHyperDroppedSolidColor:(id)aColor;
- (void)setHyperSolidColor:(id)aColor;
- (id)hyperSolidColor;
- (void)setBrushColor:(id)aColor;
- (void)setBrushThickness:(CGFloat)aThickness;
- (void)setBrushName:(id)aName;
- (id)brushColor;
- (CGFloat)brushThickness;
- (id)brushName;
- (id)toolSettingsWrapper;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
@end

