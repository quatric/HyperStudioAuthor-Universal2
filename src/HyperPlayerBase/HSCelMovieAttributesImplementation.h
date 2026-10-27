#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSCelMovieAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSFramesPerSecondAttributes, HSAttributes, HyperInterface, NSObject, HSExtendedPlayableObjectAttributes, HSPlayableObjectAttributes, HSPlayableObjectUIDAttribute, HSAttribute, HSPlayableObjectNameAttribute, HSPlayableObjectDurationAttribute, HSPlayableObjectStartTimeAttribute, HSPlayableObjectPlayRangeAttribute, HSPlayableObjectHyperPlayingAttribute, HSExtendedPlayableObjectPlayCountAttribute, HSCelMovieObjectAttributes, HSCelMovieObjectFrameCountAttribute, HSMovieObjectEraseWhenDoneAttribute, HSVisualAttribute, HSUndoableAttribute, HSImageAttributes, HSImageAttribute, HSImageRectAttribute>
{
    HSNode *_node;
    HSCelMovieNodeUnit *_nodeUnit;
    HSCelMovieObjectFramesCache *_framesCache;
    BOOL _isMovieStarted;
    BOOL _wasMoviePlaying;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (void)HSCelMovieAttributesImplementation_recacheFrames;
- (NSInteger)hyperFrameCount;
- (void)setHyperEraseWhenDone:(BOOL)aDone;
- (BOOL)hyperEraseWhenDone;
- (BOOL)isImageComposite;
- (id)image;
- (NSRect)imageRect;
- (void)hyperStepForward;
- (void)hyperStepBack;
- (void)setHyperCurrentTime:(double)aTime;
- (double)hyperCurrentTime;
- (void)hyperStop;
- (void)hyperStart:(id)aStart atRate:(CGFloat)aRate startupMode:(NSInteger)aMode;
- (void)hyperStart:(id)aStart startupMode:(NSInteger)aMode;
- (void)hyperStart:(id)aStart;
- (id)hyperStarter;
- (BOOL)isHyperPlaying;
- (void)setHyperPlayRange:(struct HSTimeRange)aRange;
- (struct HSTimeRange)hyperPlayRange;
- (void)setHyperStartTime:(double)aTime;
- (double)hyperStartTime;
- (double)hyperDuration;
- (id)hyperPlayableObjectName;
- (id)hyperPlayableObjectUID;
- (void)setHyperPlayCount:(NSUInteger)aCount;
- (NSUInteger)hyperPlayCount;
- (double)hyperFramesPerSecond;
- (id)attributeObservingController;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
- (void)hyperPause;
- (void)hyperResume;
@end

