#import "HSUserObject+KeynoteSoundImporting.h"

@implementation HSUserObject (KeynoteSoundImporting)

- (void)addSoundMedia:(id)aMedia fromKeynoteMedia:(id)aMedia2 loopMode:(NSInteger)aMode
{
    [self addSoundMedia:aMedia fromKeynoteMedia:aMedia2 forEvent:[self actionEventTypeForKeynoteMedia:aMedia2] loopMode:aMode];
}

- (id)actionEventTypeForKeynoteMedia:(id)aMedia
{
    id slide = [aMedia slide];

    if (slide == nil)
        return kHSArriveActionEventType;
    return [slide eventTypeForMediaId:[aMedia nodeId]];
}

- (void)addSoundMedia:(id)aMedia fromKeynoteMedia:(id)aMedia2 forEvent:(id)aEvent loopMode:(NSInteger)aMode
{
    id actor = [self queryNewHyperInterface:@protocol(HSActor)];
    NSString *path = [aMedia fullPathToMediaFileCreateIfNeeded:YES];
    HSMovie *movie = nil;
    HSSoundItem *item = nil;
    HSPlaySoundAction *action = nil;

    if (path != nil)
        movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:NULL];
    if (movie != nil)
        item = [[HSSoundItem alloc] initWithMediaUID:[aMedia mediaUID] andApplyOptionsFromSound:movie];
    if (item != nil) {
        action = [HSPlaySoundAction new];
        [action addSound:item];
        [action setSynchronousSound:NO];
        [item setVolume:[(KeynoteMovieMedia *)aMedia2 volume]];
        [item setPlayCount:aMode == 0];
        if ([aMedia2 hasPlayRangeSettings]) {
            long timeScale = [[(QTMovie *)[movie quickTimeMovie] attributeForKey:QTMovieTimeScaleAttribute] longValue];
            double start = [(KeynoteMovieMedia *)aMedia2 startTime] / (double)timeScale;
            double end = [(KeynoteMovieMedia *)aMedia2 endTime] / (double)timeScale;
            [item setSoundPlayRange:HSMakeTimeRange(start, end - start)];
        }
        [actor addHyperAction:action forEvent:[HSActionEvent actionEventOfType:aEvent]];
    }
    [movie release];
    [item release];
    [action release];
}

- (void)chooseAnotherSoundForKeynoteMedia:(id)aMedia loopMode:(NSInteger)aMode
{
    NSString *path = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSSoundFileType];

    if (path != nil)
        [self addSoundMedia:[HSNewMedia mediaWithPath:path] fromKeynoteMedia:aMedia loopMode:aMode];
}

- (void)addSoundFromKeynoteMedia:(id)aMedia
{
    [self addSoundFromKeynoteMedia:aMedia loopMode:[aMedia playLoopMode]];
}

- (void)addSoundFromKeynoteMedia:(id)aMedia loopMode:(NSInteger)aMode
{
    NSString *path = [aMedia path];
    id media = [HSNewMedia mediaWithData:[aMedia data] name:[path lastPathComponent] type:[path pathExtension]];

    if (media != nil) {
        [self addSoundMedia:media fromKeynoteMedia:aMedia loopMode:aMode];
        return;
    }

    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *resources;

    [alert setAlertStyle:5];
    resources = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[NSString stringWithFormat:[resources localizedStringForKey:@"CannotFindKeynoteSoundAlertMessageText" value:@"" table:@"Alerts"], [[path lastPathComponent] stringByDeletingPathExtension]]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotFindKeynoteSoundAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"ChooseKeynoteMedia" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"SkipKeynoteMedia" value:@"" table:@"Alerts"]];
    NSInteger result = [alert runModal];
    [alert release];
    if (result == NSAlertFirstButtonReturn)
        [self chooseAnotherSoundForKeynoteMedia:aMedia loopMode:aMode];
}

@end
