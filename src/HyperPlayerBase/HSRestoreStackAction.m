#import "HSRestoreStackAction.h"
@implementation HSRestoreStackAction
- (id)XMLElementName
{
    return @"actRestoreStack";
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (void)startInContext:(id)aContext
{
    [aContext restoreStack];
    [self notifyDidFinish];
}
@end
