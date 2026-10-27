#import "HSCanvasLayerActionSelectorSupport.h"
@implementation HSCanvasLayerActionSelectorSupport
+ (id)methodSignatureForActionSelector
{
    // the signature of an action method, - (void)action:(id)sender
    id support = [[self alloc] init];
    NSMethodSignature *signature = [[support methodSignatureForSelector:@selector(stubAction:)] retain];
    [support release];
    return signature;
}
- (void)stubAction:(id)aAction
{
}
@end
