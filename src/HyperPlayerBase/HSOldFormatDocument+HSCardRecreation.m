#import "HSOldFormatDocument+HSCardRecreation.h"
// Old-format import: the card header fields of each card record. The card
// being rebuilt is kept in the parser's values buffer under "~Card"; actions
// found later look themselves up there by the keys these handlers store.
@implementation HSOldFormatDocument (HSCardRecreation)
- (void)processBy_cardHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self setOldCursorForObject:[[self parser] valuesBufferObjectForKey:@"~Card"] withOldCursorId:[aValue intValue]];
}
- (void)processBy_cardHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] == 0)
        return;
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    NSString *key = [NSString stringWithFormat:@"~clickingActionObjectByID_%@_%@", [[self parser] valuesBufferObjectForKey:@"cardHeader.type.ID"], aValue];
    [[self parser] setValuesBufferObject:card forKey:key];
    [[self parser] setValuesBufferObject:card forKey:[NSString stringWithFormat:@"~clickingActionObjectOnlyByID_%@", aValue]];
}
- (void)processBy_cardHeader_closeCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] == 0)
        return;
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    NSString *key = [NSString stringWithFormat:@"~leavingActionObjectByID_%@_%@", [[self parser] valuesBufferObjectForKey:@"cardHeader.type.ID"], aValue];
    [[self parser] setValuesBufferObject:card forKey:key];
}
- (void)processBy_cardHeader_openCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] == 0)
        return;
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    NSString *key = [NSString stringWithFormat:@"~arrivingActionObjectByID_%@_%@", [[self parser] valuesBufferObjectForKey:@"cardHeader.type.ID"], aValue];
    [[self parser] setValuesBufferObject:card forKey:key];
}
- (void)processBy_cardHeader_cardName_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue isKindOfClass:[NSData class]])
        aValue = [self stringForImportedData:aValue];
    if (![aValue isEqualToString:@""])
        [[[self parser] valuesBufferObjectForKey:@"~Card"] setHyperTitle:aValue];
}
// Flag 0x80: a marked card.
- (void)processBy_cardHeader_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (([aValue intValue] & 0x80) != 0)
        [[[self parser] valuesBufferObjectForKey:@"~Card"] setMarkedCard:YES];
}
- (void)processBy_cardHeader_master_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    _isMasterCardIdExists = NO;
    if ([aValue shortValue] != 0) {
        [[[self parser] valuesBufferObjectForKey:@"~Card"] setUserInfo:aValue forKey:@"~MasterCard"];
        _isMasterCardIdExists = YES;
    }
}
- (void)processBy_cardHeader_length_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}
- (void)processBy_cardHeader_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [[self parser] setValuesBufferObject:aValue forKey:@"~CardId"];
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    [card setUserInfo:aValue forKey:@"~CardId"];
    [card setCardIdOldFileFormat:[aValue intValue]];
    [[self parser] setValuesBufferObject:card forKey:[NSString stringWithFormat:@"~cardID_%@", aValue]];
}
// A new card record: the next card of the stack becomes the current one.
- (void)processFirstParentAppearance_cardHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters
{
    id card = [[self stack] hyperChildAtIndex:_currentCardIndex];
    _currentCardIndex++;
    [[self parser] setValuesBufferObject:card forKey:@"~Card"];
}
@end
