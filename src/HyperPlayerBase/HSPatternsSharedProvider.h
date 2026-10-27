#import "HyperPlayerBasePrefix.h"


@interface HSPatternsSharedProvider : NSObject <HSPatternsSharedProvider, NSObject>
{
    NSMutableDictionary *_patterns;
}
+ (id)sharedPatternsProvider;
- (id)patterns;
- (id)patternExtensions;
- (id)hyperPatternPathForName:(id)aName;
- (id)hyperPatternForName:(id)aName;
- (id)hyperPatternNames;
- (void)dealloc;
@end

