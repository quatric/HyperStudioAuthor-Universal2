#import "HyperPlayerBasePrefix.h"


@interface HSVisualSystemViewLoader : NSObject
{
    NSView *_containerView;
    NSView *_cocoaView;
}
+ (id)cocoaViewWithNibName:(id)aName;
+ (id)cocoaViewWithNibName:(id)aName zone:(NSZone *)aZone;
- (id)cocoaView;
- (void)dealloc;
- (id)initWithNibName:(id)aName;
@end

