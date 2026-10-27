#import "HyperPlayerBasePrefix.h"


@interface HSAlternateClickButton : NSButton
{
    SEL _alternateAction;
    id _alternateTarget;
}
+ (Class)cellClass;
- (void)setAlternateAction:(SEL)aAction;
- (SEL)alternateAction;
- (void)mouseDown:(id)aDown;
- (void)dealloc;
@end

