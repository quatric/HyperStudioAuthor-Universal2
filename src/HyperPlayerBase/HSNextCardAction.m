#import "HSNextCardAction.h"
#import "HyperPlayerBaseData.h"
@implementation HSNextCardAction
// With a fade a quarter of the way from the shortest to the longest
// transition.
+ (id)nextCardActionWithFadeTransition
{
    HSNextCardAction *action = [[[self alloc] init] autorelease];
    HSTransition *transition = [HSTransition transitionWithName:@"Fade"];
    [transition setDuration:HSMaxTransitionDuration * 0.25 + HSMinTransitionDuration * 0.75];
    [action setTransition:transition];
    return action;
}
- (id)XMLElementName
{
    return @"actNextCard";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
// Only within the action's own stack.
- (BOOL)canRunInContext:(id)aContext
{
    if (![super canRunInContext:aContext])
        return NO;
    return [[aContext document] stack] == [self stack];
}
- (BOOL)canGoToHyperDestinationCard
{
    return YES;
}
- (id)createNavigationOperation
{
    return [[HSNavigationOperation alloc] initWithDestinationStackURL:nil destinationCardIndex:[self destinationCardIndex] transition:[self transition]];
}
// The card after this one; the first after the last.
- (NSUInteger)destinationCardIndex
{
    NSUInteger index = [[[self card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperIndex];
    if (index == NSNotFound)
        return NSNotFound;
    NSUInteger count = [[[self stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperCount];
    return index + 1 < count ? index + 1 : 0;
}
@end
