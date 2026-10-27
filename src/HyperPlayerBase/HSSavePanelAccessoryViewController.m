#import "HSSavePanelAccessoryViewController.h"
@implementation HSSavePanelAccessoryViewController
- (id)accessoryView
{
    if (_accessoryView == nil)
        [NSBundle loadNibNamed:_nibName owner:self];
    return _accessoryView;
}
- (void)dealloc
{
    [_nibName release];
    [_accessoryView release];
    [super dealloc];
}
- (id)initWithNibName:(id)aName
{
    self = [super init];
    if (self != nil)
        _nibName = [aName retain];
    return self;
}
@end
