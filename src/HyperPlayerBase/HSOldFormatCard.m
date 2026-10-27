#import "HSOldFormatCard.h"
// A card of an old-format (HyperStudio 4) stack during import: its id, its
// master (background) card id and index, and the cards recreated from it.
@implementation HSOldFormatCard
- (id)description
{
    return [NSString stringWithFormat:@"%@ {cardId: %d, master: %d, index: %d, recreatedCard: %@}",
                                      [super description], _cardId, _master, _index, _recreatedCard];
}
- (void)setRecreatedMasterCard:(id)aCard
{
    if (_recreatedMasterCard != aCard) {
        [_recreatedMasterCard release];
        _recreatedMasterCard = [aCard retain];
    }
}
- (id)recreatedMasterCard
{
    return _recreatedMasterCard;
}
- (void)setRecreatedCard:(id)aCard
{
    if (_recreatedCard != aCard) {
        [_recreatedCard release];
        _recreatedCard = [aCard retain];
    }
}
- (id)recreatedCard
{
    return _recreatedCard;
}
- (void)setIndex:(NSInteger)aIndex
{
    _index = (int)aIndex;
}
- (NSInteger)index
{
    return _index;
}
- (void)setMaster:(NSInteger)aMaster
{
    _master = (int)aMaster;
}
- (NSInteger)master
{
    return _master;
}
- (void)setCardId:(NSInteger)aId
{
    _cardId = (int)aId;
}
- (NSInteger)cardId
{
    return _cardId;
}
- (void)dealloc
{
    [_recreatedCard release];
    [_recreatedMasterCard release];
    [super dealloc];
}
@end
