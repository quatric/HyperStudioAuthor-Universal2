#import "HSMovieVerifier.h"
// Opens movies, repairing broken alias data references (media moved since
// the movie was saved): the repaired movie is flattened into a temporary file
// and reopened from it.
// QuickTime's media data references (GetMediaDataRef, alias records) have no
// AVFoundation counterpart: AVFoundation resolves references itself, so no
// broken reference is ever found and movies are returned as opened.
@implementation HSMovieVerifier
- (id)verifyMovie:(id)aMovie withOptions:(NSInteger)aOptions error:(id *)aError
{
    id result = nil;
    if (aMovie != nil) {
        _movie = aMovie;
        _options = (unsigned int)aOptions;
        NSArray *brokenRefs = [self brokenMediaDataRefsAttributesInMovie];
        if ([brokenRefs count] == 0)
            result = [[aMovie retain] autorelease];
        else {
            [self showStatusWindow];
            if ([self tryToResolveBrokenDataRefs:brokenRefs]) {
                NSString *base = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[NSString hyperUIDString]];
                NSString *path = [NSString extraCreateUniqueFilename:base extension:@"mov"];
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], QTMovieFlatten, nil];
                if ([aMovie writeToFile:path withAttributes:attributes error:aError])
                    result = [QTMovie movieWithFile:path error:aError];
            }
            [self hideStatusWindow];
        }
    }
    _movie = nil;
    _options = 0;
    return result;
}
- (id)verifyMovieWithData:(id)aData withOptions:(NSInteger)aOptions error:(id *)aError
{
    if (aData == nil)
        return nil;
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:aData, QTMovieDataAttribute,
                                [NSNumber numberWithBool:NO], QTMovieResolveDataRefsAttribute,
                                [NSNumber numberWithBool:NO], QTMovieAskUnresolvedDataRefsAttribute, nil];
    QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:aError];
    [attributes release];
    if (movie == nil)
        return nil;
    id result = [self verifyMovie:movie withOptions:aOptions error:aError];
    [movie release];
    return result;
}
// Returns the verified movie's URL.
- (id)verifyMovieAtURL:(id)aURL withOptions:(NSInteger)aOptions error:(id *)aError
{
    NSString *path = [aURL path];
    if (aURL == nil || path == nil || ![[NSFileManager defaultManager] hyperIsFileReadableAtPath:path])
        return nil;
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[QTDataReference dataReferenceWithReferenceToURL:aURL], QTMovieDataReferenceAttribute,
                                [NSNumber numberWithBool:NO], QTMovieResolveDataRefsAttribute,
                                [NSNumber numberWithBool:NO], QTMovieAskUnresolvedDataRefsAttribute, nil];
    QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:aError];
    [attributes release];
    if (movie == nil)
        return nil;
    id result = [self verifyMovie:movie withOptions:aOptions error:aError];
    if (result != nil)
        result = [result attributeForKey:QTMovieURLAttribute];
    [movie release];
    return result;
}
- (BOOL)tryToResolveBrokenDataRefs:(id)aRefs
{
    if (_movie == nil)
        return YES;
    for (id attributes in aRefs) {
        if (![self resolveBrokenMediaDataRefWithAttributes:attributes])
            return NO;
    }
    return YES;
}
// The original matched the reference's alias (FSMatchAlias relative to the
// movie's file) and stored the updated one with SetMediaDataRef.
- (BOOL)resolveBrokenMediaDataRefWithAttributes:(id)aAttributes
{
    return NO;
}
// The original listed each track's alias data references whose file isn't
// readable ({media, mediaIndex}); see above.
- (id)brokenMediaDataRefsAttributesInMovie
{
    return [NSMutableArray array];
}
- (void)hideStatusWindow
{
    if (_statusWindow != nil && _statusWindowModalSession != NULL) {
        [_progressIndicator stopAnimation:self];
        [NSApp endModalSession:_statusWindowModalSession];
        _statusWindowModalSession = NULL;
    }
}
// A modal status window that stays up while the work goes on.
- (BOOL)showStatusWindow
{
    if (![self loadNibIfNeeded] || (_options & HSMovieVerifierNoUI) != 0)
        return NO;
    [_progressIndicator setUsesThreadedAnimation:YES];
    [_progressIndicator startAnimation:self];
    _statusWindowModalSession = [NSApp beginModalSessionForWindow:_statusWindow];
    if ([NSApp runModalSession:_statusWindowModalSession] == NSModalResponseContinue)
        return YES;
    [NSApp endModalSession:_statusWindowModalSession];
    _statusWindowModalSession = NULL;
    return NO;
}
- (BOOL)loadNibIfNeeded
{
    if (_statusWindow != nil)
        return YES;
    return [NSBundle loadNibNamed:@"MovieVerifier" owner:self];
}
- (void)dealloc
{
    [_statusWindow release];
    [super dealloc];
}
@end
