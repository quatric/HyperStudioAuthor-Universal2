#import "HSMovieObject+KeynoteImporting.h"

@implementation HSMovieObject (KeynoteImporting)

- (id)mediaFromKeynoteMovieData:(id)aData name:(id)aName type:(id)aType
{
    HSMovieVerifier *verifier;
    id movie, media;

    if ([aData length] == 0)
        return nil;
    verifier = [HSMovieVerifier new];
    movie = [verifier verifyMovieWithData:aData withOptions:HSMovieVerifierNoUI error:NULL];
    if (movie != nil)
        media = [HSNewMedia mediaWithQTMovie:movie name:aName type:aType];
    else
        media = [HSNewMedia mediaWithData:aData name:aName type:aType];
    [verifier release];
    return media;
}

- (void)importPlayRangeFromKeynoteObject:(id)aObject
{
    long timeScale = [[(QTMovie *)[[self movie] quickTimeMovie] attributeForKey:QTMovieTimeScaleAttribute] longValue];
    double start = 0.0, end = FLT_MAX;

    if ([aObject hasPlayRangeSettings]) {
        start = [(KeynoteMovieMedia *)aObject startTime] / (double)timeScale;
        end = [(KeynoteMovieMedia *)aObject endTime] / (double)timeScale;
    }
    [self setHyperPlayRange:HSMakeTimeRange(start, end - start)];
}

- (void)chooseAnotherMediaForKeynoteObject:(id)aObject
{
    id path = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:[(KeynoteMedia *)aObject mediaType] != 0 ? kHSSoundFileType : kHSMovieFileType];

    if (path != nil)
        [self setMedia:[HSNewMedia mediaWithPath:path]];
}

- (void)continueImportFromKeynoteObject:(id)aObject
{
    [super importFromKeynoteObject:aObject];
    [self setHyperVolume:[(KeynoteMovieMedia *)aObject volume]];
    [self importPlayRangeFromKeynoteObject:aObject];
}

- (void)importFromKeynoteObject:(id)aObject
{
    id path = [aObject path];
    id media = [self mediaFromKeynoteMovieData:[aObject data] name:[path lastPathComponent] type:[path pathExtension]];
    HSExecutableResourceProvider *provider;
    HSAlert *alert;
    NSInteger result;

    if (media != nil) {
        [self setMedia:media];
        [self continueImportFromKeynoteObject:aObject];
        return;
    }
    provider = [HSExecutableResourceProvider sharedInstance];
    alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[NSString stringWithFormat:[provider localizedStringForKey:@"CannotFindKeynoteMediaAlertMessageText" value:@"" table:@"Alerts"], [[path lastPathComponent] stringByDeletingPathExtension]]];
    [alert setInformativeText:[provider localizedStringForKey:@"CannotFindKeynoteMediaAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"ChooseKeynoteMedia" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"SkipKeynoteMedia" value:@"" table:@"Alerts"]];
    result = [alert runModal];
    [alert release];
    if (result == NSAlertSecondButtonReturn)
        [self removeFromHyperParent];
    else {
        [self chooseAnotherMediaForKeynoteObject:aObject];
        [self continueImportFromKeynoteObject:aObject];
    }
}

@end
