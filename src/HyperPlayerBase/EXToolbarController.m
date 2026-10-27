#import "EXToolbarController.h"
#import "EXCodingContext.h"
#import "EXEnterModeItem.h"
#import "NSString+EXMacTypes.h"
#import "NSMutableDictionary+EXExtensions.h"

static NSMutableDictionary *sToolbarConfigurations = nil;
static NSDictionary *sDisplayModes = nil;
static NSDictionary *sSizeModes = nil;

@implementation EXToolbarController

- (BOOL)validateToolbarItem:(id)aItem
{
    return [self extraValidateToolbarItem:aItem];
}

- (void)toolbarDidRemoveItem:(id)aItem
{
    [self extraToolbarDidRemoveItem:aItem];
}

- (void)toolbarWillAddItem:(id)aItem
{
    [self extraToolbarWillAddItem:aItem];
}

- (id)toolbarSelectableItemIdentifiers:(id)aIdentifiers
{
    if (_toolbar == aIdentifiers)
        return _selectableItemIdentifiers;
    return nil;
}

- (id)toolbarAllowedItemIdentifiers:(id)aIdentifiers
{
    if (_toolbar == aIdentifiers)
        return _allowedItemIdentifiers;
    return nil;
}

- (id)toolbarDefaultItemIdentifiers:(id)aIdentifiers
{
    if (_toolbar == aIdentifiers)
        return _defaultItemIdentifiers;
    return nil;
}

- (id)toolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2
{
    return [self extraToolbar:aToolbar itemForItemIdentifier:aIdentifier willBeInsertedIntoToolbar:aToolbar2];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}

// Defaults to the window's frame autosave name.
- (id)toolbarIdentifier
{
    if (_identifier == nil)
        _identifier = [[_window frameAutosaveName] retain];
    return _identifier;
}

- (void)setIdentifier:(id)aIdentifier
{
    if (![aIdentifier isEqualToString:_identifier]) {
        [_identifier release];
        _identifier = [aIdentifier retain];
    }
}

// Loaded once from the extra dictionary named after the identifier.
- (id)toolbar
{
    if (_toolbar == nil && !_loaded) {
        _loaded = YES;
        [self loadExtraDictionaryRepresentation:[NSDictionary extraDictionaryNamed:[self toolbarIdentifier]]];
        [_toolbar setDelegate:self];
        _loaded = _toolbar != nil;
    }
    return _toolbar;
}

- (void)setupToolbar
{
    [_window setToolbar:[self toolbar]];
}

- (void)dealloc
{
    [_toolbar setDelegate:nil];
    [_toolbar release];
    [_identifier release];
    [_allowedItemIdentifiers release];
    [_defaultItemIdentifiers release];
    [_selectableItemIdentifiers release];
    [_toolbarItemDescriptions release];
    [_stringsTable release];
    [super dealloc];
}

- (id)initWithToolbarIdentifier:(id)aIdentifier
{
    self = [super init];
    if (self != nil)
        _identifier = [aIdentifier retain];
    return self;
}

@end

@implementation HSCustomValidationToolbarItem

- (void)validate
{
    if (![[self toolbar] customizationPaletteIsRunning])
        [super validate];
}

@end

@implementation NSObject (EXToolbarDelegateImplementation)

- (BOOL)extraValidateToolbarItem:(id)aItem
{
    if ([NSApp targetForAction:[(NSToolbarItem *)aItem action] to:[(NSToolbarItem *)aItem target] from:aItem] != nil)
        return YES;
    return [[aItem toolbar] customizationPaletteIsRunning];
}

- (void)extraToolbarDidRemoveItem:(id)aItem
{
}

// Standard items get their description applied when they are added.
- (void)extraToolbarWillAddItem:(id)aItem
{
    NSToolbarItem *item = [[aItem userInfo] objectForKey:@"item"];
    if ([NSToolbar extraIsStandardToolbarItemIdentifier:[item itemIdentifier]]) {
        NSDictionary *descriptions = [[NSToolbar extraToolbarConfigurationNamed:[[aItem object] identifier]] objectForKey:@"toolbarItemDescriptions"];
        NSDictionary *info = [descriptions objectForKey:[item itemIdentifier]];
        [[aItem object] extraSetupToolbarItem:item itemInfo:info willBeInsertedIntoToolbar:YES];
    }
}

- (id)extraToolbarAllowedItemIdentifiers:(id)aIdentifiers
{
    return [[NSToolbar extraToolbarConfigurationNamed:[aIdentifiers identifier]] objectForKey:@"allowedItemIdentifiers"];
}

- (id)extraToolbarDefaultItemIdentifiers:(id)aIdentifiers
{
    return [[NSToolbar extraToolbarConfigurationNamed:[aIdentifiers identifier]] objectForKey:@"defaultItemIdentifiers"];
}

- (id)extraToolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2
{
    NSDictionary *descriptions = [[NSToolbar extraToolbarConfigurationNamed:[aToolbar identifier]] objectForKey:@"toolbarItemDescriptions"];
    NSDictionary *info = [descriptions objectForKey:aIdentifier];
    if (info == nil)
        return nil;
    Class itemClass = NSClassFromString([info objectForKey:@"EXClassName"]);
    if (itemClass == Nil)
        itemClass = [HSCustomValidationToolbarItem class];
    NSToolbarItem *item = [[[itemClass allocWithZone:[aToolbar zone]] initWithItemIdentifier:aIdentifier] autorelease];
    if (item != nil)
        [aToolbar extraSetupToolbarItem:item itemInfo:info willBeInsertedIntoToolbar:aToolbar2];
    return item;
}

@end

@implementation NSToolbar (EXToolbar)

+ (BOOL)extraIsStandardToolbarItemIdentifier:(id)aIdentifier
{
    return [aIdentifier extraContainsString:@"NSToolbar"];
}

+ (id)extraToolbarNamed:(id)aNamed delegate:(id)aDelegate
{
    NSToolbar *toolbar = [NSToolbar objectWithExtraDictionary:[[self extraToolbarConfigurationNamed:aNamed] objectForKey:@"toolbar"]];
    [toolbar setDelegate:aDelegate];
    return toolbar;
}

+ (NSInteger)_sizeModeFromString:(id)aString
{
    if (sSizeModes == nil) {
        sSizeModes = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSNumber numberWithInt:0], @"NSToolbarSizeModeDefault", [NSNumber numberWithInt:0], @"0",
                      [NSNumber numberWithInt:1], @"NSToolbarSizeModeRegular", [NSNumber numberWithInt:1], @"1",
                      [NSNumber numberWithInt:2], @"NSToolbarSizeModeSmall", [NSNumber numberWithInt:2], @"2", nil];
    }
    return [[sSizeModes objectForKey:aString] intValue];
}

+ (NSUInteger)_displayModeFromString:(id)aString
{
    if (sDisplayModes == nil) {
        sDisplayModes = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithInt:0], @"NSToolbarDisplayModeDefault", [NSNumber numberWithInt:0], @"0",
                         [NSNumber numberWithInt:1], @"NSToolbarDisplayModeIconAndLabel", [NSNumber numberWithInt:1], @"1",
                         [NSNumber numberWithInt:2], @"NSToolbarDisplayModeIconOnly", [NSNumber numberWithInt:2], @"2",
                         [NSNumber numberWithInt:3], @"NSToolbarDisplayModeLabelOnly", [NSNumber numberWithInt:3], @"3", nil];
    }
    return [[sDisplayModes objectForKey:aString] intValue];
}

+ (id)extraToolbarConfigurationNamed:(id)aNamed
{
    if (sToolbarConfigurations == nil)
        sToolbarConfigurations = [NSMutableDictionary new];
    NSDictionary *configuration = [sToolbarConfigurations objectForKey:aNamed];
    if (configuration == nil) {
        configuration = [NSDictionary extraDictionaryNamed:aNamed];
        if (configuration != nil)
            [sToolbarConfigurations setObject:configuration forKey:aNamed];
    }
    return configuration;
}

// Applies an item description: custom view (a dictionary naming a delegate
// selector, or a delegate key path), labels localized from the
// configuration's strings table, image, and for inserted items the tool tip,
// action, tag, target and menu representation.
- (void)extraSetupToolbarItem:(id)aItem itemInfo:(id)aInfo willBeInsertedIntoToolbar:(BOOL)aToolbar
{
    NSToolbarItem *item = aItem;
    NSString *identifier = [item itemIdentifier];
    if (aInfo == nil)
        return;
    BOOL isStandard = [NSToolbar extraIsStandardToolbarItemIdentifier:identifier];
    NSString *table = [[NSToolbar extraToolbarConfigurationNamed:[self identifier]] objectForKey:@"stringsTable"];
    NSString *label = [aInfo objectForKey:@"label"];
    NSString *paletteLabel = [aInfo objectForKey:@"paletteLabel"];
    NSString *imageName = [aInfo objectForKey:@"imageName"];
    id customView = [aInfo objectForKey:@"customView"];
    if (customView != nil && !isStandard) {
        id view = nil;
        id minWidth = nil, maxWidth = nil, minHeight = nil, maxHeight = nil;
        if ([customView isKindOfClass:[NSDictionary class]]) {
            SEL accessor = NSSelectorFromString([customView objectForKey:@"customViewAccessSelector"]);
            if (accessor != NULL && [[self delegate] respondsToSelector:accessor]) {
                view = [(id)[self delegate] performSelector:accessor withObject:customView];
                minWidth = [customView objectForKey:@"minWidth"];
                maxWidth = [customView objectForKey:@"maxWidth"];
                minHeight = [customView objectForKey:@"minHeight"];
                maxHeight = [customView objectForKey:@"maxHeight"];
            }
        } else {
            @try {
                view = [(id)[self delegate] valueForKey:customView];
            } @catch (NSException *exception) {
            }
        }
        if ([view isKindOfClass:[NSView class]]) {
            NSRect frame = [view frame];
            [item setView:view];
            NSSize minSize, maxSize;
            minSize.width = minWidth ? (float)[minWidth intValue] : frame.size.width;
            maxSize.width = maxWidth ? (float)[maxWidth intValue] : frame.size.width;
            minSize.height = minHeight ? (float)[minHeight intValue] : frame.size.height;
            maxSize.height = maxHeight ? (float)[maxHeight intValue] : frame.size.height;
            [item setMinSize:minSize];
            [item setMaxSize:maxSize];
        }
    }
    if (label != nil)
        [item setLabel:[[NSBundle mainBundle] localizedStringForKey:label value:@"" table:table]];
    else if (!isStandard)
        [item setLabel:[[NSBundle mainBundle] localizedStringForKey:identifier value:@"" table:table]];
    if (paletteLabel != nil)
        [item setPaletteLabel:[[NSBundle mainBundle] localizedStringForKey:paletteLabel value:@"" table:table]];
    else if (!isStandard)
        [item setPaletteLabel:[item label]];
    if (imageName != nil) {
        NSImage *image = [NSImage imageNamed:imageName];
        NSEnumerator *e = [[image representations] objectEnumerator];
        NSImageRep *rep;
        while ((rep = [e nextObject]) != nil) {
            NSInteger high = [rep pixelsHigh];
            NSInteger wide = [rep pixelsWide];
            [rep setSize:NSMakeSize((float)wide, (float)high)];
        }
        [item setImage:image];
    }
    if (!aToolbar)
        return;
    NSString *toolTip = [aInfo objectForKey:@"toolTip"];
    id tag = [aInfo objectForKey:@"tag"];
    NSString *action = [aInfo objectForKey:@"action"];
    NSString *target = [aInfo objectForKey:@"target"];
    id menuRepresentation = [aInfo objectForKey:@"menuRepresentation"];
    if (toolTip != nil)
        [item setToolTip:[[NSBundle mainBundle] localizedStringForKey:toolTip value:@"" table:table]];
    if (action != nil)
        [item setAction:NSSelectorFromString(action)];
    if (tag != nil)
        [item setTag:[tag intValue]];
    if (target != nil) {
        if ([target compare:@"NSApp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [item setTarget:NSApp];
        } else if ([target compare:@"firstResponder" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [item setTarget:nil];
        } else {
            @try {
                [item setTarget:[(id)[self delegate] valueForKey:target]];
            } @catch (NSException *exception) {
            }
        }
    }
    if (menuRepresentation == nil)
        return;
    NSMenuItem *menuItem = nil;
    if ([menuRepresentation isKindOfClass:[NSDictionary class]]) {
        menuItem = [NSMenuItem extraMenuItemWithDictionary:menuRepresentation];
    } else {
        @try {
            menuItem = [(id)[self delegate] valueForKey:menuRepresentation];
        } @catch (NSException *exception) {
        }
    }
    if (menuItem == nil)
        return;
    if ([[menuItem title] length] == 0)
        [menuItem setTitle:[item label]];
    if ([menuItem action] == NULL)
        [menuItem setAction:[item action]];
    [menuItem setImage:[item image]];
    [item setMenuFormRepresentation:menuItem];
}

- (void)setSizeModeAsString:(id)aString
{
    if ([self respondsToSelector:@selector(setSizeMode:)])
        [self setSizeMode:[[self class] _sizeModeFromString:aString]];
}

- (id)sizeModeAsString
{
    return nil;
}

- (void)setDisplayModeAsString:(id)aString
{
    [self setDisplayMode:[[self class] _displayModeFromString:aString]];
}

- (id)displayModeAsString
{
    return nil;
}

@end
