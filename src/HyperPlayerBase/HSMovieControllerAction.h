#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSMovieControllerAction : HSNBAAction <HSMovieControllerActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSMovieCommandAttribute>
{
    int _movieCommand;
}
+ (NSInteger)movieControllerCommandTypeFromStringForXMLStoring:(id)aStoring;
+ (id)stringForXMLStoringFromMovieControllerCommandType:(NSInteger)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (void)hyperPlayableObjectDidStop:(id)aStop;
- (BOOL)supportedInIPad;
- (void)setMovieCommand:(NSInteger)aCommand;
- (NSInteger)movieCommand;
- (void)startInContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setMovieUID:(id)aUID;
@end

