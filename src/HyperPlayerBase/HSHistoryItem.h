#import "HyperPlayerBasePrefix.h"


@interface HSHistoryItem : NSObject
{
    HSUID *_cardUID;
    HSStack *_cardStack;
    NSString *_cardDocumentPath;
    id<HSTransitionAttributes> _cardTransition;
}
+ (id)itemWithCard:(id)aCard transition:(id)aTransition;
- (void)removeLinkOnStack;
- (id)cardStack;
- (id)cardUID;
- (id)createNavigationOperationWithTransition:(id)aTransition;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)setCardDocumentPath:(id)aPath;
- (id)cardDocumentPath;
- (void)dealloc;
- (id)initWithCard:(id)aCard transition:(id)aTransition;
@end

@interface HSHistoryStack : NSObject
{
    NSMutableArray *_back;
    NSMutableArray *_forward;
    NSMutableArray *_currentStack;
    NSMutableArray *_navigationStack;
    HSHistoryItem *_lastMarkedCard;
    BOOL _isGoingInStack;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedHistoryStack;
- (void)removeCardWithUID:(id)aUID inStack:(id)aStack navigationStack:(id)aStack2;
- (void)removeStack:(id)aStack navigationStack:(id)aStack2;
- (void)removeCardWithUID:(id)aUID inStack:(id)aStack;
- (void)removeStack:(id)aStack;
- (void)removeAllLinksOnStack:(id)aStack navigationStack:(id)aStack2;
- (void)removeAllLinksOnStack:(id)aStack;
- (id)lastMarkedCard;
- (void)startForwardOperation;
- (void)startBackOperation;
- (void)concludeHistoryOperation:(BOOL)aOperation;
- (void)startHistoryOperation;
- (id)createLastMarkedCardNavigationOperationWithTransition:(id)aTransition;
- (id)createForwardNavigationOperationWithTransition:(id)aTransition;
- (id)createBackNavigationOperationWithTransition:(id)aTransition;
- (void)pushCard:(id)aCard withTransition:(id)aTransition;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)init;
@end

