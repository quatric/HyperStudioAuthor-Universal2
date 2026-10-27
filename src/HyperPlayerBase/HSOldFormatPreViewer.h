#import "HyperPlayerBasePrefix.h"


@interface HSOldFormatPreViewer : NSObject
{
    NSMutableArray *_cards;
    NSMutableDictionary *_cardsById;
    HSOldFormatCard *_currentCard;
    HSOldFormatParser *_parser;
}
- (void)processBy_cardHeader_master_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processFirstParentAppearance_cardHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters;
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters;
- (void)setParser:(id)aParser;
- (id)parser;
- (void)setCurrentCard:(id)aCard;
- (id)currentCard;
- (void)setCardsById:(id)aId;
- (id)cardsById;
- (void)setCards:(id)aCards;
- (id)cards;
- (void)dealloc;
@end

