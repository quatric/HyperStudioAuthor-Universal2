#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSShowMessageAction : HSNBAAction <HSShowMessageActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSMessageStyleAttribute, HSMessageStringAttribute, HSMessageButtonTitleAttribute, HSRunAsModalDialogAttribute, HSMessageIconImageAttribute, HSMediaCopySupport>
{
    int _alertStyle;
    NSString *_messageString;
    NSString *_buttonTitle;
    BOOL _runAsModalDialog;
    HSNewMedia *_messageIconMedia;
}
+ (NSInteger)messageStyleFromStringForXMLStoring:(id)aStoring;
+ (id)stringForXMLStoringFromMessageStyle:(NSInteger)aStyle;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (id)ownedMediaUIDs;
- (id)mediaUIDs;
- (void)setMessageIcon:(id)aIcon;
- (id)messageIcon;
- (void)setMessageIconImageUID:(id)aUID;
- (id)messageIconImageUID;
- (void)setMessageIconMedia:(id)aMedia;
- (id)messageIconMedia;
- (void)setRunAsModalDialog:(BOOL)aDialog;
- (BOOL)runAsModalDialog;
- (void)setButtonTitle:(id)aTitle;
- (id)buttonTitle;
- (void)setMessageString:(id)aString;
- (id)messageString;
- (void)setMessageStyle:(NSInteger)aStyle;
- (NSInteger)messageStyle;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)startInContext:(id)aContext;
- (BOOL)isSynchronous;
- (BOOL)canChangeSynchronousFlag;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

