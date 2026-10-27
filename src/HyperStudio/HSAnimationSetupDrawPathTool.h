#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSAnimationSetupDrawPathTool : HSTool <HSDrawPathCanvasLayerOwner>
{
    id<HSAnimationSetupDrawPathToolDelegate> _delegate;
    HSDrawPathCanvasLayer *_drawPathCanvasLayer;
    HSAnimationSetupDrawPathCanvasItem *_drawPathCanvasItem;
    NSBezierPath *_path;
    NSMutableArray *_keyFrames;
    NSPoint _lastPoint;
    double _lastEventTime;
    BOOL _needsAddAnimatedObject;
}
- (id)layerForEditPathCanvasItem:(id)aItem;
- (id)pathForEditPathCanvasItem:(id)aItem;
- (void)cleanUpPathAndKeyFrames;
- (BOOL)didStartPath;
- (void)drawPathCanvasLayer:(id)aLayer mouseMovedToPoint:(NSPoint)aPoint;
- (void)cancelPathCreationForDrawPathCanvasLayer:(id)aLayer;
- (void)finishPathCreationForDrawPathCanvasLayer:(id)aLayer;
- (void)drawPathCanvasLayer:(id)aLayer continuePathAtPoint:(NSPoint)aPoint;
- (void)drawPathCanvasLayer:(id)aLayer finishPathPartAtPoint:(NSPoint)aPoint;
- (void)drawPathCanvasLayer:(id)aLayer addPointToPath:(NSPoint)aPath;
- (void)HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:(NSPoint)aEnough lastKeyFrame:(double *)aFrame;
- (void)HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:(NSPoint)aEnough lastKeyFrame:(double *)aFrame continuePath:(BOOL)aPath;
- (void)HSAnimationSetupDrawPathTool_addPointToPath:(NSPoint)aPath lastKeyFrame:(double *)aFrame;
- (void)HSAnimationSetupDrawPathTool_addPointToPath:(NSPoint)aPath lastKeyFrame:(double *)aFrame continuePath:(BOOL)aPath2;
- (void)drawPathCanvasLayer:(id)aLayer startPathCreationAtPoint:(NSPoint)aPoint;
- (BOOL)didStartPathForDrawPathCanvasLayer:(id)aLayer;
- (NSInteger)pathCreationMode;
- (void)HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration:(double)aDuration;
- (void)removeAnimatedObject;
- (void)addAnimatedObject;
- (void)run;
- (id)drawPathCanvasItem;
- (id)drawPathCanvasLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)allowsActiveInPlaceEditors;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)shouldResetToolOnAddObjects;
- (void)dealloc;
@end

