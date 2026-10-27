#import "SMKBitmapToolsPrefix.h"
#import "BTClustersMutableDataArray.h"
#import "BTTool.h"

extern NSString * const BTCollectingDragPointsMode;
extern NSString * const BTCollectingPickPointsMode;


@interface BTPointsContainer : BTDataArray
{
    BTMutableDataArray *_pointsContainer;
    NSUInteger _count;
}
+ (id)containerWithDataArray:(id)aArray count:(NSUInteger)aCount;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)itemSize;
- (NSUInteger)count;
- (void)dealloc;
- (id)initWithDataArray:(id)aArray count:(NSUInteger)aCount;
@end

@interface BTPointsCreationTool : BTTool <BTMouseTracker, NSObject>
{
    BTMutableDataArray *_pointsDataContainer;
    NSPoint _lastUncorrectedPoint;
    NSCursor *_willStartPointsCollectingCursor;
    NSCursor *_doPickPointCursor;
    NSCursor *_doDragPointCursor;
    NSUInteger _maxPointsCount;
    NSString *_correctionMode;
    CGFloat _correctionDiagonalTangent;
    CGFloat _alternateCorrectionDiagonalTangent;
    unsigned int _isCorrectionModePrimary:1;
    unsigned int _isTracking:1;
    unsigned int _isInCorrectionMode:2;
    unsigned int _isWillStartPointsCollectingCursorInitialized:1;
    unsigned int _isDoPickPointCursorInitialized:1;
    unsigned int _isDoDragPointCursorInitialized:1;
    unsigned int _isStopCreationOnDoubleClick:1;
    unsigned int _isLastPointDynamic:1;
    unsigned int _isWaitingForClick:1;
    unsigned int _isPointCollectingStarted:1;
}
- (void)selectAllArea:(id)aArea;
- (BOOL)validateAction_selectAllArea;
- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent;
- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)haltWithMouseUp:(id)aUp inView:(id)aView;
- (BOOL)scrollWheel:(id)aWheel;
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView;
- (void)trackMouseUp:(id)aUp inView:(id)aView;
- (void)trackMouseDragged:(id)aDragged inView:(id)aView;
- (void)trackMouseDown:(id)aDown inView:(id)aView;
- (unsigned char)BTPointsCreationTool_isInCorrectionModeForModifierFlags:(NSUInteger)aFlags;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayers:(id)aLayers;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayer:(id)aLayer;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayers:(id)aLayers;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer;
- (id)activeFeedbackLayersForDrawing;
- (BOOL)isFeedbackLayerActive:(id)aActive;
- (id)activeFeedbackLayers;
- (void)drawRect:(NSRect)aRect;
- (BOOL)mouseMoved:(id)aMoved;
- (BOOL)mouseDown:(id)aDown;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (BOOL)isTracking;
- (id)currentStage;
- (void)performDeactivate;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (id)outputKeys;
- (id)inputKeys;
- (id)pointsArray;
- (void)setAlternateCorrectionDiagonalTangent:(CGFloat)aTangent;
- (CGFloat)alternateCorrectionDiagonalTangent;
- (CGFloat)defaultAlternateCorrectionDiagonalTangent;
- (void)setCorrectionDiagonalTangent:(CGFloat)aTangent;
- (CGFloat)correctionDiagonalTangent;
- (CGFloat)defaultCorrectionDiagonalTangent;
- (void)setCorrectionMode:(id)aMode;
- (id)correctionMode;
- (id)defaultCorrectionMode;
- (void)setIsCorrectionModePrimary:(BOOL)aPrimary;
- (BOOL)isCorrectionModePrimary;
- (BOOL)defaultIsCorrectionModePrimary;
- (void)setMaxPointsCount:(NSUInteger)aCount;
- (NSUInteger)maxPointsCount;
- (NSUInteger)defaultMaxPointsCount;
- (void)setCollectingMode:(id)aMode;
- (id)collectingMode;
- (id)defaultCollectingMode;
- (void)setIsLastPointDynamic:(BOOL)aDynamic;
- (BOOL)isLastPointDynamic;
- (BOOL)defaultIsLastPointDynamic;
- (void)setDoDragPointCursor:(id)aCursor;
- (id)doDragPointCursor;
- (id)defaultDoDragPointCursor;
- (void)setDoPickPointCursor:(id)aCursor;
- (id)doPickPointCursor;
- (id)defaultDoPickPointCursor;
- (void)setWillStartPointsCollectingCursor:(id)aCursor;
- (id)willStartPointsCollectingCursor;
- (id)defaultWillStartPointsCollectingCursor;
- (NSPoint)BTPointsCreationTool_guidePoint:(NSPoint)aPoint withEvent:(id)aEvent previousPoint:(NSPoint)aPoint2;
- (void)dealloc;
- (id)init;
@end

@interface BTPointsCreationTool (Private)
- (void)BTPointsCreationTool_didFinalizeWithEvent:(id)aEvent;
- (void)BTPointsCreationTool_addTrackPointWithEvent:(id)aEvent;
- (void)BTPointsCreationTool_trackMouse:(id)aMouse;
@end

