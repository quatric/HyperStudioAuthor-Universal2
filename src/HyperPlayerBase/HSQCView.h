#import "HyperPlayerBasePrefix.h"


@interface HSQCView : QCView
{
    id _delegate;
}
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)mouseDown:(id)aDown;
- (void)keyDown:(id)aDown;
@end

