#import "HyperPlayerBasePrefix.h"


@interface EXWordStateMenuItem : NSMenuItem
{
    NSString *_onStateTitle;
    NSString *_offStateTitle;
    NSString *_storedTitle;
    int _storedState;
    BOOL _onceInited;
}
- (id)storedTitle;
- (void)setStoredTitle:(id)aTitle;
- (void)setTitle:(id)aTitle;
- (void)initTitles;
- (id)offStateTitle;
- (id)onStateTitle;
- (NSInteger)state;
- (void)setState:(NSInteger)aState;
- (void)initOnce;
- (void)awakeFromNib;
- (id)initWithTitle:(id)aTitle action:(SEL)aAction keyEquivalent:(id)aEquivalent;
@end

@interface EXEnterModeItem : EXWordStateMenuItem
{
}
- (id)offStateTitle;
- (id)onStateTitle;
@end

@interface EXEnterLeaveMenuItem : EXWordStateMenuItem
{
}
- (id)offStateTitle;
- (id)onStateTitle;
@end

@interface EXLockUnlockMenuItem : EXWordStateMenuItem
{
}
- (id)offStateTitle;
- (id)onStateTitle;
@end

@interface EXTurnOnOffMenuItem : EXWordStateMenuItem
{
}
- (id)offStateTitle;
- (id)onStateTitle;
@end

@interface EXSetOnOffMenuItem : EXWordStateMenuItem
{
}
- (id)offStateTitle;
- (id)onStateTitle;
@end

@interface EXShowHideMenuItem : EXWordStateMenuItem
{
}
- (id)offStateTitle;
- (id)onStateTitle;
@end

@interface NSMenuItem (EXRetitle)
- (void)extraReplaceNewApplicationInTitles;
- (void)extraReplaceStringInTitles:(id)aTitles withString:(id)aString;
@end

@interface NSMenuItem (SelectedTag)
- (NSInteger)selectedTag;
@end

@interface NSMenu (EXMenu)
+ (id)extraMenuWithItemArrayDescription:(id)aDescription;
- (id)initWithItemArrayDescription:(id)aDescription;
@end

@interface NSMenuItem (EXMenuItem)
+ (id)newExtraMenuItemWithDictionary:(id)aDictionary;
+ (id)extraMenuItemWithDictionary:(id)aDictionary;
- (void)setExtraValue:(id)aValue forUndefinedKey:(id)aKey;
@end

