#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSHypertextLinksContainerNodeUnit : HSNodeUnit
{
    NSMutableDictionary *_links;
    NSArray *_sortedTitles;
}
- (void)linkActorDidChange:(id)aChange;
- (id)mediaUIDs;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)supportsSharingBetweenGroupObjects;
- (id)allSortedTitles;
- (id)allLinks;
- (void)takeLinkWithTitle:(id)aTitle fromContainer:(id)aContainer;
- (void)removeAllLinks;
- (void)removeLinkWithTitle:(id)aTitle;
- (void)renameLinkWithTitle:(id)aTitle to:(id)aTo;
- (id)addLinkWithTitle:(id)aTitle;
- (id)addLinkWithTitle:(id)aTitle actor:(id)aActor;
- (id)linkWithTitle:(id)aTitle;
- (id)hyperObjectForActor:(id)aActor;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (void)dealloc;
- (void)removeObservers;
@end

@interface HSHypertextLink : NSObject <HSHypertextLink, HyperInterface, NSObject, HSUserObjectSupport, EXKeyValueCoding, NSCopying, HSImportUserInfoContainer, HSHTML5ExportSupport>
{
    NSString *_title;
    id _actor;
    id _container;
    id _userInfo;
}
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)shouldBeExportedAsImage;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (void)cleanupUserInfo;
- (id)userInfoForKey:(id)aKey;
- (void)setUserInfo:(id)aInfo forKey:(id)aKey;
- (id)uniqueNameGenerator;
- (id)document;
- (id)card;
- (id)stack;
- (id)copyWithZone:(NSZone *)aZone;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)supportsActionType:(id)aType forEvent:(id)aEvent;
- (id)queryHyperInterface:(id)aInterface;
- (void)setContainer:(id)aContainer;
- (id)container;
- (id)actor;
- (id)title;
- (void)dealloc;
- (id)initWithTitle:(id)aTitle actor:(id)aActor container:(id)aContainer;
@end

