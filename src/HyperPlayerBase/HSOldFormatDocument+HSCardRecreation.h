#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"


@interface HSOldFormatDocument (HSCardRecreation)
- (void)processBy_cardHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_closeCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_openCdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_cardName_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_master_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_length_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_cardHeader_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processFirstParentAppearance_cardHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters;
@end

