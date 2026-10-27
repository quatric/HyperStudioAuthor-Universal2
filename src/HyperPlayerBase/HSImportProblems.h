#import "HyperPlayerBasePrefix.h"


@interface HSImportProblems : NSObject
{
    NSMutableDictionary *_problems;
}
- (NSInteger)runUserConfirmationAlert;
- (BOOL)needToShowAlert;
- (id)reportTextWithFilename:(id)aFilename;
- (id)problemsDescriptions;
- (void)addImportingProblemForCode:(NSInteger)aCode point:(id)aPoint info:(id)aInfo;
- (id)problems;
- (void)dealloc;
@end

