#import "HSOldFormatImportProblemsChecker+Stack.h"
@implementation HSOldFormatImportProblemsChecker (Stack)
- (void)processBy_stackHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self addCursorImportingProblemIfNeededForOldCursorID:[aValue intValue]];
}
- (void)processBy_stackHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
- (void)processBy_stackHeader_closeStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
- (void)processBy_stackHeader_openStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 0)
        [self checkActionForId:[aValue intValue]];
}
// 'LP': the stack was saved by the legacy player.
- (void)processBy_stackHeader_newreserved2_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    _isLegacyPlayerDetected = [aValue intValue] == 0x4c50;
}
@end
