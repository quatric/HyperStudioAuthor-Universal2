#import "HSPublishComboDialog.h"

@implementation HSPublishComboDialog

- (id)initWithExportFormat:(int)aFormat
{
    self = [super init];
    if (self != nil) {
        _exportFormat = aFormat;
    }
    return self;
}

- (int)publishType
{
    return _publishType;
}

- (int)exportFormat
{
    return _exportFormat;
}

- (id)nibName
{
    return @"PublishDialog";
}

- (void)didLoadNib
{
    [self validateButtonDescriptionTextFields];
    [self validateButtons];
}

- (void)validateButtonDescriptionTextFields
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    if (_exportFormat == 9) {
        [_firstButtonDescriptionField setStringValue:[bundle localizedStringForKey:@"PublishComboDialogPublishToWebAsWebAppPageDescription" value:@"" table:@"Publish"]];
        [_secondButtonDescriptionField setStringValue:[bundle localizedStringForKey:@"PublishComboDialogPublishToDiskAsWebAppDescription" value:@"" table:@"Publish"]];
    } else {
        [_firstButtonDescriptionField setStringValue:[bundle localizedStringForKey:@"PublishComboDialogPublishToWebAsWebPageDescription" value:@"" table:@"Publish"]];
        [_secondButtonDescriptionField setStringValue:[bundle localizedStringForKey:@"PublishComboDialogPublishToDiskAsWebPageDescription" value:@"" table:@"Publish"]];
    }
}

- (void)validateButtons
{
    if ([[_publishToDiskButton cell] respondsToSelector:@selector(setBackgroundRenderer:)]) {
        [[_publishToDiskButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    }
    if ([[_publishToWebButton cell] respondsToSelector:@selector(setBackgroundRenderer:)]) {
        [[_publishToWebButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    }
}

- (IBAction)choosePublishTypeDisk:(id)aSender
{
    _publishType = 1;
    [self finishDialog:YES];
}

- (IBAction)choosePublishTypeWeb:(id)aSender
{
    _publishType = 5;
    [self finishDialog:YES];
}

- (IBAction)cancel:(id)aSender
{
    [self finishDialog:NO];
}

@end
