#import "HyperStudioPrefix.h"


@interface HSStackChoosableItemsDataSource : NSObject <HSChooserDataSource>
{
    NSArray *_sortedMediaUIDs;
    int _mediaGroup;
    HSStack *_stack;
}
- (void)updateChoosableItemsIfNeeded;
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfChoosableItems;
- (BOOL)excludesUnusedMedia;
- (void)setMediaGroup:(NSInteger)aGroup;
- (NSInteger)mediaGroup;
- (id)sortedMediaUIDs;
- (id)mediaUIDs;
- (void)stopObserveNotificationFromStack:(id)aStack;
- (void)startObserveNotificationFromStack:(id)aStack;
- (void)setStack:(id)aStack;
- (id)stack;
- (void)dealloc;
- (id)initWithStack:(id)aStack;
@end

