#import "HSQuickTimeMovieHelper.h"
#import "NSImage+HSImageSize.h"

// Converting and tagging movies. The original goes through QuickTime's movie
// export components ('MOV ' flattens, 'M4V ', 'M4VP' and 'M4VH' are the
// MPEG-4 exporters, the last set to H.264) and its metadata API; here
// AVFoundation does both. Errors come back as OSStatus values, a cancelled
// export as no error.

// The QuickTime movie progress proc and its messages.
typedef short (*HSMovieProgressProc)(void *aMovie, short aMessage, short aOperation, int aPercentDone, id aSender);
enum { kHSMovieProgressOpen = 0, kHSMovieProgressUpdatePercent = 1, kHSMovieProgressClose = 2 };
enum { kHSMovieProgressOperationCopying = 3 };

// Scales the video to the frame size.
static AVVideoComposition *HSQuickTimeMovieHelperVideoComposition(AVAsset *aAsset, NSSize aSize)
{
    AVAssetTrack *track = [[aAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (track == nil || aSize.width < 1 || aSize.height < 1)
        return nil;
    CGSize natural = CGSizeApplyAffineTransform([track naturalSize], [track preferredTransform]);
    natural = CGSizeMake(fabs(natural.width), fabs(natural.height));
    if (natural.width < 1 || natural.height < 1)
        return nil;
    AVMutableVideoCompositionLayerInstruction *layer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
    [layer setTransform:CGAffineTransformConcat([track preferredTransform],
                                                CGAffineTransformMakeScale(aSize.width / natural.width, aSize.height / natural.height)) atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [instruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [aAsset duration])];
    [instruction setLayerInstructions:[NSArray arrayWithObject:layer]];
    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoComposition];
    [composition setRenderSize:CGSizeMake(lround(aSize.width), lround(aSize.height))];
    CMTime frameDuration = CMTimeMake(1, 30);
    if ([track nominalFrameRate] > 0)
        frameDuration = CMTimeMakeWithSeconds(1.0 / [track nominalFrameRate], 600);
    [composition setFrameDuration:frameDuration];
    [composition setInstructions:[NSArray arrayWithObject:instruction]];
    return composition;
}

@implementation HSQuickTimeMovieHelper

+ (NSInteger)convertMovie:(id)aMovie frameSize:(NSSize)aSize ofType:(NSInteger)aType toFile:(id)aFile progressCallback:(void *)aCallback sender:(id)aSender
{
    HSMovieProgressProc progress = aCallback != (void *)-1 ? (HSMovieProgressProc)aCallback : NULL;
    NSError *error = nil;
    if (aType == 'MOV ') {
        BOOL ok = [aMovie writeToFile:aFile withAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:QTMovieFlatten] error:&error];
        return ok ? noErr : (error != nil && [error code] != 0 ? [error code] : -1);
    }
    AVAsset *asset = [[[aMovie AVAsset] copy] autorelease];
    if (asset == nil)
        return paramErr;
    BOOL isMPEG4 = aType == 'M4V ' || aType == 'M4VP' || aType == 'M4VH';
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    if (session == nil)
        return paramErr;
    NSURL *url = [NSURL fileURLWithPath:aFile];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    [session setOutputURL:url];
    [session setMetadata:[[aMovie AVAsset] metadata]];
    [session setOutputFileType:isMPEG4 ? AVFileTypeAppleM4V : AVFileTypeQuickTimeMovie];
    [session setVideoComposition:HSQuickTimeMovieHelperVideoComposition(asset, aSize)];

    void *movie = [aMovie quickTimeMovie];
    if (progress)
        progress(movie, kHSMovieProgressOpen, kHSMovieProgressOperationCopying, 0, aSender);
    __block BOOL finished = NO;
    [session exportAsynchronouslyWithCompletionHandler:^{
        finished = YES;
    }];
    BOOL cancelled = NO;
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        if (progress && !cancelled && progress(movie, kHSMovieProgressUpdatePercent, kHSMovieProgressOperationCopying, (int)lroundf([session progress] * 0x10000), aSender) != noErr) {
            [session cancelExport];
            cancelled = YES;
        }
    }
    if (progress)
        progress(movie, kHSMovieProgressClose, kHSMovieProgressOperationCopying, 0x10000, aSender);
    if (cancelled || [session status] == AVAssetExportSessionStatusCancelled) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
        return noErr;
    }
    if ([session status] != AVAssetExportSessionStatusCompleted) {
        error = [session error];
        return error != nil && [error code] != 0 ? [error code] : -1;
    }
    return noErr;
}

// Movies get the image as iTunes cover art, other files as QuickTime artwork;
// the movie file is then updated.
+ (NSInteger)addArtworkImage:(id)aImage inMovie:(id)aMovie ofType:(NSInteger)aType
{
    AVAsset *asset = [aMovie AVAsset];
    if (![asset isKindOfClass:[AVMutableMovie class]])
        return paramErr;
    NSData *data = [aImage hyperPNGRepresentation];
    if (data == nil)
        return noErr;
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    if (aType == 'MOV ') {
        [item setKeySpace:AVMetadataKeySpaceiTunes];
        [item setKey:AVMetadataiTunesMetadataKeyCoverArt];
    } else {
        [item setKeySpace:AVMetadataKeySpaceQuickTimeMetadata];
        [item setKey:AVMetadataQuickTimeMetadataKeyArtwork];
    }
    [item setDataType:(NSString *)kCMMetadataBaseDataType_PNG];
    [item setValue:data];
    NSMutableArray *metadata = [NSMutableArray arrayWithArray:[asset metadata]];
    [metadata addObject:item];
    [(AVMutableMovie *)asset setMetadata:metadata];
    [aMovie updateMovieFile];
    return noErr;
}

@end
