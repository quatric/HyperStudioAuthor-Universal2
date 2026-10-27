#import "HyperStudioPrefix.h"


@interface HSLayoutRulesCanvasLayer : HSGenericItemsCanvasSublayer <HSLayoutGuidingRulesRenderer, HyperInterface, NSObject>
{
    NSMutableArray *_xSideLayoutGuidingRuleRects;
    NSMutableArray *_ySideLayoutGuidingRuleRects;
    NSMutableArray *_xMiddleLayoutGuidingRuleRects;
    NSMutableArray *_yMiddleLayoutGuidingRuleRects;
    NSMutableArray *_widthLayoutGuidingRuleRects;
    NSMutableArray *_heightLayoutGuidingRuleRects;
    NSRect _snappedRect;
    NSMapTable *_widthRuleInitialRectsAndTransforms;
    NSMapTable *_heightRuleInitialRectsAndTransforms;
}
- (id)guidelinesColor;
- (void)setAppliedLayoutRules:(id)aRules forSnappingRect:(NSRect)aRect;
- (void)renderRect:(NSRect)aRect;
- (void)setNeedsDisplayInRect:(NSRect)aRect;
- (void)dealloc;
- (id)init;
@end

