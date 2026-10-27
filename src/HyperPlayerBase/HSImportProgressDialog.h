#import "HyperPlayerBasePrefix.h"


@interface HSImportProgressDialog : NSWindowController
{
    NSString *_title;
    NSProgressIndicator *_progressBar;
    NSTextField *_taskDescription;
    HSOldFormatDocument *_importer;
    struct _NSModalSession *_session;
}
- (void)cancelImport:(id)aImport;
- (id)importer;
- (void)setImporter:(id)aImporter;
- (void)stopModalSession:(struct _NSModalSession *)aSession;
- (struct _NSModalSession *)runModalSession;
- (void)setValue:(double)aValue;
- (void)finishCurrentOperation;
- (void)startOperationName:(id)aName minValue:(double)aValue maxValue:(double)aValue2;
- (void)windowDidLoad;
- (id)initWithTitle:(id)aTitle;
- (void)dealloc;
@end

