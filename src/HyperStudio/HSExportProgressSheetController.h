#import "HyperStudioPrefix.h"


@interface HSExportProgressSheetController : NSObject
{
    id _delegate;
    NSWindow *_progressWindow;
    NSProgressIndicator *_progressIndicator;
    NSButton *_exportCancelButton;
    BOOL _isOpened;
    struct _NSModalSession *_session;
    NSTextField *_descriptionField;
    NSString *_description;
    BOOL _isProgressIndicatorIndeterminate;
}
- (void)adjustWindowWidth;
- (void)validateControls;
- (id)progressWindow;
- (void)cancelExport:(id)aExport;
- (void)endSheetWithErrorSheet:(id)aSheet modalForWindow:(id)aWindow;
- (void)endSheet;
- (void)beginSheetForWindow:(id)aWindow;
- (void)setProgressIndicatorIndeterminate:(BOOL)aIndeterminate;
- (BOOL)isProgressIndicatorIndeterminate;
- (void)setProgress:(double)aProgress;
- (void)incrementProgressBy:(double)aBy;
- (double)progress;
- (id)description;
- (void)setDescription:(id)aDescription;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (void)awakeFromNib;
@end

