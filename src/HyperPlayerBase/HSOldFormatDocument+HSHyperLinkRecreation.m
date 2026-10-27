#import "HSOldFormatDocument+HSHyperLinkRecreation.h"
@implementation HSOldFormatDocument (HSHyperLinkRecreation)
- (void)processBy_link_linkText_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [[self parser] setValuesBufferObject:nil forKey:@"~ActionableObject"];
    id container = [[self parser] valuesBufferObjectForKey:@"~TextView"];
    if (container == nil)
        container = [self stack];
    container = [container queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
    if (aValue != nil && [aValue length] != 0 && [container linkWithTitle:aValue] == nil) {
        id link = [container addLinkWithTitle:aValue];
        [[self parser] setValuesBufferObject:link forKey:@"~ActionableObject"];
    }
}
- (void)processBy_linkHeader_fieldID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id textView = nil;
    if ([aValue intValue] != 0)
        textView = [[self parser] valuesBufferObjectForKey:
            [NSString stringWithFormat:@"~hyperlinkObjectByID_%@_%@", aValue, aValue]];
    [[self parser] setValuesBufferObject:textView forKey:@"~TextView"];
}
@end
