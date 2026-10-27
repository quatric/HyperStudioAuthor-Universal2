#import "HSForceOpenedHelpPane.h"

@implementation HSForceOpenedHelpPane

- (void)setShouldHideAssistantOnGoBack:(BOOL)aBack
{
    _shouldHideAssistantOnGoBack = aBack;
}

- (BOOL)shouldHideAssistantOnGoBack
{
    return _shouldHideAssistantOnGoBack;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide
{
    if (!_shouldHideAssistantOnGoBack)
        [super dismiss:aDismiss slide:aSlide];
    else
        [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
}

// The pane takes itself out of the history when it goes away.
- (void)viewWillDisappear:(BOOL)aDisappear
{
    NSMutableArray *history;

    [super viewWillDisappear:aDisappear];
    history = [[[[self assistant] paneHistory] mutableCopy] autorelease];
    if ([history lastObject] == self) {
        [history removeLastObject];
        [[self assistant] setPaneHistory:history];
    }
}

- (BOOL)needsToBeSavedInHistory
{
    return YES;
}

@end
