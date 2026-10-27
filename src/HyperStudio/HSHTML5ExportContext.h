#import "HyperStudioPrefix.h"
#import "HSExportContext.h"


@interface HSHTML5ExportContext : HSExportContext
{
    NSString *_documentType;
    NSMutableSet *_currentLinkedStacks;
    NSMutableDictionary *_groupUIDs;
    NSMutableDictionary *_mediaUIDs;
    NSMutableDictionary *_shapeUIDs;
    NSMutableArray *_exportedMovieObjects;
    HSHTML5LinkedStacksContext *_linkedStacksContext;
    unsigned int _shouldTerminateExport:1;
}
- (id)shapeNameForGroupUID:(id)aUID;
- (void)addGroupUID:(id)aUID withShapeName:(id)aName;
- (id)mediaNameForUID:(id)aUID;
- (void)addUID:(id)aUID withMediaName:(id)aName;
- (id)mediaNameForGroupUID:(id)aUID;
- (void)addGroupUID:(id)aUID withMediaName:(id)aName;
- (id)linkedStackURLs;
- (void)addLinkedStackURL:(id)aURL;
- (BOOL)shouldAddLinkedStacks;
- (BOOL)isRootStackURL:(id)aURL;
- (id)nameForLinkedStackURL:(id)aURL;
- (void)setShouldTerminateExport:(BOOL)aExport;
- (BOOL)shouldTerminateExport;
- (id)linkedStacksContext;
- (id)documentType;
- (void)dealloc;
- (id)initWithDocument:(id)aDocument ofType:(id)aType linkedStacksContext:(id)aContext;
- (id)exportedMovieObjects;
- (void)addExportedMovieObject:(id)aObject withMediaName:(id)aName;
- (id)mediaNameForExportedMovieObject:(id)aObject;
@end

