#import "HyperStudioPrefix.h"
#import "KeynoteLineEndContainer.h"


@interface KeynoteLine : KeynoteLineEndContainer <KeynoteBezierPathContainer, NSObject>
{
}
- (CGFloat)angle;
- (id)bezierPath;
- (BOOL)isLine;
- (BOOL)exportsBezierPath;
@end

