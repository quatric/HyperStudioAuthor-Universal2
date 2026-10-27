#import "HyperEditorBasePrefix.h"


@interface HSLibraryPasteboardDataProvider : NSObject
{
    NSArray *_itemsArray;
}
+ (id)dataProviderWithItems:(id)aItems;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (void)dealloc;
- (id)initWithItems:(id)aItems;
@end

