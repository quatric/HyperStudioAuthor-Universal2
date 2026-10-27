#import "HyperStudioPrefix.h"


@interface HSReadyMadeCardsProvider : NSObject
{
    NSMenu *_readyMadeCardsMenu;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedReadyMadeCardsProvider;
- (void)awakeFromNib;
- (void)readyMadeCardsChanged:(id)aChanged;
- (void)removeReadyMadeCardsItems;
- (void)addReadyMadeCardsItems;
- (void)addReadyMadeCardsItemsAtPath:(id)aPath toMenu:(id)aMenu recursively:(BOOL)aRecursively withSeparator:(BOOL)aSeparator;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

