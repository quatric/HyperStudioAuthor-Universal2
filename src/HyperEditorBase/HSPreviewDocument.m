#import "HSPreviewDocument.h"

// A player document showing an editor document's stack (or a copy of it,
// for export), named after it.

@implementation HSPreviewDocument

- (void)closePlayer
{
    [self close];
}

- (id)initWithOriginal:(id)aOriginal
{
    if ((self = [super init])) {
        [self setStack:[aOriginal stack]];
        _originalDocument = aOriginal;
    }
    return self;
}

- (id)initForExportWithDocument:(id)aDocument
{
    if ((self = [super init])) {
        [self readFromFileWrapper:[aDocument hyperFileWrapperOfType:@"HSDocumentWithoutResourcesType" error:NULL] ofType:@"HSAiBADocumentType" error:NULL];
        _originalDocument = aDocument;
    }
    return self;
}

- (id)init
{
    return [self initWithOriginal:nil];
}

- (id)fileName
{
    id name = [super fileName];
    return name != nil ? name : [_originalDocument fileName];
}

- (id)fileURL
{
    id url = [super fileURL];
    return url != nil ? url : [_originalDocument fileURL];
}

- (id)displayName
{
    if ([super fileName] == nil)
        return [_originalDocument displayName];
    return [super displayName];
}

- (void)invalidateOriginal:(id)aOriginal
{
    _originalDocument = nil;
    [self close];
}

- (id)modeSwitcher
{
    return [(id)_originalDocument modeSwitcher];
}

@end
