#import "HSSlideshowAttributes.h"

// Slideshow playback options; defaults come from the user defaults.
@implementation HSSlideshowAttributes
+ (id)defaultSlideshowAttributes
{
    return [self objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSSlideshowAttributesKeyString"]];
}
- (void)setReturnsToOriginalCard:(BOOL)aCard
{
    _returnsToOriginalCard = aCard ? 1 : 0;
}
- (BOOL)returnsToOriginalCard
{
    return _returnsToOriginalCard;
}
- (void)setLeavesLastPictureOnExit:(BOOL)aExit
{
    _leavesLastPictureOnExit = aExit ? 1 : 0;
}
- (BOOL)leavesLastPictureOnExit
{
    return _leavesLastPictureOnExit;
}
- (void)setSoundEndOnExitCard:(BOOL)aCard
{
    _soundEndOnExitCard = aCard ? 1 : 0;
}
- (BOOL)soundEndOnExitCard
{
    return _soundEndOnExitCard;
}
- (void)setUseKeystrokeOnExitCard:(BOOL)aCard
{
    _useKeystrokeOnExitCard = aCard ? 1 : 0;
}
- (BOOL)useKeystrokeOnNextSlide
{
    return NO;
}
- (BOOL)useKeystrokeOnExitCard:(id)aCard
{
    return _useKeystrokeOnExitCard;
}
- (BOOL)useClickOnNextSlide
{
    return NO;
}
- (void)setUseClickOnExitCard:(BOOL)aCard
{
    _useClickOnExitCard = aCard ? 1 : 0;
}
- (BOOL)useClickOnExitCard
{
    return _useClickOnExitCard;
}
- (void)setStopsAfterEnd:(BOOL)aEnd
{
    _stopsAfterEnd = aEnd ? 1 : 0;
}
- (BOOL)stopsAfterEnd
{
    return _stopsAfterEnd;
}
- (void)setDurationBetweenSlides:(double)aSlides
{
    _durationBetweenSlides = aSlides;
}
- (double)durationBetweenSlides
{
    return _durationBetweenSlides;
}
- (void)setStartsNextSlideAutomatically:(BOOL)aAutomatically
{
    _startsNextSlideAutomatically = aAutomatically ? 1 : 0;
}
- (BOOL)startsNextSlideAutomatically
{
    return _startsNextSlideAutomatically;
}
- (void)setTransition:(id)aTransition
{
    if (_transition != aTransition) {
        [_transition release];
        _transition = [aTransition retain];
    }
}
- (id)transition
{
    if (_transition == nil)
        _transition = [[HSTransition alloc] init];
    return _transition;
}
- (void)dealloc
{
    [_transition release];
    [super dealloc];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"transition", @"startsNextSlideAutomatically", @"durationBetweenSlides",
            @"stopsAfterEnd", @"useClickOnExitCard", @"useKeystrokeOnExitCard", @"soundEndOnExitCard",
            @"leavesLastPictureOnExit", @"returnsToOriginalCard", nil];
}
@end
