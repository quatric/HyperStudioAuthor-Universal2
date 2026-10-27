#import "HyperStudioPrefix.h"
#import "HSHTML5Exporter.h"


@interface HSiBooksAuthorExporter : HSHTML5Exporter
{
}
- (void)finalizeExportForDocument:(id)aDocument;
- (void)removeNeedlessResources;
- (id)stackPreviewForDocument:(id)aDocument;
- (id)infoPlistDataForDocument:(id)aDocument;
- (id)progressSheetDescription;
- (id)exportedDocumentName;
@end

