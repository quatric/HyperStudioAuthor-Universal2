#import "HyperStudioPrefix.h"


@interface HSNavigationMatrix : NSMatrix
{
    HSKeyMapping *_forwardKeyEquivalent;
    HSKeyMapping *_backwardKeyEquivalent;
}
- (void)navigateBackward;
- (void)navigateForward;
- (void)setBackwardKeyEquivalent:(id)aEquivalent;
- (id)backwardKeyEquivalent;
- (void)setForwardKeyEquivalent:(id)aEquivalent;
- (id)forwardKeyEquivalent;
- (BOOL)performKeyEquivalent:(id)aEquivalent;
- (BOOL)acceptsFirstResponder;
- (void)dealloc;
@end

