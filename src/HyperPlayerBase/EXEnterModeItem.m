#import "EXEnterModeItem.h"

// Declared for the super call below; NSObject itself may not implement it.
@interface NSObject (EXEnterModeItemExtraValue)
- (void)setExtraValue:(id)aValue forUndefinedKey:(id)aKey;
@end

// Menu items whose title follows their state: "on" and "off" titles are made
// from the title set in the nib.
@implementation EXWordStateMenuItem

- (id)storedTitle
{
    return _storedTitle;
}

- (void)setStoredTitle:(id)aTitle
{
    if (_storedTitle != aTitle) {
        [_storedTitle release];
        _storedTitle = [aTitle retain];
    }
}

- (void)setTitle:(id)aTitle
{
    int state = _storedState;
    [super setTitle:aTitle];
    _storedState = -1;
    [self setState:state];
}

- (void)initTitles
{
    NSString *title = [self title];
    if ([title length]) {
        [_storedTitle autorelease];
        [_onStateTitle autorelease];
        [_offStateTitle autorelease];
        _storedTitle = [[NSString alloc] initWithString:title];
        _onStateTitle = [[self onStateTitle] retain];
        _offStateTitle = [[self offStateTitle] retain];
    }
}

- (id)offStateTitle
{
    return _storedTitle;
}

- (id)onStateTitle
{
    return _storedTitle;
}

- (NSInteger)state
{
    // The state shows in the title, never as a check mark.
    return NSControlStateValueOff;
}

- (void)setState:(NSInteger)aState
{
    if (_storedState == aState)
        return;
    if (![_storedTitle length])
        [self initTitles];
    _storedState = (int)aState;
    NSString *title;
    if (aState == NSControlStateValueOff)
        title = _offStateTitle;
    else if (aState == NSControlStateValueOn)
        title = _onStateTitle;
    else
        title = _storedTitle;
    [super setTitle:title];
}

- (void)initOnce
{
    if (!_onceInited) {
        _storedState = -1;
        [self setState:[super state]];
        _onceInited = YES;
    }
}

- (void)awakeFromNib
{
    [self initOnce];
}

- (id)initWithTitle:(id)aTitle action:(SEL)aAction keyEquivalent:(id)aEquivalent
{
    self = [super initWithTitle:aTitle action:aAction keyEquivalent:aEquivalent];
    if (self != nil)
        [self initOnce];
    return self;
}

@end

@implementation EXEnterModeItem

- (id)offStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Enter Browse %@" value:@"" table:nil], _storedTitle];
}

- (id)onStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Enter Edit %@" value:@"" table:nil], _storedTitle];
}

@end

@implementation EXEnterLeaveMenuItem

- (id)offStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Enter %@" value:@"" table:nil], _storedTitle];
}

- (id)onStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Leave %@" value:@"" table:nil], _storedTitle];
}

@end

@implementation EXLockUnlockMenuItem

- (id)offStateTitle
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Lock" value:@"" table:nil];
}

- (id)onStateTitle
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Unlock" value:@"" table:nil];
}

@end

@implementation EXTurnOnOffMenuItem

- (id)offStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Turn %@ On" value:@"" table:nil], _storedTitle];
}

- (id)onStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Turn %@ Off" value:@"" table:nil], _storedTitle];
}

@end

@implementation EXSetOnOffMenuItem

- (id)offStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Set %@ On" value:@"" table:nil], _storedTitle];
}

- (id)onStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Set %@ Off" value:@"" table:nil], _storedTitle];
}

@end

@implementation EXShowHideMenuItem

- (id)offStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Show %@" value:@"" table:nil], _storedTitle];
}

- (id)onStateTitle
{
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Hide %@" value:@"" table:nil], _storedTitle];
}

@end

@implementation NSMenuItem (EXRetitle)

- (void)extraReplaceNewApplicationInTitles
{
    NSString *appName = [[NSBundle mainBundle] localizedStringForKey:@"CFBundleName" value:@"" table:@"InfoPlist"];
    [self extraReplaceStringInTitles:@"NewApplication" withString:appName];
}

- (void)extraReplaceStringInTitles:(id)aTitles withString:(id)aString
{
    NSMutableString *title = [NSMutableString stringWithString:[self title]];
    NSMenu *submenu = [self submenu];
    [title extraReplaceString:aTitles withString:aString];
    [self setTitle:title];
    if (submenu != nil) {
        NSEnumerator *enumerator = [[submenu itemArray] objectEnumerator];
        NSMenuItem *item;
        while ((item = [enumerator nextObject]) != nil)
            [item extraReplaceStringInTitles:aTitles withString:aString];
    }
}

@end

@implementation NSMenuItem (SelectedTag)

- (NSInteger)selectedTag
{
    return [self tag];
}

@end

@implementation NSMenu (EXMenu)

+ (id)extraMenuWithItemArrayDescription:(id)aDescription
{
    return [[[self alloc] initWithItemArrayDescription:aDescription] autorelease];
}

- (id)initWithItemArrayDescription:(id)aDescription
{
    self = [self initWithTitle:@""];
    if (self != nil && aDescription != nil) {
        NSEnumerator *enumerator = [aDescription objectEnumerator];
        id itemDescription;
        while ((itemDescription = [enumerator nextObject]) != nil) {
            NSMenuItem *item = [NSMenuItem extraMenuItemWithDictionary:itemDescription];
            if (item != nil)
                [self addItem:item];
        }
    }
    return self;
}

@end

@implementation NSMenuItem (EXMenuItem)

+ (id)newExtraMenuItemWithDictionary:(id)aDictionary
{
    if (aDictionary == nil)
        return nil;
    id className = [aDictionary objectForKey:@"class"];
    Class itemClass = className ? NSClassFromString(className) : [NSMenuItem class];
    if ([[aDictionary objectForKey:@"isSeparatorItem"] boolValue])
        return [[itemClass separatorItem] retain];
    id attributes = [aDictionary objectForKey:@"attributes"];
    NSMenuItem *item = [[itemClass alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
    @try {
        [item takeValuesFromDictionary:attributes];
    } @catch (NSException *exception) {
        [item release];
        item = nil;
    }
    return item;
}

+ (id)extraMenuItemWithDictionary:(id)aDictionary
{
    return [[NSMenuItem newExtraMenuItemWithDictionary:aDictionary] autorelease];
}

- (void)setExtraValue:(id)aValue forUndefinedKey:(id)aKey
{
    if ([aKey isEqual:@"action"])
        [self setAction:NSSelectorFromString(aValue)];
    else if ([aKey isEqual:@"menuItems"])
        [self setSubmenu:[NSMenu extraMenuWithItemArrayDescription:aValue]];
    else
        [super setExtraValue:aValue forUndefinedKey:aKey];
}

@end
