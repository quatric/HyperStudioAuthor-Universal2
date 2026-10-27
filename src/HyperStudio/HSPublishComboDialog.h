#import "HyperStudioPrefix.h"


@interface HSPublishComboDialog : HSGenericModalController
{
    int _publishType;
    int _exportFormat;
    NSTextField *_firstButtonDescriptionField;
    NSTextField *_secondButtonDescriptionField;
    NSButton *_publishToDiskButton;
    NSButton *_publishToWebButton;
}
- (id)initWithExportFormat:(int)aFormat;
- (int)publishType;
- (int)exportFormat;
- (id)nibName;
- (void)didLoadNib;
- (void)validateButtons;
- (void)validateButtonDescriptionTextFields;
- (IBAction)choosePublishTypeDisk:(id)aSender;
- (IBAction)choosePublishTypeWeb:(id)aSender;
- (IBAction)cancel:(id)aSender;
@end
