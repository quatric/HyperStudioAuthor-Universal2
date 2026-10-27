#import "HSMediaValidator.h"

@implementation HSMediaValidator
+ (id)mediaValidatorForDocument:(id)aDocument
{
    return [[[self alloc] initWithDocument:aDocument] autorelease];
}
- (void)removeActionFromParent:(id)aParent
{
    id actor = [[aParent owner] queryHyperInterface:@protocol(HSActor)];
    NSEnumerator *enumerator = [[[[aParent events] copy] autorelease] objectEnumerator];
    id event;
    while ((event = [enumerator nextObject]))
        [actor removeHyperAction:aParent forEvent:event];
}
- (id)soundItemFromMedia:(id)aMedia
{
    HSMovie *movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:[aMedia fullPathToMediaFile]] error:NULL];
    HSSoundItem *item = [[[HSSoundItem alloc] initWithMediaUID:[aMedia mediaUID] andApplyOptionsFromSound:movie] autorelease];
    [movie release];
    return item;
}
// Asks for a replacement file until one can be stored or the user skips.
- (id)findNewMediaForOldMedia:(id)aMedia
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    if (!panel)
        return nil;
    [panel setAllowsMultipleSelection:NO];
    NSString *directory = [[HSPathsProvider sharedPathsProvider] mediaObjectsFolder];
    NSString *file = [aMedia mediaName];
    if (!directory || !file)
        return nil;
    NSArray *types = [NSArray arrayWithObjects:[aMedia mediaType], nil];
    if (!types)
        return nil;
    NSAlert *alert = nil;
    id media = nil;
    do {
        media = nil;
        do {
            if ([panel runModalForDirectory:directory file:file types:types] != NSModalResponseOK)
                goto done;
            // AppKit 1038 and later.
            NSString *chosenDirectory = [[panel directoryURL] path];
            if (!chosenDirectory)
                goto done;
            [[HSPathsProvider sharedPathsProvider] setMediaObjectsFolder:chosenDirectory];
            directory = chosenDirectory;
            file = [[panel URL] path];
            if (!file)
                goto done;
            media = [HSNewMedia mediaWithPath:file];
        } while (!media);
        if ([self canStoreMedia:media])
            goto done;
        if (!alert) {
            alert = [[NSAlert alloc] init];
            if (!alert)
                break;
            HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
            BOOL sound = [aMedia mediaGroup] == 2;
            [alert setMessageText:[resources localizedStringForKey:(sound ? @"HSInvalidSoundMediaReplacementAlertMessageText" : @"HSInvalidMovieMediaReplacementAlertMessageText") value:@"" table:@"Alerts"]];
            [alert setInformativeText:[resources localizedStringForKey:(sound ? @"HSInvalidSoundMediaReplacementAlertInformativeText" : @"HSInvalidMovieMediaReplacementAlertInformativeText") value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[resources localizedStringForKey:@"HSInvalidMediaAlertReplacementChooseAnotherButtonTitle" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[resources localizedStringForKey:@"HSInvalidMediaAlertReplacementSkipButtonTitle" value:@"" table:@"Alerts"]];
        }
    } while ([alert runModal] != NSAlertSecondButtonReturn);
    media = nil;
done:
    [alert release];
    return media;
}
- (void)addMedia:(id)aMedia forObject:(id)aObject inMediaToObjectMapIfCannotStore:(id)aStore
{
    if (!aMedia || [self canStoreMedia:aMedia])
        return;
    NSMutableSet *objects = NSMapGet(aStore, aMedia);
    if (objects)
        [objects addObject:aObject];
    else
        NSMapInsert(aStore, aMedia, [NSMutableSet setWithObject:aObject]);
}
- (BOOL)canStoreMedia:(id)aMedia
{
    return [aMedia isValid];
}
- (void)closeUndoGroupIfNeeded
{
    if (_isUndoGroupOpened) {
        [[_document undoManager] endUndoGrouping];
        _isUndoGroupOpened = NO;
    }
}
- (void)openUndoGroupIfNeeded
{
    if (!_isUndoGroupOpened) {
        [[_document undoManager] beginUndoGrouping];
        _isUndoGroupOpened = YES;
    }
}
- (void)validateMedia
{
    [self validateMediaWithError:NULL];
}
// Sounds, then movie actions, then movie objects, stopping on a cancel.
- (void)validateMediaWithError:(id *)aError
{
    if (!_document)
        return;
    BOOL groupsByEvent = [[_document undoManager] groupsByEvent];
    [[_document undoManager] setGroupsByEvent:NO];
    id stack = [_document stack];
    [self validatePlaySoundActions:[HSSoundsInUseProvider playSoundActionsInUseForStack:stack] error:aError];
    if (!aError || !*aError)
        [self validatePlayMovieActions:[HSMoviesInUseProvider playMovieActionsInUseForStack:stack] error:aError];
    if (!aError || !*aError)
        [self validatePlayMovieObjects:[HSMoviesInUseProvider playMovieObjectsInStack:stack] error:aError];
    [self closeUndoGroupIfNeeded];
    [[_document undoManager] setGroupsByEvent:groupsByEvent];
}
- (void)validatePlayMovieObjects:(id)aItems error:(id *)aError
{
    NSMapTable *map = [self createInvalidMediaToPlayMovieObjectsMapFor:aItems];
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    id media = nil;
    id items = nil;
    NSString *format = nil;
    NSAlert *alert = nil;
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&media, (void **)&items)) {
        if (!alert) {
            format = [resources localizedStringForKey:@"HSInvalidMovieMediaWithoutActionAlertInformativeFormat" value:@"" table:@"Alerts"];
            if (!format)
                break;
            alert = [[NSAlert alloc] init];
            if (!alert)
                break;
            NSString *message = [resources localizedStringForKey:@"HSInvalidMovieMediaWithoutActionAlertMessageText" value:@"" table:@"Alerts"];
            if (!message)
                break;
            NSString *find = [resources localizedStringForKey:@"HSInvalidMediaAlertFindButtonTitle" value:@"" table:@"Alerts"];
            if (!find)
                break;
            NSString *skip = [resources localizedStringForKey:@"HSInvalidMediaAlertSkipButtonTitle" value:@"" table:@"Alerts"];
            if (!skip)
                break;
            NSString *cancel = [resources localizedStringForKey:@"HSInvalidMediaAlertCancelButtonTitle" value:@"" table:@"Alerts"];
            if (!cancel)
                break;
            [alert setMessageText:message];
            [alert addButtonWithTitle:find];
            [alert addButtonWithTitle:skip];
            [alert addButtonWithTitle:cancel];
        }
        NSString *name = [media mediaName];
        if (!name)
            break;
        NSString *informative = [NSString stringWithFormat:format, name];
        if (!informative)
            break;
        [alert setInformativeText:informative];
        [self invalidMovieMediaWithoutActionAlertDidEndWithReturnCode:[alert runModal] media:media objects:items error:aError];
    }
    [alert release];
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(map);
}
// Find (1000) replaces the media, Skip (1001) removes the objects.
- (void)invalidMovieMediaWithoutActionAlertDidEndWithReturnCode:(NSInteger)aCode media:(id)aMedia objects:(id)aObjects error:(id *)aError
{
    if (aCode == NSAlertThirdButtonReturn) {
        if (aError)
            *aError = [[[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil] autorelease];
        return;
    }
    [self openUndoGroupIfNeeded];
    id newMedia = aCode == NSAlertFirstButtonReturn ? [self findNewMediaForOldMedia:aMedia] : nil;
    NSEnumerator *enumerator = [aObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject])) {
        if (newMedia)
            [object setMedia:newMedia];
        else
            [object removeFromHyperParent];
    }
}
- (id)createInvalidMediaToPlayMovieObjectsMapFor:(id)aFor
{
    NSMapTable *map = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    NSEnumerator *enumerator = [aFor objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]))
        [self addMedia:[object media] forObject:object inMediaToObjectMapIfCannotStore:map];
    return map;
}
- (void)validatePlayMovieActions:(id)aItems error:(id *)aError
{
    NSMapTable *map = [self createInvalidMediaToPlayMovieActionsMapFor:aItems];
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    id media = nil;
    id items = nil;
    NSString *format = nil;
    NSAlert *alert = nil;
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&media, (void **)&items)) {
        if (!alert) {
            format = [resources localizedStringForKey:@"HSInvalidMovieMediaAlertInformativeFormat" value:@"" table:@"Alerts"];
            if (!format)
                break;
            alert = [[NSAlert alloc] init];
            if (!alert)
                break;
            NSString *message = [resources localizedStringForKey:@"HSInvalidMovieMediaAlertMessageText" value:@"" table:@"Alerts"];
            if (!message)
                break;
            NSString *find = [resources localizedStringForKey:@"HSInvalidMediaAlertFindButtonTitle" value:@"" table:@"Alerts"];
            if (!find)
                break;
            NSString *skip = [resources localizedStringForKey:@"HSInvalidMediaAlertSkipButtonTitle" value:@"" table:@"Alerts"];
            if (!skip)
                break;
            NSString *cancel = [resources localizedStringForKey:@"HSInvalidMediaAlertCancelButtonTitle" value:@"" table:@"Alerts"];
            if (!cancel)
                break;
            [alert setMessageText:message];
            [alert addButtonWithTitle:find];
            [alert addButtonWithTitle:skip];
            [alert addButtonWithTitle:cancel];
        }
        NSString *name = [media mediaName];
        if (!name)
            break;
        NSString *informative = [NSString stringWithFormat:format, name];
        if (!informative)
            break;
        [alert setInformativeText:informative];
        [self invalidMovieMediaAlertDidEndWithReturnCode:[alert runModal] media:media actions:items error:aError];
    }
    [alert release];
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(map);
}
- (void)invalidMovieMediaAlertDidEndWithReturnCode:(NSInteger)aCode media:(id)aMedia actions:(id)aActions error:(id *)aError
{
    if (aCode == NSAlertThirdButtonReturn) {
        if (aError)
            *aError = [[[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil] autorelease];
        return;
    }
    [self openUndoGroupIfNeeded];
    id newMedia = aCode == NSAlertFirstButtonReturn ? [self findNewMediaForOldMedia:aMedia] : nil;
    NSEnumerator *enumerator = [aActions objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        NSEnumerator *movies = [[[[action movies] copy] autorelease] objectEnumerator];
        id movie;
        while ((movie = [movies nextObject])) {
            if (![[movie movieMediaUID] isEqual:[aMedia mediaUID]])
                continue;
            id object = [movie movieObjectForCard:nil];
            if (newMedia) {
                [object setMedia:newMedia];
            } else {
                [action removeMovie:movie];
                [object removeFromHyperParent];
            }
        }
        if (![[action movies] count])
            [self removeActionFromParent:action];
    }
}
- (id)createInvalidMediaToPlayMovieActionsMapFor:(id)aFor
{
    NSMapTable *map = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    NSEnumerator *enumerator = [aFor objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        NSEnumerator *movies = [[action movies] objectEnumerator];
        id movie;
        while ((movie = [movies nextObject]))
            [self addMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[movie movieMediaUID]] forObject:action inMediaToObjectMapIfCannotStore:map];
    }
    return map;
}
- (void)validatePlaySoundActions:(id)aItems error:(id *)aError
{
    NSMapTable *map = [self createInvalidMediaToPlaySoundActionsMapFor:aItems];
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    id media = nil;
    id items = nil;
    NSString *format = nil;
    NSAlert *alert = nil;
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&media, (void **)&items)) {
        if (!alert) {
            format = [resources localizedStringForKey:@"HSInvalidSoundMediaAlertInformativeFormat" value:@"" table:@"Alerts"];
            if (!format)
                break;
            alert = [[NSAlert alloc] init];
            if (!alert)
                break;
            NSString *message = [resources localizedStringForKey:@"HSInvalidSoundMediaAlertMessageText" value:@"" table:@"Alerts"];
            if (!message)
                break;
            NSString *find = [resources localizedStringForKey:@"HSInvalidMediaAlertFindButtonTitle" value:@"" table:@"Alerts"];
            if (!find)
                break;
            NSString *skip = [resources localizedStringForKey:@"HSInvalidMediaAlertSkipButtonTitle" value:@"" table:@"Alerts"];
            if (!skip)
                break;
            NSString *cancel = [resources localizedStringForKey:@"HSInvalidMediaAlertCancelButtonTitle" value:@"" table:@"Alerts"];
            if (!cancel)
                break;
            [alert setMessageText:message];
            [alert addButtonWithTitle:find];
            [alert addButtonWithTitle:skip];
            [alert addButtonWithTitle:cancel];
        }
        NSString *name = [media mediaName];
        if (!name)
            break;
        NSString *informative = [NSString stringWithFormat:format, name];
        if (!informative)
            break;
        [alert setInformativeText:informative];
        [self invalidSoundMediaAlertDidEndWithReturnCode:[alert runModal] media:media actions:items error:aError];
    }
    [alert release];
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(map);
}
- (void)invalidSoundMediaAlertDidEndWithReturnCode:(NSInteger)aCode media:(id)aMedia actions:(id)aActions error:(id *)aError
{
    if (aCode == NSAlertThirdButtonReturn) {
        if (aError)
            *aError = [[[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil] autorelease];
        return;
    }
    [self openUndoGroupIfNeeded];
    id newItem = aCode == NSAlertFirstButtonReturn ? [self soundItemFromMedia:[self findNewMediaForOldMedia:aMedia]] : nil;
    NSEnumerator *enumerator = [aActions objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        NSEnumerator *sounds = [[[[action sounds] copy] autorelease] objectEnumerator];
        id sound;
        while ((sound = [sounds nextObject])) {
            if ([sound media] != aMedia)
                continue;
            if (newItem) {
                [newItem copyAttributesFromSoundItem:sound];
                [action addSound:newItem];
            }
            [action removeSound:sound];
        }
        if (![[action sounds] count])
            [self removeActionFromParent:action];
    }
}
- (id)createInvalidMediaToPlaySoundActionsMapFor:(id)aFor
{
    NSMapTable *map = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    NSEnumerator *enumerator = [aFor objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        NSEnumerator *sounds = [[action sounds] objectEnumerator];
        id sound;
        while ((sound = [sounds nextObject]))
            [self addMedia:[sound media] forObject:action inMediaToObjectMapIfCannotStore:map];
    }
    return map;
}
// The document is not retained.
- (id)initWithDocument:(id)aDocument
{
    self = [super init];
    if (self)
        _document = aDocument;
    return self;
}
@end
