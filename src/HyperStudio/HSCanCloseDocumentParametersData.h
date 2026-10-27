#import "HyperStudioPrefix.h"


@interface HSCanCloseDocumentParametersData : NSObject
{
    id _delegate;
    SEL _selector;
    void *_contextInfo;
}
- (void)invokeCanCloseCallbackFrom:(id)aFrom shouldClose:(BOOL)aClose;
- (void *)contextInfo;
- (SEL)selector;
- (id)delegate;
- (id)initWithDelegate:(id)aDelegate selector:(SEL)aSelector contextInfo:(void *)aInfo;
@end

