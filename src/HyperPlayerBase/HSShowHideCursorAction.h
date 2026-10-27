#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSShowHideCursorAction : HSNBAAction <HSShowHideCursorActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSChangeCursorVisibilityActionAttribute>
{
    int _changeCursorVisibilityAction;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)setChangeCursorVisibilityAction:(NSInteger)aAction;
- (NSInteger)changeCursorVisibilityAction;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

