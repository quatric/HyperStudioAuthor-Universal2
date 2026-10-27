#import "HSShowHideCursorAction.h"
@implementation HSShowHideCursorAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self changeCursorVisibilityAction]] forKey:@"cursorVisibility"];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}
- (void)setChangeCursorVisibilityAction:(NSInteger)aAction
{
    if (_changeCursorVisibilityAction == aAction)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Cursor Visibility Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setChangeCursorVisibilityAction:[self changeCursorVisibilityAction]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSChangeCursorVisibilityActionAttribute) ofObject:self withUserInfo:nil];
    _changeCursorVisibilityAction = (int)aAction;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSChangeCursorVisibilityActionAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)changeCursorVisibilityAction
{
    return _changeCursorVisibilityAction;
}
// 0 shows, 1 hides, 2 obscures the cursor (until it moves).
- (void)startInContext:(id)aContext
{
    switch ([self changeCursorVisibilityAction]) {
    case 2: [aContext obscureCursor]; break;
    case 1: [aContext hideCursor]; break;
    case 0: [aContext showCursor]; break;
    }
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"changeCursorVisibilityAction"];
}
@end
