#import "HyperStudioPrefix.h"


@interface HSSpinButton : NSButton
{
}
+ (Class)cellClass;
+ (void)initialize;
- (void)performClick:(id)aClick;
- (void)moveDown:(id)aDown;
- (void)moveUp:(id)aUp;
- (void)moveLeft:(id)aLeft;
- (void)moveRight:(id)aRight;
- (id)initWithCoder:(id)aCoder;
@end

