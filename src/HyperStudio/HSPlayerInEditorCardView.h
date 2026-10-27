#import "HyperStudioPrefix.h"


@interface HSPlayerInEditorCardView : HSPlayerCardView <HSEditorCardViewBackgroundHost, NSObject, HSEditorCardViewDragHost, HSPointConvertion, HSLayoutGuidingContextProvider>
{
    NSColor *_backgroundColor;
    HSEditorCardViewDragHelper *_dragHelper;
    HSGridSettings *_gridSettings;
    HSBackgroundViewRenderer *_backgroundRenderer;
}
- (id)layoutGuidingContext;
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate;
- (void)gridSettingsDidChange:(id)aChange;
- (void)renderGrid;
- (id)gridSettings;
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard;
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard useDragPreferences:(BOOL)aPreferences;
- (void)showHelpPaneBeforeAddAction:(id)aAction actionEvent:(id)aEvent toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences;
- (void)showHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences;
- (BOOL)needsOpenHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer;
- (BOOL)allowsDragSession;
- (void)switchToEditorWithBlockingAnimation:(BOOL)aAnimation;
- (BOOL)performDragOperation:(id)aOperation;
- (void)concludeDragOperation:(id)aOperation;
- (void)draggingExited:(id)aExited;
- (NSUInteger)draggingUpdated:(id)aUpdated;
- (NSUInteger)draggingEntered:(id)aEntered;
- (id)pasteboardTypes;
- (void)drawWindowLayerContentRect:(NSRect)aRect;
- (void)drawViewLayerContentRect:(NSRect)aRect;
- (void)HSPlayerInEditorCardView_clipToCardBounds;
- (void)preDrawContentRect:(NSRect)aRect;
- (NSRect)HSPlayerInEditorCardView_opaqueBoundingRectForCardSize:(NSSize)aSize;
- (void)changeRoundsCardCorners:(BOOL)aCorners;
- (void)adjustCardFrame;
- (BOOL)isOpaque;
- (id)cardForDragHost;
- (void)endDragOperation;
- (void)beginDragOperation;
- (BOOL)needImageOriginConvertion;
- (NSRect)convertToDragHostCardRect:(NSRect)aRect;
- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard;
- (NSPoint)dragHostCardCenterPoint;
- (NSRect)userBoundingRectForViewRect:(NSRect)aRect;
- (NSRect)viewBoundingRectForUserRect:(NSRect)aRect;
- (NSPoint)convertPointFromViewSpaceToUserSpace:(NSPoint)aSpace;
- (NSPoint)convertPointFromUserSpaceToViewSpace:(NSPoint)aSpace;
- (id)viewSpaceToUserSpaceTransform;
- (id)userSpaceToViewSpaceTransform;
- (void)cardSizeDidChange:(id)aChange;
- (void)autosizeToReflectEnclosingScrollView;
- (void)autosizeToFitEnclosingScrollView;
- (void)autosizeCenteringAtUserPoint:(NSPoint)aPoint respectingLastVisibleContent:(BOOL)aContent;
- (void)autosizePreservingVisibleCenter;
- (void)autosizePreservingVisibleArea;
- (void)autooffsetCardTo:(NSPoint)aTo;
- (void)setNeedsDisplayWorkAreaBackground;
- (void)HSPlayerInEditorCardView_setNeedsDisplayAroundRoundedCardCorners;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (id)HSPlayerInEditorCardView_backgroundPattern;
- (NSRect)contentBoundingRect;
- (NSSize)cardOffset;
- (void)setCardOffset:(NSSize)aOffset;
- (id)editorWindowController;
- (id)editorDocument;
- (void)awakeFromNib;
- (NSUInteger)importToCardDataFromFiles:(id)aFiles showHelpPane:(BOOL)aPane;
- (id)dragHelper;
- (void)dealloc;
- (void)UIModeSettingsDidChangeNotification:(id)aNotification;
- (BOOL)canActivateNonScalableObjects;
- (void)fillBackground;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame;
- (void)initializeBackgroundRendering;
- (void)onScalePopUp:(id)aPopUp;
- (void)updateBackgroundRendererState;
- (CGAffineTransform)userSpaceToViewSpaceCGAffineTransformForZoomFactor:(float)aFactor;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (NSRect)viewBoundingRectForUserRect:(NSRect)aRect forZoomFactor:(float)aFactor;
- (void)zoomIn;
- (void)zoomOut;
- (void)zoomToActualSize;
@end

