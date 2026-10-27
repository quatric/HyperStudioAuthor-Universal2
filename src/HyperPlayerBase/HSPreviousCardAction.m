#import "HSPreviousCardAction.h"
@implementation HSPreviousCardAction
- (id)XMLElementName
{
    return @"actPreviousCard";
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
// The card before this one; the last card before the first.
- (NSUInteger)destinationCardIndex
{
    NSUInteger index = [[[self card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperIndex];
    if (index == NSNotFound)
        return NSNotFound;
    id stack = [[self stack] queryHyperInterface:@protocol(HSNodeContainer)];
    if (index == 0)
        index = [stack hyperCount];
    return index - 1;
}
@end
