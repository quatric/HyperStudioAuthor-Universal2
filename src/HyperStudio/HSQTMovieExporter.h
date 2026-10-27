#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSQTMovieExporter : HSExporter2
{
    NSDictionary *_codeConfiguration;
    char **_dataHandleRef;
    QTMovie *_outputMovie;
    NSString *_tempFilePath;
    unsigned int _currentImageIndex;
    NSBezierPath *_cornersClipPath;
    NSString *_transitionName;
    float _slideDelay;
    unsigned int _canUseRoundedCorners:1;
}
+ (id)defaultCodecConfigurationForIPadMovie;
+ (id)defaultCodecConfigurationForIPhone4Movie;
+ (id)defaultCodecConfigurationForIPhoneMovie;
+ (id)defaultCodecConfigurationForIPodMovie;
+ (id)defaultCodecConfigurationForMovie;
- (void)cleanupMovieAfterExport;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (BOOL)buildMovieContent:(id)aContent inProgressRange:(double)aRange error:(id *)aError;
- (double)longestTrackDurationForMovie:(id)aMovie;
- (void)addTransitionInMovie:(id)aMovie withProgressStep:(double)aStep;
- (void)addMovies:(id)aMovies withLongestPlayTime:(double)aTime atTime:(double)aTime2 runOnStart:(BOOL)aStart inMovie:(id)aMovie withProgressStep:(double)aStep;
- (void)addBackgroundSoundWithProperties:(id)aProperties atTime:(double)aTime withDuration:(double)aDuration inMovie:(id)aMovie;
- (void)addSounds:(id)aSounds atTime:(double)aTime inMovie:(id)aMovie withProgressStep:(double)aStep backgroundSounds:(id *)aSounds2;
- (void)insertSoundTrack:(id)aTrack atTime:(double)aTime withDuration:(double)aDuration inMovie:(id)aMovie withProperties:(id)aProperties;
- (void)addImageWithDuration:(struct HyperStudio_anon7)aDuration inMovie:(id)aMovie withProgressStep:(double)aStep;
- (id)HSQTMovieExporter_slideShowAttributes;
- (id)transitionImageForTime:(double)aTime afterCardAtIndex:(NSUInteger)aIndex applyMovieFrameSize:(BOOL)aSize;
- (id)imageAtIndex:(NSUInteger)aIndex applyMovieFrameSize:(BOOL)aSize;
- (id)HS_drawMovieImageWithImage:(id)aImage applyMovieFrameSize:(BOOL)aSize;
- (double)transitionTimeAfterImageAtIndex:(NSInteger)aIndex;
- (double)longestPlayTimeOfMedia:(id)aMedia;
- (id)allTracksOfTypes:(unsigned int *)aTypes count:(NSUInteger)aCount forMovie:(id)aMovie;
- (id)allProportiesFromDictionaries:(id)aDictionaries forKey:(id)aKey;
- (id)mediasFromDictionaries:(id)aDictionaries runOnStart:(BOOL)aStart;
- (id)createQTKitMovieWithError:(id *)aError;
- (struct MovieType **)createQuickTimeMovie:(char ***)aMovie;
- (id)cornersClipPathForFrameRect:(NSRect)aRect;
- (id)addImageCodecConfiguration;
- (void)setUseRoundedCorners:(BOOL)aCorners;
- (BOOL)canUseRoundedCorners;
- (void)setSlideDelay:(CGFloat)aDelay;
- (CGFloat)slideDelay;
- (void)setTransitionName:(id)aName;
- (id)transitionName;
- (void)setMovieFrameSize:(NSSize)aSize;
- (NSSize)movieFrameSize;
- (CGFloat)exportFPS;
- (void)setCodecConfiguration:(id)aConfiguration;
- (id)codecConfiguration;
- (void)setDataSource:(id)aSource;
- (void)dealloc;
@end

