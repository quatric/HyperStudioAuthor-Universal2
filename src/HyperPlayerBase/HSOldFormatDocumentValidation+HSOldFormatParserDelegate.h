#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"


@interface HSOldFormatDocumentValidation (HSOldFormatParserDelegate)
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters;
@end

@interface HSOldFormatDocument (HSOldFormatParserDelegate)
- (void)oldFormatParser:(id)aParser didFinishParsingWithTypesTree:(id)aTree parsingType:(id)aType;
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters;
@end

