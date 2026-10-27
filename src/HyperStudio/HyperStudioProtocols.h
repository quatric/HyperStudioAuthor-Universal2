// The protocols HyperStudio declares (gen_protocols.py), after the prefix's
// structures; the prefix forward-declares them all.


@protocol BTLayoutGuidingContext <NSObject>
- (void)showAppliedRules:(id)aRules;
- (BOOL)snapPoints:(id)aPoints sizes:(id)aSizes withEvent:(id)aEvent options:(id)aOptions snappedReflectedPoint:(CGPoint *)aPoint snapDistance:(float *)aDistance appliedRules:(id *)aRules;
@end

@protocol BTPencilStrokeConsumer <NSObject>
- (void)addPencilStrokeFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2;
@end

@protocol HSActionAssistantPaneActionEvents <NSObject>
- (id)actionEvents;
- (void)setActionEvents:(id)aEvents;
@end

@protocol HSAddActionHandlerDelegate <NSObject>
- (void)addHyperAction:(id)aAction;
@end

@protocol HSAnimationDropHelpPaneInterface <NSObject>
- (id)actingObject;
- (id)actionEvents;
- (id)animatedObject;
- (id)delegate;
- (NSInteger)revertMode;
- (void)setActingObject:(id)aObject;
- (void)setActionEvents:(id)aEvents;
- (void)setAnimatedObject:(id)aObject;
- (void)setDelegate:(id)aDelegate;
- (void)setRevertMode:(NSInteger)aMode;
@end

@protocol HSAnimationPickObjectCanvasLayerDelegate <NSObject>
- (void)animationPickObjectCanvasLayer:(id)aLayer pickedObject:(id)aObject final:(BOOL)aFinal event:(id)aEvent;
- (void)cancelFromPickObjectCanvasLayer:(id)aLayer;
@end

@protocol HSAnimationSetupCoachingAssistantPaneDelegate <NSObject>
- (void)coachingAssistantGoBackFromPane:(id)aPane;
@end

@protocol HSAnimationSetupCropSelectedGraphicAssistantPaneDelegate <NSObject>
- (void)cropTemporaryObject:(id)aObject options:(id)aOptions forAssistantPane:(id)aPane shouldProceedWithMode:(NSInteger)aMode;
- (id)prepareToCroppingForAssistantPane:(id)aPane image:(id)aImage options:(id)aOptions;
- (void)unprepareCroppingForAssistantPane:(id)aPane temporaryObject:(id)aObject;
@end

@protocol HSAnimationSetupDrawPathAssistantPaneDelegate <NSObject>
- (void)drawPathShouldCancelFromDrawPathAssistantPane:(id)aPane;
- (void)drawPathShouldFinishFromDrawPathAssistantPane:(id)aPane;
@end

@protocol HSAnimationSetupDrawPathToolDelegate <NSObject>
- (void)addAnimatedObjectToCardForDrawPathTool:(id)aTool;
- (id)animationForDrawPathTool:(id)aTool;
- (void)drawPathTool:(id)aTool setAnimatedObjectPosition:(NSPoint)aPosition;
- (void)drawingCanceledForDrawPathTool:(id)aTool;
- (void)drawingFinishedForDrawPathTool:(id)aTool;
- (void)pathStateIsUpdatedForDrawPathTool:(id)aTool;
- (void)removeAnimatedObjectFromCardForDrawPathTool:(id)aTool;
@end

@protocol HSAnimationSetupEditPathAssistantPaneDelegate <NSObject>
- (void)goBackFromAnimationSetupEditPathAssistantPane:(id)aPane;
@end

@protocol HSAnimationSetupEditPathCanvasLayerOwner <NSObject>
- (id)canvasItemForEditPathCanvasLayer:(id)aLayer;
- (void)deselectAllKnobsForEditPathCanvasLayer:(id)aLayer;
- (void)didEndEditingFromEditPathCanvasLayer:(id)aLayer;
- (void)editPathCanvasLayer:(id)aLayer addPointAfterPoint:(NSInteger)aPoint relativeDistance:(CGFloat)aDistance;
- (void)editPathCanvasLayer:(id)aLayer didNotHandleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (void)editPathCanvasLayer:(id)aLayer firstPathPointWillChangeTo:(NSPoint)aTo;
- (BOOL)editPathCanvasLayer:(id)aLayer isKnobSelected:(NSUInteger)aSelected;
- (NSUInteger)editPathCanvasLayer:(id)aLayer knobAtViewPoint:(NSPoint)aPoint;
- (void)editPathCanvasLayer:(id)aLayer setSelected:(BOOL)aSelected knob:(NSUInteger)aKnob;
- (NSUInteger)knobCountForEditPathCanvasLayer:(id)aLayer;
- (id)pathForEditPathCanvasLayer:(id)aLayer;
- (void)removeSelectedKnobsForEditPathCanvasLayer:(id)aLayer;
- (id)transformedPathForEditPathCanvasLayer:(id)aLayer;
- (id)tryItPathForEditPathCanvasLayer:(id)aLayer;
- (void)updateTryItAnimatedObjectFromEditPathCanvasLayer:(id)aLayer;
- (void)willBeginEditingFromEditPathCanvasLayer:(id)aLayer;
@end

@protocol HSAnimationSetupEditPathToolDelegate <NSObject>
- (id)animationForEditPathTool:(id)aTool;
- (void)editingDidEndForEditPathTool:(id)aTool;
- (void)editingWillBeginForEditPathTool:(id)aTool;
- (id)tryItAnimationForEditPathTool:(id)aTool;
- (void)updateAnimationPathBounds:(NSRect)aBounds forEditPathTool:(id)aTool;
@end

@protocol HSAnimationSetupMainAssistantPaneDelegate <NSObject>
- (id)animationForAnimationSetupMainAssistantPane:(id)aPane;
- (void)cancelFromAnimationSetupMainAssistantPane:(id)aPane;
- (id)cardView;
- (void)cleanUpTryItAnimation;
- (void)doneFromAnimationSetupMainAssistantPane:(id)aPane;
- (void)getNewSourceFromAnimationSetupMainAssistantPane:(id)aPane;
- (void)newPathFromAnimationSetupMainAssistantPane:(id)aPane;
- (void)playStopFromAnimationSetupMainAssistantPane:(id)aPane;
- (void)setUpTryItAnimation;
- (void)transparentColorFromAnimationSetupMainAssistantPane:(id)aPane;
- (id)tryItAnimationForAnimationSetupMainAssistantPane:(id)aPane;
- (id)undoHelperForAnimationSetupMainAssistantPane:(id)aPane;
- (id)undoManagerForAnimationSetupMainAssistantPane:(id)aPane;
- (void)updatePathInEditPathTool;
@end

@protocol HSAnimationSetupPickImageAssistantPaneDelegate <NSObject>
- (void)cancelFromPickImageAssistantPane:(id)aPane;
- (void)hideAnimationObjectForAssistantPane:(id)aPane;
- (void)pickMovie:(id)aMovie name:(id)aName forPickImageAssistantPane:(id)aPane;
@end

@protocol HSAnimationSetupPickObjectToolDelegate <NSObject>
- (void)animationEditModePickTool:(id)aTool pickedObject:(id)aObject event:(id)aEvent;
- (void)cancelFromPickObjectTool:(id)aTool;
@end

@protocol HSAnimationSetupPickPartOfCardAssistantPaneDelegate <HSAnimationSetupCropSelectedGraphicAssistantPaneDelegate>
- (void)pickCardObjectForAssistantPane:(id)aPane temporaryObject:(id)aObject;
@end

@protocol HSAnimationSetupTryItCanvasLayerDelegate <NSObject>
- (void)cancelForTryItCanvasLayer:(id)aLayer;
@end

@protocol HSArduinoWatcherActionConfigurationDataSource <NSObject>
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forAnalogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forDigitalPin:(unsigned char)aPin;
- (void)removeConfigurationRangeForAnalogPin:(unsigned char)aPin;
- (void)removeConfigurationRangeForDigitalPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forDigitalPin:(unsigned char)aPin;
@end

@protocol HSArtworkImageDataSource <NSObject>
- (id)artworkImageForExporter:(id)aExporter;
@end

@protocol HSColorMatrixDataProvider <NSObject>
- (id)colorAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)colorSwatchImageAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (NSSize)colorSwatchImageSize;
- (NSInteger)numberOfColumns;
- (NSInteger)numberOfRows;
- (id)positionOfColor:(id)aColor;
- (void)setColor:(id)aColor atRow:(NSInteger)aRow column:(NSInteger)aColumn;
@end

@protocol HSBigColorMatrixDataProvider <HSColorMatrixDataProvider>
- (void)deactivateAllViews;
- (void)resetToDefault;
@end

@protocol HSBrushTouchesStorageDelegate <NSObject>
- (void)touchStorageDidAddTouch:(id)aTouch;
@end

@protocol HSCannotBeAnimated <NSObject>
@end

@protocol HSChooserDataSource <NSObject>
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfChoosableItems;
- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex;
- (void)updateChoosableItemsIfNeeded;
@end

@protocol HSColorPickingController <NSObject>
- (void)activateColorPickingModeWithDelegate:(id)aDelegate didEndSelector:(SEL)aSelector;
- (void)cancelColorPicking;
- (BOOL)isColorPickingModeActive;
@end

@protocol HSControlWebCamViewDelegateProtocol <NSObject>
- (void)newPreviewIsDoneForWebCamView:(id)aView;
@end

@protocol HSCursorAssistantPaneDataSource <NSObject>
- (NSUInteger)countOfCursors;
- (id)cursorAtIndex:(NSUInteger)aIndex;
- (void)updateCursors;
@end

@protocol HSCursorDialogControllerDataSource <NSObject>
- (NSUInteger)countOfCursors;
- (id)cursorAtIndex:(NSUInteger)aIndex;
@end

@protocol HSDocumentSelectionHolderInterface <NSObject>
- (id)currentSelectionHost;
- (void)makeCurrentSelectionHost:(id)aHost;
- (void)selectionHostDidChangeSelectedObject:(id)aObject;
@end

@protocol HSDrawPathCanvasLayerOwner <NSObject>
- (void)cancelPathCreationForDrawPathCanvasLayer:(id)aLayer;
- (BOOL)didStartPathForDrawPathCanvasLayer:(id)aLayer;
- (void)drawPathCanvasLayer:(id)aLayer addPointToPath:(NSPoint)aPath;
- (void)drawPathCanvasLayer:(id)aLayer continuePathAtPoint:(NSPoint)aPoint;
- (void)drawPathCanvasLayer:(id)aLayer finishPathPartAtPoint:(NSPoint)aPoint;
- (void)drawPathCanvasLayer:(id)aLayer mouseMovedToPoint:(NSPoint)aPoint;
- (void)drawPathCanvasLayer:(id)aLayer startPathCreationAtPoint:(NSPoint)aPoint;
- (void)finishPathCreationForDrawPathCanvasLayer:(id)aLayer;
@end

@protocol HSDrawingDlegate <NSObject>
- (void)redrawViewInContext:(id)aContext rect:(NSRect)aRect;
@end

@protocol HSDropHelpPaneDelegate <NSObject>
- (void)dropHelpPaneDidEnd:(id)aEnd canceled:(BOOL)aCanceled;
@end

@protocol HSDropOffPlaceObjectAssistantPaneDelegate <NSObject>
- (void)placeObjectShouldCancelFromPlaceObjectAssistantPane:(id)aPane;
- (void)prepareToolAndCardViewAfterSwitchForPlaceObjectAssistantPane:(id)aPane;
- (void)prepareToolAndCardViewForPlaceObjectAssistantPane:(id)aPane;
@end

@protocol HSEditorCanvasLayerContext <HSCanvasLayerContext, HSLayoutGuidingContextProvider>
- (BOOL)canPerformDeleteOperationWithNodesInArray:(id)aArray;
- (void)duplicateObjectsInEnumerator:(id)aEnumerator duplicatedObjects:(id *)aObjects;
- (id)editObjectDialogContext;
- (id)editorSelection;
- (BOOL)handleClickWithModifiers:(NSUInteger)aModifiers clickCount:(NSUInteger)aCount inNode:(id)aNode nodeIsSelected:(BOOL)aSelected;
- (BOOL)handleDoubleClickOutsideNodesWithModifiers:(NSUInteger)aModifiers;
- (BOOL)handleMouseUpWithModifiers:(NSUInteger)aModifiers inNode:(id)aNode nodeIsSelected:(BOOL)aSelected previousEvent:(id)aEvent;
- (id)layoutGuidingContext;
- (void)noteDidPerformCutOperation;
- (void)performDeleteOperationWithNodesInArray:(id)aArray;
- (void)selectedRuntimeEditorDidChangeAndWantsToActivate:(BOOL)aActivate;
- (BOOL)shouldPerformDeleteOperationWithNodesInArray:(id)aArray;
- (BOOL)startDragWithNodes:(id)aNodes event:(id)aEvent;
- (void)writeObjectsInEnumeratorToPasteboard:(id)aPasteboard;
- (CGFloat)zoomFactor;
- (void)zoomInAboutPoint:(NSPoint)aPoint;
- (void)zoomOutAboutPoint:(NSPoint)aPoint;
- (void)zoomToFactor:(CGFloat)aFactor;
- (void)zoomToFactor:(CGFloat)aFactor aboutPoint:(NSPoint)aPoint;
@end

@protocol HSPointConvertion <NSObject>
- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard;
- (NSRect)convertToDragHostCardRect:(NSRect)aRect;
- (NSPoint)dragHostCardCenterPoint;
- (BOOL)needImageOriginConvertion;
@end

@protocol HSEditorCardViewDragHost <NSObject, HSPointConvertion>
- (BOOL)allowsDragSession;
- (void)beginDragOperation;
- (id)cardForDragHost;
- (void)endDragOperation;
- (BOOL)needsOpenHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer;
- (void)showHelpPaneBeforeAddAction:(id)aAction actionEvent:(id)aEvent toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences;
- (void)showHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences;
@end

@protocol HSEffectsPreviewControllerDataSource <NSObject>
- (id)effectPreviewImage;
- (BOOL)isOriginalObjectFlippedHorizontally;
- (BOOL)isOriginalObjectFlippedVertically;
- (id)originalPreviewImage;
@end

@protocol HSRunTimeEditor <HyperInterface, HSSelectableObject>
- (BOOL)activateEditing;
- (NSRect)boundsInHostView;
- (BOOL)canEditObject;
- (void)deactivateEditing;
- (BOOL)disablesRenderingEditingObject;
- (id)editingObject;
- (BOOL)haveChanges;
- (void)hostViewDidChangeUserSpaceToViewSpaceTransform;
- (void)hyperRenderRect:(NSRect)aRect;
- (BOOL)isActive;
- (BOOL)isEditing;
- (BOOL)isInCreationMode;
- (NSRect)occupiedAreaInHostView;
- (id)owner;
- (void)postProcessEditingObjectAfterDeactivateEditing;
- (BOOL)prepareForEditingInCreationMode:(BOOL)aMode;
- (BOOL)prepareForEditingWithPointInHostView:(NSPoint)aView;
- (void)saveEditing;
- (void)setOwner:(id)aOwner;
- (BOOL)wantsToDeactivateASAPWhenSwitchToNonRuntimeEditorTool;
@end

@protocol HSEmbeddedEditor <HSRunTimeEditor>
- (void)setViewEmbedder:(id)aEmbedder;
- (id)viewEmbedder;
- (id)viewEmbeddingInterface;
@end

@protocol HSEventBasedEditor <HSRunTimeEditor>
- (id)cursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleMouseDown:(id)aDown;
- (BOOL)handleMouseMoved:(id)aMoved;
@end

@protocol HSExportCardsImages <NSObject>
- (id)exportedCardIndexesForExporter:(id)aExporter onlySelected:(BOOL)aSelected;
- (id)imageForCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
@end

@protocol HSExportVideoAttributes <NSObject>
- (NSSize)videoFrameSize;
@end

@protocol HSExporter2DataSource <NSObject>
@end

@protocol HSExporterDelegate <NSObject>
@optional
- (void)exportDidEnd:(id)aEnd;
- (void)exportDidStart:(id)aStart;
- (void)exportDidTerminate:(id)aTerminate;
- (void)exportErrorInProgress:(id)aProgress error:(id)aError;
- (void)exportProgressDidChange:(id)aChange withProgress:(double)aProgress;
- (void)exportWillEnd:(id)aEnd;
- (void)exportWillStart:(id)aStart withSlideshowAttributes:(id)aAttributes;
@end

@protocol HSExporting <NSObject>
- (BOOL)exportDocument:(id)aDocument withBackupToFile:(id)aFile ofType:(id)aType error:(id *)aError;
@end

@protocol HSExtendedSelectionAccessor <HSSelectionAccessor>
- (id)hyperActiveSelectionHolder;
@end

@protocol HSFrameManipulationSelectionKnobAttributes <NSObject>
- (NSSize)framePositionFactor;
- (NSSize)framePositionOffset;
@end

@protocol HSHyperCastingExporterDataSource <HSExporter2DataSource, HSExportVideoAttributes, HSArtworkImageDataSource>
- (id)hyperCastingLauncherForExporter:(id)aExporter;
@end

@protocol HSHyperCastingLauncher <NSObject>
- (void)exitFromHyperCastingModeWithReturnCode:(NSInteger)aCode;
- (id)hyperCastingWindowController;
- (void)switchToHyperCastingModeWithDelegate:(id)aDelegate;
@end

@protocol HSHyperCastingModePaneRecordingProvider <NSObject>
- (void)cancelRecording;
- (id)documentName;
- (BOOL)isRecording;
- (id)outputFileName;
- (BOOL)prepareToStart;
- (void)setOutputToInputDevice:(id)aDevice;
- (void)setVoiceInputDevice:(id)aDevice;
- (BOOL)startRecording;
- (void)stopRecording;
@end

@protocol HSIconsGridDataSource <NSObject>
- (id)iconAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid;
- (NSUInteger)iconsCountInIconsGrid:(id)aGrid;
@end

@protocol HSImageRequestor <NSObject>
- (void)quickCaptureImageController:(id)aController didProduceImage:(id)aImage;
@end

@protocol HSImageSequenceExporterDataSource <HSExporter2DataSource, HSExportCardsImages>
- (NSUInteger)countExistedCards;
- (BOOL)isExportDocumentInStoryboardMode;
@end

@protocol HSImportDialogPaneViewController <NSObject>
- (id)dialogType;
- (id)helpTopicKey;
- (BOOL)isObjectOptionsDisabled;
- (BOOL)isObjectValid;
- (BOOL)isPaneValid;
- (id)paneAccessoryView;
- (void)paneDialogWillCancel;
- (void)paneDialogWillClose;
- (void)paneDialogWillOpen;
- (id)paneFileDisplayName;
- (id)paneFilePath;
- (id)paneHyperDocument;
- (id)paneIdentifier;
- (id)paneTitle;
- (id)paneUserOptions;
- (id)paneView;
- (NSInteger)paneWeight;
- (void)setObjectOptionsDisabled:(BOOL)aDisabled;
- (void)setupDialogInterfaceWithOptions:(id)aOptions;
- (void)willMountToDialogController:(id)aController;
- (void)willUnmountFromDialogController:(id)aController;
@end

@protocol HSKnobsProvider <HyperInterface>
- (id)buildDefaultKnob;
- (id)buildSelectionKnobs;
- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob;
@end

@protocol HSLayoutGridVisibilityAttribute <HSAttribute>
- (BOOL)isGridVisible;
@end

@protocol HSLayoutGuideGeometry <HSLayoutGeometryHolder>
- (CGFloat)hyperLayoutGuideCoordinate;
- (BOOL)isHorizontalHyperLayoutGuide;
@end

@protocol HSLayoutGuidingContext <NSObject>
- (id)appliedLayoutGuidingRules;
- (void)cancelAppliedLayoutGuidingRulesClearing;
- (void)clearAppliedLayoutGuidingRules;
- (CGFloat)commonSnapDelta;
- (id)filterSnapRules:(id)aRules madeForRect:(NSRect)aRect byMoveDirection:(NSPoint)aDirection;
- (CGFloat)gridSnapDelta;
- (void)hideInfoTag;
- (BOOL)isSnappingEnabled;
- (id)layoutGuidingProcessor;
- (void)setAppliedLayoutGuidingRules:(id)aRules forSnappingRect:(NSRect)aRect;
- (void)showAppliedLayoutGuidingRules;
- (void)showInfoTagWithCoordinate:(CGFloat)aCoordinate horizontal:(BOOL)aHorizontal;
- (void)showInfoTagWithPoint:(NSPoint)aPoint;
- (void)showInfoTagWithSize:(NSSize)aSize;
- (void)showInfoTagWithString:(id)aString;
@end

@protocol HSLayoutGuidingRulesRenderer <HyperInterface>
- (void)setAppliedLayoutRules:(id)aRules forSnappingRect:(NSRect)aRect;
@end

@protocol HSLayoutRule <NSObject>
- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex;
- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex alongAxis:(NSInteger)aAxis;
- (NSUInteger)affectedRectSidesCount;
- (BOOL)affectsRectSide:(NSInteger)aSide;
- (BOOL)appliesToAxis:(NSInteger)aAxis;
- (BOOL)appliesToXAxis;
- (BOOL)appliesToYAxis;
- (BOOL)canSnapTo;
- (NSUInteger)countOfAffectedRectSidesAlongAxis:(NSInteger)aAxis;
- (NSPoint)directionSnapsRectTo:(NSRect)aTo;
- (id)geometryHoldersSortedByOppositeCoordinate;
- (id)geometryHoldersUsed;
- (BOOL)isEqual:(id)aEqual;
- (CGFloat)layoutRuleFloatValueForRectSide:(NSInteger)aSide;
- (NSInteger)ruleType;
- (NSRect)scaleRect:(NSRect)aRect;
- (BOOL)scalesRectWithPositiveDirection:(BOOL *)aDirection;
- (NSRect)translateRect:(NSRect)aRect;
@end

@protocol HSLibraryMediaPlugin <NSObject>
- (BOOL)isPlayable;
- (BOOL)isSearchable;
@end

@protocol HSLibraryMediaViewContainer <NSObject>
- (BOOL)allowsEmptySelection;
- (BOOL)canInsertFromPasteboard:(id)aPasteboard;
- (id)filter:(id)aFilter byCategory:(id)aCategory;
- (void)insertFromPasteboard:(id)aPasteboard;
- (BOOL)isMultiLevel;
- (BOOL)isPlaying;
- (void)playSelection;
- (void)selectItem:(id)aItem;
- (void)stopPlaying;
@end

@protocol HSLibraryPluginControlsToolTip <NSObject>
- (id)libraryPlayButtonTooltip;
- (id)librarySearchFieldTooltip;
@end

@protocol HSLiveVideoUIItemInterface <NSObject>
- (id)deviceName;
- (id)liveVideoPlaybackItem;
@end

@protocol HSMediaContentFilter <NSObject>
- (id)globalUIDStringForMediaItem:(id)aItem;
- (BOOL)mediaItem:(id)aItem conformsToDisplayNameFilter:(id)aFilter mediaTypeFilter:(id)aFilter2;
- (id)mediaTypes;
- (id)sortedMediaTypes;
@end

@protocol HSMediaStripAnimationDataSource <NSObject>
- (id)itemsEnumeratorForAnimation:(id)aAnimation;
@end

@protocol HSMovieRecordingAssistantPaneDelegate <NSObject>
- (void)movieRecordingAssistantPane:(id)aPane didChooseMovieObject:(id)aObject;
@end

@protocol HSMovieUIItemInterface <NSObject>
- (id)movieDuration;
- (id)moviePlaybackItem;
@end

@protocol HSNewActionDropHelpPaneInterface <NSObject>
- (id)actionsToAdd;
- (void)addActionToAdd:(id)aAdd actionEvent:(id)aEvent forContainer:(id)aContainer;
- (id)containersForAdd;
- (void)setDelegate:(id)aDelegate;
@end

@protocol HSNewObjectDropHelpPaneInterface <NSObject>
- (id)containerForAdd;
- (id)objectToAdd;
- (void)setContainerForAdd:(id)aAdd;
- (void)setObjectToAdd:(id)aAdd;
@end

@protocol HSNodeSelectionInterface <NSObject>
- (void)addNode:(id)aNode;
- (void)addNodesInEnumerator:(id)aEnumerator;
- (id)anySelectedNode;
- (void)beginSelectionChanging;
- (BOOL)containsNode:(id)aNode;
- (void)endSelectionChanging;
- (id)localizedSelectionName;
- (id)nodesArray;
- (NSUInteger)nodesCount;
- (id)nodesEnumerator;
- (void)removeAllNodes;
- (void)removeAllNodesExcept:(id)aExcept;
- (void)removeNode:(id)aNode;
- (void)removeNodesIfExist:(id)aExist;
- (void)selectNode:(id)aNode;
- (void)selectNodesInEnumerator:(id)aEnumerator;
- (id)selectedNode;
- (void)setShouldDisplaySelectionKnobs:(BOOL)aKnobs;
- (BOOL)shouldDisplaySelectionKnobs;
- (void)toggleNode:(id)aNode;
@end

@protocol HSNonOpaqueTextViewDelegate <NSTextViewDelegate>
@optional
- (void)textView:(id)aView didPerformClick:(id)aClick;
- (void)textView:(id)aView hyperColorDidChange:(id)aChange;
- (BOOL)textView:(id)aView shouldHandlePerformKeyEquivalentOutsideOfKeyDown:(id)aDown;
- (BOOL)textView:(id)aView shouldHandleRawKeyDownEvent:(id)aEvent;
- (BOOL)textView:(id)aView shouldHyperChangeAttributes:(id)aAttributes;
- (BOOL)textView:(id)aView shouldHyperChangeColor:(id)aColor;
- (BOOL)textView:(id)aView shouldHyperChangeFont:(id)aFont;
- (BOOL)textView:(id)aView shouldHyperDocumentBackgroundColor:(id)aColor;
- (void)textView:(id)aView willInsertText:(id)aText;
- (void)toggleOutlineInTextView:(id)aView;
@end

@protocol HSObjectAssistantDelegate <NSObject>
- (NSRect)editorCardViewFrameForObjectAssistant:(id)aAssistant;
- (NSRect)mainWindowFrameForObjectAssistant:(id)aAssistant;
- (BOOL)objectAssistant:(id)aAssistant doCommandBySelector:(SEL)aSelector;
- (NSRect)objectAssistantObjectScreenFrame:(id)aFrame;
@end

@protocol HSObjectAssistantLayout <NSObject>
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout;
@end

@protocol HSObjectAssistantNullObjectInterface <HyperInterface>
- (BOOL)supportsSettingsOnTheSpotMode;
@end

@protocol HSObjectListDataProvider <HyperInterface>
- (id)objectListSelectionSynchronizer;
- (id)objectListTopLevelParent;
@end

@protocol HSPickMovieSourceAssistantPaneDelegate <NSObject>
- (void)pickMovieSourceAssistantPane:(id)aPane didChooseLiveObject:(id)aObject;
- (void)pickMovieSourceAssistantPane:(id)aPane didChooseMovieObject:(id)aObject isInUse:(BOOL)aUse;
@end

@protocol HSPickSoundSourceAssistantPaneDelegate <NSObject>
- (void)pickSoundSourceAssistantPane:(id)aPane didChooseSoundItem:(id)aItem;
- (void)stopSound:(id)aSound;
@end

@protocol HSPlaceObjectCanvasLayerOwner <NSObject>
- (void)cancelPlacingObjectForPlaceObjectCanvasLayer:(id)aLayer;
- (void)finishPlacingObjectForPlaceObjectCanvasLayer:(id)aLayer;
- (void)placeObjectCanvasLayer:(id)aLayer mouseMovedToPoint:(NSPoint)aPoint;
@end

@protocol HSPlaceObjectToolDelegate <NSObject>
- (void)addObjectToCardForPlaceObjectTool:(id)aTool;
- (void)placeObjectTool:(id)aTool setObjectPosition:(NSPoint)aPosition;
- (void)placingCanceledForPlaceObjectTool:(id)aTool;
- (void)placingFinishedForPlaceObjectTool:(id)aTool atPoint:(NSPoint)aPoint;
- (void)removeObjectFromCardForPlaceObjectTool:(id)aTool;
@end

@protocol HSPointSelectionToolDelegate <NSObject>
- (void)pointSelectionTool:(id)aTool selectedPointChange:(NSPoint)aChange;
- (void)pointSelectionToolDidCancelSelection;
@end

@protocol HSPrimitiveSelectionHost <NSObject>
- (id)ownSelectedObject;
@end

@protocol HSQTMovieExporterDataSource <HSExporter2DataSource, HSExportCardsImages, HSExportVideoAttributes, HSArtworkImageDataSource>
- (double)asyncSoundLengthOnCardAtIndex:(NSUInteger)aIndex;
- (BOOL)asyncSoundPresentOnCardAtIndex:(NSUInteger)aIndex;
- (BOOL)hasTransitionAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (id)moviesWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (void)setCurrentTimeForMovies:(double)aMovies runOnStart:(BOOL)aStart onCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (id)soundsWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (double)timeDelayOnArriveOnCardAtIndex:(NSUInteger)aIndex;
- (double)timeIntervalBetweenFrames;
- (id)transitionImageForTime:(double)aTime afterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (double)transitionTimeAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
@end

@protocol HSRunTimeEditorEmbedder <HyperInterface>
- (NSRect)frame;
- (BOOL)isMountedInHostView;
- (void)mountInHostView:(id)aView;
- (id)observer;
- (NSSize)preferredSize;
- (void)setFrame:(NSRect)aFrame;
- (void)setObserver:(id)aObserver;
- (void)sizeToFitWithObjectBounds:(NSRect)aBounds;
- (void)unmountFromHostView:(id)aView;
@end

@protocol HSRunTimeEditorEmbedderObserver <HyperInterface>
- (void)runTimeEditorEmbedderDidChangeContent:(id)aContent;
- (void)runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:(id)aContent;
- (void)runTimeEditorEmbedderWantsToCancel:(id)aCancel;
- (void)runTimeEditorEmbedderWantsToResign:(id)aResign;
- (void)runTimeEditorEmbedderWillChangeSelectionWithoutChangingContent:(id)aContent;
@end

@protocol HSRunTimeEditorHost <NSObject>
- (id)canvasHitTester;
- (id)hostView;
- (void)runtimeEditorWantsToResign:(id)aResign;
- (void)setNeedsDisplayInRect:(NSRect)aRect;
- (void)setNeedsDisplayRunTimeEditor:(id)aEditor;
@end

@protocol HSScriptingEnvironmentDataSource <HyperInterface>
- (NSUInteger)countOfTopLevelHyperScriptableEntities;
- (id)hyperScriptableEntityWithScriptName:(id)aName;
- (id)objectInTopLevelHyperScriptableEntitiesAtIndex:(NSUInteger)aIndex;
- (id)transitionNames;
@end

@protocol HSScrollCardPositionAssistantPaneDelegate <NSObject>
- (void)setScrollCardPositionAssistantPane:(id)aPane closeWithPosition:(NSPoint)aPosition;
@end

@protocol HSSelectionHolder <HSSelectionAccessor>
- (void)displaySelectionHolderActiveStateAndBecomeFirstResponder:(BOOL)aResponder;
- (void)displaySelectionHolderInactiveState;
- (BOOL)isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor:(id)aAccessor;
- (BOOL)isPrimarySelectionAccessorForCurrentlyHeldSelection;
- (void)selectHyperObject:(id)aObject;
- (void)selectHyperObjects:(id)aObjects;
- (id)selectionChangeDelegate;
- (void)setSelectionChangeDelegate:(id)aDelegate;
- (BOOL)updateSelectionWithInactiveCardViewSelectionAccessor:(id)aAccessor;
- (BOOL)updateSelectionWithSelectionAccessor:(id)aAccessor;
@end

@protocol HSSelectionHolderDelegate <NSObject>
- (void)selectionHolderDidChangeSelectedHyperObject:(id)aObject wantsToActivate:(BOOL)aActivate;
- (void)selectionHolderWantsToReactivate:(id)aReactivate;
- (void)selectionHolderWantsToResignAndPassOnSelection:(id)aSelection;
@end

@protocol HSSelectionHost <HSPrimitiveSelectionHost>
- (id)documentSelectionHolder;
- (void)setDocumentSelectionHolder:(id)aHolder;
- (void)updateSelectionWithSelectedObject:(id)aObject;
@end

@protocol HSSelectionInterface <NSObject>
- (id)anySelectedObject;
- (BOOL)containsObject:(id)aObject;
- (id)objectEnumerator;
- (id)objectsArray;
- (NSUInteger)objectsCount;
- (id)selectedObject;
@end

@protocol HSSelectionKnobsProvider <HSKnobsProvider>
@end

@protocol HSSelectionOwner <NSObject>
- (void)selectionDidChange:(id)aChange wasExpanded:(BOOL)aExpanded;
@end

@protocol HSSnappingCanvasItemDelegate <NSObject>
- (id)itemPrototypeObject;
- (NSUInteger)snappingRange;
@end

@protocol HSSoundRecordingAssistantPaneDelegate <NSObject>
- (void)soundRecordingAssistantPane:(id)aPane didRecordSoundItem:(id)aItem;
@end

@protocol HSSoundsLibraryTableViewDelegate <NSTableViewDelegate>
@optional
- (void)copyMediaItem:(id)aItem;
- (id)placeholderString;
- (void)setPlaceholderString:(id)aString;
- (BOOL)validateCopy:(id)aCopy;
@end

@protocol HSStackBackgroundController <NSObject>
- (void)apply;
- (id)contentView;
- (BOOL)deactivatedColorWellOnUnmount;
- (id)delegate;
- (void)setApplier:(id)aApplier;
- (void)setDelegate:(id)aDelegate;
- (void)setShouldActivateColorWellOnMount:(BOOL)aMount;
- (void)validateUIElements;
@end

@protocol HSStackView <HSSelectionHolder, NSObject>
- (id)activeCard;
- (BOOL)isCardNavigationEnabled;
- (BOOL)isEnabled;
- (BOOL)isStripVisible;
- (void)makeFirstResponder;
- (void)reloadCards;
- (void)setCardNavigationEnabled:(BOOL)aEnabled;
- (void)setEnabled:(BOOL)aEnabled;
- (void)setMediaStripUpdateDisabled:(BOOL)aDisabled;
- (void)setStack:(id)aStack;
- (void)setStack:(id)aStack forceSelection:(BOOL)aSelection;
- (void)setStackViewDelegate:(id)aDelegate;
- (BOOL)showsFirstResponderStatus;
- (id)stack;
- (id)stackViewDelegate;
- (NSRect)stackViewFrame;
@end

@protocol HSStopExporting <NSObject>
- (void)stopExport;
@end

@protocol HSStoryboardItemParent <NSObject>
- (id)cocoaView;
- (id)imageLoader;
- (id)presentationContext;
- (void)setNeedsDisplayStoryboardItem:(id)aItem;
@end

@protocol HSTextEditorEmbedder <HSRunTimeEditorEmbedder>
- (void)applyOriginalTextSize:(NSSize)aSize;
- (NSRect)borderRect;
- (void)breakUndoCoalescing;
- (BOOL)drawsBorderRect;
- (id)hyperText;
- (void)removeAllUndoActions;
- (NSSize)scaleFactor;
- (void)setBorderRect:(NSRect)aRect;
- (void)setDrawsBorderRect:(BOOL)aRect;
- (void)setScaleFactor:(NSSize)aFactor;
- (id)undoManager;
@end

@protocol HSTextObjectDataSource <NSObject>
- (void)activateCurrentItem;
- (void)activateInspectorOfCurrentItem;
- (void)deactivateCurrentItem;
- (id)hyperNameForCurrentItem;
- (BOOL)hyperReplaceTextForCurrentItem:(id)aItem inRanges:(id)aRanges;
- (NSInteger)hyperSpellDocumentTag;
- (id)hyperTextForCurrentItem;
- (BOOL)moveToNext;
- (void)selectCurrentItemNameWithRange:(NSRange)aRange;
- (void)selectCurrentItemStringWithRange:(NSRange)aRange;
- (NSRange)selectedRangeForCurrentItem;
- (NSRange)selectedRangeForCurrentItemName;
- (void)setDirection:(NSInteger)aDirection;
- (BOOL)setHyperNameForCurrentItem:(id)aItem;
- (void)setHyperTextForCurrentItem:(id)aItem;
- (void)setIncludeObjectNames:(BOOL)aNames;
- (void)setWrapsAround:(BOOL)aAround;
- (BOOL)shouldEnableIncludeObjectNamesButton;
- (void)startEnumeration;
@end

@protocol HSTextObjectSelectionInterface <NSObject>
- (NSRange)hyperSelectedRange;
- (void)setHyperSelectedRange:(NSRange)aRange;
@end

@protocol HSTextToolObjectEditingCanvasLayerClient <NSObject>
- (void)handleMouseDownInNode:(id)aNode atPoint:(NSPoint)aPoint event:(id)aEvent inTextToolObjectEditingCanvasLayer:(id)aLayer;
@end

@protocol HSTextToolShadowAttribute <NSObject>
- (BOOL)flatTextShadowEnabled;
- (void)setFlatTextShadowEnabled:(BOOL)aEnabled;
- (void)setTextShadowEnabled:(BOOL)aEnabled;
- (BOOL)textShadowEnabled;
@end

@protocol HSToolAlternateProportionAttribute <NSObject>
- (CGFloat)alternateProportion;
- (void)setAlternateProportion:(CGFloat)aProportion;
@end

@protocol HSToolTextColorAttribute <NSObject>
- (void)setTextColor:(id)aColor;
- (id)textColor;
@end

@protocol HSToolDrawColorAttribute <NSObject>
- (id)drawColor;
- (void)setDrawColor:(id)aColor;
@end

@protocol HSToolFillColorAttribute <NSObject>
- (id)fillColor;
- (void)setFillColor:(id)aColor;
@end

@protocol HSToolEraserColorAttribute <NSObject>
- (id)eraserColor;
- (void)setEraserColor:(id)aColor;
@end

@protocol HSToolStrokeWidthAttribute <NSObject>
- (void)setStrokeWidth:(CGFloat)aWidth;
- (CGFloat)strokeWidth;
@end

@protocol HSToolSizeAttribute <NSObject>
- (void)setSizeRatio:(CGFloat)aRatio;
- (CGFloat)sizeRatio;
@end

@protocol HSToolEraserSizeAttribute <NSObject>
- (NSSize)eraserSize;
- (void)setEraserSize:(NSSize)aSize;
@end

@protocol HSToolShapeStyleAttributes <NSObject>
- (void)setShouldFillShapes:(BOOL)aShapes;
- (void)setShouldStrokeShapes:(BOOL)aShapes;
- (BOOL)shouldFillShapes;
- (BOOL)shouldStrokeShapes;
@end

@protocol HSToolEffectIntencityAttribute <NSObject>
- (CGFloat)effectIntencity;
- (void)setEffectIntencity:(CGFloat)aIntencity;
@end

@protocol HSToolCursorContourAttribute <NSObject>
- (void)setShouldUseCursorContours:(CGFloat)aContours;
- (CGFloat)shouldUseCursorContours;
@end

@protocol HSToolAttributes <HSToolTextColorAttribute, HSToolDrawColorAttribute, HSToolFillColorAttribute, HSToolEraserColorAttribute, HSToolStrokeWidthAttribute, HSToolSizeAttribute, HSToolEraserSizeAttribute, HSToolShapeStyleAttributes, HSToolEffectIntencityAttribute, HSToolCursorContourAttribute, HSTextToolShadowAttribute, HSToolAlternateProportionAttribute>
- (void)resetColorsToDefault;
@end

@protocol HSToolCanvasLayerClient <NSObject>
- (id)cursorForToolCanvasLayer:(id)aLayer;
- (void)handleAutoscrollingWithMouseEvent:(id)aEvent whileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint inToolCanvasLayer:(id)aLayer;
- (void)handleFlagsChanged:(id)aChanged whileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)handleKeyEventSelector:(SEL)aSelector inToolCanvasLayer:(id)aLayer;
- (void)handleMouseDown:(id)aDown whileTrackingInToolCanvasLayer:(id)aLayer;
- (void)handleMouseDragged:(id)aDragged whileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)handleMouseMoved:(id)aMoved inToolCanvasLayer:(id)aLayer;
- (void)handleMouseUp:(id)aUp whileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)wantsAutoscrollingWhileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)wantsToSwitchToolInToolCanvasLayer:(id)aLayer event:(id)aEvent viewPoint:(NSPoint)aPoint newToolTag:(int *)aTag newTemplateIndex:(int *)aIndex skipToolApplying:(BOOL *)aApplying;
- (BOOL)wantsToTrackMouseInToolCanvasLayer:(id)aLayer;
@end

@protocol HSToolPaletteColorViewControllerDelegate <NSObject>
- (id)colorPickingController;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
@end

@protocol HSToolSettingsViewControllerParent <NSObject>
- (void)changeDrawerHeightTo:(CGFloat)aTo;
@end

@protocol HSTrackingButtonCellDelegate <NSObject>
- (void)trackingButtonCell:(id)aCell isTracking:(BOOL)aTracking wasTracking:(BOOL)aTracking2 isInside:(BOOL)aInside wasInside:(BOOL)aInside2;
@end

@protocol HSTransitionsGridDataSource <NSObject>
- (id)endImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (id)startImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (NSUInteger)transitionEffectCountInTransitionsGrid:(id)aGrid;
- (id)transitionEffectWithDisplayName:(id *)aName thumbnail:(id *)aThumbnail atIndex:(NSUInteger)aIndex inTransitionsGrid:(id)aGrid;
@end

@protocol HSTransitionsGridDelegate <NSMatrixDelegate>
@optional
- (void)doubleClickOnTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (void)selectionDidChangeInTransitionsGrid:(id)aGrid;
@end

@protocol HSTransparentColorAssistantPaneApplierDelegate <NSObject>
- (id)transparentColorAttributes;
@end

@protocol HSTransparentColorAssistantPaneDelegate <NSObject>
- (void)editingFinishedForTransparentAssistantPane:(id)aPane;
- (id)tryItAnimationForTransparentColorAssistantPane:(id)aPane;
@end

@protocol HSVectorGraphicsKnobsProvider <HSKnobsProvider>
@end

@protocol HSVideoExporterDataSource <HSQTMovieExporterDataSource, HSHyperCastingExporterDataSource>
- (BOOL)canExportDocumentAsVideoWithNarration;
@end

@protocol HSYouTubeDataProviderInterface <NSObject>
- (id)dataValueForIndex:(NSUInteger)aIndex valueCondition:(id)aCondition;
- (NSUInteger)numberOfDataItems;
@end

@protocol KeynoteBezierPathContainer <NSObject>
- (id)bezierPath;
- (BOOL)exportsBezierPath;
- (BOOL)isLine;
@end

@protocol KeynoteCache <NSObject>
- (void)addObject:(id)aObject type:(id)aType inCacheForId:(id)aId;
- (id)objectOfType:(id)aType inCacheForId:(id)aId;
@end

@protocol KeynoteImageContainer <NSObject>
- (id)data;
- (id)dataObject;
- (id)image;
- (id)media;
- (id)path;
- (NSSize)size;
@end

@protocol KeynoteLineEndContainer <NSObject>
- (id)headLineEnd;
- (id)tailLineEnd;
@end

@protocol KeynoteTextContainer <NSObject>
- (BOOL)exportsText;
- (id)text;
- (id)textBackgroundColor;
- (NSUInteger)verticalAlignment;
@end

@protocol SRConnectionItem <NSObject>
- (id)delegate;
- (id)domain;
- (NSInteger)establishListeningConnectionWithTimeout:(double)aTimeout;
- (id)identifier;
- (BOOL)isProvider;
- (id)name;
- (unsigned short)port;
- (void)refuseConnection;
- (void)setDelegate:(id)aDelegate;
@end
