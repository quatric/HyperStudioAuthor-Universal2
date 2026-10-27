#import <Foundation/Foundation.h>

// The media library helpers' shared code (each helper class had its own
// copy in the original): directory scans that collect file URLs, or objects
// made from them, and the text attributes of library item cells.

void HSLibraryPlainScanDirectory(NSString *aDirectory, id aTypes, NSMutableArray *aArray, Class aClass);
void HSLibraryScanDirectoryToDictionary(Class aHelper, NSString *aDirectory, id aTypes, NSMutableDictionary *aDictionary, Class aClass);
void HSLibraryScanDirectoryToArray(Class aHelper, NSString *aDirectory, id aTypes, NSMutableArray *aArray, Class aClass);
NSMutableArray *HSLibraryFolderContents(NSString *aFolder);
NSMutableDictionary *HSLibraryDefaultAttributes(id aCell);

// The iApps (iPhoto, iTunes) helpers' shared code; aTable is the strings
// table with the app's keys.
NSArray *HSiAppsRecentDatabasesForKeys(Class aHelper, NSArray *aKeys, NSString *aTable);
NSBundle *HSiAppsApplicationBundle(NSString *aBundleID);
NSArray *HSiAppsArrayByRemovingNonExistedPaths(Class aHelper, NSArray *aURLs);
NSURL *HSiAppsResolveAliasesInURL(Class aHelper, NSURL *aURL);
