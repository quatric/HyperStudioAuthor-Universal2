#import "HyperPlayerBasePrefix.h"


@interface HSiPadExporter : NSObject
{
    HSUID *_mediaXMLElementUID;
    HSiPadExportContext *_context;
}
- (BOOL)containsDocument:(id)aDocument iPadUnsupportedActions:(id *)aActions;
- (BOOL)containsDocument:(id)aDocument iPadUnsupportedFeatures:(id *)aFeatures;
- (BOOL)isStackHasMoreThanThreePlayMovieActionsPerCardInDocument:(id)aDocument;
- (BOOL)documentCanBeExported:(id)aExported showAlertIfNeeded:(BOOL)aNeeded;
- (void)scaleCardsDownIfNeededForDocument:(id)aDocument;
- (BOOL)cardsShouldBeScaledDownBeforeExportDocument:(id)aDocument toSize:(NSSize *)aSize;
- (id)mediaXMLElementUID;
- (id)previewFileWrapperForDocument:(id)aDocument;
- (void)terminateExport;
- (id)fileWrapperForDocument:(id)aDocument;
- (id)contentsWrapperForDocument:(id)aDocument withResFolder:(id)aFolder;
- (id)resourcesWrappersWithContext:(id)aContext withResFolder:(id)aFolder;
- (id)infoPlistWrapper;
- (id)documentWrapperWithContext:(id)aContext;
- (id)cardWrappersWithContext:(id)aContext;
- (BOOL)doesDocumentContainActionsThatCannotBeRun:(id)aRun;
- (id)actionsInDocumentThatCannotBeRun:(id)aRun forObjects:(id *)aObjects;
- (BOOL)canRunAction:(id)aAction;
- (BOOL)shouldVerifyDocumentActions;
- (void)dealloc;
@end

