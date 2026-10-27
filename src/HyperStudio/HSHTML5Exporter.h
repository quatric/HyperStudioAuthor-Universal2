#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSHTML5Exporter : HSExporter2
{
    BOOL _isDownloadFinished;
    NSMutableSet *_linkedStackPaths;
    unsigned int _linkedStacksLevel;
    HSHTML5ExportContext *_context;
    NSSize _widgetSize;
    HSXMLNode *_embeddedCode;
}
+ (id)embeddedCodeForDocument:(id)aDocument cardWidth:(CGFloat)aWidth cardHeight:(CGFloat)aHeight urlPath:(id)aPath;
- (void)terminateExport;
- (id)embeddedCode;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (void)correctTemplate:(id)aTemplate forDocument:(id)aDocument ofType:(id)aType;
- (id)stackDataManifestFiles;
- (id)stringContentsOfFileWrapperAtKey:(id)aKey atDirectory:(id)aDirectory;
- (void)finalizeExportForDocument:(id)aDocument;
- (id)embeddedCodeForDocument:(id)aDocument;
- (id)unsupportedFeaturesInDocument:(id)aDocument;
- (void)linkedStacksFileWrapper:(id)aWrapper withContext:(id)aContext currentLevel:(NSUInteger)aLevel;
- (void)correctWidgetSizeWithLinkedStackSize:(NSSize)aSize;
- (id)resourcesWrapperWithContext:(id)aContext;
- (id)previewsWrapperForDocument:(id)aDocument;
- (id)previewIconWrapperForDocument:(id)aDocument;
- (id)JSonStringWithDictionary:(id)aDictionary humanReadable:(BOOL)aReadable;
- (BOOL)download:(id)aDownload shouldDecodeSourceDataOfMIMEType:(id)aType;
- (void)download:(id)aDownload didFailWithError:(id)aError;
- (void)downloadDidFinish:(id)aFinish;
- (id)downloadFile:(id)aFile;
- (id)progressSheetDescription;
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType;
- (BOOL)areLinkedStacksInDocument:(id)aDocument;
- (id)exportRepresentation;
- (void)dealloc;
- (id)defaultExportSettings;
- (id)requiredFileType;
- (id)webAppIconWrapperForDocument:(id)aDocument;
@end

