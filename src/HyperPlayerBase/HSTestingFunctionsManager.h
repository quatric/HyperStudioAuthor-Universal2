#import "HyperPlayerBasePrefix.h"


@interface HSTestingFunctionsManager : NSObject <HSTestingFunctions, HyperInterface, NSObject>
{
    HSStack *_stack;
    NSString *_userName;
    NSMutableDictionary *_cardUIDsToAnswersMap;
    NSOutputStream *_stream;
}
- (id)implementationForHyperObject:(id)aObject;
- (id)hyperObject;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)queryHyperInterface:(id)aInterface;
- (void)resetTestingInformation;
- (void)storeTestingInformation;
- (id)stringForStoring;
- (NSUInteger)numberOfAnswers;
- (NSUInteger)numberOfCorrectAnswers;
- (void)setUserName:(id)aName;
- (id)userName;
- (void)recordIncorrectAnswerForObjectWithUID:(id)aUID cardUID:(id)aUID2;
- (void)recordCorrectAnswerForObjectWithUID:(id)aUID cardUID:(id)aUID2;
- (id)cardUIDsToAnswersMap;
- (void)dealloc;
- (id)initWithStack:(id)aStack;
@end

