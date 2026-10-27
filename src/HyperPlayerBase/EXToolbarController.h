#import "HyperPlayerBasePrefix.h"


@interface EXToolbarController : NSObject <NSToolbarDelegate, NSObject, EXKeyValueCoding>
{
    NSWindow *_window;
    NSString *_identifier;
    BOOL _loaded;
    NSToolbar *_toolbar;
    NSArray *_allowedItemIdentifiers;
    NSArray *_defaultItemIdentifiers;
    NSArray *_selectableItemIdentifiers;
    NSDictionary *_toolbarItemDescriptions;
    NSString *_stringsTable;
}
- (BOOL)validateToolbarItem:(id)aItem;
- (void)toolbarDidRemoveItem:(id)aItem;
- (void)toolbarWillAddItem:(id)aItem;
- (id)toolbarSelectableItemIdentifiers:(id)aIdentifiers;
- (id)toolbarAllowedItemIdentifiers:(id)aIdentifiers;
- (id)toolbarDefaultItemIdentifiers:(id)aIdentifiers;
- (id)toolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)toolbarIdentifier;
- (void)setIdentifier:(id)aIdentifier;
- (id)toolbar;
- (void)setupToolbar;
- (void)dealloc;
- (id)initWithToolbarIdentifier:(id)aIdentifier;
@end

@interface HSCustomValidationToolbarItem : NSToolbarItem
{
}
- (void)validate;
@end

@interface NSObject (EXToolbarDelegateImplementation)
- (BOOL)extraValidateToolbarItem:(id)aItem;
- (void)extraToolbarDidRemoveItem:(id)aItem;
- (void)extraToolbarWillAddItem:(id)aItem;
- (id)extraToolbarAllowedItemIdentifiers:(id)aIdentifiers;
- (id)extraToolbarDefaultItemIdentifiers:(id)aIdentifiers;
- (id)extraToolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2;
@end

@interface NSToolbar (EXToolbar)
+ (BOOL)extraIsStandardToolbarItemIdentifier:(id)aIdentifier;
+ (id)extraToolbarNamed:(id)aNamed delegate:(id)aDelegate;
+ (NSInteger)_sizeModeFromString:(id)aString;
+ (NSUInteger)_displayModeFromString:(id)aString;
+ (id)extraToolbarConfigurationNamed:(id)aNamed;
+ (id)iconImageForName:(id)aName;
- (void)extraSetupToolbarItem:(id)aItem itemInfo:(id)aInfo willBeInsertedIntoToolbar:(BOOL)aToolbar;
- (void)setSizeModeAsString:(id)aString;
- (id)sizeModeAsString;
- (void)setDisplayModeAsString:(id)aString;
- (id)displayModeAsString;
@end

