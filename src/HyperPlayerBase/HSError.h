#import "HyperPlayerBasePrefix.h"


@interface HSError : NSError
{
}
+ (id)cantOpenFileErrorWithFileName:(id)aName;
+ (id)appleScriptErrorWithDictionary:(id)aDictionary;
+ (id)fileErrorWithHSCode:(NSInteger)aCode URL:(id)aURL;
+ (id)fileErrorWithHSCode:(NSInteger)aCode filePath:(id)aPath;
+ (id)errorWithError:(id)aError;
+ (id)errorWithHSCode:(NSInteger)aCode;
- (id)localizedRecoveryOptions;
- (id)localizedRecoverySuggestion;
- (id)localizedFailureReason;
- (id)localizedDescription;
- (id)localizationForSuffix:(id)aSuffix;
@end

