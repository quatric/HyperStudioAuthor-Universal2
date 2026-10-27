#import "HyperEditorBasePrefix.h"


@interface SMKShadow (SMKShadowCoding)
- (void)setShadowOffsetAsString:(id)aString;
- (id)shadowOffsetAsString;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraClassNameForStoring;
@end

