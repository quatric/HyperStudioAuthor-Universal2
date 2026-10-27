#import "HSHelpBookManager.h"

// Opens help topics by their anchors (HelpTopics.plist) in the app's help
// book.

@implementation HSHelpBookManager

+ (id)helpBookName
{
    static id name;
    if (name == nil)
        name = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleHelpBookName"] retain];
    return name;
}

+ (id)helpTopicToAnchorDictionary
{
    static id topics;
    if (topics == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HelpTopics" ofType:@"plist"];
        if (path != nil)
            topics = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return topics;
}

+ (id)sharedHelpBookManager
{
    static id manager;
    if (manager == nil)
        manager = [[[self class] alloc] init];
    return manager;
}

// An unknown topic opens the home page.
- (void)openHelpTopic:(id)aTopic
{
    NSString *anchor = [[[self class] helpTopicToAnchorDictionary] objectForKey:aTopic];
    if (anchor == nil)
        anchor = [[[self class] helpTopicToAnchorDictionary] objectForKey:@"HSHomeTopic"];
    if (anchor != nil)
        [[NSHelpManager sharedHelpManager] openHelpAnchor:anchor inBook:[[self class] helpBookName]];
}

- (void)openHomePage
{
    [self openHelpTopic:@"HSHomeTopic"];
}

@end
