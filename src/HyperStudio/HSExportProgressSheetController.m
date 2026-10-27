#import "HSExportProgressSheetController.h"

@implementation HSExportProgressSheetController

- (void)adjustWindowWidth
{
    NSSize cellSize = [[_descriptionField cell] cellSize];
    NSRect fieldFrame = [_descriptionField frame];
    NSRect windowFrame = [_progressWindow frame];
    windowFrame.size.width = (cellSize.width - fieldFrame.size.width) + windowFrame.size.width;
    NSSize minSize = [_progressWindow minSize];
    if (windowFrame.size.width < minSize.width)
        windowFrame.size.width = minSize.width;
    [_progressWindow setFrame:windowFrame display:NO];
}

- (void)validateControls
{
    if (_description)
        [_descriptionField setStringValue:_description];
    [_descriptionField displayIfNeeded];
    [_progressIndicator setIndeterminate:_isProgressIndicatorIndeterminate];
    [_progressIndicator setUsesThreadedAnimation:_isProgressIndicatorIndeterminate];
    [_progressIndicator displayIfNeeded];
}

- (id)progressWindow
{
    if (!_progressWindow)
        [NSBundle loadNibNamed:@"ExportProgressSheet" owner:self];
    return _progressWindow;
}

- (void)cancelExport:(id)aExport
{
    if ([_delegate respondsToSelector:@selector(cancelExport:)])
        [_delegate cancelExport:self];
    [[self progressWindow] makeFirstResponder:nil];
    [_exportCancelButton setEnabled:NO];
}

- (void)endSheetWithErrorSheet:(id)aSheet modalForWindow:(id)aWindow
{
    if (_isOpened) {
        [_progressIndicator stopAnimation:nil];
        [self endSheet];
        if (aSheet)
            [[HSErrorManager sharedErrorManager] presentError:aSheet inWindow:aWindow];
    }
}

- (void)endSheet
{
    if (_isOpened) {
        [_progressIndicator stopAnimation:nil];
        [NSApp endSheet:[self progressWindow]];
        [[self progressWindow] orderOut:self];
        _isOpened = NO;
    }
}

- (void)beginSheetForWindow:(id)aWindow
{
    [self progressWindow];
    [_exportCancelButton setEnabled:YES];
    [self setProgressIndicatorIndeterminate:YES];
    [self validateControls];
    [self adjustWindowWidth];
    [_progressIndicator startAnimation:nil];
    if (!_isOpened) {
        _isOpened = YES;
        [NSApp beginSheet:[self progressWindow] modalForWindow:aWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    }
}

- (void)setProgressIndicatorIndeterminate:(BOOL)aIndeterminate
{
    _isProgressIndicatorIndeterminate = aIndeterminate;
}

- (BOOL)isProgressIndicatorIndeterminate
{
    return _isProgressIndicatorIndeterminate;
}

// Switches to a determinate bar, snaps to full when the end is reached from
// below, and runs one event so the sheet redraws and the Cancel button works.
- (void)setProgress:(double)aProgress
{
    if ([self isProgressIndicatorIndeterminate]) {
        [self setProgressIndicatorIndeterminate:NO];
        [self validateControls];
    }
    double previous = [_progressIndicator doubleValue];
    double previousMaximum = [_progressIndicator maxValue];
    [_progressIndicator setDoubleValue:aProgress];
    double maximum = [_progressIndicator maxValue];
    double value = [_progressIndicator doubleValue];
    double magnitude = value != 0 ? fabs(value) : 1.0;
    double maximumMagnitude = maximum != 0 ? fabs(maximum) : 1.0;
    if (maximumMagnitude <= magnitude)
        maximumMagnitude = magnitude;
    if (fabs(value - maximum) <= maximumMagnitude * 1e-05 && previous < previousMaximum) {
        [_progressIndicator setDoubleValue:0];
        [_progressIndicator setDoubleValue:[_progressIndicator maxValue]];
    }
    NSEvent *event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
    [NSApp sendEvent:event];
}

- (void)incrementProgressBy:(double)aBy
{
    [self setProgress:[self progress] + aBy];
}

- (double)progress
{
    return [_progressIndicator doubleValue];
}

- (id)description
{
    return _description;
}

- (void)setDescription:(id)aDescription
{
    if (![_description isEqualToString:aDescription]) {
        [_description release];
        _description = [aDescription retain];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    _delegate = nil;
    [_description release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self validateControls];
}

@end
