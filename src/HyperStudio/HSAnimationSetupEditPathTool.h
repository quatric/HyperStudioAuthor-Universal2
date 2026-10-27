#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSAnimationSetupEditPathTool : HSTool <HSAnimationSetupEditPathCanvasLayerOwner>
{
    id<HSAnimationSetupEditPathToolDelegate> _delegate;
    HSAnimationSetupEditPathCanvasLayer *_editPathCanvasLayer;
    HSAnimationSetupEditPathCanvasItem *_editPathCanvasItem;
    HSTrackingRectCanvasLayer *_trackingCanvasLayer;
    HSDragCardViewCanvasLayer *_dragCardCanvasLayer;
    NSMutableArray *_selection;
}
- (void)trackingRectCanvasLayer:(id)aLayer didFinishTrackingWithRect:(NSRect)aRect event:(id)aEvent;
- (id)layerForEditPathCanvasItem:(id)aItem;
- (BOOL)editPathCanvasItem:(id)aItem isSelectedKnob:(NSUInteger)aKnob;
- (NSInteger)lastKnobIndexForEditPathCanvasItem:(id)aItem;
- (NSInteger)firstKnobIndexForEditPathCanvasItem:(id)aItem;
- (NSUInteger)knobCountForEditPathCanvasItem:(id)aItem;
- (id)pathForEditPathCanvasItem:(id)aItem;
- (void)editPathCanvasLayer:(id)aLayer didNotHandleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)canvasItemForEditPathCanvasLayer:(id)aLayer;
- (void)didEndEditingFromEditPathCanvasLayer:(id)aLayer;
- (void)willBeginEditingFromEditPathCanvasLayer:(id)aLayer;
- (void)editPathCanvasLayer:(id)aLayer firstPathPointWillChangeTo:(NSPoint)aTo;
- (void)updateTryItAnimatedObjectFromEditPathCanvasLayer:(id)aLayer;
- (void)updateAnimationPath;
- (void)cleanupAnimationPath;
- (void)editPathCanvasLayer:(id)aLayer addPointAfterPoint:(NSInteger)aPoint relativeDistance:(CGFloat)aDistance;
- (void)removeSelectedKnobsForEditPathCanvasLayer:(id)aLayer;
- (id)transformedPathForEditPathCanvasLayer:(id)aLayer;
- (id)tryItPathForEditPathCanvasLayer:(id)aLayer;
- (id)pathForEditPathCanvasLayer:(id)aLayer;
- (void)deselectAllKnobsForEditPathCanvasLayer:(id)aLayer;
- (void)editPathCanvasLayer:(id)aLayer setSelected:(BOOL)aSelected knob:(NSUInteger)aKnob;
- (BOOL)editPathCanvasLayer:(id)aLayer isKnobSelected:(NSUInteger)aSelected;
- (NSUInteger)editPathCanvasLayer:(id)aLayer knobAtViewPoint:(NSPoint)aPoint;
- (NSUInteger)knobCountForEditPathCanvasLayer:(id)aLayer;
- (NSPoint)pointAtIndex:(NSUInteger)aIndex;
- (id)tryItAnimation;
- (id)animation;
- (void)resetSelection;
- (void)updatePath;
- (void)run;
- (id)trackingCanvasLayer;
- (id)editPathCanvasItem;
- (id)editPathCanvasLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)allowsActiveInPlaceEditors;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)shouldResetToolOnAddObjects;
- (void)dealloc;
- (id)init;
- (BOOL)shouldResetToolOnSelectObjects;
- (void)userSelectAnotherObject:(id)aObject withEditPathCanvasLayer:(id)aLayer;
- (void)editPathCanvasLayer:(id)aLayer delegatesToHandleTrackingRectFromPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
@end

