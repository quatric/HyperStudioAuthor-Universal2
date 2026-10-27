#import "HSVisualSystemViewLoader.h"
@implementation HSVisualSystemViewLoader
+ (id)cocoaViewWithNibName:(id)aName
{
    return [self cocoaViewWithNibName:aName zone:NULL];
}
+ (id)cocoaViewWithNibName:(id)aName zone:(NSZone *)aZone
{
    return [[[[self allocWithZone:aZone] initWithNibName:aName] autorelease] cocoaView];
}
- (id)cocoaView
{
    return _cocoaView;
}
- (void)dealloc
{
    [_cocoaView release];
    [_containerView release];
    [super dealloc];
}
// The nib's _cocoaView outlet, taken out of its container.
- (id)initWithNibName:(id)aName
{
    if (aName == nil) {
        [super dealloc];
        return nil;
    }
    self = [super init];
    if (self != nil && [NSBundle loadNibNamed:aName owner:self]) {
        [_cocoaView retain];
        [_cocoaView removeFromSuperview];
    }
    return self;
}
@end
