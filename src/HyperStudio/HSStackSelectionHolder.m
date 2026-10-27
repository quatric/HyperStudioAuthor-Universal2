#import "HSStackSelectionHolder.h"

@implementation HSStackSelectionHolder

- (void)documentDidChangeCurrentStack:(id)aStack
{
    [self noteDidChangeSelectedObject];
}

- (id)ownSelectedObject
{
    return [_document stack];
}

- (void)setDocument:(id)aDocument
{
    if (_document == aDocument)
        return;
    if (_document != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentDidChangeCurrentStack object:_document];
    _document = aDocument;
    if (aDocument != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidChangeCurrentStack:) name:HSDocumentDidChangeCurrentStack object:_document];
    [self noteDidChangeSelectedObject];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
