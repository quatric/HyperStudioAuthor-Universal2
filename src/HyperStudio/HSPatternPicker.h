#import "HyperStudioPrefix.h"
#import "HSColorPicker.h"


@interface HSPatternPicker : HSColorPicker
{
    SMKGridControl *_gridControl;
    NSImageView *_imageView;
    id<HSLibraryMediaDataFolder> _mediaDataFolder;
    NSMutableArray *_colors;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedPatternPicker;
- (void)chooseImageFromFile:(id)aFile;
- (void)imageDidChangeInImageView:(id)aView;
- (void)setColor:(id)aColor;
- (id)nibName;
- (id)imageName;
- (NSInteger)currentMode;
- (BOOL)supportsMode:(NSInteger)aMode;
- (id)buttonToolTip;
- (id)imageForColor:(id)aColor;
- (id)colors;
- (void)addItemsFromMediaDataFolder:(id)aFolder;
- (id)mediaData;
- (id)mediaDataProvider;
- (id)mediaDataFolder;
- (id)pathToMediaFolder;
- (id)mediaType;
- (id)mediaDataFolderAtPath:(id)aPath;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (Class)cellClass;
- (void)didLoadNib;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

