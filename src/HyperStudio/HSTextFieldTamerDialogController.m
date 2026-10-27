#import "HSTextFieldTamerDialogController.h"

@implementation HSTextFieldTamerDialogController

// Applies the read/write choice to the text fields of this card or the whole stack.
- (void)applyChanges
{
    [[HSEditorController sharedDocumentController] setLastTextFieldTamerReadOnly:[_switchReadWrite selectedTag] == 0];
    [[HSEditorController sharedDocumentController] setLastTextFieldTamerThisCard:[_switchStackCard selectedTag] == 0];
    NSEnumerator *enumerator;
    if ([_switchStackCard selectedTag] == 0)
        enumerator = [[self card] hyperEnumerator];
    else
        enumerator = [[self stack] hyperDeepEnumerator];
    BOOL editable = (BOOL)[_switchReadWrite selectedTag];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        BOOL isTextView = [object implementsHyperInterface:@protocol(HSSystemTextViewAttributes)];
        if (isTextView && [[object queryHyperInterface:@protocol(HSSystemTextViewAttributes)] isRotatableText])
            isTextView = NO;
        if (!isTextView && ![object implementsHyperInterface:@protocol(HSSystemTextFieldAttributes)])
            continue;
        if ([object isEditable] != editable)
            [object setEditable:editable];
        if ([object isSelectable] != editable)
            [object setSelectable:editable];
    }
}

- (void)willShowWindow
{
    [_switchReadWrite selectCellWithTag:![[HSEditorController sharedDocumentController] lastTextFieldTamerReadyOnly]];
    [_switchStackCard selectCellWithTag:![[HSEditorController sharedDocumentController] lastTextFieldTamerThisCard]];
}

- (id)nibName
{
    return @"TextFieldTamer";
}

@end
