#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatImportProblemsChecker.h"


@interface HSOldFormatImportProblemsChecker (Card)
- (void)processBy_cardHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_closeCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_openCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
@end

