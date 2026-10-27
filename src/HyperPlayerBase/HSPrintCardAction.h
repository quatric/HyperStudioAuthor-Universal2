#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSPrintCardAction : HSNBAAction <HSPrintCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSPrintCardShowPageSetupAttribute, HSPrintCardShowPrintDialogAttribute, HSPrintCardCenterPrintoutAttribute>
{
    BOOL _showPageSetupDialog;
    BOOL _showPrintDialog;
    BOOL _centerPrintout;
    HSActionExecutionContext *_context;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)printCurrentCard;
- (void)setCenterPrintout:(BOOL)aPrintout;
- (BOOL)centerPrintout;
- (void)setShowPrintDialog:(BOOL)aDialog;
- (BOOL)showPrintDialog;
- (void)setShowPageSetupDialog:(BOOL)aDialog;
- (BOOL)showPageSetupDialog;
- (void)documentDidEndPrinting;
- (void)documentDidCancelPrinting;
- (void)documentDidEndPageSetupDialog;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

