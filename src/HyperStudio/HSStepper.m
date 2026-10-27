#import "HSStepper.h"

@implementation HSStepper

+ (Class)cellClass
{
    return [HSStepperCell class];
}

- (void)awakeFromNib
{
    id target = [[self cell] target];
    SEL action = [[self cell] action];

    [self setCell:[NSCell hyperCellOfClass:[HSStepper cellClass] withCell:[self cell]]];
    [[self cell] setTarget:target];
    [[self cell] setAction:action];
}

- (void)mouseDown:(id)aDown
{
    if ([[self delegate] respondsToSelector:@selector(hyperCustomStepperDidStartTracking:)])
        [[self delegate] performSelector:@selector(hyperCustomStepperDidStartTracking:) withObject:self];
    [super mouseDown:aDown];
    if ([[self delegate] respondsToSelector:@selector(hyperCustomStepperDidFinishTracking:)])
        [[self delegate] performSelector:@selector(hyperCustomStepperDidFinishTracking:) withObject:self];
}

- (void)keyUp:(id)aUp
{
    [super keyUp:aUp];
    [self updateCell:[self cell]];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
