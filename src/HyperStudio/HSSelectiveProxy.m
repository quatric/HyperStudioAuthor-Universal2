#import "HSSelectiveProxy.h"

@implementation HSSelectiveProxy

- (void)forwardInvocation:(id)aInvocation
{
    [aInvocation invokeWithTarget:_modelInterface];
    if ([_runtimeEditor respondsToSelector:[aInvocation selector]])
        [aInvocation invokeWithTarget:_runtimeEditor];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    id signature = [super methodSignatureForSelector:aSelector];

    if (signature == nil)
        signature = [_modelInterface methodSignatureForSelector:aSelector];
    return signature;
}

- (BOOL)lastHyperAccessDidReturnMultipleValues
{
    return [_modelInterface lastHyperAccessDidReturnMultipleValues];
}

- (id)queryHyperInterface:(id)aInterface
{
    return [_runtimeEditor queryHyperInterface:aInterface];
}

- (void)dealloc
{
    [_runtimeEditor release];
    [_modelInterface release];
    [super dealloc];
}

- (id)initWithRunTimeEditor:(id)aEditor modelInterface:(id)aInterface
{
    self = [super init];
    if (self != nil) {
        _runtimeEditor = [aEditor retain];
        _modelInterface = [aInterface retain];
    }
    return self;
}

@end
