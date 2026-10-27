#import "HSAddSoundComboDialog.h"

@implementation HSAddSoundComboDialog

- (void)recordSound:(id)aSound
{
    _action = @selector(runSoundRecordingPanel:);
    [self ok:aSound];
}

- (void)diskFile:(id)aFile
{
    _action = @selector(addSoundObject:);
    [self ok:aFile];
}

- (SEL)action
{
    return _action;
}

- (void)didLoadNib
{
    if ([[_firstButton cell] respondsToSelector:@selector(setBackgroundRenderer:)])
        [(SMKBackgroundPopUpButtonCell *)[_firstButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    if ([[_secondButton cell] respondsToSelector:@selector(setBackgroundRenderer:)])
        [(SMKBackgroundPopUpButtonCell *)[_secondButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [_secondButton setEnabled:[[HSSystem sharedSystem] isQTKitCapturingAvailable]];
}

- (id)nibName
{
    return @"HSAddSoundDialogWindow";
}

@end
