#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSGoToLastMarkedCardAction : HSChangeCardAction
{
    HSAlert *_noMarkedCardsAlert;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)startInContext:(id)aContext;
- (BOOL)canRunInContext:(id)aContext;
- (id)noMarkedCardsAlert;
- (id)createNavigationOperation;
- (void)dealloc;
@end

