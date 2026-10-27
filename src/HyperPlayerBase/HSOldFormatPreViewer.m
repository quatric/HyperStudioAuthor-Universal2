#import "HSOldFormatPreViewer.h"
// A first pass over an old-format (HyperStudio 4) stack: collects its cards
// (id, master, index) as the parser reports values. Values are dispatched
// by name to methods that exist:
//   processFirstParentAppearance_<parent>_WithParser:value:forName:parameters:
//   processFirstParentAppearanceWithParser:value:forName:parentName:parameters:
//     (both when the parent name changes),
//   processByParent_<parent>_WithParser:value:forName:parameters:
//   processBy_<parent>_<name>_WithParser:value:parameters:
@implementation HSOldFormatPreViewer
- (void)processBy_cardHeader_master_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [[self currentCard] setMaster:[aValue intValue]];
}
- (void)processBy_cardHeader_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int cardId = [aValue intValue];
    [[self currentCard] setCardId:cardId];
    [[self cardsById] setObject:[self currentCard] forKey:[NSString stringWithFormat:@"%d", cardId]];
}
- (void)processFirstParentAppearance_cardHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters
{
    HSOldFormatCard *card = [[HSOldFormatCard new] autorelease];
    [[self cards] addObject:card];
    [self setCurrentCard:card];
    [[self currentCard] setIndex:[[self cards] count] - 1];
}
static void HSOldFormatPreViewerInvoke(id target, SEL selector, id *arguments, NSUInteger count)
{
    if (![target respondsToSelector:selector])
        return;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    for (NSUInteger i = 0; i < count; i++)
        [invocation setArgument:&arguments[i] atIndex:i + 2];
    [invocation invoke];
    [pool release];
}
// The last parent name seen is shared by all previewers, as in the
// original.
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters
{
    static NSString *lastParentName = nil;
    if (![aName2 isEqualToString:lastParentName]) {
        [lastParentName release];
        lastParentName = [aName2 retain];
        id firstArguments[] = { aParser, aValue, aName, aParameters };
        HSOldFormatPreViewerInvoke(self,
            NSSelectorFromString([NSString stringWithFormat:
                @"processFirstParentAppearance_%@_WithParser:value:forName:parameters:", aName2]),
            firstArguments, 4);
        id allArguments[] = { aParser, aValue, aName, aName2, aParameters };
        HSOldFormatPreViewerInvoke(self,
            NSSelectorFromString(@"processFirstParentAppearanceWithParser:value:forName:parentName:parameters:"),
            allArguments, 5);
    }
    id parentArguments[] = { aParser, aValue, aName, aParameters };
    HSOldFormatPreViewerInvoke(self,
        NSSelectorFromString([NSString stringWithFormat:@"processByParent_%@_WithParser:value:forName:parameters:", aName2]),
        parentArguments, 4);
    id nameArguments[] = { aParser, aValue, aParameters };
    HSOldFormatPreViewerInvoke(self,
        NSSelectorFromString([NSString stringWithFormat:@"processBy_%@_%@_WithParser:value:parameters:", aName2, aName]),
        nameArguments, 3);
}
- (void)setParser:(id)aParser
{
    if (_parser != aParser) {
        [_parser release];
        _parser = [aParser retain];
    }
}
- (id)parser
{
    return _parser;
}
- (void)setCurrentCard:(id)aCard
{
    if (_currentCard != aCard) {
        [_currentCard release];
        _currentCard = [aCard retain];
    }
}
- (id)currentCard
{
    return _currentCard;
}
- (void)setCardsById:(id)aId
{
    if (_cardsById != aId) {
        [_cardsById release];
        _cardsById = [aId retain];
    }
}
- (id)cardsById
{
    if (_cardsById == nil)
        _cardsById = [NSMutableDictionary new];
    return _cardsById;
}
- (void)setCards:(id)aCards
{
    if (_cards != aCards) {
        [_cards release];
        _cards = [aCards retain];
    }
}
- (id)cards
{
    if (_cards == nil)
        _cards = [NSMutableArray new];
    return _cards;
}
- (void)dealloc
{
    [_cards release];
    [_cardsById release];
    [_currentCard release];
    [_parser release];
    [super dealloc];
}
@end
