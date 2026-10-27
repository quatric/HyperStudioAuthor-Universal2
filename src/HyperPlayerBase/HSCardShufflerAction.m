#import "HSCardShufflerAction.h"
// "Shuffle cards": randomly reorders the cards between two indexes (by
// default only for this session: the moves aren't saved).
@implementation HSCardShufflerAction
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self startingCardIndex]] forKey:@"startingCardIndex"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self endingCardIndex]] forKey:@"endingCardIndex"];
    [dictionary setObject:[self shouldClearChanges] ? @"1" : @"0" forKey:@"shouldClearChanges"];
    return dictionary;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setStartingCardIndex:[[[aRepresentation attributeForName:@"startingCardIndex"] stringValue] intValue]];
    [self setEndingCardIndex:[[[aRepresentation attributeForName:@"endingCardIndex"] stringValue] intValue]];
    [self setShouldClearChanges:[[[aRepresentation attributeForName:@"shouldClearChanges"] stringValue] hyperBoolValue]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"startingCardIndex" stringValue:[NSString stringWithFormat:@"%u", (unsigned int)[self startingCardIndex]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"endingCardIndex" stringValue:[NSString stringWithFormat:@"%u", (unsigned int)[self endingCardIndex]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"shouldClearChanges" stringValue:[self shouldClearChanges] ? HSXMLStoring1String : HSXMLStoring0String]];
    return element;
}
- (id)XMLElementName
{
    return @"actCardShuffler";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
// Two cards swap half the time; more get each card moved to a random place
// in the range.
- (void)shuffleCards
{
    NSRange range = [self rangeForRandom];
    if (range.length <= 1)
        return;
    id cards = [[self stack] queryHyperInterface:@protocol(HSNodeContainer)];
    SEL move = _shouldClearChanges ? @selector(moveTemporarilyHyperChildFromIndex:toIndex:) : @selector(moveHyperChildFromIndex:toIndex:);
    if (range.length < 3) {
        if ((unsigned int)random() % range.length != 0)
            ((void (*)(id, SEL, NSUInteger, NSUInteger))objc_msgSend)(cards, move, range.location, range.location + 1);
        return;
    }
    NSUInteger index = range.location;
    for (NSUInteger count = range.length; count != 0; count--, index++) {
        move = _shouldClearChanges ? @selector(moveTemporarilyHyperChildFromIndex:toIndex:) : @selector(moveHyperChildFromIndex:toIndex:);
        ((void (*)(id, SEL, NSUInteger, NSUInteger))objc_msgSend)(cards, move, index, (unsigned int)random() % range.length + range.location);
    }
}
// The indexes in either order, clamped to the stack.
- (NSRange)rangeForRandom
{
    unsigned int last = (unsigned int)[[[self stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperCount] - 1;
    unsigned int end = _endingCardIndex > last ? last : _endingCardIndex;
    unsigned int start = _startingCardIndex <= last ? _startingCardIndex : last;
    if (end <= start)
        return NSMakeRange(end, start - end + 1);
    return NSMakeRange(start, end - start + 1);
}
- (void)startInContext:(id)aContext
{
    [self shuffleCards];
    [self notifyDidFinish];
}
- (void)setEndingCardIndex:(NSUInteger)aIndex
{
    if ([self endingCardIndex] == aIndex)
        return;
    [(HSCardShufflerAction *)[[self undoManager] prepareWithInvocationTarget:self] setEndingCardIndex:_endingCardIndex];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCardShufflerActionEndingCardIndexAttribute) ofObject:self withUserInfo:nil];
    _endingCardIndex = (unsigned int)aIndex;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCardShufflerActionEndingCardIndexAttribute) ofObject:self withUserInfo:nil];
}
- (NSUInteger)endingCardIndex
{
    return _endingCardIndex;
}
- (void)setStartingCardIndex:(NSUInteger)aIndex
{
    if ([self startingCardIndex] == aIndex)
        return;
    [(HSCardShufflerAction *)[[self undoManager] prepareWithInvocationTarget:self] setStartingCardIndex:_startingCardIndex];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCardShufflerActionStartingCardIndexAttribute) ofObject:self withUserInfo:nil];
    _startingCardIndex = (unsigned int)aIndex;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCardShufflerActionStartingCardIndexAttribute) ofObject:self withUserInfo:nil];
}
- (NSUInteger)startingCardIndex
{
    return _startingCardIndex;
}
- (void)setShouldClearChanges:(BOOL)aChanges
{
    if (!_shouldClearChanges == !aChanges)
        return;
    [(HSCardShufflerAction *)[[self undoManager] prepareWithInvocationTarget:self] setShouldClearChanges:[self shouldClearChanges]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCardShufflerActionShouldClearChangesAttribute) ofObject:self withUserInfo:nil];
    _shouldClearChanges = aChanges;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCardShufflerActionShouldClearChangesAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)shouldClearChanges
{
    return _shouldClearChanges;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"shouldClearChanges", @"startingCardIndex", @"endingCardIndex", nil]];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _shouldClearChanges = YES;
    return self;
}
@end
