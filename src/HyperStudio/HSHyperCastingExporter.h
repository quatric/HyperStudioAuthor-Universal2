#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSHyperCastingExporter : HSExporter2
{
    NSString *_documentType;
    id<HSHyperCastingLauncher> _hyperCastingLauncher;
    int _recordedMovieFormat;
    NSSize _movieFrameSize;
    unsigned int _canUseRoundedCorners:1;
}
- (void)notifyExportDidTerminate;
- (void)notifyExportDidEnd;
- (void)didConfirmHyperCastingWindowController:(id)aController;
- (void)didCancelHyperCastingWindowController:(id)aController;
- (void)terminateExport;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (void)setUseRoundedCorners:(BOOL)aCorners;
- (BOOL)canUseRoundedCorners;
- (void)setMovieFrameSize:(NSSize)aSize;
- (NSSize)movieFrameSize;
- (void)setRecordedMovieFormat:(NSInteger)aFormat;
- (NSInteger)recordedMovieFormat;
- (void)setHyperCastingLauncher:(id)aLauncher;
- (id)hyperCastingLauncher;
- (BOOL)isSupportedProgressSheet;
- (void)setDataSource:(id)aSource;
- (void)dealloc;
@end

