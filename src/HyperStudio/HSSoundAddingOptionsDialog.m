#import "HSSoundAddingOptionsDialog.h"

@implementation HSSoundAddingOptionsDialog

- (id)selectedActionEvent
{
    NSString *type;

    switch ([_soundAddingOptionsMatrix selectedTag]) {
    case 2:
        type = kHSLeaveActionEventType;
        break;
    case 0:
        type = kHSClickActionEventType;
        break;
    default:
        type = kHSArriveActionEventType;
        break;
    }
    return [HSActionEvent actionEventOfType:type];
}

- (void)addingOptionsMatrixChanged:(id)aChanged
{
}

- (void)cancel:(id)aCancel
{
    [self closeDialogWithCode:0];
}

- (void)ok:(id)aOk
{
    [self closeDialogWithCode:1];
}

- (void)closeDialogWithCode:(NSInteger)aCode
{
    if ([NSApp modalWindow] == [self window]) {
        [[self window] close];
        [NSApp stopModalWithCode:aCode];
    }
}

- (id)windowNibName
{
    return @"SoundAddingOptionsDialog";
}

@end
