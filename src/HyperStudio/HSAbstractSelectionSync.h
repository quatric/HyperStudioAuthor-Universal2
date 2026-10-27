#import "HyperStudioPrefix.h"


@interface HSAbstractSelectionSync : NSObject
{
    id<HSPrimitiveSelectionHost> _currentSelectionHost;
    id _currentSelectedObject;
    BOOL _isEnabled;
}
+ (BOOL)isEnabledByDefault;
- (void)notifySelectionDidChange;
- (BOOL)isRegisteredSelectionHost:(id)aHost;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)setCurrentSelectionHost:(id)aHost;
- (void)setCurrentSelectionHost:(id)aHost andNotify:(BOOL)aNotify;
- (id)currentSelectionHost;
- (void)refreshCurrentlySelectedObjectAndNotify:(BOOL)aNotify;
- (id)currentlySelectedObjectInActiveSelectionHost;
- (void)setCurrentSelectedObject:(id)aObject;
- (id)currentSelectedObject;
- (id)init;
- (void)dealloc;
@end

