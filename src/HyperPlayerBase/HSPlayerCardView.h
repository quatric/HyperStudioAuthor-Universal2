#import "HyperPlayerBasePrefix.h"
#import "HSCardView.h"


@interface HSPlayerCardView : HSCardView <HSInteractiveCanvasLayerContext, HSCanvasLayerContext, HyperInterface, NSObject>
{
    id<HSStackAttributes> _observedStackAttributes;
    unsigned int _inited:1;
    unsigned int _buttonBorderVisibilityFlag:1;
    unsigned int _roundsCardCorners:1;
    HSPlayerView *_playerView;
    HSPasteboardDataProvider *_draggingPasteboardDataProvider;
    id _nodeForGesture;
}
+ (id)visualizationProtocol;
- (void)endGestureWithEvent:(id)aEvent;
- (void)beginGestureWithEvent:(id)aEvent;
- (void)invalidateCursor;
- (void)changeRoundsCardCorners:(BOOL)aCorners;
- (void)setRoundsCardCorners:(BOOL)aCorners;
- (BOOL)roundsCardCorners;
- (void)clearQuartzSurfaceRect:(NSRect)aRect;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (void)drawViewLayerContentRect:(NSRect)aRect;
- (void)HSPlayerCardView_clipToCardBounds;
- (void)addCardRect:(NSRect)aRect toContext:(struct CGContext *)aContext;
- (CGFloat)HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize:(NSSize)aSize;
- (BOOL)acceptsFirstResponder;
- (void)enableInteractivity;
- (void)disableInteractivity;
- (void)deactivate;
- (void)activate;
- (void)deactivateActiveTextField;
- (id)activeTextField;
- (void)saveEditingState;
- (NSRange)selectedRangeInNode:(id)aNode;
- (void)selectRange:(NSRange)aRange inNode:(id)aNode;
- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode;
- (void)insertText:(id)aText toNode:(id)aNode;
- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation;
- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal;
- (BOOL)startDragWithNodes:(id)aNodes event:(id)aEvent;
- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard;
- (void)scrollWheel:(id)aWheel;
- (void)rightMouseDown:(id)aDown;
- (void)mouseDown:(id)aDown;
- (BOOL)isTextObjectSelected;
- (void)updateShapeButtonsShowBorder:(BOOL)aBorder;
- (void)stackPasswordDidChange:(id)aChange;
- (void)drawQuartzRect:(NSRect)aRect;
- (void)cardSizeDidChange:(id)aChange;
- (void)setCard:(id)aCard;
- (void)adjustCardFrame;
- (void)unregisterObservingUserObjectAttributesChange;
- (void)registerObservingUserObjectAttributesChange;
- (void)setUserObject:(id)aObject;
- (void)presentationContextDidChange;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)viewDidMoveToWindow;
- (void)refreshCanvasLayersIfNeededWithWindow:(id)aWindow;
- (void)insertNewline:(id)aNewline;
- (void)insertBacktab:(id)aBacktab;
- (void)insertTab:(id)aTab;
- (id)presentationContext;
- (id)userObjectChildrenEnumerator;
- (id)createCanvasHitTester;
- (id)createRootCanvasLayer;
- (BOOL)isOpenGLSurfaceOpaque;
- (void)setPlayerView:(id)aView;
- (id)playerView;
- (void)dealloc;
- (id)onceInit;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame;
- (BOOL)canActivateNonScalableObjects;
@end

