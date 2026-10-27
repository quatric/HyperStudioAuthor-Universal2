#import "HyperPlayerBasePrefix.h"


@interface HSHypertextLinkLegacyLoading : NSObject <EXKeyValueCoding>
{
    id _hyperObject;
}
+ (id)loaderWithHyperObject:(id)aObject;
- (id)reloadExtraDictionaryRepresentation:(id)aRepresentation;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

