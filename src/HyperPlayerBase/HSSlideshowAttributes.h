#import "HyperPlayerBasePrefix.h"


@interface HSSlideshowAttributes : NSObject <EXKeyValueCoding>
{
    HSTransition *_transition;
    double _durationBetweenSlides;
    unsigned int _startsNextSlideAutomatically:1;
    unsigned int _stopsAfterEnd:1;
    unsigned int _useClickOnExitCard:1;
    unsigned int _useKeystrokeOnExitCard:1;
    unsigned int _soundEndOnExitCard:1;
    unsigned int _leavesLastPictureOnExit:1;
    unsigned int _returnsToOriginalCard:1;
}
+ (id)defaultSlideshowAttributes;
- (void)setReturnsToOriginalCard:(BOOL)aCard;
- (BOOL)returnsToOriginalCard;
- (void)setLeavesLastPictureOnExit:(BOOL)aExit;
- (BOOL)leavesLastPictureOnExit;
- (void)setSoundEndOnExitCard:(BOOL)aCard;
- (BOOL)soundEndOnExitCard;
- (void)setUseKeystrokeOnExitCard:(BOOL)aCard;
- (BOOL)useKeystrokeOnNextSlide;
- (BOOL)useKeystrokeOnExitCard:(id)aCard;
- (BOOL)useClickOnNextSlide;
- (void)setUseClickOnExitCard:(BOOL)aCard;
- (BOOL)useClickOnExitCard;
- (void)setStopsAfterEnd:(BOOL)aEnd;
- (BOOL)stopsAfterEnd;
- (void)setDurationBetweenSlides:(double)aSlides;
- (double)durationBetweenSlides;
- (void)setStartsNextSlideAutomatically:(BOOL)aAutomatically;
- (BOOL)startsNextSlideAutomatically;
- (void)setTransition:(id)aTransition;
- (id)transition;
- (void)dealloc;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

