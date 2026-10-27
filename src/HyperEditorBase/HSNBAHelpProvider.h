#import "HyperEditorBasePrefix.h"


@interface HSNBAHelpProvider : NSObject
{
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedNBAHelpProvider;
- (id)localizedHelpForActionOfType:(id)aType;
- (id)localizedDescriptionForActionOfType:(id)aType;
- (id)shortDescriptionFileNameForActionType:(id)aType;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

