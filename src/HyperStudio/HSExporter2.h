#import "HyperStudioPrefix.h"


@interface HSExporter2 : NSObject
{
    NSString *_exportedDocumentName;
    id<HSExporterDelegate> _delegate;
    id _dataSource;
    double _framesPerSecondLimit;
    NSMutableDictionary *_exportSettings;
    NSFileWrapper *_exportRepresentation;
    HSExportAccessoryViewController *_exportAccessoryViewController;
    unsigned int _shouldTerminateExport:1;
}
+ (id)defaultExportDocumentName;
- (void)notifyExportDidTerminate;
- (void)notifyExportDidEnd;
- (void)notifyExportWillEnd;
- (void)notifyExportDidStart;
- (void)notifyExportWillStartWithSlideshowAttributes:(id)aAttributes;
- (void)notifyExportErrorInProgress:(id)aProgress;
- (void)notifyExportProgressDidChangeWithProgress:(double)aProgress;
- (void)terminateExport;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (void)exportDocument:(id)aDocument ofType:(id)aType;
- (void)invalidActionsAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (id)actionsInDocumentThatCannotBeRun:(id)aRun forObjects:(id *)aObjects;
- (BOOL)doesDocumentContainActionsThatCannotBeRun:(id)aRun;
- (BOOL)canRunAction:(id)aAction;
- (BOOL)shouldVerifyDocumentActions;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)progressSheetDescription;
- (BOOL)isSupportedProgressSheet;
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType;
- (id)exportRepresentation;
- (double)framesPerSecondLimit;
- (void)setFramesPerSecondLimit:(double)aLimit;
- (void)setExportedDocumentName:(id)aName;
- (id)exportedDocumentName;
- (void)dealloc;
- (id)init;
- (id)defaultExportSettings;
- (id)exportSettings;
- (id)exportSettingsValueForKey:(id)aKey;
- (void)setExportSettingsValue:(id)aValue forKey:(id)aKey;
- (id)requiredFileType;
- (id)escapeFileNameForExport:(id)aName;
@end

