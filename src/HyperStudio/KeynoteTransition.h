#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteTransition : KeynoteObject
{
}
- (id)transitionAttributes;
- (double)duration;
- (id)directionCodeString;
- (id)type;
- (void)didInitFromParser;
@end

