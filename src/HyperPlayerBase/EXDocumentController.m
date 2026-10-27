#import "EXDocumentController.h"
// A document controller that (unless multi-document) keeps one document
// open: opening or creating another first reviews the unsaved one, runs
// events until that's done, then closes it and opens the new one.
@implementation EXDocumentController
- (id)currentDocument
{
    if ([self isMultiDocument])
        return [super currentDocument];
    return [[self documents] lastObject];
}
// (The original searched the documents itself before 10.7.)
- (id)documentForURL:(id)aURL
{
    return [super documentForURL:aURL];
}
- (id)openDocumentWithContentsOfURL:(id)aURL display:(BOOL)aDisplay error:(id *)aError
{
    if (_waitingForClosingDocuments)
        return _lastCreatedDocument;
    if (![self isMultiDocument] && [[self documents] count] != 0 && !_recreate) {
        if (aError != NULL)
            *aError = nil;
        NSInvocation *invocation = [[NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]] retain];
        [invocation setTarget:self];
        [invocation setSelector:_cmd];
        [invocation setArgument:&aURL atIndex:2];
        [invocation setArgument:&aDisplay atIndex:3];
        [invocation setArgument:&aError atIndex:4];
        [invocation retainArguments];
        [self createDocumentWithInvocation:invocation];
        // The error was kept alive through the event loop (below).
        if (_lastCreatedDocument == nil && aError != NULL && *aError != nil)
            [*aError autorelease];
        return _lastCreatedDocument;
    }
    _lastCreatedDocument = [super openDocumentWithContentsOfURL:aURL display:aDisplay error:aError];
    if (_lastCreatedDocument == nil && aError != NULL && *aError != nil && _recreate)
        [*aError retain];
    return _lastCreatedDocument;
}
- (void)openDocument:(id)aDocument
{
    for (NSURL *url in [self URLsFromRunningOpenPanel]) {
        NSError *error = nil;
        [self openDocumentWithContentsOfURL:url display:YES error:&error];
        if (error != nil)
            [self presentError:error];
    }
}
- (id)makeDocumentForURL:(id)aURL withContentsOfURL:(id)aURL2 ofType:(id)aType error:(id *)aError
{
    _lastCreatedDocument = [super makeDocumentForURL:aURL withContentsOfURL:aURL2 ofType:aType error:aError];
    return _lastCreatedDocument;
}
- (id)openUntitledDocumentAndDisplay:(BOOL)aDisplay error:(id *)aError
{
    if (_waitingForClosingDocuments)
        return _lastCreatedDocument;
    if (![self isMultiDocument] && [[self documents] count] != 0 && !_recreate) {
        if (aError != NULL)
            *aError = nil;
        NSInvocation *invocation = [[NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]] retain];
        [invocation setTarget:self];
        [invocation setSelector:_cmd];
        [invocation setArgument:&aDisplay atIndex:2];
        [invocation setArgument:&aError atIndex:3];
        [invocation retainArguments];
        [self createDocumentWithInvocation:invocation];
        if (_lastCreatedDocument == nil && aError != NULL && *aError != nil)
            [*aError autorelease];
        return _lastCreatedDocument;
    }
    _lastCreatedDocument = [super openUntitledDocumentAndDisplay:aDisplay error:aError];
    // (The original retained the error outside the event loop too.)
    if (_lastCreatedDocument == nil && aError != NULL && *aError != nil && _recreate)
        [*aError retain];
    return _lastCreatedDocument;
}
// The invocation (retained) runs once the unsaved documents are reviewed.
- (void)createDocumentWithInvocation:(id)aInvocation
{
    _recreate = YES;
    _waitingForClosingDocuments = YES;
    [self reviewUnsavedDocumentsWithAlertTitle:nil cancellable:YES delegate:self
                          didReviewAllSelector:@selector(documentController:didReviewAll:contextInfo:) contextInfo:aInvocation];
    while (_recreate)
        [NSApp sendEvent:[NSApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES]];
    _recreate = NO;
}
- (void)documentController:(id)aController didReviewAll:(BOOL)aAll contextInfo:(id)aInfo
{
    _waitingForClosingDocuments = NO;
    if (aAll) {
        id document = _lastCreatedDocument;
        if ([[self documents] indexOfObjectIdenticalTo:document] != NSNotFound)
            [document close];
        [aInfo invoke];
    }
    // (The original leaked it when cancelled.)
    [aInfo autorelease];
    _recreate = NO;
}
- (BOOL)isMultiDocument
{
    return NO;
}
@end
