#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSCardShufflerAction : HSNBAAction <HSCardShufflerActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSCardShufflerActionEndingCardIndexAttribute, HSCardShufflerActionStartingCardIndexAttribute, HSCardShufflerActionShouldClearChangesAttribute>
{
    unsigned int _startingCardIndex;
    unsigned int _endingCardIndex;
    BOOL _shouldClearChanges;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)shuffleCards;
- (NSRange)rangeForRandom;
- (void)startInContext:(id)aContext;
- (void)setEndingCardIndex:(NSUInteger)aIndex;
- (NSUInteger)endingCardIndex;
- (void)setStartingCardIndex:(NSUInteger)aIndex;
- (NSUInteger)startingCardIndex;
- (void)setShouldClearChanges:(BOOL)aChanges;
- (BOOL)shouldClearChanges;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)init;
@end

