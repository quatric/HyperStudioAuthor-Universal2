#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSRunCommandAction : HSNBAAction <HSRunCommandActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSRunCommandActionTypeAttribute>
{
    int _runCommandActionType;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)setRunCommandActionType:(NSInteger)aType;
- (NSInteger)runCommandActionType;
- (void)startInContext:(id)aContext;
- (void)startAfterClosingCurrentUndoGroup;
- (BOOL)canRunInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)init;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
@end

