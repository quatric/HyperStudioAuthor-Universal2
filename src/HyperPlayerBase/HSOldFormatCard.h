#import "HyperPlayerBasePrefix.h"


@interface HSOldFormatCard : NSObject
{
    int _cardId;
    int _master;
    int _index;
    HSCard *_recreatedCard;
    HSCard *_recreatedMasterCard;
}
- (id)description;
- (void)setRecreatedMasterCard:(id)aCard;
- (id)recreatedMasterCard;
- (void)setRecreatedCard:(id)aCard;
- (id)recreatedCard;
- (void)setIndex:(NSInteger)aIndex;
- (NSInteger)index;
- (void)setMaster:(NSInteger)aMaster;
- (NSInteger)master;
- (void)setCardId:(NSInteger)aId;
- (NSInteger)cardId;
- (void)dealloc;
@end

