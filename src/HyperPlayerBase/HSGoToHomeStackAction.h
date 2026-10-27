#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSGoToHomeStackAction : HSChangeCardAction
{
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementName;
- (void)homeStackURLDidChange:(id)aChange;
- (BOOL)isValid;
- (id)createNavigationOperation;
- (void)startInContext:(id)aContext;
- (void)cantFindHomeStackAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (id)cantFindHomeStackAlert;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)showCantGoHomeStackAlertWithActionExecutionContext:(id)aContext;
- (void)dealloc;
@end

