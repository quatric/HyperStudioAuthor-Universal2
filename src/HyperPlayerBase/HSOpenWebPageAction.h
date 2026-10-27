#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSOpenWebPageAction : HSToDoAction <HSOpenWebPageActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSMutableURLAttributes, HSURLAttribute, HSOpenWebPageInForegroundAttribute>
{
    NSURL *_URL;
    BOOL _launchInForeground;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)isValid;
- (void)setLaunchInForeground:(BOOL)aForeground;
- (BOOL)launchInForeground;
- (void)setURL:(id)aURL;
- (id)URL;
- (void)startInContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

