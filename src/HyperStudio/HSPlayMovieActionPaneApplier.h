#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSPlayMovieActionPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialMovies;
    NSArray *_initialLiveVideos;
    NSArray *_movies;
    NSArray *_liveVideos;
    NSMutableDictionary *_initialMoviesSettings;
    NSMutableDictionary *_moviesSettings;
    NSMutableDictionary *_initialLiveVideosSettings;
    NSMutableDictionary *_liveVideosSettings;
    id<HSPlayMovieActionAttributes> _playMovieActionAttributes;
    unsigned int _initialSettingApplied:1;
    unsigned int _ignoresAssistantActions:1;
    BOOL _settingsForPlaybackItemsBuilded;
}
- (void)liveVideosChanged:(id)aChanged;
- (void)moviesChanged:(id)aChanged;
- (id)addPlaybackItems:(id)aItems toPlaybackItems:(id)aItems2 excludeTemporaryItems:(BOOL)aItems3;
- (id)removePlaybackItem:(id)aItem fromArray:(id)aArray;
- (id)differencesOfPlaybackItems:(id)aItems fromPlaybaclItems:(id)aItems2;
- (void)stopObservingChangesFromPlayMovieAction;
- (void)startObservingChangesFromPlayMovieAction;
- (void)HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem:(id)aItem;
- (id)createSettingForLiveVideoPlaybackItem:(id)aItem;
- (id)createSettingForMoviePlaybackItem:(id)aItem;
- (id)buildSettingsForPlaybackItems:(id)aItems withSettingsSelector:(SEL)aSelector;
- (void)removeSettingsForPlaybackItems:(id)aItems fromSettingsStorage:(id)aStorage;
- (void)addSettingsForPlaybackItems:(id)aItems withSettingsSelector:(SEL)aSelector toSettingsStorage:(id)aStorage;
- (void)applingSettings:(id)aSettings toLiveVideoPlaybackItem:(id)aItem;
- (void)applingSettings:(id)aSettings toMoviePlaybackItem:(id)aItem;
- (void)applingSettings:(id)aSettings toPlaybackItems:(id)aItems withAppingSelector:(SEL)aSelector;
- (void)applingPlaybackItemsSettings;
- (void)buildSettingsForPlaybackItems;
- (NSUInteger)liveVideosCountInCurrentAppliedSettings;
- (NSUInteger)moviesCountInCurrentAppliedSettings;
- (void)copyDataContainsInCurrentStateToInitial;
- (void)setIgnoresAssistantActions:(BOOL)aActions;
- (BOOL)ignoresAssistantActions;
- (void)setLiveVideoPlaybackItem:(id)aItem name:(id)aName;
- (void)removeLiveVideo:(id)aVideo;
- (void)addLiveVideo:(id)aVideo;
- (void)setLiveVideos:(id)aVideos;
- (void)setMoviePlaybackItem:(id)aItem playRange:(struct HSTimeRange)aRange;
- (void)setMoviePlaybackItem:(id)aItem volume:(CGFloat)aVolume;
- (void)setMoviePlaybackItem:(id)aItem useMovieController:(BOOL)aController;
- (void)removeMovie:(id)aMovie;
- (void)addMovie:(id)aMovie;
- (void)setMovies:(id)aMovies;
- (void)invalidateActionAttributes;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)applyChanges;
- (void)addActionToActor;
- (void)setUpInitialSettings;
- (id)playMovieActionAttributes;
- (void)dealloc;
@end

