#import "HyperStudioPrefix.h"


@interface HSSoundAddingOptionsDialog : NSWindowController
{
    NSMatrix *_soundAddingOptionsMatrix;
}
- (id)selectedActionEvent;
- (void)addingOptionsMatrixChanged:(id)aChanged;
- (void)cancel:(id)aCancel;
- (void)ok:(id)aOk;
- (void)closeDialogWithCode:(NSInteger)aCode;
- (id)windowNibName;
@end

