#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSCompareTextAction : HSNBAAction <HSCompareTextActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSCompareTextActionResponseObjectAttribute, HSCompareTextActionTextToMatchObjectAttribute, HSCompareTextActionComparisonMatchObjectUIDAttribute, HSCompareTextActionComparisonMismatchObjectUIDAttribute, HSCompareTextActionDefinedStringAttribute, HSCompareTextActionComparisonSelectorAttribute, HSCompareTextActionCaseSensitiveComparisonAttribute>
{
    HSUID *_responseObjectUID;
    HSUID *_textToMatchObjectUID;
    NSString *_definedString;
    HSUID *_comparisonMatchObjectUID;
    HSUID *_comparisonMismatchObjectUID;
    SEL _comparisonSelector;
    BOOL _isCaseSensitiveComparison;
}
+ (SEL *)compareSelectors;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)startInContext:(id)aContext;
- (id)missingObjectsAlert;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (void)setCaseSensitiveComparison:(BOOL)aComparison;
- (BOOL)isCaseSensitiveComparison;
- (void)setComparisonSelectorName:(id)aName;
- (id)comparisonSelectorName;
- (void)setComparisonSelector:(SEL)aSelector;
- (SEL)comparisonSelector;
- (void)setWrongAnswerObjectUID:(id)aUID;
- (id)wrongAnswerObjectUID;
- (void)setRightAnswerObjectUID:(id)aUID;
- (id)rightAnswerObjectUID;
- (void)setComparisonMismatchObjectUID:(id)aUID;
- (id)comparisonMismatchObjectUID;
- (void)setComparisonMatchObjectUID:(id)aUID;
- (id)comparisonMatchObjectUID;
- (void)setComparisonMismatchObjectUIDString:(id)aString;
- (id)comparisonMismatchObjectUIDString;
- (void)setComparisonMatchObjectUIDString:(id)aString;
- (id)comparisonMatchObjectUIDString;
- (void)setComparisonString:(id)aString;
- (id)comparisonString;
- (void)setDefinedString:(id)aString;
- (id)definedString;
- (void)setComparisonObjectUID:(id)aUID;
- (id)comparisonObjectUID;
- (void)setTextToMatchObjectUID:(id)aUID;
- (id)textToMatchObjectUID;
- (void)setResponseObjectUID:(id)aUID;
- (id)responseObjectUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

@interface NSString (HSCompareTextAction)
- (BOOL)HSCompareTextAction_isLessThanOrEqualTo:(id)aTo options:(NSUInteger)aOptions;
- (BOOL)HSCompareTextAction_isGreaterThanOrEqualTo:(id)aTo options:(NSUInteger)aOptions;
- (BOOL)HSCompareTextAction_isLessThan:(id)aThan options:(NSUInteger)aOptions;
- (BOOL)HSCompareTextAction_isGreaterThan:(id)aThan options:(NSUInteger)aOptions;
- (BOOL)HSCompareTextAction_contains:(id)aContains options:(NSUInteger)aOptions;
- (BOOL)HSCompareTextAction_isNotEqualTo:(id)aTo options:(NSUInteger)aOptions;
- (BOOL)HSCompareTextAction_isEqualTo:(id)aTo options:(NSUInteger)aOptions;
@end

