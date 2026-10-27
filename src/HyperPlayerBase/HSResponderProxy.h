#import "HyperPlayerBasePrefix.h"


@interface HSResponderProxy : NSResponder
{
    id _realResponder;
}
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)conformsToProtocol:(id)aProtocol;
- (void)doCommandBySelector:(SEL)aSelector;
- (BOOL)tryToPerform:(SEL)aPerform with:(id)aWith;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)dealloc;
- (id)initWithRealResponder:(id)aResponder;
@end

