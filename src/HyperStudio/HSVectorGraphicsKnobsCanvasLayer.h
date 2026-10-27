#import "HyperStudioPrefix.h"
#import "HSObjectKnobsCanvasLayer.h"


@interface HSVectorGraphicsKnobsCanvasLayer : HSObjectKnobsCanvasLayer
{
    HSVectorGraphicsTangentSelectionKnob * _tangentKnobs[2];
    BOOL _visibleTangentKnobs[2];
}
+ (id)knobsLayerWithHyperObject:(id)aObject;
+ (BOOL)canInitWithHyperObject:(id)aObject;
+ (BOOL)canInitWithHyperObject:(id)aObject knobsProvider:(id *)aProvider;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (void)setAssociatedElementIndex:(NSUInteger)aIndex forTangentKnobAtIndex:(NSUInteger)aIndex2;
- (void)setHidden:(BOOL)aHidden forTangentKnobAtIndex:(NSUInteger)aIndex;
- (void)didActivateItem:(id)aItem;
- (void)willDeactivateItem:(id)aItem;
- (void)willStartTrackingKnob:(id)aKnob;
- (id)pointKnobForCanvasItem:(id)aItem;
- (BOOL)isTangentKnob:(id)aKnob;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfCanvasItems;
- (id)visibleTangentKnobAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfVisibleTangentKnobs;
- (id)vectorAttributes;
- (void)dealloc;
- (id)init;
- (id)initWithHyperObject:(id)aObject knobsProvider:(id)aProvider;
@end

