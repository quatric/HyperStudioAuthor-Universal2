#import "HSPublisher.h"

@implementation HSPublisher

- (void)notifyPublishDidTerminate
{
    if ([[self delegate] respondsToSelector:@selector(publishDidTerminate:)])
        [[self delegate] publishDidTerminate:self];
}

- (void)notifyPublishDidEnd
{
    if ([[self delegate] respondsToSelector:@selector(publishDidEnd:)])
        [[self delegate] publishDidEnd:self];
}

- (void)notifyPublishWillEnd
{
    if ([[self delegate] respondsToSelector:@selector(publishWillEnd:)])
        [[self delegate] publishWillEnd:self];
}

- (void)notifyPublishDidStart
{
    if ([[self delegate] respondsToSelector:@selector(publishDidStart:)])
        [[self delegate] publishDidStart:self];
}

- (void)notifyPublishWillStart
{
    if ([[self delegate] respondsToSelector:@selector(publishWillStart:)])
        [[self delegate] publishWillStart:self];
}

- (void)notifyPublishAlertInProgress:(id)aProgress
{
    if ([[self delegate] respondsToSelector:@selector(publishAlertInProgress:invokeOptions:)])
        [[self delegate] publishAlertInProgress:self invokeOptions:aProgress];
}

- (void)notifyPublishErrorInProgress:(id)aProgress
{
    if ([[self delegate] respondsToSelector:@selector(publishErrorInProgress:error:)])
        [[self delegate] publishErrorInProgress:self error:aProgress];
}

- (void)notifyPublishProgressDidChangeWithProgress:(double)aProgress
{
    if ([[self delegate] respondsToSelector:@selector(publishProgressDidChange:withProgress:)])
        [[self delegate] publishProgressDidChange:self withProgress:aProgress];
}

- (void)terminatePublish
{
    _shouldTerminatePublish = YES;
}

- (void)publish:(id)aPublish
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate)
        _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)progressSheetDescription
{
    return nil;
}

- (id)exportPanelController
{
    if (!_exportPanelController)
        _exportPanelController = [[HSDesktopExportPanelController alloc] initWithPublisher:self];
    return _exportPanelController;
}

- (void)setPublishLocation:(id)aLocation
{
    if (_publishLocation != aLocation) {
        [_publishLocation release];
        _publishLocation = [aLocation retain];
    }
}

- (id)publishLocation
{
    return _publishLocation;
}

- (void)dealloc
{
    [_publishLocation release];
    [_exportPanelController release];
    [super dealloc];
}

@end
