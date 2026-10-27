#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSRestoreStackAction : HSNBAAction
{
}
- (id)XMLElementName;
- (BOOL)supportedInIPad;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)startInContext:(id)aContext;
@end

