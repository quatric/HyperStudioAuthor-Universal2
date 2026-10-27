#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSOpenStackAction : HSChangeCardAction <HSOpenStackActionAttributes, HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute, HSURLAttribute>
{
    NSURL *_URL;
    BOOL _shouldOpenInSeparateWindow;
    NSURL *_temporaryURL;
    HSAlert *_stackNotFoundAlert;
    NSString *_downloadFilePath;
    long long _dowloadFileDataSize;
    long long _currentDowloadedFileSize;
    BOOL _isDownloadFinished;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementName;
- (BOOL)supportedInIPad;
- (void)cleanupDownloadedFile;
- (void)navigationOperationStageDidChange:(id)aChange;
- (void)download:(id)aDownload didReceiveDataOfLength:(NSUInteger)aLength;
- (void)download:(id)aDownload didReceiveResponse:(id)aResponse;
- (BOOL)download:(id)aDownload shouldDecodeSourceDataOfMIMEType:(id)aType;
- (void)download:(id)aDownload didFailWithError:(id)aError;
- (void)downloadDidFinish:(id)aFinish;
- (void)downloadDidBegin:(id)aBegin;
- (void)downloadFile:(id)aFile;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (void)openStackFromNewLocationWithContext:(id)aContext;
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)validateURL;
- (void)setURL:(id)aURL;
- (id)URL;
- (id)baseURL;
- (void)updateURL;
- (void)notifyDidFinish;
- (void)startInContext:(id)aContext;
- (BOOL)supportedInStackToGo;
- (BOOL)supportedInWebPlayer;
- (BOOL)hasLinkToOFFStack;
- (void)askUserToLocateTheStackInContext:(id)aContext;
- (id)stackNotFoundAlert;
- (id)createNavigationOperation;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen;
- (BOOL)shouldOpenInSeparateWindow;
- (id)initialURL;
- (void)HSOpenStackAction_validateURL;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
@end

