#import "HSSystemObjectData.h"
// An object shown with a system (Cocoa) view, made from its template.
@implementation HSSystemObjectData
- (id)systemViewManager:(id)aManager viewCreateIfNeeded:(BOOL)aNeeded
{
    if (_systemView == nil)
        _systemView = [[self templateCocoaView] retain];
    return _systemView;
}
- (id)systemViewForSetAccessor
{
    return [[self viewManager] systemViewForSetAccessor];
}
- (id)systemViewForGetAccessor
{
    return [[self viewManager] systemViewForGetAccessor];
}
- (id)viewManager
{
    if ([self wantsSystemView] && _viewManager == nil) {
        _viewManager = [HSSystemViewManager new];
        [_viewManager setDelegate:self];
    }
    return _viewManager;
}
- (BOOL)wantsSystemView
{
    return YES;
}
- (void)dealloc
{
    [_systemView release];
    [_viewManager setDelegate:nil];
    [_viewManager release];
    [super dealloc];
}
- (id)templateCocoaView
{
    return nil;
}
@end
