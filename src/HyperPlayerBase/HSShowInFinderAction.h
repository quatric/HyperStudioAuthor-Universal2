#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSShowInFinderAction : HSNBAAction <HSShowInFinderActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSShowInFinderActionAttribute>
{
    NSString *_filePath;
}
- (void)applicationDidActivate:(id)aActivate;
- (void)setFilePath:(id)aPath;
- (id)filePath;
- (BOOL)isValid;
- (BOOL)isAbleToStartInInvalidState;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

