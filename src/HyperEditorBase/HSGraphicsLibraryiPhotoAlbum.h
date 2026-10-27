#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryiPhotoAlbum : NSObject <NSCopying, HSLibraryMediaItem, NSObject, HSLibraryMediaDataFolder, HSLibraryMediaDataItem>
{
    NSMutableArray *_photos;
    NSString *_name;
    NSString *_type;
    unsigned int _albumID;
    unsigned int _parentID;
    float _libraryVersion;
    NSMutableArray *_subalbums;
    BOOL _isMaster;
    NSImage *_lastImportImage;
    NSImage *_libraryImage;
    NSImage *_library4Image;
    NSImage *_smartAlbumImage;
    NSImage *_albumImage;
    NSImage *_specialMonthImage;
    NSImage *_specialRollImage;
    NSImage *_folderImage;
    NSImage *_bookImage;
    NSImage *_slideshowImage;
    NSImage *_flaggedImage;
    NSImage *_eventImage;
}
+ (id)rootLevelAlbumsResolvingParentIndexesInAlbums:(id)aAlbums;
- (id)copyWithZone:(NSZone *)aZone;
- (BOOL)isEvent;
- (BOOL)isSlideshow;
- (BOOL)isBook;
- (BOOL)isFolder;
- (BOOL)isSmart;
- (BOOL)isSpecialMonth;
- (BOOL)isSpecialRoll;
- (BOOL)isFlagged;
- (BOOL)isLastImport;
- (NSInteger)compareDecrease:(id)aDecrease;
- (NSInteger)compareIncrease:(id)aIncrease;
- (id)filterPhotos:(id)aPhotos byCategory:(id)aCategory;
- (BOOL)isMaster;
- (NSInteger)sortWeight;
- (id)photoAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfPhotos;
- (id)dataDisplayName;
- (id)dataURL;
- (id)dataFolderAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataFolders;
- (id)dataItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataItems;
- (id)subitemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSubitems;
- (id)actionTarget;
- (SEL)actionSelector;
- (id)actionImage;
- (id)displayName;
- (id)icon;
- (void)addSubalbum:(id)aSubalbum;
- (void)dealloc;
- (id)initWithDictionaryRepresentation:(id)aRepresentation photos:(id)aPhotos version:(NSInteger)aVersion;
- (id)initWithName:(id)aName dictionaryRepresentation:(id)aRepresentation photos:(id)aPhotos version:(NSInteger)aVersion;
- (id)init;
@end

