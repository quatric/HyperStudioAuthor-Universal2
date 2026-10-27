#import "HyperPlayerBasePrefix.h"
#import "HSChangeCardAction.h"


@interface HSOtherCardAction : HSChangeCardAction <HSOtherCardActionAttributes, HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute, HSDestinationCardUIDAttribute, HSURLAttribute, HSActionCopySupport>
{
    int _cardIndex;
    int _cardIdOldFileFormat;
    HSUID *_destinationCardUID;
    BOOL _shouldOpenInSeparateWindow;
    HSDocument *_previewDocument;
    NSURL *_URL;
    NSURL *_temporaryURL;
    NSString *_downloadFilePath;
    BOOL _isDownloadFinished;
    HSAlert *_stackNotFoundAlert;
}
- (id)unrefreshingUIDs;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)cleanupDownloadedFile;
- (BOOL)download:(id)aDownload shouldDecodeSourceDataOfMIMEType:(id)aType;
- (void)download:(id)aDownload didFailWithError:(id)aError;
- (void)downloadDidFinish:(id)aFinish;
- (void)downloadFile:(id)aFile;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)destinationStackForContext:(id)aContext;
- (BOOL)isValid;
- (void)openStackFromNewLocationWithContext:(id)aContext;
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)notifyDidFinish;
- (void)startInContext:(id)aContext;
- (BOOL)canRunInContext:(id)aContext;
- (void)askUserToLocateTheStackInContext:(id)aContext;
- (id)stackNotFoundAlert;
- (BOOL)supportedInStackToGo;
- (BOOL)supportedInWebPlayer;
- (BOOL)hasLinkToOFFStack;
- (id)createNavigationOperation;
- (void)setDestinationCardUID:(id)aUID;
- (id)destinationCardUID;
- (void)setURL:(id)aURL;
- (id)URL;
- (id)baseURL;
- (void)updateURL;
- (void)setCardIdOldFileFormat:(NSInteger)aFormat;
- (NSInteger)cardIdOldFileFormat;
- (BOOL)canGoToHyperDestinationCard;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen;
- (BOOL)shouldOpenInSeparateWindow;
@end

