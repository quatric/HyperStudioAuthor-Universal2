#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSGoogleEarthAction : HSNBAAction <HSGoogleEarthActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSMediaUIDAttribute, HSMediaAttribute, HSVisualAttribute, HSUndoableAttribute, HSOpenLocationQuitAfterLaunchAttribute, HSOpenLocationLaunchInForegroundAttribute, HSURLAttribute, HSMediaCopySupport, NSXMLParserDelegate>
{
    HSOpenLocationAction *_openLocationAction;
    HSNewMedia *_media;
    HSUID *_mediaUID;
    NSURL *_documentURL;
    NSURL *_urlFromMedia;
    NSMutableDictionary *_googleEarthExport;
    NSMutableString *_textInProgress;
}
+ (id)cantLaunchGoogleEarthAlert;
+ (id)cantFindGoogleEarthAlert;
- (void)parser:(id)aParser foundCharacters:(id)aCharacters;
- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName;
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes;
- (id)placemarkKeys;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (id)media;
- (id)mediaUID;
- (void)setMediaUID:(id)aUID;
- (void)setURL:(id)aURL;
- (id)URL;
- (void)setLaunchInForeground:(BOOL)aForeground;
- (BOOL)launchInForeground;
- (void)setQuitAfterLaunch:(BOOL)aLaunch;
- (BOOL)quitAfterLaunch;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)notifyDidFinish;
- (void)startInContext:(id)aContext;
- (id)ownedMediaUIDs;
- (id)mediaUIDs;
- (void)renameGEDocument;
- (void)updateMediaUID;
- (void)setDocumentURL:(id)aURL;
- (id)documentURL;
- (void)setOpenLocationAction:(id)aAction;
- (id)openLocationAction;
- (id)urlFromMedia;
- (void)dealloc;
@end

