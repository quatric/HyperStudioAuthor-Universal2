#import "HSEditObjectDialogContext.h"

@implementation HSEditObjectDialogContext

- (id)document
{
    return _document;
}

- (id)stack
{
    return [_document stack];
}

- (id)card
{
    return [_document currentCard];
}

- (id)initWithEditorDocument:(id)aDocument
{
    self = [super init];
    if (self != nil)
        _document = aDocument;
    return self;
}

@end
