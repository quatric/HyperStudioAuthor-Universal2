#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSPlayMovieAction : HSToDoAction <HSPlayMovieActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSPlaybackItemSupport, HSPlayMovieMoviesAttribute, HSPlayMovieLiveVideosAttribute, HSPlayableObjectsActionAttributes, HSSelectedPlayableObjectsUIDsAttribute, HSMediaCopySupport, HSNodeSupport, HSCardObjectOptimization>
{
    NSArray *_movies;
    NSArray *_liveVideos;
    NSMutableArray *_currentlyPlayingLiveVideos;
    NSMutableArray *_currentlyPlayingMovies;
    BOOL _isNeedVerifyMovies;
    float _storeVersion;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)delegate;
- (id)scriptController;
- (id)undoManager;
- (id)objectForAction;
- (id)nodeSupportForMovie;
- (id)itemAttributeNotificationCenter;
- (id)stackForAction;
- (id)cardForAction;
- (void)playbackItemStateDidChange:(id)aChange;
- (void)playbackItemStateWillChange:(id)aChange;
- (void)unsubscribeToAllPlaybackItemsAboutEnabledChagning:(id)aChagning;
- (void)subscribeToAllPlaybackItemsAboutEnabledChagning:(id)aChagning;
- (id)currentlyPlayingLiveVideos;
- (id)currentlyPlayingMovies;
- (void)verifyMoviePlaybackItems;
- (id)mediaUIDsForOptimization;
- (id)mediaUIDs;
- (id)ownedMediaUIDs;
- (void)moviePlaybackDidFinish:(id)aFinish;
- (void)removePlayableObject:(id)aObject;
- (void)addPlayableObject:(id)aObject;
- (id)hyperSelectedUIDs;
- (BOOL)supportedInIPad;
- (BOOL)isValid;
- (void)stop:(id)aStop;
- (void)startInContext:(id)aContext;
- (BOOL)canBeStopped;
- (void)performPrimarySetupOnCard:(id)aCard actionExecutionContext:(id)aContext;
- (id)enabledLiveObjects;
- (void)removeLiveVideo:(id)aVideo;
- (void)addLiveVideo:(id)aVideo;
- (void)setLiveVideos_priv:(id)aPriv;
- (void)setLiveVideos:(id)aVideos;
- (id)liveVideos;
- (id)enabledMovies;
- (void)removeMovie:(id)aMovie;
- (void)addMovie:(id)aMovie;
- (void)setMovies_priv:(id)aPriv;
- (void)setMovies:(id)aMovies;
- (id)movies;
- (id)playbackItems:(id)aItems forEnableState:(BOOL)aState;
- (void)willDisconnectFromDocument;
- (void)didConnectToDocument;
- (void)mergeInPlayMovieAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (BOOL)wantsSaveAfterRemove;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (id)valueForKey:(id)aKey;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

@interface HSPlayMovieAction (HSPlayMovieActionDeprecated)
- (void)setShowLiveVideo:(BOOL)aVideo;
- (BOOL)showLiveVideo;
@end

