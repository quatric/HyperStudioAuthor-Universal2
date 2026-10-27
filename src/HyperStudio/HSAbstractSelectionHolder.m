#import "HSAbstractSelectionHolder.h"

@implementation HSAbstractSelectionHolder

- (void)updateSelectionWithSelectedObject:(id)aObject
{
}

- (void)makeCurrent
{
    [_documentSelectionHolder makeCurrentSelectionHost:self];
}

- (id)ownSelectedObject
{
    return nil;
}

- (id)documentSelectionHolder
{
    return _documentSelectionHolder;
}

- (void)setDocumentSelectionHolder:(id)aHolder
{
    _documentSelectionHolder = aHolder;
}

- (void)noteDidChangeSelectedObject
{
    [_documentSelectionHolder selectionHostDidChangeSelectedObject:self];
}

@end
