#import "HyperPlayerBasePrefix.h"


@interface HSSavePanelAccessoryViewController : NSObject
{
    NSView *_accessoryView;
    NSString *_nibName;
}
- (id)accessoryView;
- (void)dealloc;
- (id)initWithNibName:(id)aName;
@end

