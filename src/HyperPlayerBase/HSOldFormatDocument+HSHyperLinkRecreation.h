#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"


@interface HSOldFormatDocument (HSHyperLinkRecreation)
- (void)processBy_link_linkText_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_linkHeader_fieldID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
@end

