#import "HyperStudioPrefix.h"


@interface HSSelectiveProxy : NSObject
{
    id _runtimeEditor;
    id _modelInterface;
}
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)lastHyperAccessDidReturnMultipleValues;
- (id)queryHyperInterface:(id)aInterface;
- (void)dealloc;
- (id)initWithRunTimeEditor:(id)aEditor modelInterface:(id)aInterface;
@end

