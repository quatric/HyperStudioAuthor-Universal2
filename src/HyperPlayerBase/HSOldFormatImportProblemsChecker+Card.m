#import "HSOldFormatImportProblemsChecker+Card.h"
@implementation HSOldFormatImportProblemsChecker (Card)
- (void)processBy_cardHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addCursorImportingProblemIfNeededForOldCursorID:[aValue intValue]];
}
- (void)processBy_cardHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
- (void)processBy_cardHeader_closeCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
- (void)processBy_cardHeader_openCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
@end
