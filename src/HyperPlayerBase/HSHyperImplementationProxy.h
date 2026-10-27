#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSHyperImplementationProxy : HSWeaklyReferencedObject
{
    id _parentObject;
    id _implementation;
    HSProtocolIdentifier *_interfaceIdentifier;
    BOOL _isHyperObjectDirectedAtParentObject;
}
+ (id)proxyWithImplementation:(id)aImplementation forObject:(id)aObject;
+ (id)proxyWithImplementation:(id)aImplementation ofProtocol:(id)aProtocol forObject:(id)aObject;
- (BOOL)isHyperObjectDirectedAtParentObject;
- (void)setHyperObjectDirectedAtParentObject:(BOOL)aObject;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)lastHyperAccessDidReturnMultipleValues;
- (BOOL)conformsToProtocol:(id)aProtocol;
- (id)queryHyperInterface:(id)aInterface;
- (id)hyperObject;
- (void)dealloc;
- (id)init;
- (id)initWithImplementation:(id)aImplementation forInterface:(id)aInterface parentObject:(id)aObject;
@end

