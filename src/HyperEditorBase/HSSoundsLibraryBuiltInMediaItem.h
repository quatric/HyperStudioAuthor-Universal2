#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryBuiltInMediaItem : NSObject <HSLibraryMediaItem, NSObject>
{
    id<HSLibraryMediaItem> _mediaItem;
    NSString *_mediaType;
    NSMutableArray *_children;
}
+ (id)itemWithMediaItem:(id)aItem mediaType:(id)aType;
- (id)children;
- (id)initWithMediaItem:(id)aItem mediaType:(id)aType;
- (id)subitemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSubitems;
- (id)actionTarget;
- (SEL)actionSelector;
- (id)actionImage;
- (id)displayName;
- (id)icon;
- (id)mediaItem;
- (id)mediaType;
- (void)dealloc;
@end

