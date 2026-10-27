#import "HyperStudioPrefix.h"


@interface HSTransparentGroupButton : NSControl
{
}
+ (Class)cellClass;
- (BOOL)acceptsFirstResponder;
- (void)mouseUp:(id)aUp;
- (void)mouseDown:(id)aDown;
- (void)awakeFromNib;
@end

