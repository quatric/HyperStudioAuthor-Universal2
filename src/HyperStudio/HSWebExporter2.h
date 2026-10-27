#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSWebExporter2 : HSExporter2
{
    HSXMLNode *_embeddedCode;
}
+ (id)htmlTemplateDocumentWithDocument:(id)aDocument resourcePath:(id)aPath;
+ (id)htmlTemplateDocumentWithWidth:(CGFloat)aWidth height:(CGFloat)aHeight forStackAtURLWithString:(id)aString;
- (BOOL)canRunAction:(id)aAction;
- (BOOL)shouldVerifyDocumentActions;
- (id)embeddedCode;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (id)htmlTemplateWithDocument:(id)aDocument resourcePath:(id)aPath;
- (id)progressSheetDescription;
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType;
- (void)dealloc;
@end

