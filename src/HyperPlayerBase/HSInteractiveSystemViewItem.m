#import "HSInteractiveSystemViewItem.h"
@implementation HSInteractiveSystemViewItem
- (void)doCommandBySelector:(SEL)aSelector
{
}
- (void)invalidateView
{
    if (_systemViewInterface != nil) {
        [_systemViewInterface removeDuplicateHyperSystemView:[self view]];
        [_systemViewInterface release];
        _systemViewInterface = nil;
    }
    [super invalidateView];
}
- (id)createView
{
    _systemViewInterface = [[[self hyperObject] queryHyperInterface:@protocol(HSSystemViewDuplicatingInterface)] retain];
    return [[_systemViewInterface addDuplicateHyperSystemView] retain];
}
- (void)dealloc
{
    if (_systemViewInterface != nil)
        [_systemViewInterface removeDuplicateHyperSystemView:[self view]];
    [_systemViewInterface release];
    [super dealloc];
}
@end
