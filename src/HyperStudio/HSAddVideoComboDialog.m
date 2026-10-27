#import "HSAddVideoComboDialog.h"

@implementation HSAddVideoComboDialog

- (void)addYouTubeMovie:(id)aMovie
{
    _action = @selector(showYouTubeDialog:);
    [self ok:aMovie];
}

- (void)recordVideo:(id)aVideo
{
    _action = @selector(runVideoRecordingPanel:);
    [self ok:aVideo];
}

- (void)webcam:(id)aWebcam
{
    _action = @selector(addWebCamObject:);
    [self ok:aWebcam];
}

- (void)liveVideo:(id)aVideo
{
    _action = @selector(addLiveVideoObject:);
    [self ok:aVideo];
}

- (void)diskFile:(id)aFile
{
    _action = @selector(addMediaObject:);
    [self ok:aFile];
}

- (SEL)action
{
    return _action;
}

- (void)didLoadNib
{
    NSButton *buttons[] = { _firstButton, _secondButton, _addWebCamsButton, _fourthButton, _addYouTubeButton };
    for (NSUInteger i = 0; i < sizeof(buttons) / sizeof(buttons[0]); i++) {
        if ([[buttons[i] cell] respondsToSelector:@selector(setBackgroundRenderer:)])
            [(id)[buttons[i] cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    }
    [_addYouTubeButton setEnabled:[HSRestrictionsManager restrictionState:HSYouTubeDialogEnabled]];
    [_addWebCamsButton setEnabled:[HSRestrictionsManager restrictionState:HSWebCamsEnabled]];
    [_fourthButton setEnabled:[[HSSystem sharedSystem] isQTKitCapturingAvailable]];
}

- (id)nibName
{
    return @"HSAddVideoDialogWindow";
}

@end
