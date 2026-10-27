#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSMakeHomeStackAction : HSNBAAction
{
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)document:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo;
- (void)startInContext:(id)aContext;
- (void)showCantExecuteHomeStackActionAlertWithActionExecutionContext:(id)aContext;
- (void)setHomeStackToCurrentStackWithActionExecutionContext:(id)aContext;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)showCantSetHomeStackAlertWithActionExecutionContext:(id)aContext;
- (BOOL)isSynchronous;
- (BOOL)canChangeSynchronousFlag;
@end

