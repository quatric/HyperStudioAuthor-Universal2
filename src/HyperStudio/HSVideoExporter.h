#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSVideoExporter : HSExporter2 <HSQTMovieExporterDataSource, HSExporter2DataSource, HSExportCardsImages, HSExportVideoAttributes, HSArtworkImageDataSource, HSHyperCastingExporterDataSource, HSExporterDelegate, NSObject>
{
    HSExporter2 *_currentExporter;
    int _videoExportFormat;
    int _videoExportOption;
    int _videoExportDevice;
    NSSize _movieFrameSize;
    NSString *_transitionName;
    float _slideDelay;
    unsigned int _useRoundedCorners:1;
}
- (id)hyperCastingLauncherForExporter:(id)aExporter;
- (void)setCurrentTimeForMovies:(double)aMovies runOnStart:(BOOL)aStart onCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (double)timeIntervalBetweenFrames;
- (double)transitionTimeAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (BOOL)hasTransitionAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (id)transitionImageForTime:(double)aTime afterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (double)timeDelayOnArriveOnCardAtIndex:(NSUInteger)aIndex;
- (double)asyncSoundLengthOnCardAtIndex:(NSUInteger)aIndex;
- (BOOL)asyncSoundPresentOnCardAtIndex:(NSUInteger)aIndex;
- (id)soundsWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (id)moviesWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (id)artworkImageForExporter:(id)aExporter;
- (id)imageForCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter;
- (id)exportedCardIndexesForExporter:(id)aExporter onlySelected:(BOOL)aSelected;
- (NSSize)videoFrameSize;
- (void)exportDidTerminate:(id)aTerminate;
- (void)exportDidEnd:(id)aEnd;
- (void)exportWillEnd:(id)aEnd;
- (void)exportDidStart:(id)aStart;
- (void)exportWillStart:(id)aStart withSlideshowAttributes:(id)aAttributes;
- (void)exportErrorInProgress:(id)aProgress error:(id)aError;
- (void)exportProgressDidChange:(id)aChange withProgress:(double)aProgress;
- (void)terminateExport;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (void)destroyCurrentExporter;
- (id)currentExporter;
- (id)createHyperCastingExporter;
- (id)createQTMovieExporter;
- (id)progressSheetDescription;
- (BOOL)isSupportedProgressSheet;
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType;
- (id)exportRepresentation;
- (BOOL)canExportWithNarrationOption;
- (void)setUseRoundedCorners:(BOOL)aCorners;
- (BOOL)canUseRoundedCorners;
- (void)setSlideDelay:(CGFloat)aDelay;
- (CGFloat)slideDelay;
- (void)setTransitionName:(id)aName;
- (id)transitionName;
- (void)setMovieFrameSize:(NSSize)aSize;
- (NSSize)movieFrameSize;
- (void)setVideoExportDevice:(NSInteger)aDevice;
- (NSInteger)videoExportDevice;
- (void)setVideoExportOption:(NSInteger)aOption;
- (NSInteger)videoExportOption;
- (void)setVideoExportFormat:(NSInteger)aFormat;
- (NSInteger)videoExportFormat;
- (void)setDataSource:(id)aSource;
- (void)dealloc;
@end

