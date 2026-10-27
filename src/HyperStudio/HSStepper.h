#import "HyperStudioPrefix.h"


@interface HSStepper : NSStepper
{
    id _delegate;
}
+ (Class)cellClass;
- (void)awakeFromNib;
- (void)mouseDown:(id)aDown;
- (void)keyUp:(id)aUp;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

