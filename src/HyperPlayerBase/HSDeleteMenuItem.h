#import "HyperPlayerBasePrefix.h"


@interface HSMenuItem : NSMenuItem
{
    NSString *_storedTitle;
}
- (id)disabledTitle;
- (void)setEnabled:(BOOL)aEnabled;
- (void)dealloc;
@end

@interface HSDeleteMenuItem : HSMenuItem
{
}
- (id)disabledTitle;
@end

@interface HSCutMenuItem : HSMenuItem
{
}
- (id)disabledTitle;
@end

@interface HSPasteMenuItem : HSMenuItem
{
}
- (id)disabledTitle;
@end

@interface HSCopyMenuItem : HSMenuItem
{
}
- (id)disabledTitle;
@end

@interface NSMenu (HSExtensions)
- (void)insertSeparatorWithTitle:(id)aTitle;
- (id)menuItemsForAction:(SEL)aAction;
@end

