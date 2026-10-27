#import "HSKeyMapperActionShortcutAssistantPane.h"

@implementation HSKeyMapperActionShortcutAssistantPane

- (void)paneDidCancel:(id)aCancel
{
    [_keyMapping release];
    _keyMapping = nil;
    if ([[self delegate] respondsToSelector:@selector(shortcutPaneDidEnd:)])
        [[self delegate] shortcutPaneDidEnd:self];
    [self dismiss:YES];
}

// An empty custom key drops the mapping; system keys map to their special characters.
- (void)paneDidOK:(id)aOK
{
    if ([_customKeyTextField isEnabled]) {
        NSString *string = [_customKeyTextField stringValue];
        if ([string length] == 0) {
            [_keyMapping release];
            _keyMapping = nil;
        }
        else {
            [_keyMapping setObject:[string substringToIndex:1] forKey:@"HSKeyMapperActionCharacterKey"];
        }
    }
    else {
        NSMenuItem *item = [_systemKeyPopUpButton selectedItem];
        NSString *character;
        if ([[item title] isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"Space" value:@"" table:@"Keys"]])
            character = [NSString stringWithFormat:@"%C", (unichar)0x20];
        else if ([[item title] isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"Delete" value:@"" table:@"Keys"]])
            character = [NSString stringWithFormat:@"%C", (unichar)0x7f];
        else if ([[item title] isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"Clear" value:@"" table:@"Keys"]])
            character = [NSString stringWithFormat:@"%C", (unichar)0xf739];
        else
            character = [item keyEquivalent];
        [_keyMapping setObject:character forKey:@"HSKeyMapperActionCharacterKey"];
    }
    [_keyMapping setObject:[NSNumber numberWithInt:[_useCommandSwitch isEnabled] ? (int)[_useCommandSwitch state] : 0] forKey:@"HSKeyMapperActionUseCommandKeyKey"];
    unichar code = [[_keyMapping objectForKey:@"HSKeyMapperActionCharacterKey"] characterAtIndex:0];
    [_keyMapping setObject:[NSNumber numberWithUnsignedShort:code] forKey:@"HSKeyMapperActionCharacterCodeKey"];
    if ([[self delegate] respondsToSelector:@selector(shortcutPaneDidEnd:)])
        [[self delegate] shortcutPaneDidEnd:self];
    [self dismiss:YES slide:NO];
}

- (void)customKeyDidChange:(id)aChange
{
    NSString *string = [aChange stringValue];
    if ([string length] != 0)
        [aChange setStringValue:[string substringToIndex:1]];
}

- (void)useSystemKeyDidChange:(id)aChange
{
    if ([aChange state] != NSControlStateValueOn) {
        [aChange setState:NSControlStateValueOn];
        return;
    }
    [_useCustomKeyRadioButton setState:NSControlStateValueOff];
    [_customKeyTextField setEnabled:NO];
    [_systemKeyPopUpButton setEnabled:YES];
    [_useCommandSwitch setEnabled:NO];
}

- (void)useCustomKeyDidChange:(id)aChange
{
    if ([aChange state] != NSControlStateValueOn) {
        [aChange setState:NSControlStateValueOn];
        return;
    }
    [_useSystemKeyRadioButton setState:NSControlStateValueOff];
    [_systemKeyPopUpButton setEnabled:NO];
    [_customKeyTextField setEnabled:YES];
    [_useCommandSwitch setEnabled:YES];
}

- (id)resultDictionary
{
    return _keyMapping;
}

- (void)setInitialDictionary:(id)aDictionary
{
    if (_keyMapping != aDictionary) {
        [_keyMapping release];
        _keyMapping = [aDictionary mutableCopy];
    }
}

// Printable characters go to the custom key field; anything else selects the matching system key.
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"KeyMapperShortcutDescriptionFormat" value:@"" table:@"AssistantPanes"];
    [_descriptionTextFiled setStringValue:[NSString stringWithFormat:format, [_keyMapping objectForKey:@"HSKeyMapperActionObjectTitleKey"]]];
    [_customKeyTextField setStringValue:@""];
    [_systemKeyPopUpButton selectItemAtIndex:0];
    [_useCommandSwitch setState:[[_keyMapping objectForKey:@"HSKeyMapperActionUseCommandKeyKey"] intValue]];

    NSString *character = [_keyMapping objectForKey:@"HSKeyMapperActionCharacterKey"];
    if ([character length] == 0) {
        unichar code = [[_keyMapping objectForKey:@"HSKeyMapperActionCharacterCodeKey"] unsignedShortValue];
        character = [NSString stringWithCharacters:&code length:1];
    }
    unichar c = [character characterAtIndex:0];
    if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:c] || [[NSCharacterSet symbolCharacterSet] characterIsMember:c] || [[NSCharacterSet punctuationCharacterSet] characterIsMember:c]) {
        [_customKeyTextField setStringValue:character];
        [_useCustomKeyRadioButton setState:NSControlStateValueOn];
        [self useCustomKeyDidChange:_useCustomKeyRadioButton];
        return;
    }

    NSString *title = nil;
    if ([character isEqualToString:[NSString stringWithFormat:@"%C", (unichar)0x20]])
        title = @"Space";
    else if ([character isEqualToString:[NSString stringWithFormat:@"%C", (unichar)0x7f]])
        title = @"Delete";
    else if ([character isEqualToString:[NSString stringWithFormat:@"%C", (unichar)0xf739]])
        title = @"Clear";
    if (title != nil) {
        [_systemKeyPopUpButton selectItemWithTitle:[[NSBundle mainBundle] localizedStringForKey:title value:@"" table:@"Keys"]];
    }
    else {
        for (NSMenuItem *item in [[_systemKeyPopUpButton menu] itemArray]) {
            if ([[item keyEquivalent] isEqualToString:character]) {
                [_systemKeyPopUpButton selectItem:item];
                break;
            }
        }
    }
    [_useSystemKeyRadioButton setState:NSControlStateValueOn];
    [self useSystemKeyDidChange:_useSystemKeyRadioButton];
}

- (Class)applierClass
{
    return Nil;
}

- (id)actionType
{
    return [HSKeyMapperAction actionType];
}

- (id)navigationPaneSwitcher
{
    if (_paneSwitcher == nil) {
        _paneSwitcher = [HSObjectAssistantNavigationPaneSwitcher new];
        [_paneSwitcher setDelegate:self];
    }
    return _paneSwitcher;
}

- (void)dealloc
{
    [_keyMapping release];
    [super dealloc];
}

- (id)init
{
    return [super initWithNibName:@"KeyMapperShortcuts"];
}

@end
