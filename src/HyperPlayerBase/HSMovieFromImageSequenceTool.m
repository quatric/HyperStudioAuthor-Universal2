#import "HSMovieFromImageSequenceTool.h"
#import "NSString+EXMacTypes.h"

// Builds a movie from an image sequence: each image becomes one TIFF frame,
// lasting either the time from the time sequence or the default frame length
// (in 1/600 s units). The movie is written to a temporary file, unless the
// delegate supplies its own storage.

@interface NSObject (HSMovieFromImageSequenceToolDelegate)
- (struct MovieType **)movieFromImageSequenceTool:(HSMovieFromImageSequenceTool *)aTool newTempMovieAndHandle:(struct ComponentInstanceRecord **)aHandle error:(short *)aError;
- (NSData *)movieFromImageSequenceTool:(HSMovieFromImageSequenceTool *)aTool movieDataForMovie:(QTMovie *)aMovie;
@end

@implementation HSMovieFromImageSequenceTool

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)createMovieFromSequence
{
    short error = -1;
    // QuickTime movies are QTMovies in HSQTKit, and wrapping one returns
    // that same movie, retained.
    QTMovie *tempMovie = (QTMovie *)[self newTempMovieAndHandle:&_dataHandlerRef error:&error];
    if (tempMovie == nil)
        return;
    QTMovie *movie = [QTMovie movieWithQuickTimeMovie:tempMovie disposeWhenDone:YES error:NULL];
    [tempMovie release];
    // Fix: the original stored the autoreleased movie before checking the
    // error and retained it only on success, leaving a dangling ivar.
    if (movie == nil || error != 0)
        return;
    [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
    _movie = [movie retain];
    if (_imageSequence == nil)
        return;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"tiff", QTAddImageCodecType,
                                [NSNumber numberWithLong:codecHighQuality], QTAddImageCodecQuality,
                                nil];
    if (attributes == nil)
        return;
    for (NSUInteger i = 0; i < [_imageSequence count]; i++)
        [_movie addImage:[_imageSequence objectAtIndex:i] forDuration:QTMakeTime([self timeValueForFrame:i], 600) withAttributes:attributes];
}

- (long long)timeValueForFrame:(NSUInteger)aFrame
{
    long long value = [self frameLength];
    if (_timeSequence != nil && aFrame < [_timeSequence count]) {
        id time = [_timeSequence objectAtIndex:aFrame];
        if (time != nil)
            value = [time longLongValue];
    }
    return value;
}

// Returns a +1 movie. The original created a QuickTime movie file at a
// tmpnam() path through CreateMovieStorage; here it is a writable QTMovie on
// a unique temporary .mov file (AVFoundation picks the format from the
// extension) and there is no data handler to hand back.
- (struct MovieType **)newTempMovieAndHandle:(struct ComponentInstanceRecord **)aHandle error:(short *)aError
{
    *aError = -1;
    if ([_delegate respondsToSelector:@selector(movieFromImageSequenceTool:newTempMovieAndHandle:error:)])
        return [_delegate movieFromImageSequenceTool:self newTempMovieAndHandle:aHandle error:aError];
    NSString *path = [NSString extraCreateUniqueFilename:[NSTemporaryDirectory() stringByAppendingPathComponent:@"HSImageSequenceMovie"] extension:@"mov"];
    if (path == nil)
        return NULL;
    QTMovie *movie = [[QTMovie alloc] initToWritableFile:path error:NULL];
    if (movie == nil) {
        *aError = -2010;
        return NULL;
    }
    *aHandle = NULL;
    *aError = 0;
    return (struct MovieType **)movie;
}

- (id)movieData
{
    NSData *data = _data;
    if (_imageSequence != nil && data == nil) {
        [self createMovieFromSequence];
        if ([_delegate respondsToSelector:@selector(movieFromImageSequenceTool:movieDataForMovie:)])
            data = [_delegate movieFromImageSequenceTool:self movieDataForMovie:_movie];
        else
            // FlattenMovieDataToDataRef into a handle in the original.
            data = [_movie movieFormatRepresentation];
        [self setData:data];
    }
    return data;
}

- (void)setData:(id)aData
{
    if (_data != aData) {
        [_data release];
        _data = [aData retain];
    }
}

- (id)data
{
    return _data;
}

- (void)setFrameLength:(long long)aLength
{
    _frameLength = aLength;
}

- (long long)frameLength
{
    return _frameLength;
}

- (void)setTimeSequence:(id)aSequence
{
    if (_timeSequence != aSequence) {
        [self setData:nil];
        [self setMovie:nil];
        [_timeSequence release];
        _timeSequence = [aSequence retain];
    }
}

- (id)timeSequence
{
    return _timeSequence;
}

- (void)setImageSequence:(id)aSequence
{
    if (_imageSequence != aSequence) {
        [self setData:nil];
        [self setMovie:nil];
        [_imageSequence release];
        _imageSequence = [aSequence retain];
    }
}

- (id)imageSequence
{
    return _imageSequence;
}

- (void)setMovie:(id)aMovie
{
    if (_movie != aMovie) {
        [_movie release];
        _movie = [aMovie retain];
    }
}

- (id)movie
{
    if (_imageSequence != nil && _movie == nil)
        [self createMovieFromSequence];
    return _movie;
}

- (void)dealloc
{
    [_imageSequence release];
    [_timeSequence release];
    [_movie release];
    // CloseMovieStorage(_dataHandlerRef) in the original; HSQTKit movies
    // have no data handler.
    [_data release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
        _frameLength = 30;
    return self;
}

@end

@implementation HSMovie (HSMovieFromImageSequence)

+ (id)movieWithImageSequence:(id)aSequence timeSequence:(id)aSequence2 error:(id *)aError
{
    return [self movieWithImageSequence:aSequence timeSequence:aSequence2 frameLength:30 error:aError];
}

+ (id)movieWithImageSequence:(id)aSequence frameLength:(long long)aLength error:(id *)aError
{
    return [self movieWithImageSequence:aSequence timeSequence:nil frameLength:aLength error:aError];
}

+ (id)movieWithImageSequence:(id)aSequence timeSequence:(id)aSequence2 frameLength:(long long)aLength error:(id *)aError
{
    HSMovieFromImageSequenceTool *tool = [HSMovieFromImageSequenceTool new];
    [tool setTimeSequence:aSequence2];
    [tool setImageSequence:aSequence];
    [tool setFrameLength:aLength];
    [[tool movie] updateMovieFile];
    // Original quirk kept: the movie opens from the temporary file without
    // passing the error pointer along.
    HSMovie *movie = [[[HSMovie alloc] initWithURL:[[[tool movie] movieAttributes] objectForKey:QTMovieURLAttribute] error:NULL] autorelease];
    [tool release];
    return movie;
}

@end
