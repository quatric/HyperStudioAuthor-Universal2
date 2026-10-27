#import "HSRecursiveAttributeView.h"
@implementation HSRecursiveAttributeView
+ (void)initialize
{
    if (self == [HSRecursiveAttributeView class])
        [self exposeBinding:@"enabled"];
}
- (void)setEnabled:(BOOL)aEnabled
{
    [self willChangeValueForKey:@"enabled"];
    [self setHyperEnabled:aEnabled includeSelf:NO];
    _enabled = aEnabled;
    [self didChangeValueForKey:@"enabled"];
}
- (BOOL)isEnabled
{
    return _enabled;
}
@end
