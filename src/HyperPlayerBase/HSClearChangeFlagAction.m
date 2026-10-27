#import "HSClearChangeFlagAction.h"
@implementation HSClearChangeFlagAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    return nil;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (void)startInContext:(id)aContext
{
    [aContext clearAllChangesInDocument];
    [self notifyDidFinish];
}
@end
