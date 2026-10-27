#import "HSDeleteMenuItem.h"
// Edit menu items whose target can name what they act on ("Delete Card"):
// while enabled they keep that title, disabled (or for other targets) they
// show the plain one (disabledTitle).
@implementation HSMenuItem
- (id)disabledTitle
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (void)setEnabled:(BOOL)aEnabled
{
    id target = [NSApp targetForAction:[self action] to:[self target] from:self];
    if ([target conformsToProtocol:@protocol(HSStoredMenuItemTitleValidationSupport)] && [target supportMenuItemStoredTitleValidation]) {
        if ([super isEnabled] == aEnabled) {
            [super setEnabled:aEnabled];
            return;
        }
        if (aEnabled) {
            if (_storedTitle != nil) {
                if ([[self title] isEqualToString:[self disabledTitle]])
                    [self setTitle:_storedTitle];
                [_storedTitle release];
                _storedTitle = nil;
            }
            [super setEnabled:aEnabled];
            return;
        }
        [_storedTitle release];
        _storedTitle = [[self title] retain];
    }
    [self setTitle:[self disabledTitle]];
    [super setEnabled:aEnabled];
}
- (void)dealloc
{
    [_storedTitle release];
    [super dealloc];
}
@end

@implementation HSDeleteMenuItem
- (id)disabledTitle
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSDeleteMenuTitle" value:@"" table:@"Editor"];
}
@end

@implementation HSCutMenuItem
- (id)disabledTitle
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCutMenuTitle" value:@"" table:@"Editor"];
}
@end

@implementation HSPasteMenuItem
- (id)disabledTitle
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSPasteMenuTitle" value:@"" table:@"Editor"];
}
@end

@implementation HSCopyMenuItem
- (id)disabledTitle
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCopyMenuTitle" value:@"" table:@"Editor"];
}
@end

@implementation NSMenu (HSExtensions)
// A disabled item in the small system font titling the items after it.
- (void)insertSeparatorWithTitle:(id)aTitle
{
    NSMenuItem *item = [NSMenuItem new];
    NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"Separator string" value:@"" table:@"AssistantPanes"];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format, aTitle]];
    [title addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [title length])];
    [item setAttributedTitle:title];
    [title release];
    [item setEnabled:NO];
    [self addItem:item];
    [item release];
}
// In submenus too.
- (id)menuItemsForAction:(SEL)aAction
{
    NSMutableArray *items = [[NSMutableArray new] autorelease];
    for (NSMenuItem *item in [self itemArray]) {
        if ([item action] == aAction)
            [items addObject:item];
        if ([item hasSubmenu])
            [items addObjectsFromArray:[[item submenu] menuItemsForAction:aAction]];
    }
    return items;
}
@end
