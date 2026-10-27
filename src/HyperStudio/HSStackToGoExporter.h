#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSStackToGoExporter : HSExporter2
{
}
- (BOOL)canRunAction:(id)aAction;
- (BOOL)shouldVerifyDocumentActions;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (id)progressSheetDescription;
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType;
@end

