#import "HyperStudioPrefix.h"


@interface HSCoachingInfoProvider : NSObject
{
    NSDictionary *_coaching;
}
+ (id)sharedProvider;
- (id)coachingInfoForKey:(id)aKey;
- (id)coachingInfoForObject:(id)aObject;
- (id)coachingKeyForObject:(id)aObject;
- (id)coachingInfo;
- (void)setCoachingInfo:(id)aInfo;
- (void)dealloc;
@end

