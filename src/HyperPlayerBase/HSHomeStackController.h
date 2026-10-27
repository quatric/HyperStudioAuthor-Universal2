#import "HyperPlayerBasePrefix.h"


@interface HSHomeStackController : NSObject
{
    unsigned int _defaultCardIndex;
    NSURL *_tempHomeStackURL;
}
+ (id)homeStackPathPreferencesKey;
+ (BOOL)isHomeStackSupportedByCurrentEnvironment;
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedHomeStackController;
- (void)updateDefaultCardIndexUsingCurrentCard:(id)aCard;
- (NSUInteger)defaultCardIndex;
- (void)resetHomeStackURL;
- (void)setHomeStackURL:(id)aURL storeInDefaults:(BOOL)aDefaults;
- (void)setHomeStackURL:(id)aURL;
- (id)defaultHomeStackURL;
- (id)homeStackURL;
- (id)homeStackURLFromPreferences;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

