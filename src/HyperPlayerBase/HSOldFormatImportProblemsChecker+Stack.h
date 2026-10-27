#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatImportProblemsChecker.h"


@interface HSOldFormatImportProblemsChecker (Stack)
- (void)processBy_stackHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_closeStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_openStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_newreserved2_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
@end

