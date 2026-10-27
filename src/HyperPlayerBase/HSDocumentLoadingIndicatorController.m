#import "HSDocumentLoadingIndicatorController.h"

@implementation HSDocumentLoadingIndicatorController

- (id)init
{
    self = [super init];
    if (self) {
        [self window];
    }
    return self;
}

- (void)dealloc
{
    if (_session != NULL) {
        [NSApp endModalSession:_session];
    }
    [_window close];
    [super dealloc];
}

- (id)window
{
    if (_window == nil) {
        [NSBundle loadNibNamed:@"DocumentLoading" owner:self];
        if (_window != nil) {
            [self windowDidLoad];
        }
    }
    return _window;
}

- (void)windowDidLoad
{
    [_loadingIndicator setMinValue:0.0];
    [_loadingIndicator setMaxValue:100.0];
    [_loadingIndicator setDoubleValue:0.0];
}

- (void)makeProgressBarIndeterminated:(BOOL)aFlag
{
    if (aFlag) {
        [_loadingIndicator setIndeterminate:YES];
        [_loadingIndicator startAnimation:nil];
    } else {
        [_loadingIndicator stopAnimation:nil];
        [_loadingIndicator setIndeterminate:NO];
    }
}

- (void)setTotalProgressCount:(unsigned int)aCount
{
    _progressDelta = [_loadingIndicator maxValue] / (double)aCount;
    [self makeProgressBarIndeterminated:NO];
    if (_session != NULL) {
        [NSApp runModalSession:_session];
    }
}

- (void)showWindow
{
    _session = [NSApp beginModalSessionForWindow:[self window]];
    [self makeProgressBarIndeterminated:YES];
    [NSApp runModalSession:_session];
}

- (void)cancel:(id)aSender
{
    if (_session != NULL) {
        [NSApp stopModal];
    }
}

- (void)close
{
    if (_session != NULL) {
        [NSApp endModalSession:_session];
        _session = NULL;
    }
    [_window orderOut:nil];
}

- (BOOL)makeProgress
{
    [_loadingIndicator incrementBy:_progressDelta];
    if (_session != NULL) {
        return [NSApp runModalSession:_session] == -1002;
    }
    return NO;
}

@end
