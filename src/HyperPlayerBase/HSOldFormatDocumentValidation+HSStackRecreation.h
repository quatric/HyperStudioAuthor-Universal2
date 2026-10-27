#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"


@interface HSOldFormatDocumentValidation (HSStackRecreation)
- (void)processBy_stackHeader_autoButtonOn_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_locked_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_advancedUser_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_autoSaveOn_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_cardHeight_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_cardWidth_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_stackDepth_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_offsetToBlobs_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_numcards_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_version_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
@end

@interface HSOldFormatDocument (HSStackRecreation)
- (void)processBy_stackHeader_offsetToBlobs_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_closeStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_openStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_cardHeight_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_password_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_locked_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_presFlags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_presColor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_presMode_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_autoButtonOn_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_stackHeader_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processFirstParentAppearance_stackHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters;
@end

