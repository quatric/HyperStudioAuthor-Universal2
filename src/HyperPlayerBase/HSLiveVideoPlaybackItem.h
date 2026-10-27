#import "HyperPlayerBasePrefix.h"


@interface HSLiveVideoPlaybackItem : NSObject <HSAttributeObserving, NSObject, HSLiveVideoPlaybackAttributes, HSPlaybackItemAttributes, HSAttributes, HyperInterface, HSPlaybackItemUIDAttribute, HSAttribute, HSPlaybackItemTemporaryAttribute, HSPlaybackEnabledAttribute, HSPlaybackSizeAttribute, HSVisualAttribute, HSUndoableAttribute, HSPlaybackTransformAttribute, HSPlaybackItemSupportAttribute, NSCopying, HSLiveObjectUIDAttribute, HSPlayMovieActionLiveVideoDeviceIndexAttribute, HSLiveObjectAttribute, HSLiveVideoNameAttribute, HSLiveVideoPlayOverObjectsAttribute, EXKeyValueCoding, HSXMLStoringSupport>
{
    id<HSPlaybackItemSupport> _playMovieAction;
    HSLiveObject *_liveObject;
    HSLiveObject *_playableLiveObject;
    id<HSCardAttributes> _cardForPlayableLiveObject;
    unsigned int _originalIndex;
    HSUID *_liveObjectUID;
    BOOL _enabled;
    BOOL _playOverObjects;
    HSActionExecutionContext *_actionExecutionContext;
    id<HSMutableGeometryAttributes> _liveObjectMutableGeometryAttributes;
}
- (id)attributesChangedTemporary;
- (id)attributesBeingChangedContinuously;
- (void)endContinuousChangeOfAttributeSet:(id)aSet;
- (void)beginContinuousChangeOfAttributeSet:(id)aSet;
- (void)endContinuousChangeOfAttribute:(id)aAttribute;
- (void)beginContinuousChangeOfAttribute:(id)aAttribute;
- (void)removeAttributeObserver:(id)aObserver;
- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (id)attributeObservingController;
- (id)attributeNotificationCenter;
- (id)undoManager;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)hasiPadUnsupportedFunctionality;
- (id)iPadUnsupportedFunctionalityDescription;
- (id)liveObjectMutableGeometryAttributes;
- (void)setPlaybackItemSupport:(id)aSupport;
- (id)playbackItemSupport;
- (void)setLiveObjectUIDForSaving:(id)aSaving;
- (id)liveObjectUIDForSaving;
- (id)HSLiveVideoPlaybackItem_liveObject;
- (id)liveObject;
- (void)cleanupPlayableLiveObject;
- (void)preparePlayableLiveObjectWithLiveObject:(id)aObject forCard:(id)aCard;
- (void)willDisconnectFromDocument;
- (void)didConnectToDocument;
- (void)restoreAttributesOfLiveVideo:(id)aVideo;
- (void)applyAttributesForLiveVideo:(id)aVideo;
- (BOOL)isTemporary;
- (void)setPlayOverObjects:(BOOL)aObjects;
- (BOOL)playOverObjects;
- (void)setLiveVideoDeviceIndex:(NSInteger)aIndex;
- (NSInteger)liveVideoDeviceIndex;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)affineTransform;
- (void)setLiveVideoName:(id)aName;
- (id)liveVideoName;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (id)liveObjectForCard:(id)aCard;
- (id)liveObjectUID;
- (id)objectUID;
- (void)stopPlaying;
- (void)playInActionExecutionContext:(id)aContext;
- (void)setLiveVideoPlaybackItemVersion:(id)aVersion;
- (id)liveVideoPlaybackItemVersion;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (id)initWithLiveObject:(id)aObject playMovieAction:(id)aAction;
@end

