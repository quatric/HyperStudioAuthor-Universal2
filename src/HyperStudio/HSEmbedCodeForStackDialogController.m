#import "HSEmbedCodeForStackDialogController.h"

@implementation HSEmbedCodeForStackDialogController

// Copies the HTML embed code for the stack to the pasteboard.
- (void)applyChanges
{
    id code = [HSHTML5Exporter embeddedCodeForDocument:_currentDocument cardWidth:[_cardWidthField floatValue] cardHeight:[_cardHeightField floatValue] urlPath:[_stackURLField stringValue]];

    if (code != nil) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *string = [[NSString alloc] initWithData:[code data] encoding:NSUTF8StringEncoding];

        if ([string length] != 0) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
            [pasteboard setString:string forType:NSStringPboardType];
        }
        [string release];
        [pool release];
    }
}

- (BOOL)control:(id)aControl isValidObject:(id)aObject
{
    if (_cardWidthField == aControl || _cardHeightField == aControl) {
        if (_cardWidthField == aControl)
            _isCardWidthValid = 1;
        else
            _isCardHeightValid = 1;
        [_defaultButton setEnabled:_isCardWidthValid && _isCardHeightValid];
    }
    return YES;
}

- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription
{
    if (_cardWidthField == aControl || _cardHeightField == aControl) {
        if (_cardWidthField == aControl)
            _isCardWidthValid = 0;
        else
            _isCardHeightValid = 0;
        [_defaultButton setEnabled:NO];
    }
    return NO;
}

- (void)controlTextDidChange:(id)aChange
{
    id field = [aChange object];
    id editor;
    id value = nil;
    NSString *string;

    if ((field != _cardWidthField && field != _cardHeightField) || (editor = [field currentEditor]) == nil)
        return;
    string = [editor string];
    if ([string length] != 0)
        [[field formatter] getObjectValue:&value forString:string errorDescription:NULL];
    if (field == _cardWidthField)
        _isCardWidthValid = value != nil;
    else
        _isCardHeightValid = value != nil;
    [_defaultButton setEnabled:_isCardWidthValid && _isCardHeightValid];
}

- (void)didLoadNib
{
    NSSize size;

    [super didLoadNib];
    _currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    if (_currentDocument != nil)
        size = [[_currentDocument stack] hyperCardSize];
    else
        size = [HSUserObjectDefaultAttributesProvider defaultCardSize];
    [_cardWidthField setFloatValue:size.width];
    [_cardHeightField setFloatValue:size.height];
    _isCardWidthValid = [_cardWidthField floatValue] > 0.0f;
    _isCardHeightValid = [_cardHeightField floatValue] > 0.0f;
    [_defaultButton setEnabled:_isCardWidthValid && _isCardHeightValid];
}

- (id)nibName
{
    return @"EmbedCodeForStack";
}

@end
