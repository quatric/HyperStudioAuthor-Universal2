#import "HyperPlayerBasePrefix.h"


@interface HSAHTML5ExportCompatibilityChecker : NSObject
{
    NSMutableSet *_unsupportedDescriptions;
    unsigned int _existsUnsupportedObjects:1;
    unsigned int _shouldCheckCompatibility:1;
    NSURL *_verifiableDocumentURL;
    NSMutableArray *_undecidedActions;
}
- (void)dealloc;
- (BOOL)canBeExportedActionObject:(id)aObject;
- (BOOL)shouldOmitChecking;
- (id)unsupportedDescriptionForObject:(id)aObject;
- (BOOL)shouldPostponeActionValidation:(id)aAction;
- (void)setVerifiableDocumentURL:(id)aURL;
- (BOOL)canBeExportObject:(id)aObject;
- (id)unsupportedDescriptions;
- (id)undecidedActions;
- (void)addUnsupportedObjectIfNeeded:(id)aObject;
- (NSInteger)runUserConfirmationAlert;
- (void)submitRequestWithString:(id)aString;
- (BOOL)shouldImportDocumentWithError:(NSError **)aError;
- (BOOL)shouldImportDocument;
- (BOOL)existsUnsupportedObjects;
@end
