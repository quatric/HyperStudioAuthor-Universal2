#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryBuiltInMediaDataProvider : NSObject <HSLibraryMediaDataProvider, NSObject, HSLibraryMediaItem, HSLibraryMediaFiltering, HSLibraryMediaUserInterface>
{
    NSMutableArray *_rootItems;
}
+ (NSInteger)defaultSortOrder;
+ (void)setDefaultSortOrder:(NSInteger)aOrder;
- (id)rootItems;
- (id)mediaDisplayName;
- (id)mediaIcon;
- (id)rootItem;
- (id)displayStringForCategory:(id)aCategory;
- (id)searchCategories;
- (id)subitemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSubitems;
- (id)actionTarget;
- (SEL)actionSelector;
- (id)actionImage;
- (id)displayName;
- (id)icon;
- (id)queryInterface:(id)aInterface;
- (BOOL)isPlayable;
- (BOOL)supportedData:(id)aData error:(id *)aError;
- (BOOL)supportedData:(id)aData;
- (id)providerType;
- (id)mediaType;
- (BOOL)sourceApplicationPresents;
- (void)dealloc;
@end

