#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSMovieStartingAssistantPane : HSObjectAssistantPane
{
    NSView *_paneView;
    id<HSActor> _actorAttributes;
    id<HSPlayMovieActionAttributes> _playMovieActionAttributes;
    id<HSMoviePlaybackAttributes> _moviePlaybackAttributes;
    id<HSStartingPlayableObjectAttributes> _observerdStartingPlayableObjectAttributes;
    id<HSMovieObjectAttributes> _movieObjectAttributes;
    NSView *_containerView;
    NSView *_QTVRView;
    NSView *_movieView;
    NSButton *_startOnArriveSwitchButton;
    NSButton *_startOnClickSwitchButton;
    NSButton *_allowOtherMoviesSwitchButton;
    NSButton *_allowOtherSoundsSwitchButton;
    NSView *_currentContentView;
}
- (void)allowOtherSoundsDidChange:(id)aChange;
- (void)allowOtherMoviesDidChange:(id)aChange;
- (void)startingOnClickDidChange:(id)aChange;
- (void)startingOnArriveDidChange:(id)aChange;
- (void)viewDidDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)movieObjectAttributesDidChange:(id)aChange;
- (void)stopObservingChangesInMovieObjectAttributes;
- (void)startObservingChangesInMovieObjectAttributes;
- (void)playableObjectAttributesDidChange:(id)aChange;
- (void)stopObservingChangesOfPlayableObjectAttributes;
- (void)startObservingChangesOfPlayableObjectAttributes;
- (void)actorAttributesDidChange:(id)aChange;
- (void)stopObservingChangesOfActorAttributes;
- (void)startObservingChangesOfActorAttributes;
- (void)moviesInActionDidChange:(id)aChange;
- (void)stopObservingChangesInPlayMovieActionAttributes;
- (void)startObservingChangesInPlayMovieActionAttributes;
- (void)validateUserInterface;
- (void)removeMovieFromAction;
- (void)addMovieToAction;
- (void)mountContentView:(id)aView;
- (BOOL)isHyperQTVR;
- (id)movieObjectAttributes;
- (id)findMoviePlaybackAttributes;
- (void)setMoviePlaybackAttributes:(id)aAttributes;
- (id)moviePlaybackAttributes;
- (void)dealloc;
- (id)init;
@end

