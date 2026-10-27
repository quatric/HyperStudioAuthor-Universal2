#import "HyperPlayerBasePrefix.h"


@interface EXDocumentController : NSDocumentController
{
    id _lastCreatedDocument;
    BOOL _recreate;
    BOOL _waitingForClosingDocuments;
}
- (id)currentDocument;
- (id)documentForURL:(id)aURL;
- (id)openDocumentWithContentsOfURL:(id)aURL display:(BOOL)aDisplay error:(id *)aError;
- (void)openDocument:(id)aDocument;
- (id)makeDocumentForURL:(id)aURL withContentsOfURL:(id)aURL2 ofType:(id)aType error:(id *)aError;
- (id)openUntitledDocumentAndDisplay:(BOOL)aDisplay error:(id *)aError;
- (void)createDocumentWithInvocation:(id)aInvocation;
- (void)documentController:(id)aController didReviewAll:(BOOL)aAll contextInfo:(id)aInfo;
- (BOOL)isMultiDocument;
@end

