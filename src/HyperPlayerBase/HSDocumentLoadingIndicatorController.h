#import "HyperPlayerBasePrefix.h"


@interface HSDocumentLoadingIndicatorController : NSObject
{
    NSProgressIndicator *_loadingIndicator;
    NSWindow *_window;
    double _progressDelta;
    NSModalSession _session;
}
- (id)init;
- (void)dealloc;
- (id)window;
- (void)windowDidLoad;
- (void)makeProgressBarIndeterminated:(BOOL)aFlag;
- (void)setTotalProgressCount:(unsigned int)aCount;
- (void)showWindow;
- (void)cancel:(id)aSender;
- (void)close;
- (BOOL)makeProgress;
@end
