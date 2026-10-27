#import "HSPlayMovieAction.h"
#import "HSMoviePlaybackItem.h"
#import "HSLiveVideoPlaybackItem.h"
#import "HSActionMediaPlayer.h"
#import "HSActionExecutionContext.h"
#import "HSExecutableResourceProvider.h"
#import "HSUID.h"
#import "HSFunctions.h"
#import "EXCodingContext.h"
#import "NSEMutableProtocolSet.h"

// Plays the selected movies and live videos of the card. Each one is kept as
// a playback item (HSMoviePlaybackItem, HSLiveVideoPlaybackItem) holding its
// playing options; the action finishes when the last one stops.
@implementation HSPlayMovieAction

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    HSUID *uid = [HSUID UIDWithString:[[aRepresentation attributeForName:@"mediaObjectId"] stringValue]];
    HSMoviePlaybackItem *item = [[HSMoviePlaybackItem alloc] init];
    [item setMovieObjectUID:uid];
    [item setEnabled:YES];
    [self addMovie:item];
    [item release];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (id item in [self movies]) {
        if ([item canBeStoredAsXMLElement]) {
            id child = [item XMLElementRepresentationInContext:aContext];
            if (child)
                [element addChild:child];
        }
    }
    for (id item in [self liveVideos]) {
        if ([item canBeStoredAsXMLElement]) {
            id child = [item XMLElementRepresentationInContext:aContext];
            if (child)
                [element addChild:child];
        }
    }
    // Objects not on a card are stored with the action.
    for (HSMoviePlaybackItem *item in [self movies]) {
        id movieObject = [item movieObjectForCard:nil];
        if (![movieObject hyperParent]) {
            id child = [movieObject XMLElementRepresentationInContext:aContext];
            if (child)
                [element addChild:child];
        }
    }
    for (HSLiveVideoPlaybackItem *item in [self liveVideos]) {
        id liveObject = [item liveObjectForCard:nil];
        if (![liveObject hyperParent]) {
            id child = [liveObject XMLElementRepresentationInContext:aContext];
            if (child)
                [element addChild:child];
        }
    }
    [pool release];
    return element;
}

- (id)XMLElementName
{
    return @"actPlayMovie";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet set];
    HSExecutableResourceProvider *provider;
    for (HSMoviePlaybackItem *item in [self enabledMovies]) {
        if ([item soundFadeOutTime] != 0 && [aType isEqualToString:@"HSiBooksAuthorDocumentType"]) {
            provider = [HSExecutableResourceProvider sharedInstance];
            [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlayMovieFadeOut" value:@"" table:@"Export"]];
        }
        id movieObject = [item movieObjectForCard:nil];
        if (movieObject) {
            if ([movieObject isHyperPanoramaObject]) {
                provider = [HSExecutableResourceProvider sharedInstance];
                [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlayMoviePanorama" value:@"" table:@"Export"]];
            }
            if ([movieObject isHyperQTVR]) {
                provider = [HSExecutableResourceProvider sharedInstance];
                [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlayMovieQTVR" value:@"" table:@"Export"]];
            }
            if ([aType isEqualToString:@"HSiBooksAuthorDocumentType"] && [item volume] != 1.0f) {
                provider = [HSExecutableResourceProvider sharedInstance];
                [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlayMovieVolume" value:@"" table:@"Export"]];
            }
        }
    }
    if ([[self liveVideos] count]) {
        provider = [HSExecutableResourceProvider sharedInstance];
        [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlayMovieLive" value:@"" table:@"Export"]];
    }
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if ([[self liveVideos] count])
        return YES;
    for (HSMoviePlaybackItem *item in [self enabledMovies]) {
        if ([item soundFadeOutTime] != 0 && [aType isEqualToString:@"HSiBooksAuthorDocumentType"])
            return YES;
        id movieObject = [item movieObjectForCard:nil];
        if (movieObject) {
            if ([movieObject isHyperPanoramaObject] || [movieObject isHyperQTVR])
                return YES;
            if ([aType isEqualToString:@"HSiBooksAuthorDocumentType"] && (float)[item volume] != 1.0f)
                return YES;
        }
    }
    return NO;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    _isNeedVerifyMovies = YES;
    NSArray *enabledMovies = [self enabledMovies];
    if (![enabledMovies count])
        return nil;
    NSMutableDictionary *representation = [super HTML5DictionaryRepresentationInContext:aContext];
    NSMutableArray *movies = [NSMutableArray array];
    for (HSMoviePlaybackItem *item in enabledMovies) {
        id movieObject = [item movieObjectForCard:nil];
        if (!movieObject || [movieObject isHyperPanoramaObject] || [movieObject isHyperQTVR])
            continue;
        NSMutableDictionary *movie = [NSMutableDictionary new];
        [movie setObject:[[movieObject hyperUID] stringValue] forKey:@"object"];
        [movie setObject:[item playOverObjects] ? @"1" : @"0" forKey:@"isPlayOnTop"];
        [movie setObject:[item eraseWhenDone] ? @"1" : @"0" forKey:@"isEraseWhenDone"];
        [movie setObject:[NSString stringWithFormat:@"%u", (unsigned int)[item playCount]] forKey:@"playCount"];
        [movie setObject:[NSString stringWithFormat:@"%.2f", [item playRange].location] forKey:@"startTime"];
        [movie setObject:[NSString stringWithFormat:@"%.2f", [item playRange].length] forKey:@"length"];
        [movie setObject:[NSString stringWithFormat:@"%.2f", (double)[item volume]] forKey:@"volume"];
        [movie setObject:[item useMovieController] ? @"1" : @"0" forKey:@"useMovieController"];
        [movie setObject:[item showFirstFrame] ? @"1" : @"0" forKey:@"isShowFirstFrame"];
        [movie setObject:[item isEnabled] ? @"1" : @"0" forKey:@"isEnabled"];
        [movie setObject:[NSString stringWithFormat:@"%.2f", [item soundFadeOutTime]] forKey:@"fadeOutTime"];
        [movies addObject:movie];
        [movie release];
    }
    if (![movies count])
        return nil;
    [representation setObject:movies forKey:@"movies"];
    return representation;
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}

- (id)cardGroupController
{
    return nil;
}

- (id)delegate
{
    return nil;
}

- (id)scriptController
{
    return nil;
}

- (id)undoManager
{
    return [super undoManager];
}

- (id)objectForAction
{
    return [self hyperObject];
}

- (id)nodeSupportForMovie
{
    return self;
}

- (id)itemAttributeNotificationCenter
{
    return [self attributeNotificationCenter];
}

- (id)stackForAction
{
    return [self stack];
}

- (id)cardForAction
{
    return [self card];
}

- (void)playbackItemStateDidChange:(id)aChange
{
    id attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSActionValidationStatusAttribute)];
    [[self attributeNotificationCenter] notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfoInvocation:nil];
}

- (void)playbackItemStateWillChange:(id)aChange
{
    // The original notifies a did-change here too.
    id attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSActionValidationStatusAttribute)];
    [[self attributeNotificationCenter] notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfoInvocation:nil];
}

- (void)unsubscribeToAllPlaybackItemsAboutEnabledChagning:(id)aChagning
{
    NSEnumerator *enumerator = [aChagning objectEnumerator];
    id item;
    while ((item = [enumerator nextObject])) {
        id observing = [item queryHyperInterface:@protocol(HSAttributeObserving)];
        [observing removeObserver:self selector:@selector(playbackItemStateWillChange:) ofChanges:1 ofAttribute:@protocol(HSPlaybackEnabledAttribute)];
        [observing removeObserver:self selector:@selector(playbackItemStateDidChange:) ofChanges:2 ofAttribute:@protocol(HSPlaybackEnabledAttribute)];
    }
}

- (void)subscribeToAllPlaybackItemsAboutEnabledChagning:(id)aChagning
{
    NSEnumerator *enumerator = [aChagning objectEnumerator];
    id item;
    while ((item = [enumerator nextObject])) {
        id observing = [item queryHyperInterface:@protocol(HSAttributeObserving)];
        [observing addObserver:self selector:@selector(playbackItemStateWillChange:) ofChanges:1 ofAttribute:@protocol(HSPlaybackEnabledAttribute) withPriority:-0.25];
        [observing addObserver:self selector:@selector(playbackItemStateDidChange:) ofChanges:2 ofAttribute:@protocol(HSPlaybackEnabledAttribute) withPriority:-0.25];
    }
}

- (id)currentlyPlayingLiveVideos
{
    if (!_currentlyPlayingLiveVideos)
        _currentlyPlayingLiveVideos = [NSMutableArray new];
    return _currentlyPlayingLiveVideos;
}

- (id)currentlyPlayingMovies
{
    if (!_currentlyPlayingMovies)
        _currentlyPlayingMovies = [NSMutableArray new];
    return _currentlyPlayingMovies;
}

- (void)verifyMoviePlaybackItems
{
    // Drop the items whose movie object is gone.
    if (_isNeedVerifyMovies && [self document]) {
        NSMutableArray *movies = [NSMutableArray arrayWithArray:_movies];
        _isNeedVerifyMovies = NO;
        NSEnumerator *enumerator = [_movies objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            if (![item movieObjectForCard:nil])
                [movies removeObject:item];
        }
        if ([_movies count] != [movies count]) {
            NSUndoManager *undoManager = [self undoManager];
            [undoManager disableUndoRegistration];
            [self setMovies:movies];
            [undoManager enableUndoRegistration];
        }
    }
}

- (id)mediaUIDsForOptimization
{
    return [self mediaUIDs];
}

- (id)mediaUIDs
{
    return [NSSet setWithSet:[self ownedMediaUIDs]];
}

- (id)ownedMediaUIDs
{
    NSCountedSet *uids = [NSCountedSet set];
    NSEnumerator *enumerator = [[self movies] objectEnumerator];
    id item;
    while ((item = [enumerator nextObject])) {
        if ([item movieMediaUID])
            [uids addObject:[item movieMediaUID]];
    }
    return uids;
}

- (void)moviePlaybackDidFinish:(id)aFinish
{
    NSMutableArray *movies = [self currentlyPlayingMovies];
    if ([movies containsObject:aFinish]) {
        [movies removeObject:aFinish];
        if (![movies count] && ![[self currentlyPlayingLiveVideos] count])
            [self notifyDidFinish];
    }
}

- (void)removePlayableObject:(id)aObject
{
    if (![[self hyperSelectedUIDs] containsObject:[aObject hyperUID]])
        return;
    if ([aObject implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
        id uid = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
        if (!uid)
            return;
        NSEnumerator *enumerator = [[self movies] objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            if ([[[item movieObjectForCard:nil] hyperUID] isEqual:uid]) {
                [self removeMovie:item];
                return;
            }
        }
    } else if ([aObject implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
        NSEnumerator *enumerator = [[self liveVideos] objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            if ([[item liveObjectUID] isEqual:[aObject hyperUID]]) {
                [self removeLiveVideo:item];
                return;
            }
        }
    }
}

- (void)addPlayableObject:(id)aObject
{
    if ([[self hyperSelectedUIDs] containsObject:[aObject hyperUID]])
        return;
    id item;
    if ([aObject implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
        item = [[HSMoviePlaybackItem alloc] initWithMovieObject:aObject playMovieAction:self];
        [item setEnabled:YES];
        [self addMovie:item];
    } else if ([aObject implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
        item = [[HSLiveVideoPlaybackItem alloc] initWithLiveObject:aObject playMovieAction:self];
        [item setEnabled:YES];
        [self addLiveVideo:item];
    } else
        return;
    [item release];
}

- (id)hyperSelectedUIDs
{
    NSMutableArray *uids = [NSMutableArray array];
    NSEnumerator *enumerator = [[self movies] objectEnumerator];
    id item;
    while ((item = [enumerator nextObject])) {
        id movieObject = [item movieObjectForCard:nil];
        if (movieObject)
            [uids addObject:[[movieObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID]];
    }
    enumerator = [[self liveVideos] objectEnumerator];
    while ((item = [enumerator nextObject])) {
        if ([item liveObjectUID])
            [uids addObject:[item liveObjectUID]];
    }
    return [[uids copy] autorelease];
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (BOOL)isValid
{
    if ([[self enabledMovies] count])
        return YES;
    return [[self enabledLiveObjects] count] != 0;
}

- (void)stop:(id)aStop
{
    [[self currentlyPlayingLiveVideos] makeObjectsPerformSelector:@selector(stopPlaying)];
    [[self currentlyPlayingMovies] makeObjectsPerformSelector:@selector(stopPlaying)];
    [_currentlyPlayingLiveVideos release];
    _currentlyPlayingLiveVideos = nil;
    [_currentlyPlayingMovies release];
    _currentlyPlayingMovies = nil;
    [super stop:aStop];
}

- (void)startInContext:(id)aContext
{
    NSMutableArray *movies = [self currentlyPlayingMovies];
    [movies addObjectsFromArray:[self playbackItems:[self movies] forEnableState:YES]];
    NSMutableArray *liveVideos = [self currentlyPlayingLiveVideos];
    [liveVideos addObjectsFromArray:[self playbackItems:[self liveVideos] forEnableState:YES]];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];

    // Let the movies of this action play along with each other while they
    // start; stop whatever else is playing if one of them would not.
    NSMutableArray *allowedMovies = [NSMutableArray new];
    NSMutableArray *allowedSounds = [NSMutableArray new];
    for (HSMoviePlaybackItem *item in movies) {
        id movieObject = [item movieObjectForCard:nil];
        if (!movieObject)
            continue;
        id playable = [movieObject queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)];
        if (!playable)
            continue;
        if (![playable isHyperAllowPlayingOtherMovies]) {
            [playable setHyperAllowPlayingOtherMovies:YES];
            [allowedMovies addObject:playable];
        }
        if (![playable isHyperAllowPlayingOtherSounds]) {
            [playable setHyperAllowPlayingOtherSounds:YES];
            [allowedSounds addObject:playable];
        }
    }
    HSActionMediaPlayer *player = [HSActionMediaPlayer sharedActionMediaPlayer];
    if ([allowedMovies count])
        [player stopAllMovies];
    if ([allowedSounds count])
        [player stopAllSoundsForStackUID:[[[self stack] queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID] andSoundAttributes:nil];
    [liveVideos makeObjectsPerformSelector:@selector(playInActionExecutionContext:) withObject:aContext];
    [movies makeObjectsPerformSelector:@selector(playInActionExecutionContext:) withObject:aContext];
    for (id playable in allowedMovies)
        [playable setHyperAllowPlayingOtherMovies:NO];
    [allowedMovies release];
    for (id playable in allowedSounds)
        [playable setHyperAllowPlayingOtherSounds:NO];
    [allowedSounds release];
    [undoManager enableUndoRegistration];

    if (![liveVideos count] && ![movies count] && [aContext isInLimitedMode])
        [self notifyDidFinish];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)performPrimarySetupOnCard:(id)aCard actionExecutionContext:(id)aContext
{
    NSEnumerator *enumerator = [[self enabledMovies] objectEnumerator];
    id item;
    while ((item = [enumerator nextObject])) {
        if ([item showFirstFrame])
            [item showFirstFrameIfNeededInContext:aContext];
    }
}

- (id)enabledLiveObjects
{
    return [self playbackItems:[self liveVideos] forEnableState:YES];
}

- (void)removeLiveVideo:(id)aVideo
{
    NSMutableArray *liveVideos = [[self liveVideos] mutableCopy];
    [liveVideos removeObject:aVideo];
    [self setLiveVideos:liveVideos];
    [liveVideos release];
}

- (void)addLiveVideo:(id)aVideo
{
    NSArray *liveVideos = [self liveVideos];
    if (!liveVideos)
        liveVideos = [NSArray array];
    [self setLiveVideos:[liveVideos arrayByAddingObject:aVideo]];
}

- (void)setLiveVideos_priv:(id)aPriv
{
    if (_liveVideos != aPriv) {
        [self unsubscribeToAllPlaybackItemsAboutEnabledChagning:_liveVideos];
        [_liveVideos makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:nil];
        [_liveVideos release];
        _liveVideos = [aPriv retain];
        [_liveVideos makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:self];
        [self subscribeToAllPlaybackItemsAboutEnabledChagning:_liveVideos];
    }
}

- (void)setLiveVideos:(id)aVideos
{
    if (_liveVideos != aVideos) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Live Videos" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setLiveVideos:[self liveVideos]];
        id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlayMovieLiveVideosAttribute), nil];
        [[self attributeNotificationCenter] notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfoInvocation:nil];
        [self setLiveVideos_priv:aVideos];
        [[self attributeNotificationCenter] notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfoInvocation:nil];
    }
}

- (id)liveVideos
{
    if (!_liveVideos)
        _liveVideos = [NSArray new];
    return _liveVideos;
}

- (id)enabledMovies
{
    return [self playbackItems:[self movies] forEnableState:YES];
}

- (void)removeMovie:(id)aMovie
{
    NSMutableArray *movies = [[self movies] mutableCopy];
    [movies removeObject:aMovie];
    [self setMovies:movies];
    [movies release];
}

- (void)addMovie:(id)aMovie
{
    NSArray *movies = [self movies];
    if (!movies)
        movies = [NSArray array];
    [self setMovies:[movies arrayByAddingObject:aMovie]];
}

- (void)setMovies_priv:(id)aPriv
{
    if (_movies != aPriv) {
        [self unsubscribeToAllPlaybackItemsAboutEnabledChagning:_movies];
        [_movies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:nil];
        [_movies release];
        _movies = [aPriv retain];
        _isNeedVerifyMovies = YES;
        [_movies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:self];
        [self subscribeToAllPlaybackItemsAboutEnabledChagning:_movies];
    }
}

- (void)setMovies:(id)aMovies
{
    if (_movies != aMovies) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Movies" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setMovies:[self movies]];
        id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlayMovieMoviesAttribute), nil];
        [[self attributeNotificationCenter] notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfoInvocation:nil];
        [self setMovies_priv:aMovies];
        [[self attributeNotificationCenter] notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfoInvocation:nil];
    }
}

- (id)movies
{
    if (!_movies)
        _movies = [NSArray new];
    if (_isNeedVerifyMovies)
        [self verifyMoviePlaybackItems];
    return _movies;
}

- (id)playbackItems:(id)aItems forEnableState:(BOOL)aState
{
    NSMutableArray *items = [NSMutableArray array];
    if ([aItems count]) {
        NSEnumerator *enumerator = [aItems objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            if ([item isEnabled] == aState)
                [items addObject:item];
        }
    }
    return items;
}

- (void)willDisconnectFromDocument
{
    [super willDisconnectFromDocument];
    [_movies makeObjectsPerformSelector:@selector(willDisconnectFromDocument)];
    [self movies];
    [_liveVideos makeObjectsPerformSelector:@selector(willDisconnectFromDocument)];
}

- (void)didConnectToDocument
{
    [super didConnectToDocument];
    if (_storeVersion < 520)
        _storeVersion = 520;
    _isNeedVerifyMovies = NO;
    [_movies makeObjectsPerformSelector:@selector(didConnectToDocument)];
    [self movies];
    [_liveVideos makeObjectsPerformSelector:@selector(didConnectToDocument)];
}

- (void)mergeInPlayMovieAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSMutableDictionary *moviesByUID = [NSMutableDictionary new];
    for (HSMoviePlaybackItem *item in [self movies])
        [moviesByUID setObject:item forKey:[item movieObjectUID]];
    NSMutableSet *liveObjectUIDs = [NSMutableSet new];
    for (HSLiveVideoPlaybackItem *item in [self liveVideos])
        [liveObjectUIDs addObject:[item liveObjectUID]];

    // Movies already played here get the union of both play ranges.
    for (HSMoviePlaybackItem *item in [aAction movies]) {
        id uid = [item movieObjectUID];
        if ([aDs containsObject:uid])
            continue;
        HSMoviePlaybackItem *existing = [moviesByUID objectForKey:uid];
        if (!existing) {
            HSMoviePlaybackItem *copy = [item copy];
            if (copy) {
                [self addMovie:copy];
                [copy release];
            }
        } else {
            struct HSTimeRange range = [existing playRange];
            struct HSTimeRange otherRange = [item playRange];
            double location = fmin(range.location, otherRange.location);
            double end = fmax(range.location + range.length, otherRange.location + otherRange.length);
            [existing setPlayRange:HSMakeTimeRange(location, end - location)];
        }
    }
    for (HSLiveVideoPlaybackItem *item in [aAction liveVideos]) {
        id uid = [item liveObjectUID];
        if ([aDs containsObject:uid] || [liveObjectUIDs containsObject:uid])
            continue;
        HSLiveVideoPlaybackItem *copy = [item copy];
        if (copy) {
            [self addLiveVideo:copy];
            [copy release];
        }
    }
    [moviesByUID release];
    [liveObjectUIDs release];
}

- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    HSPlayMovieAction *copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    for (HSMoviePlaybackItem *item in [copy movies]) {
        if ([aDs containsObject:[item movieObjectUID]])
            [copy removeMovie:item];
    }
    for (HSLiveVideoPlaybackItem *item in [copy liveVideos]) {
        if ([aDs containsObject:[item liveObjectUID]])
            [copy removeLiveVideo:item];
    }
    if (![[copy movies] count] && ![[copy liveVideos] count]) {
        [copy release];
        copy = nil;
    }
    return copy;
}

- (BOOL)wantsSaveAfterRemove
{
    return NO;
}

- (void)setValue:(id)aValue forKey:(id)aKey
{
    if (![aKey isEqual:EXCodingVersionKey])
        [super setValue:aValue forKey:aKey];
    else if ([aValue respondsToSelector:@selector(floatValue)])
        _storeVersion = [aValue floatValue];
}

- (id)valueForKey:(id)aKey
{
    if (![aKey isEqual:EXCodingVersionKey])
        return [super valueForKey:aKey];
    return [NSNumber numberWithFloat:520];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraStoringWithCodingContext:aContext];
    return [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[@"movies" extraKeyForCollection], [@"liveVideos" extraKeyForCollection], EXCodingVersionKey, nil]];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    _storeVersion = 0;
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}

- (void)dealloc
{
    [self setMovies_priv:nil];
    [self setLiveVideos_priv:nil];
    [_currentlyPlayingMovies release];
    [_currentlyPlayingLiveVideos release];
    [_movies release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
        _storeVersion = 520;
    return self;
}

- (void)removeUnsupportedFeatures
{
    for (id item in [self enabledMovies]) {
        [item setSoundFadeOutTime:0.0];
        [item setVolume:1.0];
    }
}

// Shows the movie objects again, except the temporary ones whose first
// frame is not shown: those stay hidden and the context remembers them.
- (void)restoreMovieObjectVisibilityInContext:(id)aContext
{
    for (id item in [self playbackItems:[self movies] forEnableState:YES]) {
        id movieObject = [item movieObjectForCard:nil];
        if (movieObject == nil)
            continue;
        if ([movieObject isTemporary] && ![item showFirstFrame]) {
            [movieObject setHiddenInPlayer:YES];
            [aContext addMovieHiddenByPlayMovieAction:movieObject];
        } else {
            [movieObject setHiddenInPlayer:[movieObject isHidden]];
        }
    }
}

@end

@implementation HSPlayMovieAction (HSPlayMovieActionDeprecated)

- (void)setShowLiveVideo:(BOOL)aVideo
{
}

- (BOOL)showLiveVideo
{
    return NO;
}

@end
