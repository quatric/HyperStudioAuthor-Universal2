// The protocols HyperPlayerBase declares (gen_protocols.py), after the prefix's
// structures; the prefix forward-declares them all.


@protocol EXKeyValueCoding <NSObject>
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

@protocol EXValue <NSObject>
- (NSPoint)extraPointValue;
- (NSRange)extraRangeValue;
- (NSRect)extraRectValue;
- (NSSize)extraSizeValue;
@end

@protocol HSAttribute <NSObject>
@end

@protocol HSUndoableAttribute <HSAttribute>
@end

@protocol HSVisualAttribute <HSUndoableAttribute>
@end

@protocol HSTitleAttribute <HSVisualAttribute>
@end

@protocol HSButtonObjectTitleStyleAttribute <HSTitleAttribute>
- (id)titleAttributes;
@end

@protocol HButtonObjectTitleColorAttribute <HSButtonObjectTitleStyleAttribute>
- (id)titleColor;
@end

@protocol HSGeometryAttribute <HSVisualAttribute>
@end

@protocol HSAbsoluteCornerPositionsAttribute <HSGeometryAttribute>
- (NSPoint *)cornerPositions;
@end

@protocol HSAbstractCacheItem <NSObject>
- (NSUInteger)hardLinkCount;
@end

@protocol HyperInterface <NSObject>
- (id)hyperObject;
- (id)implementationForHyperObject:(id)aObject;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)queryHyperInterface:(id)aInterface;
@end

@protocol HSAction <HyperInterface>
- (void)didAddToDocument;
- (void)didConnectToDocument;
- (id)owner;
- (void)setOwner:(id)aOwner;
- (void)willDisconnectFromDocument;
- (void)willRemoveFromDocument;
@end

@protocol HSAttributes <HyperInterface>
- (id)attributeObservingController;
@end

@protocol HSActionSynchronousAttribute <HSAttribute>
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
@end

@protocol HSActionEventsAttribute <HSAttribute>
- (BOOL)runsWithActionEvent:(id)aEvent;
@end

@protocol HSActionLocalizedNameAttribute <HSAttribute>
- (id)localizedName;
- (id)localizedNameInInspector;
@end

@protocol HSActionAttributes <HSAttributes, HSAction, HSActionSynchronousAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute>
- (void)addActionEvent:(id)aEvent;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)events;
- (void)removeActionEvent:(id)aEvent;
- (void)setEvents:(id)aEvents;
- (void)setSynchronous:(BOOL)aSynchronous;
- (BOOL)supportedInIPad;
- (BOOL)supportedInStackToGo;
- (BOOL)supportedInWebPlayer;
- (BOOL)wantsSaveAfterRemove;
@end

@protocol HSActionCopySupport <NSObject>
- (id)unrefreshingUIDs;
@end

@protocol HSActionExecutionContextProvider <HyperInterface>
- (id)actionExecutionContext;
@end

@protocol HSActionExecutionManagerProvider <HyperInterface>
- (id)actionExecutionManager;
@end

@protocol HSActionMediaPlayerMovieOwner <NSObject>
- (void)hyperPlayableObjectDidStop:(id)aStop;
@end

@protocol HSActionOwner <NSObject>
- (id)hyperObjectForAction:(id)aAction;
@end

@protocol HSActionSupport <HSAttributes>
- (id)cardForAction:(id)aAction;
- (id)stackForAction:(id)aAction;
@end

@protocol HSActionValidationStatusAttribute <HSAttribute>
- (BOOL)isValid;
@end

@protocol HSActionValidation <HSAttributes, HSActionValidationStatusAttribute>
- (BOOL)isAbleToStartInInvalidState;
- (void)updateActionValidationStatus;
@end

@protocol HSActionsAttribute <HSUndoableAttribute>
- (BOOL)hasActionsMatchingProtocol:(id)aProtocol;
- (id)hyperActionOfType:(id)aType;
- (id)hyperActionOfType:(id)aType forEvent:(id)aEvent;
- (id)hyperActions;
- (id)hyperActionsForEvent:(id)aEvent;
- (id)hyperActionsOfType:(id)aType;
- (id)hyperActionsOfType:(id)aType forEvent:(id)aEvent;
@end

@protocol HSActionsConsumer <NSObject>
- (void)addActions:(id)aActions;
- (id)addHyperAction:(id)aAction forEvent:(id)aEvent;
- (id)addHyperActionOfType:(id)aType forEvent:(id)aEvent;
- (NSInteger)indexOfHyperAction:(id)aAction;
- (id)insertHyperAction:(id)aAction atIndex:(NSInteger)aIndex forEvent:(id)aEvent;
- (void)removeActions:(id)aActions;
- (void)removeHyperAction:(id)aAction forEvent:(id)aEvent;
- (void)removeHyperActionOfType:(id)aType forEvent:(id)aEvent;
- (void)removeHyperActionsOfType:(id)aType;
- (void)removeHyperActionsOfType:(id)aType forEvent:(id)aEvent;
- (id)replaceHyperAction:(id)aAction withAction:(id)aAction2 forEvents:(id)aEvents;
- (id)replaceHyperActionsForEvent:(id)aEvent withAction:(id)aAction;
@end

@protocol HSActionsDelayAttribute <HSAttribute>
- (double)delay;
@end

@protocol HSRunScriptActionValidation <HyperInterface>
- (BOOL)hasHyperWarnings;
- (BOOL)isHyperValid;
@end

@protocol HSMediaCopySupport <NSObject>
- (id)mediaUIDs;
- (id)ownedMediaUIDs;
@end

@protocol HSHTML5ActorExportSupport <NSObject>
- (id)actionsHTML5RepresentationForEvent:(id)aEvent inContext:(id)aContext;
- (id)nonCardObjectRepsInContext:(id)aContext;
@end

@protocol HSActor <HSActionsConsumer, HSActionsAttribute, HSRunScriptActionValidation, HSActionsDelayAttribute, HSMediaCopySupport, HSActionCopySupport, HSAttributes, HSHTML5ActorExportSupport>
- (id)actionQueueForEvent:(id)aEvent callingObject:(id)aObject;
- (id)automaticTimerForActionEvent:(id)aEvent;
- (id)createActionOfType:(id)aType forEvent:(id)aEvent;
- (id)hyperOwner;
- (void)invalidateSavedActions;
- (void)setDelay:(double)aDelay;
@end

@protocol HSActorOwner <NSObject>
- (id)hyperObjectForActor:(id)aActor;
@end

@protocol HSAffineTransformAttribute <HSGeometryAttribute>
@end

@protocol HSAnimatedObjectAttribute <HSAttribute>
- (BOOL)isAnimatedObject;
@end

@protocol HSInteractiveInAnimationAttribute <HSAttribute>
- (BOOL)isInteractiveInAnimation;
@end

@protocol HSAnimatedObjectAttributes <HSAttributes, HSAnimatedObjectAttribute, HSInteractiveInAnimationAttribute>
- (void)setAnimatedObject:(BOOL)aObject;
- (void)setInteractiveInAnimation:(BOOL)aAnimation;
@end

@protocol HSAnimationMoviePlaybackDataSource <NSObject>
- (BOOL)isPlayingForAnimationMoviePlayback:(id)aPlayback;
- (id)objectToAnimateForAnimationMoviePlayback:(id)aPlayback;
- (id)optionsForAnimationMoviePlayback:(id)aPlayback;
- (double)pathTimeForAnimationMoviePlayback:(id)aPlayback;
- (id)structureForAnimationMoviePlayback:(id)aPlayback;
@end

@protocol HSAnimationMoviePlaybackDelegate <NSObject>
- (void)stopFromAnimationMoviePlayback:(id)aPlayback;
@end

@protocol HSAnimationOptions <NSObject>
- (BOOL)allowRestart;
- (BOOL)canFlipAtFinish;
- (BOOL)canFlipAtStart;
- (double)clampedDuration;
- (BOOL)dontEraseGoing;
- (BOOL)dontEraseReturning;
- (NSInteger)goingAbsoluteLayer;
- (BOOL)hideOnFirstFrame;
- (BOOL)hideOnLastFrame;
- (BOOL)horizontalFlipAtFinish;
- (BOOL)horizontalFlipAtStart;
- (NSInteger)layer;
- (NSInteger)loopFrameRepeats;
- (NSInteger)loopMode;
- (NSInteger)loopPathRepeats;
- (double)loopSeconds;
- (BOOL)matchToMovement;
- (double)movieSpeed;
- (NSInteger)oldFormatHideMode;
- (BOOL)playBackAndForth;
- (BOOL)playMovie;
- (NSInteger)playbackDirection;
- (NSInteger)restartMode;
- (NSInteger)returningAbsoluteLayer;
- (void)setClampedDuration:(double)aDuration;
- (void)setDontEraseGoing:(BOOL)aGoing;
- (void)setDontEraseReturning:(BOOL)aReturning;
- (void)setGoingAbsoluteLayer:(NSInteger)aLayer;
- (void)setHideOnFirstFrame:(BOOL)aFrame;
- (void)setHideOnLastFrame:(BOOL)aFrame;
- (void)setHorizontalFlipAtFinish:(BOOL)aFinish;
- (void)setHorizontalFlipAtStart:(BOOL)aStart;
- (void)setLayer:(NSInteger)aLayer;
- (void)setLoopFrameRepeats:(NSInteger)aRepeats;
- (void)setLoopMode:(NSInteger)aMode;
- (void)setLoopPathRepeats:(NSInteger)aRepeats;
- (void)setLoopSeconds:(double)aSeconds;
- (void)setMatchToMovement:(BOOL)aMovement;
- (void)setMovieSpeed:(double)aSpeed;
- (void)setOldFormatHideMode:(NSInteger)aMode;
- (void)setPlayBackAndForth:(BOOL)aForth;
- (void)setPlayMovie:(BOOL)aMovie;
- (void)setPlaybackDirection:(NSInteger)aDirection;
- (void)setRestartMode:(NSInteger)aMode;
- (void)setReturningAbsoluteLayer:(NSInteger)aLayer;
- (void)setSpeedMode:(NSInteger)aMode;
- (void)setSpeedMultiplier:(CGFloat)aMultiplier;
- (void)setTimesPerSecond:(NSInteger)aSecond;
- (void)setTransparentColor:(id)aColor;
- (void)setUseClones:(BOOL)aClones;
- (void)setUsesTransparentColor:(BOOL)aColor;
- (void)setVerticalFlipAtFinish:(BOOL)aFinish;
- (void)setVerticalFlipAtStart:(BOOL)aStart;
- (NSInteger)speedMode;
- (CGFloat)speedMultiplier;
- (NSInteger)timesPerSecond;
- (id)transparentColor;
- (BOOL)useClones;
- (BOOL)usesTransparentColor;
- (BOOL)verticalFlipAtFinish;
- (BOOL)verticalFlipAtStart;
- (BOOL)wasMovieSpeedSet;
- (BOOL)wasTimesPerSecondSet;
@end

@protocol HSAnimationPlaybackState <NSObject>
- (BOOL)isPaused;
- (BOOL)isPlaying;
- (void)pause;
- (double)playbackTime;
- (void)resume;
- (void)start;
- (void)stop;
@end

@protocol HSAnimationPlaybackStateDataSource <NSObject>
- (double)playbackDurationForAnimationPlaybackState:(id)aState;
- (NSInteger)timesPerSecondForAnimationPlaybackState:(id)aState;
- (BOOL)usesNormalTimesPerSecondForAnimationPlaybackState:(id)aState;
@end

@protocol HSAnimationPlaybackStateDelegate <NSObject>
- (void)playbackDidEndForAnimationPlaybackState:(id)aState;
- (void)playbackTimeDidChangeForAnimationPlaybackState:(id)aState;
- (void)playbackWillStartForAnimationPlaybackState:(id)aState;
@end

@protocol HSAnimationPlaybackTimerDelegate <NSObject>
- (void)playbackTimerDidFired:(id)aFired;
@end

@protocol HSAnimationPositioningDataSource <NSObject>
- (id)objectToAnimateForAnimationPositioning:(id)aPositioning;
- (double)pathTimeForAnimationPositioning:(id)aPositioning;
- (id)structureForAnimationPositioning:(id)aPositioning;
@end

@protocol HSAnimationStructure <NSObject>
- (void)addAttribute:(id)aAttribute withName:(id)aName;
- (id)attributes;
- (void)clear;
- (double)duration;
- (BOOL)isEmpty;
- (BOOL)isOnePointPathAnimation;
- (id)path;
- (id)pathKeyFrames;
- (CGFloat)pathLengthAtTime:(double)aTime;
- (NSPoint)pathPointAtTime:(double)aTime;
- (void)setPath:(id)aPath keyFrames:(id)aFrames;
- (void)setPathAndGenerateKeyFrames:(id)aFrames;
@end

@protocol HSAnimationTimesDataSource <NSObject>
- (NSInteger)normalTimesPerSecondForAnimationTimes:(id)aTimes;
- (id)optionsForAnimationTimes:(id)aTimes;
- (id)structureForAnimationTimes:(id)aTimes;
- (NSInteger)timesPerSecondForAnimationTimes:(id)aTimes;
@end

@protocol HSSelectionAccessor <NSObject>
- (id)selectedHyperObject;
@end

@protocol HSStackSelectionAccessor <HSSelectionAccessor>
@end

@protocol HSCardSelectionAccessor <HSSelectionAccessor>
@end

@protocol HSCardObjectSelectionAccessor <HSSelectionAccessor>
@end

@protocol HSAnythingSelectionAccessor <HSStackSelectionAccessor, HSCardSelectionAccessor, HSCardObjectSelectionAccessor>
@end

@protocol HSAppleScriptSourceAttribute <HSAttribute>
- (id)appleScriptSource;
@end

@protocol HSAppleScriptURLAttribute <HSAttribute>
- (id)appleScriptURL;
@end

@protocol HSApplicationToQuitAttribute <HSAttribute>
- (id)applicationToQuit;
@end

@protocol HSArchiving <NSObject>
- (id)archivingMethod;
- (id)compressData:(id)aData;
- (id)description;
- (id)uncompressData:(id)aData;
@end

@protocol HSArchivingMethod <HSArchiving>
+ (id)methodKey;
@end

@protocol HSArduinoPinConfigurationAttribute <HSAttribute>
- (struct __CFDictionary *)analogPinConfigurationDictionary;
- (struct __CFDictionary *)digitalPinConfigurationDictionary;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin;
@end

@protocol HSArduinoPinConfigurationRangeMappingsAttribute <HSAttribute>
- (struct __CFDictionary *)analogPinConfigurationRangeMappings;
- (struct __CFDictionary *)analogPinConfigurationRangesForObjectWithUID:(id)aUID;
- (struct __CFDictionary *)digitalPinConfigurationRangeMappings;
- (struct __CFDictionary *)digitalPinConfigurationRangesForObjectWithUID:(id)aUID;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
@end

@protocol HSArduinoServer <NSObject>
- (id)retainDefaultDeviceWithObserver:(id)aObserver;
- (id)retainDeviceWithSerialPortName:(id)aName observer:(id)aObserver;
@end

@protocol HSArduinoSetupActionAttributes <HSActionAttributes, HSArduinoPinConfigurationAttribute>
- (void)removeConfigurationForAnalogPin:(unsigned char)aPin;
- (void)removeConfigurationForDigitalPin:(unsigned char)aPin;
- (void)setAnalogPinConfigurationDictionary:(struct __CFDictionary *)aDictionary;
- (void)setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (void)setupDevice;
@end

@protocol HSArduinoWatcherActionAttributes <HSActionAttributes, HSArduinoPinConfigurationRangeMappingsAttribute>
- (void)removeConfigurationRangeForObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (void)removeConfigurationRangeForObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
- (void)removePinConfigurationRangesForObjectWithUID:(id)aUID;
- (void)setDigitalPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings analogPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings2;
- (void)setDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
@end

@protocol HSArduinoWatchers <NSObject>
- (id)triggeringWatchers;
- (id)triggeringWatchersForAnalogPin:(unsigned char)aPin;
- (id)triggeringWatchersForDigitalPin:(unsigned char)aPin;
@end

@protocol HSAttributeDictionaryReplacements <NSObject>
- (id)applyToDictionary:(id)aDictionary;
- (id)attributeNamesEnumerator;
- (BOOL)isEmpty;
- (id)replacementValueForAttributeName:(id)aName;
@end

@protocol HSAttributeObserving <NSObject>
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (id)attributesBeingChangedContinuously;
- (id)attributesChangedTemporary;
- (void)beginContinuousChangeOfAttribute:(id)aAttribute;
- (void)beginContinuousChangeOfAttributeSet:(id)aSet;
- (void)endContinuousChangeOfAttribute:(id)aAttribute;
- (void)endContinuousChangeOfAttributeSet:(id)aSet;
- (void)removeAttributeObserver:(id)aObserver;
- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces;
@end

@protocol HSAttributedStringReplacements <NSObject>
- (NSRange)affectedRangeAtReplacementIndex:(NSUInteger)aIndex;
- (id)allIncludedAttributes;
- (id)attributeNamesEnumeratorAtReplacementIndex:(NSUInteger)aIndex;
- (BOOL)isEmpty;
- (NSUInteger)numberOfReplacements;
- (id)replacementValueForAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex;
@end

@protocol HSAttributedStringValueAttribute <HSVisualAttribute>
- (id)hyperAttributedStringValue;
@end

@protocol HSRecordTimeAttribute <HSAttribute>
- (double)recordTime;
@end

@protocol HSSensitivityLevelAttribute <HSAttribute>
- (NSInteger)sensitivityLevel;
@end

@protocol HSRecordNameAttribute <HSAttribute>
- (id)recordName;
@end

@protocol HSAutoRecordActionAttributes <HSActionAttributes, HSRecordTimeAttribute, HSSensitivityLevelAttribute, HSRecordNameAttribute>
- (void)setRecordName:(id)aName;
- (void)setRecordTime:(double)aTime;
- (void)setSensitivityLevel:(NSInteger)aLevel;
@end

@protocol HSTextViewUIDsAttribute <HSAttribute>
- (id)textViewUIDs;
@end

@protocol HSTextViewNamesAttribute <HSAttribute>
- (id)textViewNames;
@end

@protocol HSTextViewProcessingActionAttributes <HSActionAttributes, HSTextViewUIDsAttribute, HSTextViewNamesAttribute>
- (void)setTextViewNames:(id)aNames;
- (void)setTextViewUIDs:(id)aDs;
@end

@protocol HSAutoScrollNumberOfStepsAttribute <HSAttribute>
- (NSInteger)numberOfSteps;
@end

@protocol HSAutoScrollStepsPerSecondAttribute <HSAttribute>
- (NSInteger)stepsPerSecond;
@end

@protocol HSAutoScrollScrollAmountAttribute <HSAttribute>
- (NSInteger)scrollAmount;
- (NSInteger)scrollUnits;
@end

@protocol HSAutoScrollScrollDirectionAttribute <HSAttribute>
- (NSInteger)scrollDirection;
@end

@protocol HSAutoScrollIgnoreMouseClicksAttribute <HSAttribute>
- (BOOL)ignoreMouseClicks;
@end

@protocol HSAutoScrollActionAttributes <HSTextViewProcessingActionAttributes, HSAutoScrollNumberOfStepsAttribute, HSAutoScrollStepsPerSecondAttribute, HSAutoScrollScrollAmountAttribute, HSAutoScrollScrollDirectionAttribute, HSAutoScrollIgnoreMouseClicksAttribute>
- (void)setIgnoreMouseClicks:(BOOL)aClicks;
- (void)setNumberOfSteps:(NSInteger)aSteps;
- (void)setScrollAmount:(NSInteger)aAmount;
- (void)setScrollDirection:(NSInteger)aDirection;
- (void)setScrollUnits:(NSInteger)aUnits;
- (void)setStepsPerSecond:(NSInteger)aSecond;
@end

@protocol HSAutoTypeTextToTypeAttribute <HSAttribute>
- (id)textToType;
@end

@protocol HSAutoTypeActionAttributes <HSTextViewProcessingActionAttributes, HSAutoTypeTextToTypeAttribute>
- (void)setTextToType:(id)aType;
@end

@protocol HSAutomaticTimerActionsDelayAttribute <HSAttribute>
- (double)delayBeforeRunActionsAutomatically;
@end

@protocol HSAutomaticTimerActionsDelayBetweenRepeatingActionsAttribute <HSAttribute>
- (double)delayBetweenRepeatingActions;
@end

@protocol HSAutomaticTimerActionsEnabledAttribute <HSAttribute>
- (BOOL)runActionsAutomatically;
@end

@protocol HSAutomaticTimerAttributes <HSAttributes, HSAutomaticTimerActionsEnabledAttribute, HSAutomaticTimerActionsDelayAttribute, HSAutomaticTimerActionsDelayBetweenRepeatingActionsAttribute>
- (void)setDelayBeforeRunActionsAutomatically:(double)aAutomatically;
- (void)setDelayBetweenRepeatingActions:(double)aActions;
- (void)setRunActionsAutomatically:(BOOL)aAutomatically;
@end

@protocol HSAutoplayAttribute <HSAttribute>
- (BOOL)isAutoplayed;
@end

@protocol HSAutoplayAttributes <HSAttributes, HSAutoplayAttribute>
- (id)autoPlayActionEvent;
- (id)playSelfActionType;
- (void)setAutoPlayActionEvent:(id)aEvent;
- (void)setAutoplayed:(BOOL)aAutoplayed;
@end

@protocol HSTrackingLoopClient <NSObject>
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
@end

@protocol HSAutoscrollingTrackingLoopClient <HSTrackingLoopClient>
@end

@protocol HSTransitionAttribute <HSAttribute>
- (id)transition;
@end

@protocol HSTransitionOwner <HSAttributes, HSTransitionAttribute>
- (void)setTransition:(id)aTransition;
@end

@protocol HSChangeCardActionAttributes <HSActionAttributes, HSTransitionOwner>
@end

@protocol HSBackActionAttributes <HSChangeCardActionAttributes>
@end

@protocol HSBackgroundAttribute <HSVisualAttribute>
@end

@protocol HSBackgroundGraphicsAttribute <HSBackgroundAttribute>
- (id)backgroundGraphics;
@end

@protocol HSBackgroundBoundsAttribute <HSBackgroundAttribute>
- (NSRect)backgroundBounds;
@end

@protocol HSBackgroundAttributes <HSAttributes, HSBackgroundGraphicsAttribute, HSBackgroundBoundsAttribute>
@end

@protocol HSMutableBackgroundAttributes <HSBackgroundAttributes>
- (id)queryBackgroundGraphicsInterface:(id)aInterface;
- (void)setBackgroundGraphics:(id)aGraphics;
@end

@protocol HSBackgroundAttributesContainerPrimitives <HSMutableBackgroundAttributes>
- (void)_setBackgroundGraphics:(id)aGraphics;
- (id)backgroundThumbnail;
- (void)hyperDrawBackgroundInROI:(NSRect)aROI ofBounds:(NSRect)aBounds;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject;
@end

@protocol HSBaseTextAttribute <HSVisualAttribute>
@end

@protocol HSBackgroundColorAttribute <HSBaseTextAttribute>
- (id)backgroundColor;
@end

@protocol HSBackgroundRenderer <NSObject>
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize;
- (void)hyperDrawBackgroundInROI:(NSRect)aROI ofBounds:(NSRect)aBounds;
@end

@protocol HSScaleAttribute <HSAffineTransformAttribute>
@end

@protocol HSBaseScaleAttribute <HSScaleAttribute>
@end

@protocol HSVectorAttribute <HSVisualAttribute>
@end

@protocol HSBezierPathVectorAttribute <HSVectorAttribute>
- (id)bezierPath;
@end

@protocol HSBorderAttribute <HSVisualAttribute>
@end

@protocol HSBorderlessAttribute <HSBorderAttribute>
- (BOOL)isBorderless;
@end

@protocol HSBorderColorAttribute <HSBorderAttribute>
- (id)borderColor;
@end

@protocol HSBorderWidthAttribute <HSBorderAttribute>
- (CGFloat)borderWidth;
@end

@protocol HSBorderAttributes <HSAttributes, HSBorderlessAttribute, HSBorderColorAttribute, HSBorderWidthAttribute>
- (void)setBorderColor:(id)aColor;
- (void)setBorderWidth:(CGFloat)aWidth;
- (void)setIsBorderless:(BOOL)aBorderless;
@end

@protocol HSBorderPathAttribute <HSBorderAttribute>
- (id)borderPath;
@end

@protocol HSBorderShowingInPlayerAttribute <HSBorderAttribute>
- (BOOL)showsBorderInPlayer;
@end

@protocol HSBrushNameAttribute <HSAttribute>
- (id)brushName;
@end

@protocol HSBrushVisualAttribute <HSVisualAttribute>
@end

@protocol HSBrushThicknessAttribute <HSBrushVisualAttribute>
- (CGFloat)brushThickness;
@end

@protocol HSBrushColorAttribute <HSBrushVisualAttribute>
- (id)brushColor;
@end

@protocol HSBrushAttributes <HSAttributes, HSBrushNameAttribute, HSBrushThicknessAttribute, HSBrushColorAttribute>
@end

@protocol HSBrushMutableAttributes <HSBrushAttributes>
- (void)setBrushColor:(id)aColor;
- (void)setBrushName:(id)aName;
- (void)setBrushThickness:(CGFloat)aThickness;
@end

@protocol HSBrushRenderer <NSObject>
- (void)drawInRegion:(id)aRegion;
@end

@protocol HSButonObjectContentOverlapsBackgroundAtrribute <HSVisualAttribute>
- (BOOL)contentOverlapsBackground;
@end

@protocol HSSpecialAccessAudioCueAttribute <HSAttribute>
- (NSInteger)audioCueType;
@end

@protocol HSSpecialAccessAudioMediaAttribute <HSAttribute>
- (id)audioMedia;
- (id)audioMediaUID;
@end

@protocol HSSpecialAccessActionAttributes <HSActionAttributes, HSSpecialAccessAudioCueAttribute, HSSpecialAccessAudioMediaAttribute>
- (void)setAudioCueType:(NSInteger)aType;
- (void)setAudioMedia:(id)aMedia;
- (void)setAudioMediaUID:(id)aUID;
@end

@protocol HSButtonListerRepeatAttribute <HSAttribute>
- (BOOL)shouldRepeat;
@end

@protocol HSButtonListerDelayAttribute <HSAttribute>
- (CGFloat)performDelay;
@end

@protocol HSButtonListerButtonsAttribute <HSAttribute>
- (id)buttonUIDs;
@end

@protocol HSButtonListerActionAttributes <HSSpecialAccessActionAttributes, HSButtonListerRepeatAttribute, HSButtonListerDelayAttribute, HSButtonListerButtonsAttribute>
- (void)setButtonUIDs:(id)aDs;
- (void)setPerformDelay:(CGFloat)aDelay;
- (void)setShouldRepeat:(BOOL)aRepeat;
@end

@protocol HSTitleStringAttribute <HSTitleAttribute>
- (id)title;
@end

@protocol HSTitleFontAttribute <HSTitleAttribute>
- (id)titleFont;
@end

@protocol HSTitleRectAttribute <HSTitleAttribute>
- (NSRect)untransformedTitleRect;
@end

@protocol HSTitleAttributes <HSAttributes, HSTitleStringAttribute, HSTitleFontAttribute, HSTitleRectAttribute>
@end

@protocol HSTitleMutableAttributes <HSTitleAttributes>
- (void)setTitle:(id)aTitle;
- (void)setTitleFont:(id)aFont;
@end

@protocol HSSystemControlSizeAttribute <HSVisualAttribute>
- (NSUInteger)controlSize;
@end

@protocol HSSystemButtonBorderAttribute <HSVisualAttribute>
- (BOOL)isBordered;
@end

@protocol HSSystemTransparencyAttribute <HSVisualAttribute>
- (BOOL)isTransparent;
@end

@protocol HSSystemButtonContinuousAttribute <HSAttribute>
- (BOOL)isContinuous;
@end

@protocol HSSystemEnabledAttribute <HSVisualAttribute>
- (BOOL)isEnabled;
@end

@protocol HSSystemButtonAttributes <HSAttributes, HSTitleMutableAttributes, HSSystemControlSizeAttribute, HSSystemButtonBorderAttribute, HSSystemTransparencyAttribute, HSSystemButtonContinuousAttribute, HSSystemEnabledAttribute>
- (void)hyperSizeToFitContent;
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically;
- (void)setBordered:(BOOL)aBordered;
- (void)setContinuous:(BOOL)aContinuous;
- (void)setControlSize:(NSUInteger)aSize;
- (void)setEnabled:(BOOL)aEnabled;
- (void)setTransparent:(BOOL)aTransparent;
@end

@protocol HSSystemPushButtonAttributes <HSSystemButtonAttributes>
- (void)controlSizeDidChange;
- (void)controlSizeWillChange;
@end

@protocol HSImageAttribute <HSVisualAttribute>
@end

@protocol HSMediaAttribute <HSVisualAttribute>
- (id)media;
@end

@protocol HSMediaUIDAttribute <HSMediaAttribute>
- (id)mediaUID;
@end

@protocol HSSystemSquareButtonImageAttribute <HSImageAttribute, HSMediaUIDAttribute>
- (id)image;
@end

@protocol HSSystemSquareButtonImageRectAttribute <HSVisualAttribute>
@end

@protocol HSSystemSquareButtonAlternateImageAttribute <HSAttribute>
- (id)alternateImage;
- (id)alternateMedia;
@end

@protocol HSVisualSystemSquareButtonAlternateImageAttribute <HSSystemSquareButtonAlternateImageAttribute, HSVisualAttribute>
@end

@protocol HSSystemSquareButtonImagePositionAttribute <HSVisualAttribute>
- (NSUInteger)imagePosition;
@end

@protocol HSSystemSquareButtonAttributes <HSSystemPushButtonAttributes, HSSystemSquareButtonImageAttribute, HSSystemSquareButtonImageRectAttribute, HSVisualSystemSquareButtonAlternateImageAttribute, HSSystemSquareButtonImagePositionAttribute>
- (void)setAlternateImage:(id)aImage;
- (void)setAlternateMedia:(id)aMedia;
- (void)setImage:(id)aImage;
- (void)setImageFromPath:(id)aPath;
- (void)setImagePosition:(NSUInteger)aPosition;
@end

@protocol HSButtonObjectTitleVisibilityAttribute <HSTitleAttribute>
- (BOOL)isTitleVisible;
- (BOOL)isTitleVisibleForButtonType:(id)aType;
@end

@protocol HSButtonObjectIconAttribute <HSVisualAttribute>
- (id)icon;
@end

@protocol HSButtonObjectIconVisibilityAttribute <HSButtonObjectIconAttribute>
- (BOOL)isIconVisible;
@end

@protocol HSButtonObjectIconPositionAttribute <HSButtonObjectIconAttribute>
- (NSUInteger)iconPosition;
@end

@protocol HSButtonObjectVisualIconPositionAttribute <HSButtonObjectIconAttribute>
- (NSUInteger)visualIconPosition;
@end

@protocol HSButtonObjectHighlightAttribute <HSVisualAttribute>
- (BOOL)hasHighlight;
- (BOOL)hasHighlightForButtonType:(id)aType;
@end

@protocol HSButtonObjectBackgroundStyleIdentifierAttribute <HSVisualAttribute>
- (id)backgroundStyle;
@end

@protocol HSButtonObjectBackgroundStyleAttribute <HSButtonObjectBackgroundStyleIdentifierAttribute>
- (id)background;
@end

@protocol HSButtonObjectVisibilityAttribute <HSVisualAttribute>
- (BOOL)isButtonInvisible;
@end

@protocol HSButtonObjectNaturalVisibilityAttribute <HSVisualAttribute>
- (BOOL)isButtonNaturallyInvisible;
@end

@protocol HSOpacityAttribute <HSVisualAttribute>
- (CGFloat)hyperOpacity;
@end

@protocol HSOpacityAttributes <HSAttributes, HSOpacityAttribute>
@end

@protocol HSMutableOpacityAttributes <HSOpacityAttributes>
- (void)setHyperOpacity:(CGFloat)aOpacity;
@end

@protocol HSButtonObjectHiddenInEditorAttribute <HSVisualAttribute>
- (BOOL)isHiddenInEditor;
@end

@protocol HSButtonObjectAttributes <HSSystemSquareButtonAttributes, HButtonObjectTitleColorAttribute, HSButtonObjectTitleVisibilityAttribute, HSButtonObjectIconAttribute, HSButtonObjectIconVisibilityAttribute, HSButtonObjectIconPositionAttribute, HSButtonObjectVisualIconPositionAttribute, HSButonObjectContentOverlapsBackgroundAtrribute, HSButtonObjectHighlightAttribute, HSButtonObjectBackgroundStyleAttribute, HSButtonObjectVisibilityAttribute, HSButtonObjectNaturalVisibilityAttribute, HSMutableOpacityAttributes, HSButtonObjectTitleStyleAttribute, HSButtonObjectHiddenInEditorAttribute>
- (void)setBackgroundStyle:(id)aStyle;
- (void)setBackgroundStyle:(id)aStyle needsResetRotationAngle:(BOOL)aAngle;
- (void)setContentOverlapsBackground:(BOOL)aBackground;
- (void)setHasHighlight:(BOOL)aHighlight;
- (void)setHiddenInEditor:(BOOL)aEditor;
- (void)setIcon:(id)aIcon;
- (void)setIconFromPath:(id)aPath;
- (void)setIconPosition:(NSUInteger)aPosition;
- (void)setIconVisible:(BOOL)aVisible;
- (void)setTitleColor:(id)aColor;
- (void)setTitleVisible:(BOOL)aVisible;
@end

@protocol HSButtonObjectBackgroundAttributes <HSAttributes, HSButtonObjectBackgroundStyleIdentifierAttribute>
- (id)buttonType;
- (BOOL)isVisible;
- (void)setOwner:(id)aOwner;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
@end

@protocol HSButtonObjectBorderAttributes <HSBorderAttributes, HSBorderPathAttribute>
- (void)setBorderPath:(id)aPath;
@end

@protocol HSUserObjectHitTesting <HyperInterface>
- (BOOL)hitTestUserPoint:(NSPoint)aPoint;
@end

@protocol HSUserObjectEditorHitTesting <HSUserObjectHitTesting>
- (BOOL)hitTestUserRect:(NSRect)aRect;
@end

@protocol HSButtonObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSButtonObjectShapeAlternativeBorderAttribute <HSBorderAttribute>
- (BOOL)isAlternativeBorderActive;
@end

@protocol HSButtonObjectShapeButtonTypeAttribute <HSVisualAttribute>
- (id)shapeButtonType;
@end

@protocol HSButtonObjectShapeBackgroundAttributes <HSButtonObjectBackgroundAttributes, HSMutableBackgroundAttributes, HSButtonObjectBorderAttributes, HSButtonObjectShapeButtonTypeAttribute, HSBorderShowingInPlayerAttribute, HSButtonObjectShapeAlternativeBorderAttribute>
- (void)activateAlternativeBorder:(BOOL)aBorder;
- (void)setShapeButtonType:(id)aType;
- (void)setShowsBorderInPlayer:(BOOL)aPlayer;
@end

@protocol HSButtonObjectSystemBackgroundAttribute <HSVisualAttribute>
@end

@protocol HSButtonObjectSystemBackgroundColorAttribute <HSButtonObjectSystemBackgroundAttribute>
- (id)tintColor;
@end

@protocol HSButtonObjectSystemBackgroundIgnoreTintColorAttribute <HSButtonObjectSystemBackgroundAttribute>
- (BOOL)ignoreTintColor;
@end

@protocol HSButtonObjectSystemButtonTypeAttribute <HSButtonObjectSystemBackgroundAttribute>
- (id)systemButtonType;
@end

@protocol HSButtonObjectSystemStyleBackgroundAttributes <HSButtonObjectBackgroundAttributes, HSButtonObjectSystemBackgroundColorAttribute, HSButtonObjectSystemButtonTypeAttribute, HSButtonObjectSystemBackgroundIgnoreTintColorAttribute>
- (CGFloat)additionalHorizontalTitleSpace;
- (id)backgroundImagePartForType:(NSInteger)aType;
- (BOOL)canButtonStyleBeUpdated;
- (BOOL)canResizeVertically;
- (void)setIgnoreTintColor:(BOOL)aColor;
- (void)setSystemButtonType:(id)aType;
- (void)setTintColor:(id)aColor;
- (BOOL)shouldTileMiddleBackgroundParts;
- (void)updateButtonObjectStyle;
@end

@protocol HSButtonScannerScanDelayAttribute <HSAttribute>
- (CGFloat)scanDelay;
@end

@protocol HSButtonScannerResetDelayAttribute <HSAttribute>
- (CGFloat)resetDelay;
@end

@protocol HSButtonScannerScanCyclesAttribute <HSAttribute>
- (NSUInteger)scanCyclesCount;
@end

@protocol HSButtonScannerHidesCursorAttribute <HSAttribute>
- (BOOL)hidesCursor;
@end

@protocol HSButtonScannerActionAttributes <HSSpecialAccessActionAttributes, HSButtonScannerScanDelayAttribute, HSButtonScannerResetDelayAttribute, HSButtonScannerScanCyclesAttribute, HSButtonScannerHidesCursorAttribute>
- (void)setHidesCursor:(BOOL)aCursor;
- (void)setResetDelay:(CGFloat)aDelay;
- (void)setScanCyclesCount:(NSUInteger)aCount;
- (void)setScanDelay:(CGFloat)aDelay;
@end

@protocol HSButtonStepperButtonsAttribute <HSAttribute>
- (id)buttonUIDs;
@end

@protocol HSButtonStepperActionAttributes <HSSpecialAccessActionAttributes, HSButtonStepperButtonsAttribute>
- (void)setButtonUIDs:(id)aDs;
@end

@protocol HSCameraObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSCanvasHitTesting <HyperInterface>
- (BOOL)hasHitTesterForNode:(id)aNode;
- (id)hitTestNodeAtPoint:(NSPoint)aPoint;
- (id)hitTesterForNode:(id)aNode;
- (id)hitTesterForNode:(id)aNode point:(NSPoint)aPoint;
@end

@protocol HSCanvasEditorHitTesting <HSCanvasHitTesting>
- (id)hitTestNodesInRect:(NSRect)aRect;
@end

@protocol HSCanvasItem <HyperInterface>
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
@end

@protocol HSCanvasItemActivation <HSCanvasItem>
- (void)activateInCanvasLayer:(id)aLayer;
- (void)deactivate;
- (void)invalidateParentCanvasLayer;
@end

@protocol HSCanvasLayer <NSObject>
- (NSRect)boundingRectOccupiedByLayer;
- (id)context;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)invalidateDisplay;
- (BOOL)isRunning;
- (BOOL)isRunningInWindow;
- (void)renderRect:(NSRect)aRect;
- (id)representedObject;
@end

@protocol HSCanvasLayerContext <HyperInterface>
- (id)actionExecutionContext;
- (id)actionExecutionManager;
- (id)canvasHitTester;
- (id)renderingView;
@end

@protocol HSCanvasSuperlayer <HSCanvasLayer>
- (NSUInteger)numberOfSublayers;
- (id)rootLayer;
- (id)sublayerAtIndex:(NSUInteger)aIndex;
@end

@protocol HSCanvasRootLayer <HSCanvasSuperlayer>
- (id)activeLayer;
- (void)beginSublayerTreeChanging;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (void)endSublayerTreeChanging;
- (BOOL)handleFlagsChanged:(id)aChanged;
- (BOOL)handleKeyEquivalent:(id)aEquivalent;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleMagnificationGesture:(id)aGesture;
- (BOOL)handleMouseDown:(id)aDown;
- (void)handleMouseMoved:(id)aMoved;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleRawKeyUpEvent:(id)aEvent;
- (BOOL)handleRotationGesture:(id)aGesture;
- (BOOL)handleScrollWheel:(id)aWheel;
- (BOOL)handleSwipeGesture:(id)aGesture;
- (BOOL)handleTouchesBegan:(id)aBegan;
- (BOOL)handleTouchesCancelled:(id)aCancelled;
- (BOOL)handleTouchesEnded:(id)aEnded;
- (BOOL)handleTouchesMoved:(id)aMoved;
- (void)performActionSelector:(SEL)aSelector withSender:(id)aSender;
- (void)registerSupportedActionSelector:(SEL)aSelector;
- (BOOL)respondsToActionSelector:(SEL)aSelector;
- (void)setActiveLayer:(id)aLayer;
- (void)setContext:(id)aContext;
- (void)setRepresentedObject:(id)aObject;
- (void)setRunningDisabled:(BOOL)aDisabled;
- (void)sublayerTreeDidChange;
- (BOOL)validateActionSelector:(SEL)aSelector withUserInterfaceItem:(id)aItem;
@end

@protocol HSCanvasSublayer <HSCanvasLayer>
- (void)contextDidChange;
- (void)contextWillChange;
- (void)didBecomeActiveLayer;
- (void)didStartRunning;
- (void)didStartRunningInWindow;
- (id)parentLayer;
- (void)renderingViewTransformDidChange;
- (void)representedObjectDidChange;
- (void)representedObjectWillChange;
- (void)setParentLayer:(id)aLayer;
- (void)willResignActiveLayer;
- (void)willStopRunning;
- (void)willStopRunningInWindow;
@end

@protocol HSCaptureDeviceSessionClient <NSObject>
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
@end

@protocol HSCapturedFrame <NSObject>
- (id)frameRepresentation;
- (BOOL)isFrameProcessed;
- (id)sampleBuffer;
@end

@protocol HSCapturingConsumer <NSObject>
- (void)capturingDataSource:(id)aSource didOutputFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime;
@end

@protocol HSCapturingDataSource <NSObject>
- (void)startCapturingForConsumer:(id)aConsumer;
- (void)stopCapturingForConsumer:(id)aConsumer;
@end

@protocol HSCardTitleAttribute <HSAttribute>
- (id)hyperTitle;
@end

@protocol HSCardGroupAttribute <HSAttribute>
- (BOOL)isGroupCard;
@end

@protocol HSCardMarkedAttribute <HSAttribute>
- (BOOL)isMarkedCard;
@end

@protocol HSCardAttributes <HSAttributes, HSCardTitleAttribute, HSCardGroupAttribute, HSCardMarkedAttribute>
- (NSInteger)cardIdOldFileFormat;
- (id)cardIdOldFileFormatAsString;
- (BOOL)isEmpty;
@end

@protocol HSCardGroupControllerOwner <NSObject>
- (void)cardGroupController:(id)aController addCards:(id)aCards atIndexes:(id)aIndexes;
- (id)cardGroupController:(id)aController cardAtIndex:(NSUInteger)aIndex;
- (void)cardGroupController:(id)aController removeCardsAtIndexes:(id)aIndexes;
- (id)cardsForCardGroupController:(id)aController;
- (id)groupsForCardGroupController:(id)aController;
- (id)undoManagerForCardGroupController:(id)aController;
@end

@protocol HSLayoutGeometryHoldersProvider <NSObject>
- (NSUInteger)countOfHyperGeometryHoldersForInterface:(id)aInterface;
- (id)objectInHyperGeometryHoldersForInterface:(id)aInterface atIndex:(NSUInteger)aIndex;
@end

@protocol HSCardLayoutGuidingInterface <HSLayoutGeometryHoldersProvider>
- (BOOL)isHyperCardIgnoredInLayoutGuiding;
- (void)setHyperCardIgnoredInLayoutGuiding:(BOOL)aGuiding;
@end

@protocol HSCardNavigator <NSObject>
- (BOOL)canPerformNavigationOperation:(id)aOperation;
- (void)cancelNavigationOperation:(id)aOperation;
- (void)continueNavigationOperation:(id)aOperation;
- (id)currentNavigationOperation;
- (void)finishNavigationOperation:(id)aOperation;
- (void)goToCardAtIndex:(NSInteger)aIndex;
- (void)goToCardAtIndex:(NSInteger)aIndex allowGoToCurrent:(BOOL)aCurrent;
- (void)goToCardAtIndex:(NSInteger)aIndex inStackAtURL:(id)aURL withTransition:(id)aTransition;
- (void)goToCardWithUID:(id)aUID inStackAtURL:(id)aURL withTransition:(id)aTransition;
- (void)startNavigationOperation:(id)aOperation;
@end

@protocol HSCardObjectRotatableAttribute <HSAttribute>
- (BOOL)canBeRotatable;
- (BOOL)isRotatable;
@end

@protocol HSCardObjectResizableAttribute <HSAttribute>
- (BOOL)canBeResizable;
- (BOOL)isResizable;
@end

@protocol HSCardObjectDraggableAttribute <HSAttribute>
- (BOOL)canBeDraggable;
- (BOOL)isDraggable;
@end

@protocol HSCardObjectHiddenAttribute <HSVisualAttribute>
- (BOOL)canBeHidden;
- (BOOL)isHidden;
- (BOOL)isHiddenInPlayer;
- (BOOL)isVisibleInEditor;
@end

@protocol HSCardObjectLockedAttribute <HSAttribute>
- (BOOL)isLocked;
@end

@protocol HSCardObjectFlattenAttribute <HSAttribute>
- (BOOL)canBeFlatten;
@end

@protocol HSCardObjectNoClickAttribute <HSAttribute>
- (BOOL)isNoClick;
@end

@protocol HSCardObjectDropOffOnlyAttribute <HSAttribute>
- (BOOL)isDropOffOnly;
@end

@protocol HSCardObjectSendActionsOnDropAttribute <HSAttribute>
- (BOOL)canSendActionsOnDrop;
@end

@protocol HSCardObjectGroupAttribute <HSAttribute>
- (BOOL)isGroupObject;
@end

@protocol HSCardObjectEffectPerObjectAttribute <HSAttribute>
- (id)effectPerObject;
- (BOOL)hasEffectPerObject;
- (BOOL)supportsEffectPerObject;
@end

@protocol HSCardObjectAttributes <HSAttributes, HSCardObjectRotatableAttribute, HSCardObjectResizableAttribute, HSCardObjectDraggableAttribute, HSCardObjectHiddenAttribute, HSCardObjectLockedAttribute, HSCardObjectFlattenAttribute, HSCardObjectNoClickAttribute, HSCardObjectDropOffOnlyAttribute, HSCardObjectSendActionsOnDropAttribute, HSCardObjectGroupAttribute, HSCardObjectEffectPerObjectAttribute>
@end

@protocol HSCardObjectLayoutGuidingInterface <HyperInterface>
- (BOOL)isHyperIgnoredInLayoutGuiding;
- (void)setHyperIgnoredInLayoutGuiding:(BOOL)aGuiding;
@end

@protocol HSCardObjectOptimization <HyperInterface>
- (id)mediaUIDsForOptimization;
@end

@protocol HSCardShufflerActionEndingCardIndexAttribute <HSAttribute>
- (NSUInteger)endingCardIndex;
@end

@protocol HSCardShufflerActionStartingCardIndexAttribute <HSAttribute>
- (NSUInteger)startingCardIndex;
@end

@protocol HSCardShufflerActionShouldClearChangesAttribute <HSAttribute>
- (BOOL)shouldClearChanges;
@end

@protocol HSCardShufflerActionAttributes <HSActionAttributes, HSCardShufflerActionEndingCardIndexAttribute, HSCardShufflerActionStartingCardIndexAttribute, HSCardShufflerActionShouldClearChangesAttribute>
- (void)setEndingCardIndex:(NSUInteger)aIndex;
- (void)setShouldClearChanges:(BOOL)aChanges;
- (void)setStartingCardIndex:(NSUInteger)aIndex;
@end

@protocol HSCardView <NSObject>
- (id)card;
- (void)setCard:(id)aCard;
@end

@protocol HSCelMovieObjectFrameCountAttribute <HSAttribute>
- (NSInteger)hyperFrameCount;
@end

@protocol HSMovieObjectEraseWhenDoneAttribute <HSVisualAttribute>
- (BOOL)hyperEraseWhenDone;
@end

@protocol HSCelMovieObjectAttributes <HSAttributes, HSCelMovieObjectFrameCountAttribute, HSMovieObjectEraseWhenDoneAttribute>
- (void)setHyperEraseWhenDone:(BOOL)aDone;
@end

@protocol HSCelMovieObjectCacheItem <HSAbstractCacheItem>
- (id)frameImage:(id)aImage;
- (id)frameMediaUID;
- (id)groupOwner;
- (id)linkToCacheObject:(id)aObject;
- (NSUInteger)unlinkFromCacheObject:(id)aObject;
@end

@protocol HSChangeCursorVisibilityActionAttribute <HSAttribute>
- (NSInteger)changeCursorVisibilityAction;
@end

@protocol HSClipPathAttribute <HSVisualAttribute>
- (id)clipPath;
@end

@protocol HSClipAttributes <HSAttributes, HSClipPathAttribute>
@end

@protocol HSClipPathsAttribute <HSVisualAttribute>
- (id)clipPaths;
@end

@protocol HSCocoaTextStorageAccessing <HyperInterface>
- (id)cocoaTextStorage;
@end

@protocol HSGraphics <HyperInterface, EXKeyValueCoding, NSCopying>
- (void)didAddToDocument;
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (id)hyperMutableCopyWithZone:(NSZone *)aZone;
- (void)willRemoveFromDocument;
@end

@protocol HSColor <HSGraphics>
- (CGFloat)hyperAngle;
- (CGFloat)hyperCenterX;
- (CGFloat)hyperCenterY;
- (id)hyperEndColor;
- (NSInteger)hyperKind;
- (id)hyperSolidColor;
- (id)hyperStartColor;
- (BOOL)isHyperCacheEnabled;
- (BOOL)isHyperClear;
- (BOOL)isHyperGradient;
- (BOOL)isHyperSolid;
@end

@protocol HSCommentsAndAttributionsDataProvider <NSObject>
- (id)cardView;
- (id)currentActiveCard;
- (id)currentActiveStack;
@end

@protocol HSCommentsAttribute <HSAttribute>
- (id)childrenComments;
- (id)deepComments;
- (id)hyperComments;
@end

@protocol HSCommentsAttributes <HSAttributes, HSCommentsAttribute>
- (void)appendHyperComments:(id)aComments;
- (void)appendHyperCommentsFromObjects:(id)aObjects;
- (void)setHyperComments:(id)aComments;
@end

@protocol HSCompareTextActionResponseObjectAttribute <HSAttribute>
- (id)responseObjectUID;
@end

@protocol HSCompareTextActionTextToMatchObjectAttribute <HSAttribute>
- (id)textToMatchObjectUID;
@end

@protocol HSCompareTextActionComparisonMatchObjectUIDAttribute <HSAttribute>
- (id)comparisonMatchObjectUID;
@end

@protocol HSCompareTextActionComparisonMismatchObjectUIDAttribute <HSAttribute>
- (id)comparisonMismatchObjectUID;
@end

@protocol HSCompareTextActionDefinedStringAttribute <HSAttribute>
- (id)definedString;
@end

@protocol HSCompareTextActionComparisonSelectorAttribute <HSAttribute>
- (SEL)comparisonSelector;
@end

@protocol HSCompareTextActionCaseSensitiveComparisonAttribute <HSAttribute>
- (BOOL)isCaseSensitiveComparison;
@end

@protocol HSCompareTextActionAttributes <HSActionAttributes, HSCompareTextActionResponseObjectAttribute, HSCompareTextActionTextToMatchObjectAttribute, HSCompareTextActionComparisonMatchObjectUIDAttribute, HSCompareTextActionComparisonMismatchObjectUIDAttribute, HSCompareTextActionDefinedStringAttribute, HSCompareTextActionComparisonSelectorAttribute, HSCompareTextActionCaseSensitiveComparisonAttribute>
- (void)setCaseSensitiveComparison:(BOOL)aComparison;
- (void)setComparisonMatchObjectUID:(id)aUID;
- (void)setComparisonMismatchObjectUID:(id)aUID;
- (void)setComparisonSelector:(SEL)aSelector;
- (void)setDefinedString:(id)aString;
- (void)setResponseObjectUID:(id)aUID;
- (void)setTextToMatchObjectUID:(id)aUID;
@end

@protocol HSCoreImageEffectAccessing <HyperInterface>
- (id)coreImageEffect;
- (id)coreImageEffectAdjustedToSize:(NSSize)aSize;
@end

@protocol HSCoreTextAttributes <HyperInterface>
- (id)hyperFont;
- (id)hyperFontFamily;
- (CGFloat)hyperFontSize;
- (id)hyperOutlineColor;
- (CGFloat)hyperOutlineWidth;
- (CGFloat)hyperShadowAngle;
- (CGFloat)hyperShadowBlurRadius;
- (CGFloat)hyperShadowDistance;
- (NSSize)hyperShadowOffset;
- (CGFloat)hyperSpaceBetweenCharacters;
- (CGFloat)hyperSpaceBetweenLines;
- (NSUInteger)hyperTextAlignment;
- (id)hyperTextAttributesDictionary;
- (id)hyperTextColor;
- (BOOL)isHyperBold;
- (BOOL)isHyperCondensed;
- (BOOL)isHyperExpanded;
- (BOOL)isHyperItalic;
- (BOOL)isHyperOutlineEnabled;
- (BOOL)isHyperShadowEnabled;
- (BOOL)isHyperUnderlined;
@end

@protocol HSCoreTextInterface <HSCoreTextAttributes>
- (void)getHyperBold:(BOOL *)aBold multipleValues:(BOOL *)aValues;
- (void)getHyperCondensed:(BOOL *)aCondensed multipleValues:(BOOL *)aValues;
- (void)getHyperExpanded:(BOOL *)aExpanded multipleValues:(BOOL *)aValues;
- (void)getHyperFont:(id *)aFont multipleValues:(BOOL *)aValues;
- (void)getHyperFontFamily:(id *)aFamily multipleValues:(BOOL *)aValues;
- (void)getHyperFontSize:(float *)aSize multipleValues:(BOOL *)aValues;
- (void)getHyperItalic:(BOOL *)aItalic multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineColor:(id *)aColor multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineWidth:(float *)aWidth multipleValues:(BOOL *)aValues;
- (void)getHyperShadow:(id *)aShadow multipleValues:(BOOL *)aValues;
- (void)getHyperShadowAngle:(float *)aAngle multipleValues:(BOOL *)aValues;
- (void)getHyperShadowBlurRadius:(float *)aRadius multipleValues:(BOOL *)aValues;
- (void)getHyperShadowDistance:(float *)aDistance multipleValues:(BOOL *)aValues;
- (void)getHyperShadowEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues;
- (void)getHyperShadowOffset:(NSSize *)aOffset multipleValues:(BOOL *)aValues;
- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters multipleValues:(BOOL *)aValues;
- (void)getHyperSpaceBetweenLines:(float *)aLines multipleValues:(BOOL *)aValues;
- (void)getHyperTextAlignment:(unsigned int *)aAlignment multipleValues:(BOOL *)aValues;
- (void)getHyperTextAttributes:(id *)aAttributes multipleValues:(BOOL *)aValues;
- (void)getHyperTextColor:(id *)aColor multipleValues:(BOOL *)aValues;
- (void)getHyperUnderlined:(BOOL *)aUnderlined multipleValues:(BOOL *)aValues;
- (BOOL)hasBackground;
- (NSSize)hyperRequiredSizeForTextBlockOfHeight:(CGFloat)aHeight maximumWidth:(CGFloat)aWidth;
- (NSSize)hyperRequiredSizeToFitWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2;
- (id)hyperString;
- (id)hyperTextBackgroundColor;
- (BOOL)isHyperEmpty;
@end

@protocol HSCoreMutableTextInterface <HSCoreTextInterface>
- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter undoActionName:(id)aName;
- (void)applyFontWithFontConverter:(id)aConverter undoActionName:(id)aName;
- (void)applyHyperTextAttributes:(id)aAttributes undoActionName:(id)aName;
- (void)finishOutlineMutating:(BOOL)aMutating undoActionName:(id)aName;
- (void)hyperReplaceText:(id)aText undoActionName:(id)aName;
- (void)hyperReplaceTextWithString:(id)aString attributes:(id)aAttributes undoActionName:(id)aName;
- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange undoActionName:(id)aName;
- (void)hyperReplaceTextWithString:(id)aString undoActionName:(id)aName;
- (void)setHasBackground:(BOOL)aBackground undoActionName:(id)aName;
- (void)setHyperBold:(BOOL)aBold undoActionName:(id)aName;
- (void)setHyperCondensed:(BOOL)aCondensed undoActionName:(id)aName;
- (void)setHyperCursorPositionAccordingToCurrentEvent;
- (void)setHyperExpanded:(BOOL)aExpanded undoActionName:(id)aName;
- (void)setHyperFont:(id)aFont undoActionName:(id)aName;
- (void)setHyperFontFamily:(id)aFamily undoActionName:(id)aName;
- (void)setHyperFontFamilyWithFont:(id)aFont undoActionName:(id)aName;
- (void)setHyperFontSize:(CGFloat)aSize undoActionName:(id)aName;
- (void)setHyperItalic:(BOOL)aItalic undoActionName:(id)aName;
- (void)setHyperOutlineColor:(id)aColor undoActionName:(id)aName;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled undoActionName:(id)aName;
- (void)setHyperOutlineWidth:(CGFloat)aWidth undoActionName:(id)aName;
- (void)setHyperShadowAngle:(CGFloat)aAngle undoActionName:(id)aName;
- (void)setHyperShadowBlurRadius:(CGFloat)aRadius undoActionName:(id)aName;
- (void)setHyperShadowDistance:(CGFloat)aDistance undoActionName:(id)aName;
- (void)setHyperShadowEnabled:(BOOL)aEnabled undoActionName:(id)aName;
- (void)setHyperShadowOffset:(NSSize)aOffset undoActionName:(id)aName;
- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters undoActionName:(id)aName;
- (void)setHyperSpaceBetweenLines:(CGFloat)aLines undoActionName:(id)aName;
- (void)setHyperTextAlignment:(NSUInteger)aAlignment undoActionName:(id)aName;
- (void)setHyperTextBackgroundColor:(id)aColor undoActionName:(id)aName;
- (void)setHyperTextColor:(id)aColor undoActionName:(id)aName;
- (void)setHyperUnderlined:(BOOL)aUnderlined undoActionName:(id)aName;
- (void)startOutlineMutating;
@end

@protocol HSCoreTextParent <NSObject>
- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName;
- (id)undoManager;
@end

@protocol HSCroppedImageLegacyStoringOwner <NSObject>
- (id)imageObjectForLegacyImageStoring:(id)aStoring;
@end

@protocol HSCursorAttribute <HSAttribute>
- (id)hyperCursor;
@end

@protocol HSCursorAttributes <HSAttributes, HSCursorAttribute>
- (void)setHyperCursor:(id)aCursor;
@end

@protocol HSCursorPositionAttribute <HSAttribute>
- (NSPoint)cursorPosition;
@end

@protocol HSCustomButton <NSObject>
- (id)hyperCustomButtonImage;
- (id)hyperCustomButtonName;
- (id)hyperCustomButtonPathName;
- (id)hyperCustomButtonTitle;
- (id)initWithMedia:(id)aMedia name:(id)aName;
@end

@protocol HSCustomButtonsSharedProvider <NSObject>
- (CGFloat)additionalHorizontalTitleSpaceForButtonWithMediaUID:(id)aUID;
- (id)backgroundImagePartForButtonWithMediaUID:(id)aUID partType:(NSInteger)aType;
- (BOOL)canResizeVerticallyBackgroundForButtonWithMediaUID:(id)aUID;
- (id)hyperCustomButtonDescriptionForName:(id)aName;
- (id)hyperCustomButtonImageForName:(id)aName;
- (id)hyperCustomButtons;
- (BOOL)shouldTileMiddleBackgroundPartsForButtonWithMediaUID:(id)aUID;
@end

@protocol HSDefaultSizeSubattributes <HSAttributes>
- (NSSize)defaultSize;
@end

@protocol HSImage <HSGraphics>
- (id)hyperImage;
- (NSUInteger)hyperImageAlignment;
- (NSInteger)hyperImageScaling;
- (NSSize)hyperImageSize;
@end

@protocol HSMutableGraphics <HSGraphics>
- (void)setHyperOwner:(id)aOwner;
@end

@protocol HSMutableImage <HSImage, HSMutableGraphics>
- (void)setHyperImage:(id)aImage;
- (void)setHyperImageAlignment:(NSUInteger)aAlignment;
- (void)setHyperImageFromPath:(id)aPath;
- (void)setHyperImageScaling:(NSInteger)aScaling;
- (void)setHyperImageSize:(NSSize)aSize;
@end

@protocol HSDesktopCoverImage <HSMutableImage>
@end

@protocol HSDestinationCardUIDAttribute <HSAttribute>
- (id)destinationCardUID;
@end

@protocol HSDistantArduinoDevice <NSObject>
- (id)analogPinState;
- (NSInteger)connectionStatus;
- (id)digitalPinState;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin;
- (void)releaseWithObserver:(id)aObserver;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin withChangeTime:(unsigned long long)aTime;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin withChangeTime:(unsigned long long)aTime;
@end

@protocol HSDistantArduinoDeviceObserver <NSObject>
- (void)analogPinStateDidChange:(id)aChange;
- (void)deviceDidChangeConnectionStatus:(NSInteger)aStatus;
- (void)digitalPinStateDidChange:(id)aChange;
@end

@protocol HSEditModeUndoHelperDelegate <NSObject>
- (void)documentUndoManagerDidRemoveAllActions:(id)aActions;
- (void)documentUndoManagerWillRegisterUndo:(id)aUndo;
@end

@protocol HSImageRectAttribute <HSVisualAttribute>
- (NSRect)imageRect;
@end

@protocol HSEditableImageAttributes <HSAttributes, HSImageAttribute, HSImageRectAttribute>
- (void)beginEditImage:(id)aImage;
- (void)beginEditImage:(id)aImage inRect:(NSRect)aRect;
- (void)beginEditImageContinuously;
- (void)endEditImage;
- (void)endEditImageContinuously;
- (id)queryImageWithRequiredProtocols:(id *)aProtocols optionalProtocols:(id *)aProtocols2;
@end

@protocol HSEditableImageMediaAttributes <NSObject>
- (id)editableImageMedia;
- (void)setEditableImageMedia:(id)aMedia;
@end

@protocol HSVisualization <HyperInterface>
- (id)queryRenderer;
- (id)queryRendererWithVisualizationOptions:(id)aOptions;
- (id)subobjectVisualizations;
- (id)subobjects;
- (id)visualizationForSubobject:(id)aSubobject;
- (id)visualizationProtocol;
@end

@protocol HSHitTestingVisualization <HSVisualization>
@end

@protocol HSEditorHitTestingVisualization <HSHitTestingVisualization>
@end

@protocol HSEditorVisualization <HSVisualization>
@end

@protocol HSEffectAttribute <HSAttribute>
@end

@protocol HSEffectNameAttribute <HSEffectAttribute>
- (id)hyperEffectName;
@end

@protocol HSEffectVisualAttribute <HSEffectAttribute, HSVisualAttribute>
@end

@protocol HSEffectSourceAreaAttribute <HSEffectVisualAttribute>
- (struct CGPath *)effectSourceAreaBoundingPath;
@end

@protocol HSEffectAttributes <HSAttributes, HSEffectNameAttribute, HSEffectSourceAreaAttribute>
- (id)effectSettings;
- (id)hyperAttributes;
- (id)hyperInputKeys;
- (id)hyperValueForKey:(id)aKey;
@end

@protocol HSEffectMutableAttributes <HSEffectAttributes>
- (void)setHyperEffectName:(id)aName;
- (void)setHyperEffectName:(id)aName settings:(id)aSettings;
- (void)setHyperValue:(id)aValue forKey:(id)aKey;
@end

@protocol HSEffectObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSEffectPerObjectAttributes <HSAttributes>
@end

@protocol HSEffectedMediaAttribute <HSVisualAttribute>
- (id)hyperEffectedMedia;
@end

@protocol HSURLAttribute <HSAttribute>
- (id)URL;
@end

@protocol HSEmailAddressesAttribute <HSURLAttribute>
- (id)hyperEmailAddress;
- (id)hyperEmailAddresses;
@end

@protocol HSEmailSubjectAttribute <HSURLAttribute>
- (id)hyperEmailSubject;
@end

@protocol HyperObject <NSObject>
@end

@protocol HSEventResponderActionInterface <HyperObject>
- (BOOL)handleKeyDownEvent:(id)aEvent;
- (BOOL)handleKeyUpEvent:(id)aEvent;
- (BOOL)handleMouseDownEvent:(id)aEvent;
@end

@protocol HSWeakReferencing <NSObject>
- (void)registerWeakReferencer:(id)aReferencer;
- (void)unregisterWeakReferencer:(void *)aReferencer;
@end

@protocol HSRenderLayer <NSObject, HSWeakReferencing>
- (void)addObserver:(id)aObserver;
- (void)addVisualizationAttributesToSet:(id)aSet;
- (void)addVisualizationMaskAttributesToSet:(id)aSet;
- (id)boundingRegion;
- (id)boundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (id)boundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (BOOL)cacheRenderingInRegion:(id)aRegion forAffineTransform:(CGAffineTransform)aTransform withTransformationIntent:(struct HyperPlayerBase_anon1 *)aIntent acceptableValidnessLimit:(CGFloat)aLimit delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (id)continuousChangeSensitiveVisualizationAttributes;
- (id)copyRemovingRenderSublayers;
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon1 *)aIntent;
- (id)hyperObject;
- (BOOL)isEmpty;
- (BOOL)isOpaqueInRect:(NSRect)aRect;
- (void)postDrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)removeObserver:(void *)aObserver;
- (id)renderLayerAtIndexPath:(id)aPath role:(id *)aRole;
- (id)renderLayerAtPosition:(NSUInteger)aPosition inIndexPath:(id)aPath role:(id *)aRole;
- (id)renderLayerPathForIndexPath:(id)aPath;
- (id)renderSublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)renderSublayerCount;
- (id)renderSublayers;
- (BOOL)requiresTransparencyLayer;
- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)sharedRenderCaches;
- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (BOOL)unionBoundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (BOOL)unionBoundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionWithRegion:(id)aRegion;
- (id)visualizationAttributes;
- (id)visualizationMaskAttributes;
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon1 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce;
@end

@protocol HSExpandableRenderLayer <HSRenderLayer>
- (void)addRenderSublayer:(id)aSublayer forRole:(id)aRole asRoot:(BOOL)aRoot addingTransparencyLayerRequirement:(BOOL)aRequirement;
- (void)addRenderSublayersFromRenderLayer:(id)aLayer;
- (void)addRenderSublayersFromRenderLayer:(id)aLayer range:(NSRange)aRange;
- (void)beginRenderSublayersOperationGroup;
- (void)disperseRenderSublayers;
- (void)endRenderSublayersOperationGroup;
- (void)insertRenderSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex forRole:(id)aRole asRoot:(BOOL)aRoot addingTransparencyLayerRequirement:(BOOL)aRequirement;
- (void)removeAllRenderSublayers;
- (void)removeRenderSublayerAtIndex:(NSUInteger)aIndex;
- (void)removeRenderSublayersInRange:(NSRange)aRange;
- (void)replaceRenderSublayerAtIndex:(NSUInteger)aIndex withRenderSublayer:(id)aSublayer role:(id)aRole rootFlag:(BOOL)aFlag transparencyLayerRequirementAdditionFlag:(BOOL)aFlag2;
@end

@protocol HSPlayableObjectUIDAttribute <HSAttribute>
- (id)hyperPlayableObjectUID;
@end

@protocol HSPlayableObjectNameAttribute <HSAttribute>
- (id)hyperPlayableObjectName;
@end

@protocol HSPlayableObjectDurationAttribute <HSAttribute>
- (double)hyperDuration;
@end

@protocol HSPlayableObjectStartTimeAttribute <HSAttribute>
- (double)hyperStartTime;
@end

@protocol HSPlayableObjectPlayRangeAttribute <HSAttribute>
- (struct HSTimeRange)hyperPlayRange;
@end

@protocol HSPlayableObjectHyperPlayingAttribute <HSAttribute>
- (BOOL)isHyperPlaying;
@end

@protocol HSPlayableObjectAttributes <HSAttributes, HSPlayableObjectUIDAttribute, HSPlayableObjectNameAttribute, HSPlayableObjectDurationAttribute, HSPlayableObjectStartTimeAttribute, HSPlayableObjectPlayRangeAttribute, HSPlayableObjectHyperPlayingAttribute>
- (double)hyperCurrentTime;
- (void)hyperStart:(id)aStart;
- (id)hyperStarter;
- (void)hyperStepBack;
- (void)hyperStepForward;
- (void)hyperStop;
- (void)setHyperCurrentTime:(double)aTime;
- (void)setHyperPlayRange:(struct HSTimeRange)aRange;
- (void)setHyperStartTime:(double)aTime;
@end

@protocol HSExtendedPlayableObjectPlayCountAttribute <HSAttribute>
- (NSUInteger)hyperPlayCount;
@end

@protocol HSExtendedPlayableObjectAttributes <HSPlayableObjectAttributes, HSExtendedPlayableObjectPlayCountAttribute>
- (void)hyperStart:(id)aStart atRate:(CGFloat)aRate startupMode:(NSInteger)aMode;
- (void)hyperStart:(id)aStart startupMode:(NSInteger)aMode;
- (void)setHyperPlayCount:(NSUInteger)aCount;
@end

@protocol HSFillGraphicsVectorAttribute <HSVectorAttribute>
- (id)fillGraphics;
@end

@protocol HSFlipAttribute <HSAffineTransformAttribute>
@end

@protocol HSForwardActionAttributes <HSChangeCardActionAttributes>
@end

@protocol HSFrameProcessor <NSObject>
- (void)abandonCaptureOutput:(id)aOutput;
- (id)createCaptureOutputForCaptureInputs:(id)aInputs;
- (id)delegate;
- (id)outputFrameForPreprocessedFrame:(id)aFrame;
- (Class)preprocessingFrameProcessorClass;
- (void)setDelegate:(id)aDelegate;
@end

@protocol HSFramesPerSecondAttributes <HSAttributes>
- (double)hyperFramesPerSecond;
@end

@protocol HSGenericFontAttribute <HSVisualAttribute>
- (id)hyperFont;
- (id)hyperFontFamily;
- (CGFloat)hyperFontSize;
- (BOOL)isHyperBold;
- (BOOL)isHyperCondensed;
- (BOOL)isHyperExpanded;
- (BOOL)isHyperItalic;
@end

@protocol HSSystemFontPanelAdaptionInterface <HyperInterface>
- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter;
- (void)applyFontWithFontConverter:(id)aConverter;
- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor;
- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple;
@end

@protocol HSGenericFontAttributesAttribute <HSVisualAttribute>
- (id)hyperTextAttributes;
@end

@protocol HSGenericFontAttributes <HSAttributes, HSSystemFontPanelAdaptionInterface, HSGenericFontAttribute, HSGenericFontAttributesAttribute>
- (void)setHyperBold:(BOOL)aBold;
- (void)setHyperCondensed:(BOOL)aCondensed;
- (void)setHyperExpanded:(BOOL)aExpanded;
- (void)setHyperFont:(id)aFont;
- (void)setHyperFontFamily:(id)aFamily;
- (void)setHyperFontSize:(CGFloat)aSize;
- (void)setHyperItalic:(BOOL)aItalic;
@end

@protocol HSGenericObjectStringAttribute <HyperInterface>
- (id)objectString;
- (void)replaceObjectString:(id)aString inRanges:(id)aRanges;
- (void)setObjectString:(id)aString;
@end

@protocol HSGenericSolidColorAttribute <HSVisualAttribute>
- (id)hyperSolidColor;
@end

@protocol HSGenericSolidColorAttributes <HSAttributes, HSGenericSolidColorAttribute>
- (void)setHyperDroppedSolidColor:(id)aColor;
- (void)setHyperSolidColor:(id)aColor;
@end

@protocol HSGeometryAffinenessAttribute <HSGeometryAttribute>
- (BOOL)isGeometryAffine;
@end

@protocol HSSizeAttribute <HSGeometryAttribute>
@end

@protocol HSWidthAttribute <HSSizeAttribute>
- (CGFloat)width;
@end

@protocol HSHeightAttribute <HSSizeAttribute>
- (CGFloat)height;
@end

@protocol HSSizeAttributes <HSAttributes, HSWidthAttribute, HSHeightAttribute>
- (NSSize)defaultSize;
- (NSSize)size;
@end

@protocol HSHorizontalFlipAttribute <HSFlipAttribute>
- (BOOL)isFlippedHorizontally;
@end

@protocol HSVerticalFlipAttribute <HSFlipAttribute>
- (BOOL)isFlippedVertically;
@end

@protocol HSHorizontalScaleAttribute <HSBaseScaleAttribute>
- (CGFloat)horizontalScale;
@end

@protocol HSVerticalScaleAttribute <HSBaseScaleAttribute>
- (CGFloat)verticalScale;
@end

@protocol HSSkewAngleAttribute <HSAffineTransformAttribute>
- (CGFloat)skewAngle;
@end

@protocol HSSizeScaleAttribute <HSScaleAttribute>
@end

@protocol HSWidthScaleAttribute <HSSizeScaleAttribute>
- (CGFloat)widthScale;
@end

@protocol HSHeightScaleAttribute <HSSizeScaleAttribute>
- (CGFloat)heightScale;
@end

@protocol HSRotationAngleAttribute <HSAffineTransformAttribute>
- (CGFloat)rotationAngle;
@end

@protocol HSOffsetAttribute <HSAffineTransformAttribute>
@end

@protocol HSHorizontalOffsetAttribute <HSOffsetAttribute>
- (CGFloat)horizontalOffset;
@end

@protocol HSVerticalOffsetAttribute <HSOffsetAttribute>
- (CGFloat)verticalOffset;
@end

@protocol HSRelativeCornerPositionsAttribute <HSGeometryAttribute>
@end

@protocol HSGeometryAttributes <HSSizeAttributes, HSGeometryAffinenessAttribute, HSHorizontalFlipAttribute, HSVerticalFlipAttribute, HSHorizontalScaleAttribute, HSVerticalScaleAttribute, HSSkewAngleAttribute, HSWidthScaleAttribute, HSHeightScaleAttribute, HSRotationAngleAttribute, HSHorizontalOffsetAttribute, HSVerticalOffsetAttribute, HSRelativeCornerPositionsAttribute, HSAbsoluteCornerPositionsAttribute>
- (CGFloat)affineFrameHeight;
- (NSSize)affineFrameSize;
- (CGFloat)affineFrameWidth;
- (CGAffineTransform)affineTransform;
- (NSSize)baseScale;
- (NSRect)boundingRect;
- (NSRect)frameBoundingRect;
- (NSSize)offset;
- (NSSize)sizeScale;
@end

@protocol HSGeometryBehaviorAdapting <HyperInterface>
- (void)adaptAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally withLayoutGuidingContext:(id)aContext;
- (void)adaptFlippingHorizontallyWithLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (CGAffineTransform)adaptFlippingVerticallyWithLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptMovingBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptMovingHorizontallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptMovingVerticallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)adaptResizingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext force:(BOOL)aForce adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (NSSize)adaptResizingProportionallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)adaptResizingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (NSSize)adaptResizingTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptRotationBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptRotationTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)adaptSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptSize:(NSSize)aSize withLayoutGuidingContext:(id)aContext;
- (void)adaptSizeScalingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptSizeScalingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (CGAffineTransform)adaptSizeScalingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptSkewingBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptSkewingTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (id)queryGeometryBehaviorApplier;
@end

@protocol HSGeometryBehaviorAttribute <HSAttribute>
@end

@protocol HSSizeAspectRatioMaintainingPreferenceAttribute <HSGeometryBehaviorAttribute>
- (BOOL)prefersToMaintainSizeAspectRatio;
@end

@protocol HSResizingBehaviorAttributes <HSAttributes, HSSizeAspectRatioMaintainingPreferenceAttribute>
- (BOOL)canBreakSizeAspectRatio;
- (BOOL)canResizeHorizontally;
- (BOOL)canResizeVertically;
@end

@protocol HSSizeScaleAspectRatioMaintainingPreferenceAttribute <HSGeometryBehaviorAttribute>
- (BOOL)prefersToMaintainSizeScaleAspectRatio;
@end

@protocol HSGeometryBehaviorAttributes <HSResizingBehaviorAttributes, HSSizeScaleAspectRatioMaintainingPreferenceAttribute>
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)canFlipHorizontally;
- (BOOL)canFlipVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canMoveVertically;
- (BOOL)canRotate;
- (BOOL)canScaleHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canSkew;
- (BOOL)prefersResizingToScaling;
@end

@protocol HSGeometryBehaviorSubattributes <HSAttributes>
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)canFlipHorizontally;
- (BOOL)canFlipVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canMoveVertically;
- (BOOL)canRotate;
- (BOOL)canScaleHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canSkew;
- (BOOL)prefersResizingToScaling;
@end

@protocol HSGhostWriterCommandsAttribute <HSAttribute>
- (id)commands;
@end

@protocol HSGhostWriterActionAttributes <HSGhostWriterCommandsAttribute, HSActionAttributes>
- (void)setCommands:(id)aCommands;
@end

@protocol HSGhostWriterSpeedCommandInterface <HyperInterface>
- (void)setSpeed:(NSInteger)aSpeed;
- (NSInteger)speed;
@end

@protocol HSGhostWriterStuffCommandInterface <HyperInterface>
- (void)setStuffType:(id)aType;
- (id)stuffType;
@end

@protocol HSGhostWriterTargetCommandInterface <HyperInterface>
- (void)setTargetObjectUID:(id)aUID;
- (id)targetObjectUID;
@end

@protocol HSGhostWriterTypeTextCommandInterface <HyperInterface>
- (void)setStringToType:(id)aType;
- (id)stringToType;
@end

@protocol HSGoToURLActionTypeAttribute <HSAttribute>
- (NSInteger)URLType;
@end

@protocol HSGoToURLActionAttributes <HSActionAttributes, HSGoToURLActionTypeAttribute>
- (id)currentAction;
- (id)openWebPageActionAttributes;
- (id)sendMailActionAttributes;
- (void)setURLType:(NSInteger)aType;
@end

@protocol HSOpenLocationQuitAfterLaunchAttribute <HSAttribute>
- (BOOL)quitAfterLaunch;
@end

@protocol HSOpenLocationLaunchInForegroundAttribute <HSAttribute>
- (BOOL)launchInForeground;
@end

@protocol HSGoogleEarthActionAttributes <HSActionAttributes, HSMediaUIDAttribute, HSOpenLocationQuitAfterLaunchAttribute, HSOpenLocationLaunchInForegroundAttribute, HSURLAttribute>
- (void)setLaunchInForeground:(BOOL)aForeground;
- (void)setMediaUID:(id)aUID;
- (void)setQuitAfterLaunch:(BOOL)aLaunch;
- (void)setURL:(id)aURL;
@end

@protocol HSGraphicCompositionRenderer <NSObject>
- (id)inputKeys;
- (id)outputKeys;
- (BOOL)setValue:(id)aValue forInputKey:(id)aKey;
- (id)valueForInputKey:(id)aKey;
- (id)valueForOutputKey:(id)aKey;
@end

@protocol HSGraphicsDelegate <HyperInterface>
- (void)hyperVisualAttributesChanged:(id)aChanged;
- (id)undoManagerForGraphics:(id)aGraphics;
@end

@protocol HSGridInterface <NSObject>
- (id)gridColor;
- (NSSize)gridOffset;
- (BOOL)isGridVisible;
- (BOOL)isSnapToGridEnabled;
- (id)layoutGrid;
- (NSInteger)markStyle;
- (void)resetToDefaults;
- (void)setGridColor:(id)aColor;
- (void)setGridOffset:(NSSize)aOffset;
- (void)setGridVisible:(BOOL)aVisible;
- (void)setIsSnapToGridEnabled:(BOOL)aEnabled;
- (void)setMarkStyle:(NSInteger)aStyle;
@end

@protocol HSGroupBoxObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSGroupCacheItem <HSAbstractCacheItem>
- (id)groupCacheCreateIfNeed:(BOOL)aNeed;
- (id)groupIdentifier;
@end

@protocol HSHTML5ExportSupport <NSObject>
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (BOOL)shouldBeExportedAsImage;
@end

@protocol HSOutlineAvailabilityAttribute <HSVisualAttribute>
- (BOOL)isHyperOutlineEnabled;
@end

@protocol HSOutlineWidthAttribute <HSVisualAttribute>
- (CGFloat)hyperOutlineWidth;
@end

@protocol HSOutlineColorAttribute <HSVisualAttribute>
- (id)hyperOutlineColor;
@end

@protocol HSOutlineAttributes <HSAttributes, HSOutlineAvailabilityAttribute, HSOutlineWidthAttribute, HSOutlineColorAttribute>
@end

@protocol HSMutableOutlineAttributes <HSOutlineAttributes>
- (void)setHyperOutlineColor:(id)aColor;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
@end

@protocol HSHeadlineObjectAttributes <HSMutableOutlineAttributes>
@end

@protocol HSHighlightSupportAttribute <HSAttribute>
- (BOOL)canBeHighlighted;
@end

@protocol HSInteractiveHighlightAttribute <HSVisualAttribute>
- (BOOL)isHighlightedInInteractiveMode;
@end

@protocol HSHighlightAttributes <HSAttributes, HSHighlightSupportAttribute, HSInteractiveHighlightAttribute>
- (void)setCanBeHighlighted:(BOOL)aHighlighted;
- (void)setHighlightedInInteractiveMode:(BOOL)aMode;
@end

@protocol HSHypertextLink <HyperInterface>
- (id)container;
- (id)title;
@end

@protocol HSHypertextLinkContainerLinksAttribute <HSAttribute>
- (id)allLinks;
@end

@protocol HSHypertextLinkContainerAttributes <HSAttributes, HSHypertextLinkContainerLinksAttribute>
- (id)addLinkWithTitle:(id)aTitle;
- (id)allSortedTitles;
- (id)hypertextLinkAtPosition:(NSUInteger)aPosition inText:(id)aText startPosition:(unsigned int *)aPosition2;
- (id)linkWithTitle:(id)aTitle;
- (void)removeLinkWithTitle:(id)aTitle;
- (void)renameLinkWithTitle:(id)aTitle to:(id)aTo;
- (void)takeLinkWithTitle:(id)aTitle fromContainer:(id)aContainer;
@end

@protocol HSImageAttributes <HSAttributes, HSImageAttribute, HSImageRectAttribute>
- (id)image;
- (BOOL)isImageComposite;
@end

@protocol HSImageCacheAttributes <HSAttributes>
- (void)forceRecacheIfNeededForGroupObjectsOnly:(BOOL)aOnly;
- (BOOL)isEnabledCacheImage;
- (BOOL)needDisableBorderForCropping;
- (void)setEnabledCacheImage:(BOOL)aImage;
- (void)setEnabledCacheImageForAllGroupObjects:(BOOL)aObjects setUpUndoManager:(BOOL)aManager;
@end

@protocol HSImageMutableAttributes <HSImageAttributes>
- (void)setImage:(id)aImage;
@end

@protocol HSImageObjectAttribute <HSVisualAttribute>
- (id)hyperImageObject;
@end

@protocol HSRelativeImageRectAttribute <HSImageRectAttribute>
- (NSRect)relativeImageRect;
@end

@protocol HSMutableImageRectAttributes <HSAttributes, HSRelativeImageRectAttribute>
- (void)setImageRect:(NSRect)aRect;
- (void)setRelativeImageRect:(NSRect)aRect;
@end

@protocol HSInitialClipPathsAttribute <HSAttribute>
- (id)initialClipPaths;
@end

@protocol HSImageObjectAttributes <HSImageAttributes, HSMutableImageRectAttributes, HSImageObjectAttribute, HSMediaAttribute, HSEffectedMediaAttribute, HSBorderAttributes, HSInitialClipPathsAttribute, HSHighlightAttributes, HSImageCacheAttributes>
- (BOOL)canBeOptimized;
- (BOOL)canRestoreToInitialClipPaths;
- (void)dropInitialClipPaths;
- (void)resizeWithMode:(NSInteger)aMode;
- (void)setCanBeOptimized:(BOOL)aOptimized;
- (void)setCurrentClipPathsAreInitial:(BOOL)aInitial;
- (void)setHyperEffectedMedia:(id)aMedia refreshName:(BOOL)aName;
- (void)setHyperImageObject:(id)aObject;
- (void)setImageRect:(NSRect)aRect updateClipPaths:(BOOL)aPaths;
- (void)setRelativeImageRect:(NSRect)aRect updateClipPaths:(BOOL)aPaths;
- (void)setShouldUseCurrentMediaAsLegacyCroppedImageMedia:(BOOL)aMedia;
- (void)setupInitialClipPaths;
@end

@protocol HSImageObjectCropVisualization <HSVisualization>
@end

@protocol HSImageObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSImageRectSubattributes <HSAttributes, HSImageRectAttribute>
@end

@protocol HSImageWellObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSImplementationAssociating <NSObject>
- (void)associateImplementation:(id)aImplementation withInterface:(id)aInterface;
- (void)disassociateImplementation:(id)aImplementation fromInterface:(id)aInterface;
- (id)implementationAssociatedWithInterface:(id)aInterface;
- (void)rejectImplementation:(void *)aImplementation;
@end

@protocol HSImportUserInfoContainer <HyperInterface>
- (void)cleanupUserInfo;
- (void)setUserInfo:(id)aInfo forKey:(id)aKey;
- (id)userInfoForKey:(id)aKey;
@end

@protocol HSInteractiveAnimation <NSObject>
- (void)setAnimatedObject:(id)aObject;
- (void)setBasePointType:(NSInteger)aType;
- (void)setOwner:(id)aOwner;
- (void)start;
- (void)stop;
@end

@protocol HSInteractiveAnimationOwner <NSObject>
- (void)animationDidFinishForAnimatedObject:(id)aObject;
@end

@protocol HSInteractiveCanvasContext <HyperInterface>
- (id)context;
- (void)deactivateInteractiveItem:(id)aItem;
- (id)defaultInteractiveModeCursor;
- (BOOL)itemHasClickActions:(id)aActions;
- (id)nodeVisualizationDisabling;
- (BOOL)performActionsMappedToKeyEvent:(id)aEvent;
- (BOOL)resignFirstResponder;
- (void)sendClickActionsForHypertextLink:(id)aLink;
- (void)sendClickActionsForItemIfNeeded:(id)aNeeded;
- (void)sendDropOffActionsFromItemIfNeeded:(id)aNeeded;
- (void)trackMouseForDraggableItem:(id)aItem withMouseDownEvent:(id)aEvent wasDragged:(BOOL *)aDragged;
- (void)trackMouseForResizableItem:(id)aItem withMouseDownEvent:(id)aEvent wasResized:(BOOL *)aResized;
- (void)trackMouseForRotatableItem:(id)aItem withMouseDownEvent:(id)aEvent wasRotated:(BOOL *)aRotated;
@end

@protocol HSInteractiveCanvasLayerContext <HSCanvasLayerContext>
- (BOOL)isTextObjectSelected;
- (void)updateShapeButtonsShowBorder:(BOOL)aBorder;
@end

@protocol HSInteractivePlayerItem <HSCanvasItem>
- (void)awakeInPlayer;
- (BOOL)hasExecutableActionsForMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)sendingActionsIsDisabled;
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)trackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToInterceptSendingClickActionsInInteractiveContext:(id)aContext;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext;
@end

@protocol HSInteractivePlayerItemActivation <HSCanvasItemActivation, HSInteractivePlayerItem>
- (BOOL)wantsToActivateImplicitlyInInteractiveContext:(id)aContext;
- (BOOL)wantsToActivateWithMouseInInteractiveContext:(id)aContext;
@end

@protocol HSInteractiveSystemViewItemInterface <HyperInterface>
- (void)doCommandBySelector:(SEL)aSelector;
@end

@protocol HSInteractiveTextObject <NSObject>
- (BOOL)canBeActivated;
- (void)insertText:(id)aText;
- (void)saveEditingState;
- (void)selectRange:(NSRange)aRange;
- (NSRange)selectedRange;
@end

@protocol HSKeyMappingsAttribute <HSAttribute>
- (id)keyMappings;
@end

@protocol HSKeyMapperActionAttributes <HSActionAttributes, HSKeyMappingsAttribute>
- (void)setKeyMappings:(id)aMappings;
@end

@protocol HSLayoutGeometryHolder <HyperInterface>
- (BOOL)isHyperInfluencingLayout;
@end

@protocol HSLayoutGridGeometry <HSLayoutGeometryHolder>
- (BOOL)hyperGridUseMajorSteps;
- (BOOL)hyperGridUseMinorSteps;
- (BOOL)snapToCornersOnMove;
- (BOOL)snapToNegativeValues;
- (CGFloat)xHyperGridMajorStep;
- (CGFloat)xHyperGridMinorStep;
- (CGFloat)yHyperGridMajorStep;
- (CGFloat)yHyperGridMinorStep;
@end

@protocol HSLayoutGridSnappingAttribute <HSAttribute>
- (BOOL)isSnapToGridEnabled;
@end

@protocol HSLayoutGuidingContextProvider <NSObject>
- (id)layoutGuidingContext;
@end

@protocol HSLayoutInfluencingObjectGeometry <HSLayoutGeometryHolder>
- (NSRect)hyperLayoutInfluencingBoundingRect;
- (CGAffineTransform)hyperLayoutInfluencingTransform;
@end

@protocol HSLayoutObjectsSnappingAttribute <HSAttribute>
- (BOOL)isSnapToObjectsEnabled;
@end

@protocol HSLayoutSnappingAttributes <HyperInterface, HSLayoutGridSnappingAttribute, HSLayoutObjectsSnappingAttribute>
- (void)setSnapToGridEnabled:(BOOL)aEnabled;
- (void)setSnapToObjectsEnabled:(BOOL)aEnabled;
@end

@protocol HSLeavesLastPictureOnExitAttribute <HSAttribute>
- (BOOL)leavesLastPictureOnExit;
@end

@protocol HSVectorGraphicsTailEndingAttribute <HSVisualAttribute>
- (id)hyperTailEnding;
@end

@protocol HSVectorGraphicsHeadEndingAttribute <HSVisualAttribute>
- (id)hyperHeadEnding;
@end

@protocol HSLineEndingContainer <HSAttributes, HSVectorGraphicsTailEndingAttribute, HSVectorGraphicsHeadEndingAttribute>
@end

@protocol HSLiveObjectAttribute <HSAttribute>
- (id)liveObjectForCard:(id)aCard;
@end

@protocol HSLiveObjectDeviceIndexAttribute <HSAttribute>
- (NSUInteger)hyperDeviceIndex;
@end

@protocol HSLiveObjectAttributes <HSPlayableObjectAttributes, HSLiveObjectDeviceIndexAttribute>
- (void)setHyperDeviceIndex:(NSUInteger)aIndex;
@end

@protocol HSLiveObjectUIDAttribute <HSAttribute>
- (id)liveObjectUID;
@end

@protocol HSLiveVideoDeviceAttribute <HSAttribute>
- (id)liveVideoDevice;
@end

@protocol HSLiveVideoAttributes <HSAttributes, HSLiveVideoDeviceAttribute>
@end

@protocol HSLiveVideoNameAttribute <HSAttribute>
- (id)liveVideoName;
@end

@protocol HSLiveVideoPlayOverObjectsAttribute <HSAttribute>
- (BOOL)playOverObjects;
@end

@protocol HSPlaybackItemUIDAttribute <HSAttribute>
- (id)objectUID;
@end

@protocol HSPlaybackItemTemporaryAttribute <HSAttribute>
- (BOOL)isTemporary;
@end

@protocol HSPlaybackEnabledAttribute <HSAttribute>
- (BOOL)isEnabled;
@end

@protocol HSPlaybackSizeAttribute <HSVisualAttribute>
- (NSSize)size;
@end

@protocol HSPlaybackTransformAttribute <HSVisualAttribute>
- (CGAffineTransform)affineTransform;
@end

@protocol HSPlaybackItemSupportAttribute <HSAttribute>
- (id)playbackItemSupport;
@end

@protocol HSPlaybackItemAttributes <HSAttributes, HSPlaybackItemUIDAttribute, HSPlaybackItemTemporaryAttribute, HSPlaybackEnabledAttribute, HSPlaybackSizeAttribute, HSPlaybackTransformAttribute, HSPlaybackItemSupportAttribute, NSCopying>
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (void)setEnabled:(BOOL)aEnabled;
- (void)setPlaybackItemSupport:(id)aSupport;
- (void)setSize:(NSSize)aSize;
@end

@protocol HSPlayMovieActionLiveVideoDeviceIndexAttribute <HSAttribute>
- (NSInteger)liveVideoDeviceIndex;
@end

@protocol HSLiveVideoPlaybackAttributes <HSPlaybackItemAttributes, HSLiveObjectUIDAttribute, HSPlayMovieActionLiveVideoDeviceIndexAttribute, HSLiveObjectAttribute, HSLiveVideoNameAttribute, HSLiveVideoPlayOverObjectsAttribute>
- (void)playInActionExecutionContext:(id)aContext;
- (void)setLiveVideoDeviceIndex:(NSInteger)aIndex;
- (void)setLiveVideoName:(id)aName;
- (void)setPlayOverObjects:(BOOL)aObjects;
- (void)stopPlaying;
@end

@protocol HSLoopPictureShowAttribute <HSAttribute>
- (BOOL)loopPictureShow;
@end

@protocol HSLoopSlideShowAttribute <HSAttribute>
- (BOOL)loopSlideShow;
@end

@protocol HSMDItemObject <HyperInterface>
- (id)supportedMDAttributes;
- (id)valuesForMDAttribute:(id)aAttribute;
@end

@protocol HSMedia <NSObject>
- (id)dictionaryRepresentation;
- (id)fullPathToMediaFile;
- (id)mediaData;
- (id)mediaDataSize;
- (NSInteger)mediaGroup;
- (id)mediaName;
- (id)mediaType;
- (id)mediaUID;
@end

@protocol HSMediaAttributes <HSAttributes, HSMediaAttribute, HSMediaUIDAttribute>
- (void)setMedia:(id)aMedia;
- (void)setMedia:(id)aMedia error:(id *)aError;
@end

@protocol HSMediaObject <NSObject>
- (id)initWithMedia:(id)aMedia;
- (id)initWithMedia:(id)aMedia error:(id *)aError;
@end

@protocol HSMessageButtonTitleAttribute <HSAttribute>
- (id)buttonTitle;
@end

@protocol HSMessageIconImageAttribute <HSAttribute>
- (id)messageIcon;
- (id)messageIconImageUID;
@end

@protocol HSMessageStringAttribute <HSAttribute>
- (id)messageString;
@end

@protocol HSMessageStyleAttribute <HSAttribute>
- (NSInteger)messageStyle;
@end

@protocol HSMoveTextSourceObjectUIDAttribute <HSAttribute>
- (id)sourceObjectUID;
@end

@protocol HSMoveTextDestinationObjectUIDAttribute <HSAttribute>
- (id)destinationObjectUID;
@end

@protocol HSMoveTextSourceDataTypeAttribute <NSObject>
- (NSInteger)sourceDataType;
@end

@protocol HSMoveTextSourceActionAttribute <HSAttribute>
- (NSInteger)sourceAction;
@end

@protocol HSMoveTextDestinationActionAttribute <HSAttribute>
- (NSInteger)destinationAction;
@end

@protocol HSMoveTextActionAttributes <HSActionAttributes, HSMoveTextSourceObjectUIDAttribute, HSMoveTextDestinationObjectUIDAttribute, HSMoveTextSourceDataTypeAttribute, HSMoveTextSourceActionAttribute, HSMoveTextDestinationActionAttribute>
- (void)setDestinationAction:(NSInteger)aAction;
- (void)setDestinationObjectUID:(id)aUID;
- (void)setSourceAction:(NSInteger)aAction;
- (void)setSourceDataType:(NSInteger)aType;
- (void)setSourceObjectUID:(id)aUID;
@end

@protocol HSMoveToFrontSourceObjectUIDAttribute <HSAttribute>
- (id)sourceObjectUID;
@end

@protocol HSMoveToFrontActionAttributes <HSActionAttributes, HSMoveToFrontSourceObjectUIDAttribute>
- (void)setSourceObjectUID:(id)aUID;
@end

@protocol HSRelativeMovieSourceRectAttribute <HSVisualAttribute>
- (NSRect)relativeMovieSourceRect;
@end

@protocol HSMovieRectAttribute <HSVisualAttribute>
- (NSRect)movieRect;
@end

@protocol HSMovieFrameContentAttribute <HSVisualAttribute>
@end

@protocol HSRecordAttributes <HyperInterface>
- (id)defaultRecordName;
- (id)recordName;
@end

@protocol HSMovieAttributes <HSAttributes, HSRelativeMovieSourceRectAttribute, HSMovieRectAttribute, HSMovieFrameContentAttribute, HSRecordAttributes>
- (id)movieRenderer;
- (void)setRelativeMovieSourceRect:(NSRect)aRect;
@end

@protocol HSMovieCommandAttribute <HSAttribute>
- (NSInteger)movieCommand;
@end

@protocol HSMovieControllerActionAttributes <HSActionAttributes, HSMovieCommandAttribute>
- (void)setMovieCommand:(NSInteger)aCommand;
@end

@protocol HSMovieControllerVisualStateAttribute <HSVisualAttribute>
@end

@protocol HSMovieControllerRectAttribute <HSVisualAttribute>
- (NSRect)movieControllerRect;
@end

@protocol HSMovieControllerAttributes <HSAttributes, HSMovieControllerVisualStateAttribute, HSMovieControllerRectAttribute>
@end

@protocol HSMovieControllerCellDelegate <NSObject>
- (double)currentTimeForMovieController:(id)aController;
- (double)durationForMovieController:(id)aController;
- (void)gotoBeginningForMovieController:(id)aController;
- (void)gotoEndForMovieController:(id)aController;
- (BOOL)isPlayingForMovieController:(id)aController;
- (BOOL)isQTVRMovieForMovieController:(id)aController;
- (void)movieController:(id)aController setCurrentTime:(double)aTime;
- (void)playForMovieController:(id)aController;
- (struct HSTimeRange)playRangeForMovieController:(id)aController;
- (void)setNeedsDisplayForController:(id)aController;
- (void)slideWasPlaying:(BOOL)aPlaying isFinal:(BOOL)aFinal forMovieController:(id)aController;
- (void)stepBackwardForMovieController:(id)aController;
- (void)stepForwardForMovieController:(id)aController;
- (void)stopForMovieController:(id)aController;
@end

@protocol HSMovieDelegate <NSObject>
- (void)movieDidChangeImage:(id)aImage;
- (void)movieDidEnd:(id)aEnd;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidStop:(id)aStop;
@end

@protocol HSMovieObjectAttribute <HSAttribute>
- (id)movieObjectForCard:(id)aCard;
@end

@protocol HSMovieObjectBaseIsEmptyAttribute <HSVisualAttribute>
- (BOOL)isHyperEmpty;
@end

@protocol HSMovieObjectBaseVolumeAttribute <HSAttribute>
- (CGFloat)hyperVolume;
@end

@protocol HSMovieObjectBaseMovieAttribute <HSVisualAttribute>
- (id)hyperMovie;
@end

@protocol HSPlayableObjectHyperStartingOnClickAttribute <HSAttribute>
- (BOOL)isHyperStartingOnClick;
@end

@protocol HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute <HSAttribute>
- (BOOL)isHyperAllowPlayingOtherMovies;
@end

@protocol HSPlayableObjectHyperAllowPlayingOtherSoundsAttribute <HSAttribute>
- (BOOL)isHyperAllowPlayingOtherSounds;
@end

@protocol HSStartingPlayableObjectAttributes <HSAttributes, HSPlayableObjectHyperStartingOnClickAttribute, HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute, HSPlayableObjectHyperAllowPlayingOtherSoundsAttribute>
- (void)setHyperAllowPlayingOtherMovies:(BOOL)aMovies;
- (void)setHyperAllowPlayingOtherSounds:(BOOL)aSounds;
- (void)setHyperStartingOnClick:(BOOL)aClick;
@end

@protocol HSMovieObjectBaseAttributes <HSMediaAttributes, HSMovieObjectBaseIsEmptyAttribute, HSMovieObjectBaseVolumeAttribute, HSMovieObjectBaseMovieAttribute, HSExtendedPlayableObjectAttributes, HSStartingPlayableObjectAttributes>
- (void)setHyperMovie:(id)aMovie name:(id)aName;
- (void)setHyperMovieWithPath:(id)aPath;
- (void)setHyperMovieWithPath:(id)aPath error:(id *)aError;
- (void)setHyperVolume:(CGFloat)aVolume;
@end

@protocol HSMovieObjectHasControllerAttribute <HSVisualAttribute>
- (BOOL)hyperHasController;
@end

@protocol HSMovieObjectCanUseControllerAttribute <HSAttribute>
- (BOOL)hyperCanUseController;
@end

@protocol HSMovieObjectQTVRMovieAttributes <HSAttribute>
- (CGFloat)hyperFieldOfView;
- (CGFloat)hyperPanAngle;
- (CGFloat)hyperTiltAngle;
- (BOOL)isHyperPanoramaObject;
- (BOOL)isHyperQTVR;
- (void)setHyperFieldOfView:(CGFloat)aView;
- (void)setHyperPanAngle:(CGFloat)aAngle;
- (void)setHyperTiltAngle:(CGFloat)aAngle;
@end

@protocol HSMovieObjectAttributes <HSFramesPerSecondAttributes, HSMovieObjectBaseAttributes, HSMovieObjectHasControllerAttribute, HSMovieObjectEraseWhenDoneAttribute, HSMovieObjectCanUseControllerAttribute, HSMovieObjectQTVRMovieAttributes>
- (void)hyperAdjustRateWhilePlaying:(CGFloat)aPlaying;
- (void)hyperFlipHorizontal;
- (void)hyperFlipVertical;
- (NSInteger)hyperFrameCount;
- (double)hyperPosterTime;
- (void)resetHyperFrameCount;
- (void)setHyperEraseWhenDone:(BOOL)aDone;
- (void)setHyperHasController:(BOOL)aController;
@end

@protocol HSMovieObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSPlayMovieObjectMediaUIDAttribute <HSAttribute>
- (id)movieMediaUID;
@end

@protocol HSPlayMovieObjectUIDAttribute <HSAttribute>
- (id)movieObjectUID;
@end

@protocol HSMovieVolumeAttribute <HSAttribute>
- (CGFloat)volume;
@end

@protocol HSPlayMovieShowFirstFrameAttribute <HSAttribute>
- (BOOL)showFirstFrame;
@end

@protocol HSPlayMoviePlayOverObjectsAttribute <HSAttribute>
- (BOOL)playOverObjects;
@end

@protocol HSPlayMovieActionPlayCountAttribute <HSAttribute>
- (NSUInteger)playCount;
@end

@protocol HSPlayMovieUseMovieControllerAttribute <HSAttribute>
- (BOOL)useMovieController;
@end

@protocol HSPlayMovieEraseWhenDoneAttribute <HSAttribute>
- (BOOL)eraseWhenDone;
@end

@protocol HSPlayMoviePlayRangeAttribute <HSAttribute>
- (struct HSTimeRange)playRange;
@end

@protocol HSPlayMovieSoundFadeOutTimeAttribute <HSAttribute>
- (double)soundFadeOutTime;
@end

@protocol HSMoviePlaybackAttributes <HSPlaybackItemAttributes, HSPlayMovieObjectMediaUIDAttribute, HSPlayMovieObjectUIDAttribute, HSMovieVolumeAttribute, HSPlayMovieShowFirstFrameAttribute, HSPlayMoviePlayOverObjectsAttribute, HSPlayMovieActionPlayCountAttribute, HSPlayMovieUseMovieControllerAttribute, HSPlayMovieEraseWhenDoneAttribute, HSPlayMoviePlayRangeAttribute, HSPlayMovieSoundFadeOutTimeAttribute, HSMovieObjectAttribute>
- (void)playInActionExecutionContext:(id)aContext;
- (void)setEraseWhenDone:(BOOL)aDone;
- (void)setPlayCount:(NSUInteger)aCount;
- (void)setPlayOverObjects:(BOOL)aObjects;
- (void)setPlayRange:(struct HSTimeRange)aRange;
- (void)setShowFirstFrame:(BOOL)aFrame;
- (void)setSoundFadeOutTime:(double)aTime;
- (void)setUseMovieController:(BOOL)aController;
- (void)setVolume:(CGFloat)aVolume;
- (void)showFirstFrameIfNeededInContext:(id)aContext;
- (void)stopPlaying;
@end

@protocol HSMovieRenderer <NSObject>
- (struct CGImage *)currentFrameImage;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
@end

@protocol HSMovieWithControllerDelegate <NSObject>
- (double)currentTimeForMovieWithController:(id)aController;
- (double)durationForMovieWithController:(id)aController;
- (BOOL)hasControllerForMovieWithController:(id)aController;
- (BOOL)isEmptyForMovieWithController:(id)aController;
- (BOOL)isPlayingForMovieWithController:(id)aController;
- (BOOL)isQTVRMovieForMovieWithController:(id)aController;
- (void)movieWithController:(id)aController setCurrentTime:(double)aTime;
- (void)playForMovieWithController:(id)aController;
- (struct HSTimeRange)playRangeForMovieWithController:(id)aController;
- (void)setNeedsDisplayWithController:(id)aController;
- (void)stepBackwardWithController:(id)aController;
- (void)stepForwardWithController:(id)aController;
- (void)stopForMovieWithController:(id)aController;
- (void)temporaryStopForMovieWithController:(id)aController;
@end

@protocol HSMultipleObjectsAttributeSetObservingSession <NSObject>
- (void)addObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeAllObservers;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector;
@end

@protocol HSMutableCardAttributes <HSCardAttributes>
- (void)makeGroupCardWithGroupUID:(id)aUID;
- (void)makeNewGroupCard;
- (void)makeNonGroupCard;
- (void)setCardIdOldFileFormat:(NSInteger)aFormat;
- (void)setCardIdOldFileFormatAsString:(id)aString;
- (void)setHyperTitle:(id)aTitle;
- (void)setMarkedCard:(BOOL)aCard;
@end

@protocol HSMutableCardObjectAttributes <HSCardObjectAttributes>
- (void)makeGroupObject;
- (void)makeNonGroupObject;
- (void)setDraggable:(BOOL)aDraggable;
- (void)setDropOffOnly:(BOOL)aOnly;
- (void)setHidden:(BOOL)aHidden;
- (void)setHiddenInPlayer:(BOOL)aPlayer;
- (void)setIsVisibleInEditor:(BOOL)aEditor;
- (void)setLocked:(BOOL)aLocked;
- (void)setNoClick:(BOOL)aClick;
- (void)setResizable:(BOOL)aResizable;
- (void)setRotatable:(BOOL)aRotatable;
@end

@protocol HSMutableClipPathsAttributes <HSAttributes, HSClipPathsAttribute>
- (void)addObjectClipPath:(id)aPath;
- (void)addObjectClipPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (void)addObjectCropPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (void)addRelativeClipPath:(id)aPath;
- (void)addRelativeClipPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (void)addRelativeCropPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)relativeToObjectAffineTransform;
- (void)removeAllClipPaths;
- (void)removeNonInitialClipPaths;
- (void)setAllClipPathsAsInitial;
@end

@protocol HSMutableColor <HSColor, HSMutableGraphics>
- (void)hyperSwapGradientColors;
- (void)setHyperAngle:(CGFloat)aAngle;
- (void)setHyperCacheEnabled:(BOOL)aEnabled;
- (void)setHyperCenterX:(CGFloat)aX;
- (void)setHyperCenterX:(CGFloat)aX andY:(CGFloat)aY;
- (void)setHyperClear:(BOOL)aClear;
- (void)setHyperEndColor:(id)aColor;
- (void)setHyperKind:(NSInteger)aKind;
- (void)setHyperSolidColor:(id)aColor;
- (void)setHyperStartColor:(id)aColor;
@end

@protocol HSMutableSizeAttributes <HSSizeAttributes>
- (void)setSize:(NSSize)aSize;
@end

@protocol HSMutableGeometryAttributes <HSGeometryAttributes, HSMutableSizeAttributes>
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally;
- (void)setCornerPositions:(NSPoint *)aPositions;
- (void)setPosition:(NSPoint)aPosition forCornerAtIndex:(NSUInteger)aIndex;
- (void)setSize:(NSSize)aSize aboutRelativePoint:(NSPoint)aPoint;
- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform;
- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally;
@end

@protocol HSMutableResizingBehaviorAttributes <HSResizingBehaviorAttributes>
- (void)setPrefersToMaintainSizeAspectRatio:(BOOL)aRatio;
@end

@protocol HSMutableGeometryBehaviorAttributes <HSGeometryBehaviorAttributes, HSMutableResizingBehaviorAttributes>
- (void)setPrefersToMaintainSizeScaleAspectRatio:(BOOL)aRatio;
@end

@protocol HSScriptObject <HyperInterface>
- (id)hyperScriptDisplayName;
- (id)hyperScriptKind;
- (id)hyperScriptName;
@end

@protocol HSObjectNameAttribute <HSAttribute>
- (id)hyperName;
@end

@protocol HSObjectKindDisplayNameAttribute <HSAttribute>
- (id)hyperKindDisplayName;
- (id)nonLocalizedKindName;
@end

@protocol HSObjectScriptDisplayNameAttribute <HSAttribute>
- (id)hyperScriptDisplayName;
@end

@protocol HSObjectScriptKindAttribute <HSAttribute>
- (id)hyperScriptKind;
@end

@protocol HSObjectScriptNameAttribute <HSAttribute>
- (id)hyperScriptName;
@end

@protocol HSObjectUIDAttribute <HSAttribute>
- (id)hyperUID;
@end

@protocol HSObjectKindNameAttribute <HSAttribute>
- (id)nonLocalizedObjectKindKey;
@end

@protocol HSObjectAttributes <HSAttributes, HSScriptObject, HSObjectNameAttribute, HSObjectKindDisplayNameAttribute, HSObjectScriptDisplayNameAttribute, HSObjectScriptKindAttribute, HSObjectScriptNameAttribute, HSObjectUIDAttribute, HSObjectKindNameAttribute>
@end

@protocol HSMutableObjectAttributes <HSObjectAttributes>
- (void)setHyperName:(id)aName;
@end

@protocol HSShadowAttribute <HSVisualAttribute>
@end

@protocol HSShadowOffsetAttribute <HSShadowAttribute>
- (CGFloat)hyperHorizontalShadowOffset;
- (CGFloat)hyperShadowAngle;
- (CGFloat)hyperShadowDistance;
- (CGFloat)hyperVerticalShadowOffset;
@end

@protocol HSShadowEnabledAttribute <HSShadowAttribute>
- (BOOL)isHyperShadowEnabled;
@end

@protocol HSShadowBlurRadiusAttribute <HSShadowAttribute>
- (CGFloat)hyperShadowBlurRadius;
@end

@protocol HSShadowOpacityAttribute <HSShadowAttribute>
- (CGFloat)hyperShadowOpacity;
@end

@protocol HSShadowAttributes <HSAttributes, HSShadowOffsetAttribute, HSShadowEnabledAttribute, HSShadowBlurRadiusAttribute, HSShadowOpacityAttribute>
- (BOOL)hasMultipleShadowStyles;
- (id)hyperShadow;
- (NSSize)hyperShadowOffset;
@end

@protocol HSMutableShadowAttributes <HSShadowAttributes>
- (void)setHyperHorizontalShadowOffset:(CGFloat)aOffset;
- (void)setHyperShadowAngle:(CGFloat)aAngle;
- (void)setHyperShadowBlurRadius:(CGFloat)aRadius;
- (void)setHyperShadowDistance:(CGFloat)aDistance;
- (void)setHyperShadowEnabled:(BOOL)aEnabled;
- (void)setHyperShadowOffset:(NSSize)aOffset;
- (void)setHyperShadowOpacity:(CGFloat)aOpacity;
- (void)setHyperVerticalShadowOffset:(CGFloat)aOffset;
@end

@protocol HSShowHideTransitionAttribute <HSAttribute>
- (id)transition;
@end

@protocol HSShowHideTransitionFrameAttribute <HSVisualAttribute>
- (double)transitionTime;
@end

@protocol HSShowHideTransitionAttributes <HSAttributes, HSShowHideTransitionAttribute, HSShowHideTransitionFrameAttribute>
@end

@protocol HSMutableShowHideTransitionAttributes <HSShowHideTransitionAttributes>
- (void)setTransition:(id)aTransition;
@end

@protocol HSMutableSnapOptionsAttributes <HSAttribute>
- (id)dropOffRewardSoundMedia;
- (NSUInteger)dropOffSnappingRange;
- (BOOL)isDropOffSnappingEnabled;
- (BOOL)isDropOffTarget;
- (BOOL)playDropOffRewardSound;
- (void)setDropOffRewardSoundMedia:(id)aMedia;
- (void)setDropOffSnappingRange:(NSUInteger)aRange;
- (void)setIsDropOffSnappingEnabled:(BOOL)aEnabled;
- (void)setIsDropOffTarget:(BOOL)aTarget;
- (void)setPlayDropOffRewardSound:(BOOL)aSound;
- (void)setSnappingOptions:(id)aOptions;
- (id)snappingOptions;
@end

@protocol HSMutableSnappingTargetUIDIdentification <HSAttribute>
- (id)dropOffTargetUID;
- (void)setDropOffTargetUID:(id)aUID;
@end

@protocol HSStackCardSizeAttribute <HSAttribute>
- (NSSize)hyperCardSize;
@end

@protocol HSStackPasswordAttribute <HSAttribute>
@end

@protocol HSStackCardObjectsVisibilityAttribute <HSVisualAttribute>
- (NSInteger)cardObjectsVisibility;
@end

@protocol HSTemporaryObjectsManager <NSObject>
- (void)registerTemporaryObject:(id)aObject;
- (void)removeAllTemporaryObjects;
- (void)removeAllTemporaryObjectsForCard:(id)aCard;
- (void)unregisterTemporaryObject:(id)aObject;
@end

@protocol HSStackPresentationModeAttributes <HSAttribute>
- (BOOL)isPresentationCoveringDesktopMode;
- (BOOL)isPresentationMenuVisible;
- (BOOL)isPresentationPlaysWithoutTitleBar;
- (BOOL)shouldPlayInFullScreen;
@end

@protocol HSStackGridSettingsAttribute <HSAttribute>
- (id)gridSettings;
@end

@protocol HSStackSmartGuidelinesSettingsAttribute <HSAttribute>
- (id)guidelinesSettings;
@end

@protocol HSStackAttributes <HSAttributes, HSStackCardSizeAttribute, HSStackPasswordAttribute, HSStackCardObjectsVisibilityAttribute, HSTemporaryObjectsManager, HSStackPresentationModeAttributes, HSStackGridSettingsAttribute, HSStackSmartGuidelinesSettingsAttribute>
- (id)document;
@end

@protocol HSMutableStackAttributes <HSStackAttributes>
- (void)addCurrentTime:(double)aTime forMovieObject:(id)aObject;
- (void)addHiddenInPlayerObject:(id)aObject;
- (BOOL)arePresentationNotificationsSuspended;
- (id)currentWindow;
- (void)dropMovieObjectsCurrentTime;
- (void)flushPresentationNotifications;
- (BOOL)isPasswordCorrect:(id)aCorrect;
- (BOOL)isStackProtected;
- (id)recentPassword;
- (void)restoreMovieObjectsCurrentTime;
- (void)restoreObjectsVisibility;
- (void)setCardObjectsVisibility:(NSInteger)aVisibility;
- (void)setHyperCardSize:(NSSize)aSize;
- (void)setHyperPassword:(id)aPassword;
- (void)setPresentationBasicWindowMode:(BOOL)aMode;
- (void)setPresentationCoveringDesktopMode:(BOOL)aMode;
- (void)setPresentationMenuVisible:(BOOL)aVisible;
- (void)setPresentationPlaysWithoutTitleBar:(BOOL)aBar;
- (void)setShouldPlayInFullScreen:(BOOL)aScreen;
- (void)suspendPresentationNotifications;
@end

@protocol HSMutableURLAttributes <HSURLAttribute>
- (void)setURL:(id)aURL;
@end

@protocol HSVectorGraphicsBezierPathAttribute <HSVisualAttribute>
- (id)hyperBezierPath;
@end

@protocol HSVectorGraphicsElementCountAttribute <HSVectorGraphicsBezierPathAttribute>
- (NSUInteger)hyperElementCount;
@end

@protocol HSVectorGraphicsElementsAttribute <HSVectorGraphicsBezierPathAttribute>
- (NSUInteger)hyperElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints;
@end

@protocol HSVectorGraphicsPathStyleAttribute <HSVisualAttribute>
@end

@protocol HSVectorGraphicsLineWidthAttribute <HSVectorGraphicsPathStyleAttribute>
- (CGFloat)hyperLineWidth;
@end

@protocol HSVectorGraphicsLineCapStyleAttribute <HSVectorGraphicsPathStyleAttribute>
- (NSUInteger)hyperLineCapStyle;
@end

@protocol HSVectorGraphicsLineJoinStyleAttribute <HSVectorGraphicsPathStyleAttribute>
- (NSUInteger)hyperLineJoinStyle;
@end

@protocol HSVectorGraphicsWindingRuleAttribute <HSVectorGraphicsPathStyleAttribute>
- (NSUInteger)hyperWindingRule;
@end

@protocol HSVectorGraphicsMiterLimitAttribute <HSVectorGraphicsPathStyleAttribute>
- (CGFloat)hyperMiterLimit;
@end

@protocol HSVectorGraphicsFlatnessAttribute <HSVectorGraphicsPathStyleAttribute>
- (CGFloat)hyperFlatness;
@end

@protocol HSVectorGraphicsLineDashInfoAttribute <HSVectorGraphicsPathStyleAttribute>
- (id)hyperLineDashInfo;
@end

@protocol HSVectorGraphicsStrokeColorAttribute <HSVisualAttribute>
- (id)hyperStrokeColor;
@end

@protocol HSVectorGraphicsDynamicStrokeWidthAdjustingAttribute <HSAttribute>
- (NSUInteger)hyperDynamicStrokeWidthAdjustmentFactor;
@end

@protocol HSVectorGraphicsAttributes <HSAttributes, HSVectorGraphicsElementCountAttribute, HSVectorGraphicsBezierPathAttribute, HSVectorGraphicsElementsAttribute, HSVectorGraphicsLineWidthAttribute, HSVectorGraphicsLineCapStyleAttribute, HSVectorGraphicsLineJoinStyleAttribute, HSVectorGraphicsWindingRuleAttribute, HSVectorGraphicsMiterLimitAttribute, HSVectorGraphicsFlatnessAttribute, HSVectorGraphicsLineDashInfoAttribute, HSVectorGraphicsStrokeColorAttribute, HSVectorGraphicsDynamicStrokeWidthAdjustingAttribute>
- (BOOL)isHyperEmpty;
- (BOOL)isHyperShape;
@end

@protocol HSMutableVectorGraphicsAttributes <HSVectorGraphicsAttributes>
- (void)appendHyperBezierPath:(id)aPath;
- (void)appendHyperElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints;
- (void)appendHyperVectorGraphicsObject:(id)aObject;
- (void)deleteHyperElementAtIndex:(NSUInteger)aIndex glueWithEditingMode:(NSInteger)aMode;
- (void)insertHyperElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints atIndex:(NSUInteger)aIndex;
- (void)insertHyperPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex editingMode:(NSInteger)aMode;
- (void)setExtraLineDashInfo:(id)aInfo;
- (void)setHyperBezierPath:(id)aPath;
- (void)setHyperBezierPath:(id)aPath dynamicStrokeWidthAdjustmentFactor:(NSUInteger)aFactor;
- (void)setHyperBezierPath:(id)aPath dynamicStrokeWidthAdjustmentFactor:(NSUInteger)aFactor resetTransform:(BOOL)aTransform;
- (void)setHyperElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints;
- (void)setHyperFlatness:(CGFloat)aFlatness;
- (void)setHyperLineCapStyle:(NSUInteger)aStyle;
- (void)setHyperLineJoinStyle:(NSUInteger)aStyle;
- (void)setHyperLineSmoothStyle:(NSInteger)aStyle;
- (void)setHyperLineWidth:(CGFloat)aWidth;
- (void)setHyperMiterLimit:(CGFloat)aLimit;
- (void)setHyperPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex editingMode:(NSInteger)aMode;
- (void)setHyperStrokeColor:(id)aColor;
- (void)setHyperWindingRule:(NSUInteger)aRule;
@end

@protocol HSVectorGraphicsObjectLineEndingsAttribute <HSVisualAttribute>
@end

@protocol HSVectorGraphicsLineEndingScaleAttribute <HSVectorGraphicsObjectLineEndingsAttribute>
- (NSInteger)hyperScale;
@end

@protocol HSVectorGraphicsLineEndingsInfoObjectAttribute <HSVectorGraphicsObjectLineEndingsAttribute>
- (id)hyperInfoObject;
@end

@protocol HSVectorGraphicsLineEndingAttributes <HSAttributes, HSVectorGraphicsLineEndingScaleAttribute, HSVectorGraphicsLineEndingsInfoObjectAttribute>
@end

@protocol HSMutableVectorGraphicsLineEndingAttributes <HSVectorGraphicsLineEndingAttributes>
- (void)setHyperInfoObject:(id)aObject;
- (void)setHyperScale:(NSInteger)aScale;
@end

@protocol HSNextCardActionAttributes <HSChangeCardActionAttributes>
@end

@protocol HSNodeAttributes <HSAttributes>
- (BOOL)canDecrementHyperIndex;
- (BOOL)canIncrementHyperIndex;
- (id)cardGroupUID;
- (void)decrementHyperIndex;
- (NSUInteger)hyperIndex;
- (void)incrementHyperIndex;
- (void)moveToHyperBegin;
- (void)moveToHyperEnd;
- (void)removeFromHyperParent;
- (void)setHyperIndex:(NSUInteger)aIndex;
@end

@protocol HSNodeParentAttribute <HSAttribute>
- (id)hyperParent;
@end

@protocol HSNodeSupportAttribute <HSAttribute>
- (id)support;
@end

@protocol HSNodeSupportAttributes <HSAttributes, HSNodeSupportAttribute>
@end

@protocol HSObjectWeightBehaviors <NSObject>
- (NSInteger)compareWeight:(id)aWeight;
- (void)setWeight:(id)aWeight;
- (id)weight;
@end

@protocol HSNodeChild <HSAttributes, HSNodeParentAttribute, HSNodeSupportAttributes, HSObjectWeightBehaviors>
- (id)basename;
- (void)didAddToParent;
- (BOOL)dontErase;
- (NSUInteger)hyperIndex;
- (id)hyperOrderWeight;
- (BOOL)isLeaf;
- (BOOL)isRoot;
- (BOOL)isTemporary;
- (void)setDontErase:(BOOL)aErase;
- (void)setHyperOrderWeight:(id)aWeight;
- (void)setHyperParent:(id)aParent;
- (void)setSupport:(id)aSupport;
- (void)setTemporary:(BOOL)aTemporary;
- (void)willRemoveFromParent;
@end

@protocol HSNodeContainerChildrenAttribute <HSAttribute>
- (id)hyperChildAtIndex:(NSUInteger)aIndex;
- (id)hyperChildren;
- (id)hyperChildrenAtIndexes:(id)aIndexes;
- (NSUInteger)hyperCount;
- (id)hyperDeepEnumerator;
- (id)hyperDeepLoadedNodeEnumerator;
- (id)hyperEnumerator;
- (id)hyperLoadedNodeEnumerator;
- (id)hyperReverseDeepEnumerator;
- (id)hyperReverseEnumerator;
- (NSUInteger)indexOfHyperChild:(id)aChild;
@end

@protocol HSNodeContainer <HSAttributes, HSNodeContainerChildrenAttribute>
- (void)addHyperChild:(id)aChild;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (void)hyperAddChildrenBeginGrouping;
- (void)hyperAddChildrenEndGrouping;
- (void)hyperRemoveChildrenBeginGrouping;
- (void)hyperRemoveChildrenEndGrouping;
- (void)insertChild:(id)aChild atIndex:(NSUInteger)aIndex;
- (void)insertHyperChild:(id)aChild atIndex:(NSUInteger)aIndex;
- (void)moveHyperChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2;
- (void)moveTemporarilyHyperChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2;
- (void)removeChild:(id)aChild;
- (void)removeChildrenAttributeObserver:(id)aObserver;
- (void)removeChildrenAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeHyperAllChildren;
- (void)removeHyperChild:(id)aChild;
- (void)removeHyperChildren:(id)aChildren;
- (void)removeObserver:(id)aObserver ofAttributesOfChildrenInDepthRange:(NSRange)aRange;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofAttributesOfChildrenInDepthRange:(NSRange)aRange;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofChildrenInDepthRange:(NSRange)aRange;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofChildrenInDepthRange:(NSRange)aRange;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofChildrenInDepthRange:(NSRange)aRange;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofChildrenInDepthRange:(NSRange)aRange;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttribute:(id)aAttribute;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesFromSet:(id)aSet;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterfaces:(id *)aInterfaces;
- (void)setChildren:(id)aChildren;
- (void)setIndex:(NSUInteger)aIndex ofHyperChild:(id)aChild;
- (id)uniqueBasenameForChild:(id)aChild;
@end

@protocol HSNodeDataOwner <NSObject>
- (id)anyOwningObjectForNodeData:(id)aData;
- (id)objectsWithNodeDataUID:(id)aUID;
@end

@protocol HSNodeDataProvider <NSObject>
- (id)nodeDataWithUID:(id)aUID;
- (id)nodeUnitWithUID:(id)aUID;
@end

@protocol HSNodePrimarySetup <NSObject>
- (void)performPrimarySetupOnCard:(id)aCard;
@end

@protocol HSNodeSupport <NSObject>
- (id)cardGroupController;
- (id)delegate;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)scriptController;
- (id)undoManager;
@end

@protocol HSNodeUnit <NSObject, NSCopying, EXKeyValueCoding>
- (id)UID;
- (id)attributes;
- (void)didAddToDocument;
- (id)hostNodes;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)mediaUIDs;
- (void)nodeDidAddToDocument:(id)aDocument;
- (void)nodeWillRemoveFromDocument:(id)aDocument;
- (void)registerEjectionFromNode:(void *)aNode;
- (void)registerInjectionIntoNode:(id)aNode;
- (BOOL)supportsSharingBetweenGroupObjects;
- (void)willRemoveFromDocument;
@end

@protocol HSNodeUnitBasedHyperImplementationCreating <NSObject>
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
@end

@protocol HSNodeVisualizationDisabling <HyperInterface>
- (void)beginViewBasedInteractionForNodeChild:(id)aChild;
- (void)disableVisualizationForNode:(id)aNode;
- (void)endViewBasedInteractionForNodeChild:(id)aChild;
- (void)reenableVisualizationForNode:(id)aNode;
@end

@protocol HSObjectListPaletteVisualization <HSEditorVisualization>
@end

@protocol HSObjectNaming <HyperInterface>
- (id)objectName;
- (void)setObjectName:(id)aName;
@end

@protocol HSObjectProxy <NSObject>
- (id)object;
- (void)setObject:(id)aObject;
@end

@protocol HSObjectStyleCopying <NSObject>
- (BOOL)canLoadStyleFromDictionary:(id)aDictionary;
- (void)loadObjectStyleDictionaryRepresentation:(id)aRepresentation;
- (id)objectStyleDictionaryRepresentation;
@end

@protocol HSVectorGraphicObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSTextObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSTextViewObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSWebObjectHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSVectorBrushHitTesting <HSUserObjectEditorHitTesting>
@end

@protocol HSObjectTypeHitTestings <HSVectorGraphicObjectHitTesting, HSTextObjectHitTesting, HSButtonObjectHitTesting, HSEffectObjectHitTesting, HSMovieObjectHitTesting, HSImageObjectHitTesting, HSTextViewObjectHitTesting, HSCameraObjectHitTesting, HSWebObjectHitTesting, HSImageWellObjectHitTesting, HSGroupBoxObjectHitTesting, HSVectorBrushHitTesting>
@end

@protocol HSObjectUIDsAttribute <HSAttribute>
- (id)objectUIDs;
@end

@protocol HSOpenGLGraphicCompositionRenderer <HSGraphicCompositionRenderer>
- (id)frameTextureAtTime:(double)aTime;
- (id)openGLContext;
- (id)openGLPixelFormat;
- (void)renderFrameAtTime:(double)aTime;
@end

@protocol HSTransitionRenderer <NSObject>
- (void)setEndImage:(id)aImage;
- (void)setStartImage:(id)aImage;
@end

@protocol HSOpenGLTransitionRenderer <HSTransitionRenderer>
- (id)frameTextureAtTime:(double)aTime;
- (id)openGLContext;
- (id)openGLPixelFormat;
- (void)renderFrameAtTime:(double)aTime;
@end

@protocol HSOpenLocationApplicationNameAttribute <HSAttribute>
- (id)applicationName;
@end

@protocol HSOpenLocationOpensDocumentAttribute <HSAttribute>
- (BOOL)opensDocument;
@end

@protocol HSOpenLocationOpensApplicationAttribute <HSAttribute>
- (BOOL)opensApplication;
@end

@protocol HSOpenLocationActionAttributes <HSActionAttributes, HSURLAttribute, HSOpenLocationQuitAfterLaunchAttribute, HSOpenLocationApplicationNameAttribute, HSOpenLocationOpensDocumentAttribute, HSOpenLocationOpensApplicationAttribute, HSOpenLocationLaunchInForegroundAttribute>
- (void)setApplicationName:(id)aName;
- (void)setLaunchInForeground:(BOOL)aForeground;
- (void)setOpensApplication:(BOOL)aApplication;
- (void)setOpensDocument:(BOOL)aDocument;
- (void)setQuitAfterLaunch:(BOOL)aLaunch;
- (void)setURL:(id)aURL;
@end

@protocol HSOpenStackActionAttributes <HSChangeCardActionAttributes, HSURLAttribute>
- (void)setURL:(id)aURL;
- (void)updateURL;
- (void)validateURL;
@end

@protocol HSOpenWebPageInForegroundAttribute <HSAttribute>
- (BOOL)launchInForeground;
@end

@protocol HSOpenWebPageActionAttributes <HSActionAttributes, HSMutableURLAttributes, HSOpenWebPageInForegroundAttribute>
- (void)setLaunchInForeground:(BOOL)aForeground;
@end

@protocol HSOtherCardActionAttributes <HSChangeCardActionAttributes, HSDestinationCardUIDAttribute, HSURLAttribute>
- (NSInteger)cardIdOldFileFormat;
- (void)setCardIdOldFileFormat:(NSInteger)aFormat;
- (void)setDestinationCardUID:(id)aUID;
- (void)setURL:(id)aURL;
- (void)updateURL;
@end

@protocol HSPatternsSharedProvider <NSObject>
- (id)hyperPatternForName:(id)aName;
- (id)hyperPatternNames;
- (id)hyperPatternPathForName:(id)aName;
@end

@protocol HSPauseDurationAttribute <HSAttribute>
- (double)pauseDuration;
@end

@protocol HSPauseActionAttributes <HSActionAttributes, HSPauseDurationAttribute>
- (void)setPauseDuration:(double)aDuration;
@end

@protocol HSShowsFilenameOnPictureAttribute <HSAttribute>
- (BOOL)showsFilenameOnPicture;
@end

@protocol HSTimeDelayAttribute <HSAttribute>
- (double)timeDelay;
@end

@protocol HSPictureShowActionAttributes <HSActionAttributes, HSLoopPictureShowAttribute, HSLeavesLastPictureOnExitAttribute, HSShowsFilenameOnPictureAttribute, HSTimeDelayAttribute, HSURLAttribute>
- (void)setLeavesLastPictureOnExit:(BOOL)aExit;
- (void)setLoopPictureShow:(BOOL)aShow;
- (void)setShowsFilenameOnPicture:(BOOL)aPicture;
- (void)setTimeDelay:(double)aDelay;
- (void)setURL:(id)aURL;
@end

@protocol HSPlaceholderImage <NSObject>
@end

@protocol HSPlayAnimationActionAnimationAttribute <NSObject>
- (id)animation;
@end

@protocol HSPlayAnimationActionAttributes <HSActionAttributes, HSPlayAnimationActionAnimationAttribute>
- (void)setAnimation:(id)aAnimation;
@end

@protocol HSPlaybackItemSupport <NSObject>
- (id)cardForAction;
- (id)itemAttributeNotificationCenter;
- (void)moviePlaybackDidFinish:(id)aFinish;
- (id)nodeSupportForMovie;
- (id)objectForAction;
- (id)stackForAction;
@end

@protocol HSPlayMovieMoviesAttribute <HSAttribute>
- (id)movies;
@end

@protocol HSPlayMovieLiveVideosAttribute <HSAttribute>
- (id)liveVideos;
@end

@protocol HSSelectedPlayableObjectsUIDsAttribute <HSAttribute>
- (id)hyperSelectedUIDs;
@end

@protocol HSPlayableObjectsActionAttributes <HSActionAttributes, HSSelectedPlayableObjectsUIDsAttribute>
- (void)addPlayableObject:(id)aObject;
- (void)removePlayableObject:(id)aObject;
@end

@protocol HSPlayMovieActionAttributes <HSActionAttributes, HSPlaybackItemSupport, HSPlayMovieMoviesAttribute, HSPlayMovieLiveVideosAttribute, HSPlayableObjectsActionAttributes>
- (void)addLiveVideo:(id)aVideo;
- (void)addMovie:(id)aMovie;
- (id)enabledLiveObjects;
- (id)enabledMovies;
- (void)removeLiveVideo:(id)aVideo;
- (void)removeMovie:(id)aMovie;
- (void)setLiveVideos:(id)aVideos;
- (void)setMovies:(id)aMovies;
@end

@protocol HSPlaySoundStopsAllSoundsAttribute <HSAttribute>
- (BOOL)stopsAllSounds;
@end

@protocol HSPlaySoundSoundsAttribute <HSAttribute>
- (id)sounds;
@end

@protocol HSPlaySoundOldVersionAttribute <HSAttribute>
- (void)convertOldVersionAttributesIfNeeded;
@end

@protocol HSPlaySoundActionAttributes <HSActionAttributes, HSPlaySoundStopsAllSoundsAttribute, HSPlaySoundSoundsAttribute, HSPlaySoundOldVersionAttribute>
- (void)addSound:(id)aSound;
- (void)addSoundUIDToStop:(id)aStop withFadeOutTime:(double)aTime;
- (void)disableSoundItem:(id)aItem;
- (void)enableSoundItem:(id)aItem;
- (double)fadeOutTimeForStopAllSounds;
- (double)fadeOutTimeForStopSoundUID:(id)aUID;
- (BOOL)isContainsItem:(id)aItem;
- (void)removeSound:(id)aSound;
- (void)removeSoundUIDToStop:(id)aStop;
- (void)setFadeOutTimeForStopAllSounds:(double)aSounds;
- (void)setSoundFadeOutTime:(double)aTime forStopSoundUID:(id)aUID;
- (void)setSounds:(id)aSounds;
- (void)setSoundsToStop:(id)aStop;
- (void)setStopsAllSounds:(BOOL)aSounds;
- (id)soundsForState:(BOOL)aState;
- (id)soundsToStop;
- (id)soundsUIDsToStop;
@end

@protocol HSPlayerHitTestingVisualization <HSHitTestingVisualization>
@end

@protocol HSPlayerVisualization <HSVisualization>
@end

@protocol HSPlayingVideoStateAttribute <HSAttribute>
- (BOOL)isPlayingVideo;
@end

@protocol HSPositionAttribute <HSAttribute>
- (NSPoint)position;
@end

@protocol HSPositionAttributes <HSActionAttributes, HSPositionAttribute>
- (void)setPosition:(NSPoint)aPosition;
@end

@protocol HSPreferedUndoManagerOwner <NSObject>
- (id)preferedUndoManager;
@end

@protocol HSPresentationSyncDataSource <NSObject>
- (id)actionExecutionContextForPresentationSync:(id)aSync;
- (id)actionExecutionManagerForPresentationSync:(id)aSync;
- (id)currentCardForPresentationSync:(id)aSync;
- (id)currentStackForPresentationSync:(id)aSync;
@end

@protocol HSPresentationSyncDelegate <NSObject>
- (void)readyToPerformGoToCard:(id)aCard;
- (void)readyToPerformGoToStack:(id)aStack;
- (void)readyToPerformNavigationOperation:(id)aOperation;
@end

@protocol HSPreviousCardActionAttributes <HSChangeCardActionAttributes>
@end

@protocol HSPrintCardShowPageSetupAttribute <HSAttribute>
- (BOOL)showPageSetupDialog;
@end

@protocol HSPrintCardShowPrintDialogAttribute <HSAttribute>
- (BOOL)showPrintDialog;
@end

@protocol HSPrintCardCenterPrintoutAttribute <HSAttribute>
- (BOOL)centerPrintout;
@end

@protocol HSPrintCardActionAttributes <HSActionAttributes, HSPrintCardShowPageSetupAttribute, HSPrintCardShowPrintDialogAttribute, HSPrintCardCenterPrintoutAttribute>
- (void)setCenterPrintout:(BOOL)aPrintout;
- (void)setShowPageSetupDialog:(BOOL)aDialog;
- (void)setShowPrintDialog:(BOOL)aDialog;
@end

@protocol HSPromisedMediaDataRepresentationOwner <NSObject>
- (id)mediaDataForPromisedDataRepresentation:(id)aRepresentation;
- (id)mediaTypeForPromisedDataRepresentation:(id)aRepresentation;
@end

@protocol HSPurgableObject <BTPurgableObject>
- (NSUInteger)purgableSize;
@end

@protocol HSQuartzGraphicCompositionRenderer <HSGraphicCompositionRenderer>
- (struct CGImage *)frameImageAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext;
- (CGSize)rendererSize;
- (void)setRendererSize:(CGSize)aSize;
@end

@protocol HSQuartzTransitionRenderer <HSTransitionRenderer>
- (struct CGImage *)frameImageAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext;
- (CGSize)rendererSize;
- (void)setRendererSize:(CGSize)aSize;
@end

@protocol HSQuickTimeEffectAccessing <HyperInterface>
- (id)quickTimeEffect;
- (id)quickTimeEffectAdjustedToSize:(NSSize)aSize;
@end

@protocol HSQuitAnotherApplicationActionAttributes <HSActionAttributes, HSApplicationToQuitAttribute>
- (void)setApplicationToQuit:(id)aQuit;
@end

@protocol HSReadWriteTextActionTargetObjectAttribute <HSAttribute>
- (id)targetObjectUID;
@end

@protocol HSReadWriteTextActionFileURLAttribute <HSAttribute>
- (id)filePath;
- (id)fileURL;
- (BOOL)isFileURLRelativeToStack;
@end

@protocol HSReadWriteTextActionModeAttribute <HSAttribute>
- (NSInteger)mode;
@end

@protocol HSReadWriteTextActionOperationAttribute <HSAttribute>
- (NSInteger)operation;
@end

@protocol HSReadWriteTextActionAttributes <HSActionAttributes, HSReadWriteTextActionTargetObjectAttribute, HSReadWriteTextActionFileURLAttribute, HSReadWriteTextActionModeAttribute, HSReadWriteTextActionOperationAttribute>
- (id)absoluteFileURL;
- (void)setFileURL:(id)aURL relativeToStack:(BOOL)aStack;
- (void)setMode:(NSInteger)aMode;
- (void)setOperation:(NSInteger)aOperation;
- (void)setTargetObjectUID:(id)aUID;
@end

@protocol HSRenderCache <NSObject>
- (CGAffineTransform)affineTransform;
- (id)attachmentForKey:(id)aKey;
- (id)attachments;
- (NSUInteger)cashSize;
- (BOOL)containsRegion:(id)aRegion;
- (BOOL)containsWholeRenderLayer;
- (void)drawRegion:(id)aRegion;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (CGFloat)persistentValidness;
- (id)renderLayer;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (void)setAttachment:(id)aAttachment forKey:(id)aKey;
- (void)setPersistentValidness:(CGFloat)aValidness;
- (void)setTemporaryValidness:(CGFloat)aValidness;
- (CGFloat)validness;
- (CGFloat)validnessForAffineTransform:(CGAffineTransform)aTransform;
@end

@protocol HSRenderCacheController <NSObject>
- (void)addRenderCache:(id)aCache;
- (void)discardAllRenderCachesForRenderLayer:(id)aLayer;
- (void)discardRenderCache:(id)aCache;
- (void)releaseWithStorableValidnessLimit:(CGFloat)aLimit;
- (id)renderCacheForRegion:(id)aRegion ofRenderLayer:(id)aLayer withRenderLayerDelegate:(id)aDelegate acceptableValidnessLimit:(CGFloat)aLimit options:(NSInteger)aOptions;
- (id)renderCacheForRenderLayer:(id)aLayer;
- (id)retainWithStorableValidnessLimit:(CGFloat)aLimit;
@end

@protocol HSRenderCacheValidnessEvaluator <NSObject>
- (CGFloat)evaluateForAffineTransform:(CGAffineTransform)aTransform withContentValidness:(CGFloat)aValidness contentAffineTransform:(CGAffineTransform)aTransform2;
- (id)validnessEvaluatorByMergingWithValidnessEvaluator:(id)aEvaluator;
@end

@protocol HSRenderDelegate <NSObject>
- (void)renderer:(id)aRenderer didCacheDrawingInRegion:(id)aRegion forRenderLayerAtIndexPath:(id)aPath intoRenderCache:(id)aCache;
- (void)renderer:(id)aRenderer didCacheDrawingInRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(id)aCache;
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(BOOL)aCache;
- (void)renderer:(id)aRenderer didRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath;
- (BOOL)renderer:(id)aRenderer shouldDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(BOOL)aCache;
- (BOOL)renderer:(id)aRenderer shouldRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath;
- (id)renderer:(id)aRenderer willCacheDrawingInRegion:(id)aRegion forRenderLayerAtIndexPath:(id)aPath;
- (id)renderer:(id)aRenderer willCacheDrawingInRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath;
@end

@protocol HSRenderLayerDelegate <NSObject>
- (id)delegateForRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)renderLayer;
- (void)renderLayerDidCacheDrawingInRegion:(id)aRegion intoRenderCache:(id)aCache;
- (void)renderLayerDrawingIsCachedInRegion:(id)aRegion intoRenderCache:(id)aCache;
- (id)renderLayerDrawingWillBeCachedInRegion:(id)aRegion;
- (void)renderLayerIsDrawnInRegion:(id)aRegion intoRenderCache:(BOOL)aCache;
- (void)renderLayerIsRenderedInRegion:(id)aRegion;
- (BOOL)renderLayerShouldBeDrawnInRegion:(id)aRegion intoRenderCache:(BOOL)aCache;
- (BOOL)renderLayerShouldBeRenderedInRegion:(id)aRegion;
- (id)renderLayerWillCacheDrawingInRegion:(id)aRegion;
@end

@protocol HSRenderLayerObserver <NSObject>
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerWantsToReexpand:(id)aReexpand;
@end

@protocol HSRenderer <NSObject>
- (id)boundingRegion;
- (id)boundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (id)boundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)drawsOnlySubobjects;
- (id)ignoredSubobjects;
- (id)rootRenderLayer;
- (BOOL)unionBoundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (BOOL)unionBoundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (BOOL)unionBoundingRegionWithRegion:(id)aRegion;
- (id)visualization;
- (id)visualizationOptions;
@end

@protocol HSRendererUpdating <HSRenderer>
- (void)invalidateRenderLayerTree;
@end

@protocol HSResizingBehaviorSubattributes <HSAttributes>
- (BOOL)canBreakSizeAspectRatio;
- (BOOL)canResizeHorizontally;
- (BOOL)canResizeVertically;
@end

@protocol HSReturnsToOriginalCardAttribute <HSAttribute>
- (BOOL)returnsToOriginalCard;
@end

@protocol HSUseCustomAppleScriptSourceAttribute <HSAttribute>
- (BOOL)useCustomAppleScriptSource;
@end

@protocol HSRunAppleScriptActionAttributes <HSActionAttributes, HSUseCustomAppleScriptSourceAttribute, HSAppleScriptURLAttribute, HSAppleScriptSourceAttribute>
- (void)setAppleScriptSource:(id)aSource;
- (void)setAppleScriptURL:(id)aURL;
- (void)setUseCustomAppleScriptSource:(BOOL)aSource;
@end

@protocol HSRunAsModalDialogAttribute <HSAttribute>
- (BOOL)runAsModalDialog;
@end

@protocol HSRunCommandActionTypeAttribute <HSAttribute>
- (NSInteger)runCommandActionType;
@end

@protocol HSRunCommandActionAttributes <HSActionAttributes, HSRunCommandActionTypeAttribute>
- (void)setRunCommandActionType:(NSInteger)aType;
@end

@protocol HSScriptAttribute <HSAttribute>
- (id)hyperScript;
@end

@protocol HSRunScriptActionAttributes <HSActionAttributes, HSScriptAttribute>
- (void)setHyperScript:(id)aScript;
@end

@protocol HSRunTimeEditorUndoManagerDelegate <NSObject>
- (void)didRegisterUndoInUndoManager:(id)aManager;
- (void)willRegisterUndoInUndoManager:(id)aManager;
@end

@protocol HSSaveOperationQueue <NSObject>
- (void)removeFileAtPath:(id)aPath;
- (void)saveObjectOnSeparateThread:(NSUInteger)aThread;
@end

@protocol HSSaveOperationQueueObject <NSObject>
- (void)writeDataToFileInSeparateThread;
@end

@protocol HSScriptController <NSObject>
- (id)evaluateScript:(id)aScript;
- (id)evaluateScript:(id)aScript withSender:(id)aSender;
@end

@protocol HSScriptableEntity <HSObjectAttributes>
- (NSUInteger)countOfHyperScriptableEntities;
- (id)objectInHyperScriptableEntitiesAtIndex:(NSUInteger)aIndex;
- (id)parentHyperScriptableEntity;
@end

@protocol HSScrollCardActionAttribute <HSAttribute>
- (NSPoint)scrollPoint;
@end

@protocol HSScrollCardActionAttributes <HSActionAttributes, HSScrollCardActionAttribute, HSPositionAttributes>
- (void)setScrollPoint:(NSPoint)aPoint;
@end

@protocol HSSelectableObject <HyperInterface>
- (id)hyperKindDisplayName;
@end

@protocol HSSelectionKnobsProviderAttribute <HSAttribute>
@end

@protocol HSSendMailActionAttributes <HSActionAttributes, HSEmailAddressesAttribute, HSEmailSubjectAttribute, HSMutableURLAttributes>
- (id)hyperInvalidEmailAddressError;
- (void)setHyperEmailAddress:(id)aAddress;
- (void)setHyperEmailAddresses:(id)aAddresses;
- (void)setHyperEmailSubject:(id)aSubject;
@end

@protocol HSSequenceItemsAttribute <HSAttribute>
- (id)sequenceItems;
@end

@protocol HSSequencerActionAttributes <HSActionAttributes, HSSequenceItemsAttribute>
- (void)setSequenceItems:(id)aItems;
@end

@protocol HSSetCursorPositionActionAttributes <HSActionAttributes, HSCursorPositionAttribute, HSPositionAttributes>
- (void)setCursorPosition:(NSPoint)aPosition;
@end

@protocol HSVolumeLevelAttribute <HSAttribute>
- (CGFloat)volumeLevel;
@end

@protocol HSSetVolumeActionAttributes <HSActionAttributes, HSVolumeLevelAttribute>
- (void)setVolumeLevel:(CGFloat)aLevel;
@end

@protocol HSShadowAndOpacityRenderLayer_ShadowMaskConsumer <NSObject>
- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:(struct CGImage *)aMask transform:(CGAffineTransform)aTransform;
@end

@protocol HSSheetHandler <NSObject>
- (BOOL)isSheetRunning;
- (id)sheetWindow;
@end

@protocol HSShowHideCursorActionAttributes <HSActionAttributes, HSChangeCursorVisibilityActionAttribute>
- (void)setChangeCursorVisibilityAction:(NSInteger)aAction;
@end

@protocol HSShowHideObjectsAttribute <HSAttribute>
- (NSInteger)actionForObjectWithUID:(id)aUID;
- (id)hideEffectSettingsWithUID:(id)aUID;
- (id)objectsToHide;
- (id)objectsToShow;
- (id)objectsToToggle;
- (id)showEffectSettingsWithUID:(id)aUID;
@end

@protocol HSShowHideObjectActionAttributes <HSActionAttributes, HSShowHideObjectsAttribute>
- (void)addObjectUID:(id)aUID action:(NSInteger)aAction showEffectSettings:(id)aSettings hideEffectSettings:(id)aSettings2;
@end

@protocol HSShowInFinderActionAttribute <HSAttribute>
- (id)filePath;
@end

@protocol HSShowInFinderActionAttributes <HSActionAttributes, HSShowInFinderActionAttribute>
- (void)setFilePath:(id)aPath;
@end

@protocol HSShowMessageActionAttributes <HSActionAttributes, HSMessageStyleAttribute, HSMessageStringAttribute, HSMessageButtonTitleAttribute, HSRunAsModalDialogAttribute, HSMessageIconImageAttribute>
- (void)setButtonTitle:(id)aTitle;
- (void)setMessageIcon:(id)aIcon;
- (void)setMessageIconImageUID:(id)aUID;
- (void)setMessageString:(id)aString;
- (void)setMessageStyle:(NSInteger)aStyle;
- (void)setRunAsModalDialog:(BOOL)aDialog;
@end

@protocol HSSizeAdditionalAttributes <NSObject>
- (BOOL)isIntegralSize;
@end

@protocol HSSizeNodeStorage <NSObject>
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
@end

@protocol HSSlideDurationAttribute <HSAttribute>
- (double)slideDuration;
@end

@protocol HSSlideTransitionAttribute <HSAttribute>
- (id)slideTransition;
@end

@protocol HSUseClickOnExitCardAttribute <HSAttribute>
- (BOOL)useClickOnExitCard;
@end

@protocol HSSlideShowActionAttributes <HSActionAttributes, HSSlideTransitionAttribute, HSSlideDurationAttribute, HSReturnsToOriginalCardAttribute, HSLoopSlideShowAttribute, HSUseClickOnExitCardAttribute>
- (void)setLoopSlideShow:(BOOL)aShow;
- (void)setReturnsToOriginalCard:(BOOL)aCard;
- (void)setSlideDuration:(double)aDuration;
- (void)setSlideTransition:(id)aTransition;
- (void)setUseClickOnExitCard:(BOOL)aCard;
- (id)sourceCard;
@end

@protocol HSSoundItemEnableAttribute <HSAttribute>
- (BOOL)isEnabled;
@end

@protocol HSSoundItemOwnerAttribute <HSAttribute>
- (id)owner;
@end

@protocol HSSoundItemUIDAttribute <HSAttribute>
- (id)itemUID;
@end

@protocol HSSoundItemAttributes <HSAttributes, HSSoundItemEnableAttribute, HSSoundItemOwnerAttribute, HSSoundItemUIDAttribute, HSRecordAttributes>
- (void)setEnabled:(BOOL)aEnabled;
- (void)setOwner:(id)aOwner;
@end

@protocol HSSoundItemOwnerAttributes <HSAttributes>
- (id)attributeNotificationCenter;
- (id)undoManager;
@end

@protocol HSSoundPlaybackSoundAttribute <HSAttribute>
- (id)sound;
@end

@protocol HSSoundPlaybackMediaAttribute <HSAttribute>
- (id)media;
- (id)mediaUID;
@end

@protocol HSSoundPlaybackPlayCountAttribute <HSAttribute>
- (NSUInteger)playCount;
@end

@protocol HSSoundPlaybackFadeOutTimeAttribute <HSAttribute>
- (double)soundFadeOutTime;
@end

@protocol HSSoundPlaybackPlayRangeAttribute <HSAttribute>
- (struct HSTimeRange)soundPlayRange;
@end

@protocol HSSoundPlaybackDurationAttribute <HSAttribute>
- (double)soundDuration;
@end

@protocol HSSoundPlaybackSynchronousSoundAttribute <HSAttribute>
- (BOOL)isSynchronousSound;
@end

@protocol HSSoundPlaybackVolumeAttribute <HSAttribute>
- (CGFloat)volume;
@end

@protocol HSSoundPlaybackStopThisSoundAttribute <HSAttribute>
- (BOOL)stopThisSound;
@end

@protocol HSSoundPlaybackAttributes <HSAttributes, HSSoundPlaybackSoundAttribute, HSSoundPlaybackMediaAttribute, HSSoundPlaybackPlayCountAttribute, HSSoundPlaybackFadeOutTimeAttribute, HSSoundPlaybackPlayRangeAttribute, HSSoundPlaybackDurationAttribute, HSSoundPlaybackSynchronousSoundAttribute, HSSoundPlaybackVolumeAttribute, HSSoundPlaybackStopThisSoundAttribute>
- (void)setPlayCount:(NSUInteger)aCount;
- (void)setSoundFadeOutTime:(double)aTime;
- (void)setSoundPlayRange:(struct HSTimeRange)aRange;
- (void)setStopThisSound:(BOOL)aSound;
- (void)setSynchronousSound:(BOOL)aSound;
- (void)setVolume:(CGFloat)aVolume;
@end

@protocol HSSpeechRecognitionActionAttributes <HSActionAttributes, HSObjectUIDsAttribute>
- (void)setObjectUIDs:(id)aDs;
@end

@protocol HSStackSoundStorage <NSObject>
- (id)soundMediaForPath:(id)aPath;
- (BOOL)stackContainsSoundMediaWithName:(id)aName;
@end

@protocol HSStandaloneResizingBehaviorAttributes <HSResizingBehaviorAttributes>
@end

@protocol HSStandaloneMutableResizingBehaviorAttributes <HSStandaloneResizingBehaviorAttributes, HSMutableResizingBehaviorAttributes>
@end

@protocol HSStandaloneSizeAttributes <HSSizeAttributes>
@end

@protocol HSStandaloneMutableSizeAttributes <HSStandaloneSizeAttributes, HSMutableSizeAttributes>
@end

@protocol HSStarFieldDurationAttribute <HSAttribute>
- (double)starFieldDuration;
@end

@protocol HSStarFieldDurationModeAttribute <HSAttribute>
- (NSInteger)starFieldDurationMode;
@end

@protocol HSStarFieldActionAttributes <HSActionAttributes, HSStarFieldDurationAttribute, HSStarFieldDurationModeAttribute>
- (void)setStarFieldDuration:(double)aDuration;
- (void)setStarFieldDurationMode:(NSInteger)aMode;
@end

@protocol HSStoredMenuItemTitleValidationSupport <NSObject>
- (BOOL)supportMenuItemStoredTitleValidation;
@end

@protocol HSStringValueAttribute <HSVisualAttribute>
- (id)hyperStringValue;
@end

@protocol HSStringContentAttributes <HSAttributes, HSStringValueAttribute, HSAttributedStringValueAttribute>
- (void)setHyperAttributedStringValue:(id)aValue;
- (void)setHyperStringValue:(id)aValue;
@end

@protocol HSStrokeColorVectorAttribute <HSVectorAttribute>
- (id)strokeColor;
@end

@protocol HSSystemBoxTitleVisibilityAttribute <HSVisualAttribute>
- (BOOL)canToggleTitleVisibility;
- (BOOL)isHyperTitleVisible;
@end

@protocol HSSystemBoxTitleAttributes <HSTitleAttributes, HSSystemBoxTitleVisibilityAttribute>
@end

@protocol HSSystemBoxTitleMutableAttributes <HSSystemBoxTitleAttributes, HSTitleMutableAttributes>
- (void)setHyperTitleVisible:(BOOL)aVisible;
@end

@protocol HSSystemBoxBorderTypeAttribute <HSVisualAttribute>
- (NSUInteger)hyperBorderType;
@end

@protocol HSSystemBoxAttributes <HSSystemBoxTitleMutableAttributes, HSSystemBoxBorderTypeAttribute>
- (void)setHyperBorderType:(NSUInteger)aType;
@end

@protocol HSSystemButtonInteractiveHighlightAttribute <HSVisualAttribute>
- (BOOL)isHyperHighlightedInInteractiveMode;
@end

@protocol HSSystemButtonInteractiveModeAttributes <HSAttributes, HSSystemButtonInteractiveHighlightAttribute>
- (void)setHyperHighlightedInInteractiveMode:(BOOL)aMode;
@end

@protocol HSSystemButtonSpecialAccessHighlightAttribute <HSVisualAttribute>
- (BOOL)isSpecialAccessHighlightActive;
@end

@protocol HSSystemButtonSpecialAccessHighlightAttributes <HSAttributes, HSSystemButtonSpecialAccessHighlightAttribute>
- (void)setSpecialAccessHighlightActive:(BOOL)aActive;
@end

@protocol HSSystemEditableAttribute <HSVisualAttribute>
- (BOOL)isEditable;
@end

@protocol HSSystemImageViewAlignmentAttribute <HSVisualAttribute>
- (NSUInteger)hyperImageAlignment;
@end

@protocol HSSystemImageViewFrameStyleAttribute <HSVisualAttribute>
- (NSUInteger)hyperImageFrameStyle;
@end

@protocol HSSystemImageViewScalingAttribute <HSVisualAttribute>
- (NSUInteger)hyperImageScaling;
@end

@protocol HSSystemImageViewAttributes <HSImageMutableAttributes, HSMediaAttribute, HSSystemImageViewAlignmentAttribute, HSSystemImageViewFrameStyleAttribute, HSSystemImageViewScalingAttribute, HSSystemEditableAttribute, HSSystemEnabledAttribute>
- (void)setEditable:(BOOL)aEditable;
- (void)setEnabled:(BOOL)aEnabled;
- (void)setHyperImageAlignment:(NSUInteger)aAlignment;
- (void)setHyperImageFrameStyle:(NSUInteger)aStyle;
- (void)setHyperImageScaling:(NSUInteger)aScaling;
- (void)setImageWithPath:(id)aPath;
@end

@protocol HSSystemViewAttribute <HSVisualAttribute>
- (id)hyperSystemView;
- (id)placeholderSystemView;
@end

@protocol HSSystemObjectAttributes <HSAttributes, HSSystemViewAttribute>
@end

@protocol HSSystemObjectTitleAlignmentAttribute <HSVisualAttribute>
- (NSUInteger)hyperTitleAlignment;
@end

@protocol HSSystemObjectTitleAvailabilityAttribute <HSVisualAttribute>
- (BOOL)hasHyperTitle;
@end

@protocol HSSystemObjectTitleAttributes <HSTitleMutableAttributes, HSSystemObjectTitleAvailabilityAttribute, HSSystemObjectTitleAlignmentAttribute>
- (void)hyperAutoSizeToFitTitle;
@end

@protocol HSSystemTextFieldAlignmentAttribute <HSVisualAttribute>
- (NSUInteger)hyperTextAlignment;
@end

@protocol HSSystemTextFieldPlaceholderAttribute <HSAttribute>
- (id)hyperPlaceholderString;
@end

@protocol HSTextColorAttribute <HSBaseTextAttribute>
- (id)textColor;
@end

@protocol HSSystemTextFieldBorderTypeAttribute <HSVisualAttribute>
- (NSUInteger)hyperBorderType;
@end

@protocol HSSystemTextFieldBezelStyleAttribute <HSVisualAttribute>
- (NSUInteger)hyperTextFieldBezelStyle;
@end

@protocol HSSystemTextFieldSelectableAttribute <HSAttribute>
- (BOOL)isSelectable;
@end

@protocol HSSystemTextFieldBorderedAttribute <HSVisualAttribute>
- (BOOL)isHyperBordered;
@end

@protocol HSSystemTextFieldBezeledAttribute <HSVisualAttribute>
- (BOOL)isHyperBezeled;
@end

@protocol HSSystemTextFieldAttributes <HSTitleMutableAttributes, HSStringContentAttributes, HSSystemTextFieldPlaceholderAttribute, HSTextColorAttribute, HSBackgroundColorAttribute, HSSystemTextFieldBorderTypeAttribute, HSSystemTextFieldBezelStyleAttribute, HSSystemTextFieldAlignmentAttribute, HSSystemControlSizeAttribute, HSSystemTextFieldSelectableAttribute, HSSystemEditableAttribute, HSSystemTextFieldBorderedAttribute, HSSystemTextFieldBezeledAttribute, HSGenericFontAttributes>
- (CGFloat)hyperFontSize;
- (void)hyperSizeToFitContent;
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically;
- (void)setBackgroundColor:(id)aColor;
- (void)setControlSize:(NSUInteger)aSize;
- (void)setEditable:(BOOL)aEditable;
- (void)setHyperBezeled:(BOOL)aBezeled;
- (void)setHyperBorderType:(NSUInteger)aType;
- (void)setHyperBordered:(BOOL)aBordered;
- (void)setHyperPlaceholderString:(id)aString;
- (void)setHyperTextAlignment:(NSUInteger)aAlignment;
- (void)setHyperTextFieldBezelStyle:(NSUInteger)aStyle;
- (void)setSelectable:(BOOL)aSelectable;
- (void)setTextColor:(id)aColor;
@end

@protocol HSSystemTextFieldVisualPlaceholderAttribute <HSSystemTextFieldPlaceholderAttribute, HSVisualAttribute>
@end

@protocol HSSystemTextViewAttribute <HSVisualAttribute>
- (id)placeholderSystemTextView;
- (id)systemTextView;
@end

@protocol HSTextViewTextAttribute <HSBaseTextAttribute>
- (id)hyperPlainText;
- (id)hyperText;
@end

@protocol HSTextAttributes <HSAttributes, HSGenericFontAttributes, HSTextColorAttribute, HSBackgroundColorAttribute, HSTextViewTextAttribute>
- (void)applyHyperTextAttributesDictionary:(id)aDictionary;
- (void)replaceTextInRange:(NSRange)aRange withAttributedString:(id)aString;
- (void)setBackgroundColor:(id)aColor;
- (void)setHyperPlainText:(id)aText;
- (void)setHyperText:(id)aText;
- (void)setTextColor:(id)aColor;
@end

@protocol HSSystemTextViewBorderTypeAttribute <HSVisualAttribute>
- (NSUInteger)borderType;
@end

@protocol HSSystemTextViewScrollBarControlSizeAttribute <HSVisualAttribute>
- (NSUInteger)hyperScrollBarControlSize;
@end

@protocol HSSystemTextViewSelectableAttribute <HSAttribute>
- (BOOL)isSelectable;
@end

@protocol HSSystemTextViewVerticalScrollerVisibilityAttribute <HSVisualAttribute>
- (BOOL)hasVerticalScroller;
@end

@protocol HSSystemTextViewScrollableAttribute <HSAttribute>
- (BOOL)isScrollable;
@end

@protocol HSSystemTextViewScrollDirectionAttribute <HSAttribute>
- (BOOL)scrollsHorizontally;
@end

@protocol HSSystemTextViewVerticalScrollPositionAttribute <HSVisualAttribute>
- (CGFloat)verticalScrollPosition;
@end

@protocol HSSystemTextViewHorizontalScrollPostionAttribute <HSVisualAttribute>
- (CGFloat)horizontalScrollPosition;
@end

@protocol HSSystemTextViewSelectedRangeAttribute <HSVisualAttribute>
- (NSRange)selectedRange;
@end

@protocol HSSystemTextViewTypeAttribute <HSVisualAttribute>
- (BOOL)isRotatableText;
@end

@protocol HSSystemTextViewFontAttribute <HSAttribute>
- (id)font;
@end

@protocol HSSystemTextViewAttributes <HSAttributes, HSTextAttributes, HSSystemTextViewAttribute, HSSystemTextViewBorderTypeAttribute, HSSystemTextViewScrollBarControlSizeAttribute, HSSystemTextViewSelectableAttribute, HSSystemEditableAttribute, HSSystemTransparencyAttribute, HSSystemTextViewVerticalScrollerVisibilityAttribute, HSSystemTextViewScrollableAttribute, HSSystemTextViewScrollDirectionAttribute, HSSystemTextViewVerticalScrollPositionAttribute, HSSystemTextViewHorizontalScrollPostionAttribute, HSSystemTextViewSelectedRangeAttribute, HSSystemTextViewTypeAttribute, HSSystemTextViewFontAttribute>
- (CGFloat)heightOfFirstLineFragments:(NSUInteger)aFragments;
- (void)setBorderType:(NSUInteger)aType;
- (void)setEditable:(BOOL)aEditable;
- (void)setEditable:(BOOL)aEditable setByUser:(BOOL)aUser;
- (void)setFont:(id)aFont;
- (void)setHasVerticalScroller:(BOOL)aScroller;
- (void)setHorizontalScrollPosition:(CGFloat)aPosition;
- (void)setHyperScrollBarControlSize:(NSUInteger)aSize;
- (void)setHyperTextFilePath:(id)aPath;
- (void)setRotatableText:(BOOL)aText;
- (void)setRotatableText:(BOOL)aText autoresizing:(BOOL)aAutoresizing;
- (void)setScrollable:(BOOL)aScrollable;
- (void)setScrollsHorizontally:(BOOL)aHorizontally;
- (void)setSelectable:(BOOL)aSelectable;
- (void)setSelectedRange:(NSRange)aRange;
- (void)setTransparent:(BOOL)aTransparent;
- (void)setVerticalScrollPosition:(CGFloat)aPosition;
- (CGFloat)totalScrollAmountInPixels;
@end

@protocol HSSystemTextViewExportAttributes <HSAttributes>
- (BOOL)willBeExportedAsImage;
@end

@protocol HSSystemTextViewFontTraitsAttributes <HSAttributes>
- (void)finishOutlineMutating:(BOOL)aMutating;
- (BOOL)hasMultipleShadowStyles;
- (NSInteger)hyperAlignment;
- (id)hyperOutlineColor;
- (CGFloat)hyperOutlineWidth;
- (CGFloat)hyperShadowAngle;
- (CGFloat)hyperShadowBlurRadius;
- (CGFloat)hyperShadowDistance;
- (NSSize)hyperShadowOffset;
- (CGFloat)hyperSpaceBetweenCharacters;
- (CGFloat)hyperSpaceBetweenLines;
- (BOOL)isHyperBold;
- (BOOL)isHyperCondensed;
- (BOOL)isHyperExpanded;
- (BOOL)isHyperItalic;
- (BOOL)isHyperOutlineEnabled;
- (BOOL)isHyperShadowEnabled;
- (BOOL)isHyperUnderlined;
- (void)setHyperAlignment:(NSInteger)aAlignment;
- (void)setHyperBold:(BOOL)aBold;
- (void)setHyperCondensed:(BOOL)aCondensed;
- (void)setHyperExpanded:(BOOL)aExpanded;
- (void)setHyperItalic:(BOOL)aItalic;
- (void)setHyperOutlineColor:(id)aColor;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (void)setHyperShadowAngle:(CGFloat)aAngle;
- (void)setHyperShadowBlurRadius:(CGFloat)aRadius;
- (void)setHyperShadowDistance:(CGFloat)aDistance;
- (void)setHyperShadowEnabled:(BOOL)aEnabled;
- (void)setHyperShadowOffset:(NSSize)aOffset;
- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters;
- (void)setHyperSpaceBetweenLines:(CGFloat)aLines;
- (void)setHyperUnderlined:(BOOL)aUnderlined;
- (void)startOutlineMutating;
@end

@protocol HSSystemViewDuplicatingInterface <HyperInterface>
- (id)addDuplicateHyperSystemView;
- (void)removeDuplicateHyperSystemView:(id)aView;
@end

@protocol HSTestingFunctionTypeAttribute <HSAttribute>
- (NSInteger)testingFunctionType;
@end

@protocol HSTestingFunctions <HyperInterface>
- (NSUInteger)numberOfAnswers;
- (NSUInteger)numberOfCorrectAnswers;
- (void)recordCorrectAnswerForObjectWithUID:(id)aUID cardUID:(id)aUID2;
- (void)recordIncorrectAnswerForObjectWithUID:(id)aUID cardUID:(id)aUID2;
- (void)resetTestingInformation;
- (void)setUserName:(id)aName;
- (void)storeTestingInformation;
- (id)userName;
@end

@protocol HSTestingFunctionsActionAttributes <HSActionAttributes, HSTestingFunctionTypeAttribute>
- (void)setTestingFunctionType:(NSInteger)aType;
@end

@protocol HSTextAttribute <HSVisualAttribute>
- (id)hyperFontFamily;
- (CGFloat)hyperFontSize;
- (id)hyperOutlineColor;
- (CGFloat)hyperOutlineWidth;
- (CGFloat)hyperSpaceBetweenCharacters;
- (CGFloat)hyperSpaceBetweenLines;
- (id)hyperText;
- (NSUInteger)hyperTextAlignment;
- (id)hyperTextColor;
- (BOOL)isHyperBold;
- (BOOL)isHyperEmpty;
- (BOOL)isHyperItalic;
- (BOOL)isHyperOutlineEnabled;
- (BOOL)isHyperUnderlined;
@end

@protocol HSTextLayoutAttribute <HSVisualAttribute>
@end

@protocol HSTextMaximumVisibleBoundsAttribute <HSTextLayoutAttribute>
- (NSRect)maximumVisibleBoundsForText;
@end

@protocol HSTextObjectVerticalAlignmentAttribute <HSTextLayoutAttribute>
- (NSInteger)textBlockVerticalAlignment;
@end

@protocol HSTextLayoutAttributes <HSAttributes, HSTextMaximumVisibleBoundsAttribute, HSTextObjectVerticalAlignmentAttribute>
- (void)setTextBlockVerticalAlignment:(NSInteger)aAlignment;
@end

@protocol HSTextObjectAttributes <HSAttributes, HSTextAttribute, HSGenericFontAttributes>
- (void)finishOutlineMutating:(BOOL)aMutating;
- (void)hyperReplaceText:(id)aText;
- (void)hyperReplaceTextWithString:(id)aString;
- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange;
- (void)setHyperBold:(BOOL)aBold;
- (void)setHyperCondensed:(BOOL)aCondensed;
- (void)setHyperExpanded:(BOOL)aExpanded;
- (void)setHyperFontFamily:(id)aFamily;
- (void)setHyperFontFamilyWithFont:(id)aFont;
- (void)setHyperFontSize:(CGFloat)aSize;
- (void)setHyperItalic:(BOOL)aItalic;
- (void)setHyperOutlineColor:(id)aColor;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters;
- (void)setHyperSpaceBetweenLines:(CGFloat)aLines;
- (void)setHyperTextAlignment:(NSUInteger)aAlignment;
- (void)setHyperTextColor:(id)aColor;
- (void)setHyperUnderlined:(BOOL)aUnderlined;
- (void)startOutlineMutating;
@end

@protocol HSTextObjectAttributesImplementationParent <HSAttributes>
- (id)coreTextInterface;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (id)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfoInvocation:(id)aInvocation;
@end

@protocol HSTextObjectSizingAttributes <NSObject>
- (void)hyperAutoSizeToFitText;
- (NSInteger)hyperAutoresizingMode;
- (struct HSTextObjectAutoresizingOptions)hyperAutoresizingOptions;
- (BOOL)hyperHeightSetByUser;
- (BOOL)hyperWidthSetByUser;
- (void)setHyperHeightSetByUser:(BOOL)aUser;
- (void)setHyperWidthSetByUser:(BOOL)aUser;
- (NSInteger)stickyHorizontalSideForAutoresizing;
@end

@protocol HSTextObjectUIDAttribute <HSAttribute>
- (id)textObjectUID;
@end

@protocol HSTextToMovieConverterDelegate <NSObject>
- (void)converterDidFinishConvertingComponentToFile:(id)aFile;
- (void)converterDidfinishConvertingAllComponents;
@end

@protocol HSTextToSpeakAttribute <HSAttribute>
- (id)textToSpeak;
@end

@protocol HSTextToSpeechUsesTextObjectAttribute <HSAttribute>
- (BOOL)usesTextObject;
@end

@protocol HSTextToSpeechPitchAttribute <HSAttribute>
- (NSInteger)relativeSpeechPitch;
@end

@protocol HSTextToSpeechRateAttribute <HSAttribute>
- (NSInteger)relativeSpeechRate;
@end

@protocol HSTextToSpeechVoiceAttribute <HSAttribute>
- (id)speechVoice;
@end

@protocol HSTextToSpeechActionAttributes <HSActionAttributes, HSTextToSpeakAttribute, HSTextObjectUIDAttribute, HSTextToSpeechUsesTextObjectAttribute, HSTextToSpeechPitchAttribute, HSTextToSpeechRateAttribute, HSTextToSpeechVoiceAttribute>
- (void)setRelativeSpeechPitch:(NSInteger)aPitch;
- (void)setRelativeSpeechRate:(NSInteger)aRate;
- (void)setSpeechVoice:(id)aVoice;
- (void)setTextObjectUID:(id)aUID;
- (void)setTextToSpeak:(id)aSpeak;
- (void)setUsesTextObject:(BOOL)aObject;
@end

@protocol HSTransitionNameAttribute <HSAttribute>
- (id)transitionName;
@end

@protocol HSTransitionDisplayNameAttribute <HSAttribute>
- (id)displayName;
@end

@protocol HSTransitionSoundAttribute <HSAttribute>
- (id)sound;
@end

@protocol HSTransitionDurationAttribute <HSAttribute>
- (double)duration;
@end

@protocol HSTransitionSoundPlaybackModeAttribute <HSAttribute>
- (NSInteger)soundPlaybackMode;
@end

@protocol HSTransitionAttributes <HSTransitionNameAttribute, HSTransitionDisplayNameAttribute, HSTransitionSoundAttribute, HSTransitionDurationAttribute, HSTransitionSoundPlaybackModeAttribute, HSHTML5ExportSupport, HSAttributes>
- (id)effect;
- (BOOL)isFastestTransition;
- (void)setDuration:(double)aDuration;
- (void)setEffect:(id)aEffect;
- (void)setShouldStopOnMouseClick:(BOOL)aClick;
- (void)setSound:(id)aSound;
- (void)setSoundPlaybackMode:(NSInteger)aMode;
- (void)setTransitionName:(id)aName;
- (BOOL)shouldStopOnMouseClick;
@end

@protocol HSTransitionViewDataSource <NSObject>
- (id)endImageForTransitionView:(id)aView;
- (id)startImageForTransitionView:(id)aView;
@end

@protocol HSTransparentColorAttribute <HSVisualAttribute>
- (id)transparentColor;
@end

@protocol HSTransparentColorEnabledAttribute <HSVisualAttribute>
- (BOOL)isTransparentColorEnabled;
@end

@protocol HSTransparentColorCachedImageAttribute <HSAttribute>
- (id)cachedImage;
@end

@protocol HSTransparentColorHueToleranceAttribute <HSVisualAttribute>
- (double)hueTolerance;
@end

@protocol HSTransparentColorChromaToleranceAttribute <HSVisualAttribute>
- (double)chromaTolerance;
@end

@protocol HSTransparentColorLightnessToleranceAttribute <HSVisualAttribute>
- (double)lightnessTolerance;
@end

@protocol HSTransparentColorAttributes <HSAttributes, HSTransparentColorEnabledAttribute, HSTransparentColorAttribute, HSTransparentColorCachedImageAttribute, HSTransparentColorHueToleranceAttribute, HSTransparentColorChromaToleranceAttribute, HSTransparentColorLightnessToleranceAttribute>
- (void)setChromaTolerance:(double)aTolerance;
- (void)setHueTolerance:(double)aTolerance;
- (void)setLightnessTolerance:(double)aTolerance;
- (void)setTransparentColor:(id)aColor;
- (void)setTransparentColorEnabled:(BOOL)aEnabled;
@end

@protocol HSUndoableSubobjectsAttribute <HSUndoableAttribute>
@end

@protocol HSUniqueNaming <NSObject>
- (id)uniqueName:(id)aName step:(NSUInteger)aStep uniqueSeparator:(id)aSeparator;
@end

@protocol HSUserObjectHitTesterAttribute <HSAttribute>
@end

@protocol HSUserObjectInteractiveHitTesting <HSUserObjectHitTesting>
@end

@protocol HSUserObjectHitTestingImplementation <HSUserObjectHitTesting, HSUserObjectInteractiveHitTesting, HSUserObjectEditorHitTesting, HSObjectTypeHitTestings>
@end

@protocol HSUserObjectImageProvider <NSObject>
- (NSRect)affineFrameBoundingRectIncludingShadow;
- (CGAffineTransform)affineTransformIncludingShadowOffset;
- (NSRect)boundsForIPadExport;
- (id)image;
- (id)imageForExport;
- (id)imageForExportOfSize:(NSSize)aSize;
- (id)imageForExportOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol;
- (id)imageForHTML5Export;
- (id)imageForIPadExport;
- (id)imageForPresentationContext:(id)aContext;
- (id)imageOfSize:(NSSize)aSize;
- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol;
- (id)imageWithVisualizationProtocol:(id)aProtocol;
- (id)previewForHTML5Export;
- (id)shapeImageWithSize:(NSSize)aSize;
@end

@protocol HSUserObjectSupport <HyperInterface>
- (id)card;
- (id)document;
- (id)stack;
- (id)uniqueNameGenerator;
@end

@protocol HSUserObjectUIDBasedAccess <HyperInterface>
- (id)childInTreeWithUID:(id)aUID;
- (id)childWithUID:(id)aUID;
@end

@protocol HSVectorAttributes <HSAttributes, HSStrokeColorVectorAttribute, HSFillGraphicsVectorAttribute, HSBezierPathVectorAttribute>
@end

@protocol HSVectorBrushToolBoundingRectAttribute <HSAttribute>
- (NSRect)hyperToolBoundingRect;
@end

@protocol HSVectorBrushAttributes <HSAttributes, HSVectorBrushToolBoundingRectAttribute>
- (id)brushRenderer;
- (id)hyperTool;
- (id)hyperTouchProvider;
@end

@protocol HSVectorGraphicsLineEndingOwner <NSObject>
- (id)hyperObjectForLineEnding:(id)aEnding;
@end

@protocol HSVectorGraphicsOwner <NSObject>
- (id)hyperObjectForVectorGraphics:(id)aGraphics;
@end

@protocol HSVideoFrameAttribute <HSVisualAttribute>
- (void)addVideoFrameProcessorClass:(Class)aClass;
- (void)removeVideoFrameProcessorClass:(Class)aClass;
- (id)videoFrameForVideoFrameProcessorClass:(Class)aClass;
@end

@protocol HSVideoRectAttribute <HSVisualAttribute>
- (NSRect)videoRect;
@end

@protocol HSVideoStreamAttributes <HSAttributes, HSVideoRectAttribute, HSPlayingVideoStateAttribute, HSVideoFrameAttribute>
@end

@protocol HSVisualSubobjectsAttribute <HSVisualAttribute>
@end

@protocol HSVisualizationLayering <HSVisualization>
- (id)buildRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)expandRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions;
@end

@protocol HSWeakReferencer <NSObject>
- (void)dereferenceObject:(id)aObject;
@end

@protocol HSWebCamDataProviderServicePingProtocol <NSObject>
- (BOOL)ping;
@end

@protocol HSWebCamDataProviderServiceRequestProtocol <NSObject>
- (id)category:(id)aCategory attributes:(id)aAttributes application:(id)aApplication error:(id *)aError;
- (id)childrenOfCategory:(id)aCategory application:(id)aApplication error:(id *)aError;
- (BOOL)isCategoryExpandable:(id)aExpandable application:(id)aApplication error:(id *)aError;
- (void)validateClipRectForWebCam:(id)aCam application:(id)aApplication;
- (id)webCam:(id)aCam attributes:(id)aAttributes application:(id)aApplication error:(id *)aError;
- (void)webCamsForFilterPredicate:(id)aPredicate sortDescriptors:(id)aDescriptors category:(id)aCategory application:(id)aApplication;
@end

@protocol HSWebCamDataProviderServiceUpdateProtocol <NSObject>
- (void)checkForUpdates:(id)aUpdates;
- (id)databaseVersionError:(id *)aError;
- (void)terminateUpdate:(id)aUpdate;
- (void)terminateUpdatesChecking:(id)aChecking;
- (void)update:(id)aUpdate;
@end

@protocol HSWebCamDataProviderServiceProtocol <HSWebCamDataProviderServicePingProtocol, HSWebCamDataProviderServiceRequestProtocol, HSWebCamDataProviderServiceUpdateProtocol>
@end

@protocol HSWebElementHTMLCodeAttribute <HSAttribute>
- (id)HTMLCode;
@end

@protocol HSWebElementRefreshRateAttribute <HSAttribute>
- (CGFloat)refreshRate;
@end

@protocol HSWebElementPreviewImageAttribute <HSVisualAttribute>
- (struct CGImage *)previewImage;
@end

@protocol HSWebElementContentAttribute <HSVisualAttribute>
@end

@protocol HSWebElementAttributes <HSAttributes, HSWebElementHTMLCodeAttribute, HSWebElementRefreshRateAttribute, HSWebElementPreviewImageAttribute, HSWebElementContentAttribute>
- (void)drawInRect:(NSRect)aRect clipToRect:(NSRect)aRect2;
- (id)ejectWebView;
- (void)reclaimWebView;
- (void)setHTMLCode:(id)aCode;
- (void)setRefreshRate:(CGFloat)aRate;
@end

@protocol HSWebPageURLAttribute <HSAttribute>
- (id)webPageURL;
@end

@protocol HSWebPageSizeAttribute <HSAttribute>
- (NSSize)webPageSize;
@end

@protocol HSWebPageCropPathAttribute <HSVisualAttribute>
- (id)webPageCropPath;
@end

@protocol HSWebPageContentAttribute <HSVisualAttribute>
@end

@protocol HSWebPageRectAttribute <HSVisualAttribute>
- (NSRect)webPageRect;
@end

@protocol HSWebPageTitleAttribute <HSVisualAttribute>
- (id)webPageTitle;
@end

@protocol HSWebPageRefreshRateAttribute <HSVisualAttribute>
- (CGFloat)webPageRefreshRate;
@end

@protocol HSWebPageCameraIDAttribute <HSVisualAttribute>
- (id)webPageCameraID;
@end

@protocol HSWebPageLocationAttribute <HSVisualAttribute>
- (id)webPageLocation;
@end

@protocol HSWebPageTimeZoneAttribute <HSVisualAttribute>
- (id)webPageTimeZone;
@end

@protocol HSWebPageLoadStateAttribute <HSVisualAttribute>
- (NSInteger)loadState;
@end

@protocol HSWebPageCopyrightAttribute <HSVisualAttribute>
- (id)webPageCopyright;
@end

@protocol HSWebPageImageAttribute <HSAttribute>
- (id)webPageImage;
@end

@protocol HSWebPageAttributes <HSAttributes, HSWebPageURLAttribute, HSWebPageSizeAttribute, HSWebPageCropPathAttribute, HSWebPageContentAttribute, HSWebPageRectAttribute, HSWebPageTitleAttribute, HSWebPageRefreshRateAttribute, HSWebPageCameraIDAttribute, HSWebPageLocationAttribute, HSWebPageTimeZoneAttribute, HSWebPageLoadStateAttribute, HSWebPageCopyrightAttribute, HSWebPageImageAttribute>
- (BOOL)isLoading;
- (void)reload;
- (void)setWebPageCameraID:(id)aID;
- (void)setWebPageCopyright:(id)aCopyright;
- (void)setWebPageCropPath:(id)aPath;
- (void)setWebPageImage:(id)aImage;
- (void)setWebPageLoadState:(NSInteger)aState;
- (void)setWebPageLocation:(id)aLocation;
- (void)setWebPageRefreshRate:(CGFloat)aRate;
- (void)setWebPageSize:(NSSize)aSize;
- (void)setWebPageTimeZone:(id)aZone;
- (void)setWebPageTitle:(id)aTitle;
- (void)setWebPageURL:(id)aURL;
- (void)startLoading;
- (void)stopLoading;
- (id)webPageRenderer;
@end

@protocol HSWebPageObjectAttributes <HSAttributes>
- (id)pageCameraID;
- (id)pageCopyright;
- (id)pageCropPath;
- (id)pageLocation;
- (CGFloat)pageRefreshRate;
- (NSSize)pageSize;
- (id)pageTimeZone;
- (id)pageTitle;
- (id)pageURL;
- (void)setPageCameraID:(id)aID;
- (void)setPageCopyright:(id)aCopyright;
- (void)setPageCropPath:(id)aPath;
- (void)setPageLocation:(id)aLocation;
- (void)setPageRefreshRate:(CGFloat)aRate;
- (void)setPageSize:(NSSize)aSize;
- (void)setPageTimeZone:(id)aZone;
- (void)setPageTitle:(id)aTitle;
- (void)setPageURL:(id)aURL;
- (void)setWebPageImage:(id)aImage;
- (id)webPageImage;
@end

@protocol HSWebPageObjectRegistry <HyperInterface>
- (void)addWebPageObject:(id)aObject;
- (void)removeWebPageObject:(id)aObject;
- (void)startLoadingWebPageObjects;
- (void)stopLoadingWebPageObjects;
@end

@protocol HSWebPlayerURLLoading <NSObject>
- (void)hideProgress;
- (void)showProgress;
- (id)stackURL;
- (void)updateProgressWithDownloadedBytes:(long long)aBytes overallBytes:(long long)aBytes2;
@end

@protocol HSXMLLoadingSupport <NSObject>
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
@end

@protocol HSXMLStoringSupport <NSObject>
- (id)XMLElementName;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
@end

@protocol HSXMLTransitionStoringSupport <NSObject>
- (id)xmlTransitionElement;
@end

@protocol HSXMLUserObjectLoadingSupport <HSXMLLoadingSupport>
- (void)importGeometryFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
@end

@protocol HSXMLUserObjectStoringSupport <HSXMLStoringSupport>
- (id)XMLActorElementForActor:(id)aActor inContext:(id)aContext;
- (id)XMLGeometryElementRepresentationInContext:(id)aContext;
- (id)XMLHypertextLinksElementForContext:(id)aContext;
- (id)groupUIDForXMLStoring;
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
@end

@protocol HSYouTubeRectAttribute <HSVisualAttribute>
- (NSRect)youTubeRect;
@end

@protocol HSYouTubeFrameContentAttribute <HSVisualAttribute>
@end

@protocol HSYouTubeAttributes <HSAttributes, HSYouTubeRectAttribute, HSYouTubeFrameContentAttribute>
- (id)youTubeRenderer;
@end

@protocol HSYouTubeInteractiveAttribute <HSAttribute>
- (void)detachRenderer;
- (void)reattachRenderer;
- (id)youTubeInteractiveView;
@end

@protocol HSYouTubeMovieAuthorAttribute <HSAttribute>
- (id)youTubeMovieAuthor;
- (id)youTubeMovieAuthorURL;
@end

@protocol HSYouTubeMovieDurationAttribute <HSAttribute>
- (double)youTubeMovieDuration;
@end

@protocol HSYouTubeMovieIDAttribute <HSVisualAttribute>
- (id)youTubeMovieID;
@end

@protocol HSYouTubeMovieImageAttribute <HSAttribute>
- (id)youTubeMovieImage;
@end

@protocol HSYouTubeMovieSizeAttribute <HSAttribute>
- (NSSize)youTubeMovieSize;
@end

@protocol HSYouTubeMovieTitleAttribute <HSAttribute>
- (id)youTubeMovieTitle;
@end

@protocol HSYouTubeMovieURLAttribute <HSAttribute>
- (id)youTubeMovieURL;
- (id)youTubeMovieWatchURL;
@end

@protocol HSYouTubeObjectAttributes <HSAttributes, HSYouTubeMovieIDAttribute, HSYouTubeMovieURLAttribute, HSYouTubeMovieTitleAttribute, HSYouTubeMovieAuthorAttribute, HSYouTubeMovieDurationAttribute, HSYouTubeMovieSizeAttribute, HSYouTubeInteractiveAttribute, HSYouTubeMovieImageAttribute>
- (void)setYouTubeMovieAuthor:(id)aAuthor;
- (void)setYouTubeMovieAuthorURL:(id)aURL;
- (void)setYouTubeMovieDuration:(double)aDuration;
- (void)setYouTubeMovieID:(id)aID;
- (void)setYouTubeMovieImage:(id)aImage;
- (void)setYouTubeMovieSize:(NSSize)aSize;
- (void)setYouTubeMovieTitle:(id)aTitle;
- (void)setYouTubeMovieURL:(id)aURL;
- (void)setYouTubeMovieWatchURL:(id)aURL;
@end

@protocol HSYouTubeRendering <NSObject>
- (void)detach;
- (void)drawCurrentFrameInRect:(NSRect)aRect;
- (id)interactiveView;
- (void)reattach;
- (void)setYouTubeImage:(id)aImage;
- (id)updateYouTubeImage;
@end

@protocol HSiPadSoundConverterAttributes <HyperInterface>
- (BOOL)isIPadExportableFileType;
- (id)mediaConvertedForIPadExport;
@end

@protocol HSiPadUnsupportedFunctionality <NSObject>
- (BOOL)hasiPadUnsupportedFunctionality;
- (id)iPadUnsupportedFunctionalityDescription;
@end

@protocol NSMutableArrayWeightBehaviors <NSObject>
- (double)deltaForWeight:(id)aWeight betweenWeight:(id)aWeight2 andWeight:(id)aWeight3;
- (void)exchangeWeighedObjectAtIndex:(NSUInteger)aIndex withObjectAtIndex:(NSUInteger)aIndex2;
- (NSUInteger)hyperIndexForWeight:(id)aWeight;
- (id)hyperWeightForIndex:(NSUInteger)aIndex;
- (void)insertWeighedHyperObject:(id)aObject atIndex:(NSUInteger)aIndex;
- (void)normalizeHyperWeight;
- (void)sortByHyperOrder;
- (id)weightForDelta:(double)aDelta betweenWeight:(id)aWeight andWeight:(id)aWeight2;
@end
