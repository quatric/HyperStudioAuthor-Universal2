#import "HyperStudioPrefix.h"


@interface HSToolbarItem : NSToolbarItem
{
    BOOL _isTextOnlyMode;
}
- (id)copyWithZone:(NSZone *)aZone;
- (void)validate;
- (void)validateView:(id)aView;
- (BOOL)isTextOnlyMode;
- (void)setTextOnlyMode:(BOOL)aMode;
- (void)setDisplayMode:(NSToolbarDisplayMode)aMode;
- (void)setEnabled:(BOOL)aEnabled;
- (void)setEnabled:(BOOL)aEnabled view:(id)aView;
- (void)setImagesToSubMenuItems:(BOOL)aItems;
@end

