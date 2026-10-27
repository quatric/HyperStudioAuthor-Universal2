#import "HyperStudioPrefix.h"


@interface HSToolbarItem : NSToolbarItem
{
}
- (id)copyWithZone:(NSZone *)aZone;
- (void)validate;
- (void)validateView:(id)aView;
@end

