#import "HyperStudioPrefix.h"


@interface HSWebExporter : NSObject <HSExporting, NSObject, HSStopExporting>
{
    NSString *_fullDocumentPath;
    id _delegate;
    BOOL _needStopExport;
}
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError;
- (void)fileManager:(id)aManager willProcessPath:(id)aPath;
- (id)backupPathWithPath:(id)aPath;
- (void)setfullDocumentPath:(id)aPath;
- (id)htmlTemplateWithDocument:(id)aDocument dirPath:(id)aPath;
- (void)stopExport;
- (BOOL)exportDocument:(id)aDocument withBackupToFile:(id)aFile ofType:(id)aType error:(id *)aError;
- (id)fileWrapperForExportFromDocument:(id)aDocument exportError:(id *)aError;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

