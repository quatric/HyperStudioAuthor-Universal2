#import "HyperStudioPrefix.h"


@interface NSAttributedString (NSAttributedStringHSExtensions)
+ (id)hyperLoadFromXMLRepresentation:(id)aRepresentation inContext:(id)aContext;
+ (id)hyperTextAttributesFromXMLRepresentation:(id)aRepresentation inContext:(id)aContext;
+ (id)hyperAcceptableStringKeysAndAttributesForStoring;
- (id)hyperAttributedStringByAddingDefaultParagraphLineHeightAttribute;
- (id)hyperXMLRepresentationInContext:(id)aContext UID:(id)aUID;
- (id)hyperXMLNodeRepresentationInContext:(id)aContext UID:(id)aUID attributes:(id)aAttributes substring:(id)aSubstring;
@end

