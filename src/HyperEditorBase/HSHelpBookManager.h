#import "HyperEditorBasePrefix.h"


@interface HSHelpBookManager : NSObject
{
}
+ (id)helpBookName;
+ (id)helpTopicToAnchorDictionary;
+ (id)sharedHelpBookManager;
- (void)openHelpTopic:(id)aTopic;
- (void)openHomePage;
@end

