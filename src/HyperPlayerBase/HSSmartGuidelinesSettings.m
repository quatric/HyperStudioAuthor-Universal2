#import "HSSmartGuidelinesSettings.h"
// Snap-to-objects and the smart guideline colour, undoable, read from and
// saved to the user defaults.
@implementation HSSmartGuidelinesSettings
+ (id)defaultColor
{
    return [NSColor greenColor];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"isSnapToObjectsEnabled",
                                     [@"smartGuideLineColor" extraKeyForMultiRepresentations], nil];
}
- (BOOL)isSnapToObjectsEnabled
{
    return _isSnapToObjectsEnabled;
}
- (void)setSnapToObjectsEnabled:(BOOL)aEnabled
{
    if (_isSnapToObjectsEnabled == aEnabled)
        return;
    [_undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Smart Guideline Visibility Change"
                                                                       value:@""
                                                                       table:@"UndoManager"]];
    [[_undoManager prepareWithInvocationTarget:self] setSnapToObjectsEnabled:_isSnapToObjectsEnabled];
    _isSnapToObjectsEnabled = aEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSSnapToObjectsDidChangeNotification" object:self];
}
- (id)smartGuidelineColor
{
    if (_smartGuidelineColor == nil)
        _smartGuidelineColor = [[[self class] defaultColor] retain];
    return _smartGuidelineColor;
}
- (void)setSmartGuidelineColor:(id)aColor
{
    if (_smartGuidelineColor == aColor)
        return;
    [_undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Smart Guideline Color Change"
                                                                       value:@""
                                                                       table:@"UndoManager"]];
    [[_undoManager prepareWithInvocationTarget:self] setSmartGuidelineColor:_smartGuidelineColor];
    [_smartGuidelineColor release];
    _smartGuidelineColor = [aColor retain];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSSnapToObjectsDidChangeNotification" object:self];
}
- (id)undoManager
{
    return _undoManager;
}
- (void)setUndoManager:(id)aManager
{
    if (_undoManager != aManager) {
        [_undoManager release];
        _undoManager = [aManager retain];
    }
}
- (void)resetToDefaults
{
    [_smartGuidelineColor release];
    _smartGuidelineColor = nil;
    _isSnapToObjectsEnabled = NO;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HSSmartUntitledWindowLayout"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HSGuidelinesColor"];
}
// (The snap flag's defaults key really is "HSSmartUntitledWindowLayout".)
- (void)saveToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setBool:_isSnapToObjectsEnabled forKey:@"HSSmartUntitledWindowLayout"];
    [[NSUserDefaults standardUserDefaults] setObject:[_smartGuidelineColor extraDictionaryRepresentation]
                                              forKey:@"HSGuidelinesColor"];
}
- (void)dealloc
{
    [_smartGuidelineColor release];
    [_undoManager release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _isSnapToObjectsEnabled = [defaults boolForKey:@"HSSmartUntitledWindowLayout"];
        _smartGuidelineColor = [[NSColor alloc] initWithExtraDictionary:[defaults objectForKey:@"HSGuidelinesColor"]];
    }
    return self;
}
@end
