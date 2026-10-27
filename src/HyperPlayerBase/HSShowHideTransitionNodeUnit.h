#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSShowHideTransitionNodeUnit : HSNodeUnit
{
    HSTransition *_transition;
    double _transitionTime;
    HSTransitionPlayer *_transitionPlayer;
}
- (id)description;
- (void)transitionPlayerDidFinish:(id)aFinish;
- (void)transitionPlayerDidPlayNewFrame:(id)aFrame;
- (double)transitionTime;
- (void)setTransition:(id)aTransition;
- (id)transition;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (void)dealloc;
@end

