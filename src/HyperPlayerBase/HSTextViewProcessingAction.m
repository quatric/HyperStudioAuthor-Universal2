#import "HSTextViewProcessingAction.h"
// An add-on action working on text objects of its card, named or by UID
// (undoable).
@implementation HSTextViewProcessingAction
// The first text object on the card with that name.
- (id)textViewWithTitle:(id)aTitle
{
    for (id child in [[[self card] queryHyperInterface:@protocol(HSNodeContainer)] hyperChildren]) {
        if (![child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)])
            continue;
        if ([[[child queryHyperInterface:@protocol(HSObjectAttributes)] hyperName] isEqualToString:aTitle])
            return [child queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    }
    return nil;
}
- (id)textViewWithUID:(id)aUID
{
    return [[[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:aUID]
            queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
}
- (void)setTextViewNames:(id)aNames
{
    if ([_textViewNames isEqual:aNames])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text Objects" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextViewNames:[self textViewNames]];
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:1 ofAttribute:@protocol(HSTextViewNamesAttribute) ofObject:self withUserInfo:nil];
    [_textViewNames release];
    _textViewNames = [aNames retain];
    [center notifyChange:2 ofAttribute:@protocol(HSTextViewNamesAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)textViewNames
{
    return _textViewNames;
}
- (void)setTextViewUIDs:(id)aDs
{
    if ([_textViewUIDs isEqual:aDs])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text Objects" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextViewUIDs:[self textViewUIDs]];
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:1 ofAttribute:@protocol(HSTextViewUIDsAttribute) ofObject:self withUserInfo:nil];
    [_textViewUIDs release];
    _textViewUIDs = [aDs retain];
    [center notifyChange:2 ofAttribute:@protocol(HSTextViewUIDsAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)textViewUIDs
{
    return _textViewUIDs;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:[@"textViewUIDs" extraKeyForCollection], [@"textViewNames" extraKeyForCollection], nil]];
}
// (The original leaked the names.)
- (void)dealloc
{
    [_textViewUIDs release];
    [_textViewNames release];
    [super dealloc];
}
@end
