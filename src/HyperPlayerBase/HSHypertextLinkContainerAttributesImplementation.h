#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSHypertextLinkContainerAttributesImplementation : HSWeaklyReferencedObject <HSHypertextLinkContainerAttributes, HSAttributes, HyperInterface, NSObject, HSHypertextLinkContainerLinksAttribute, HSAttribute>
{
    HSNode *_node;
    HSHypertextLinksContainerNodeUnit *_nodeUnit;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)hypertextLinkAtPosition:(NSUInteger)aPosition inText:(id)aText startPosition:(unsigned int *)aPosition2;
- (id)HSHypertextLinkContainerAttributesImplementation_hypertextLinkAtPosition:(NSUInteger)aPosition inText:(id)aText startPosition:(unsigned int *)aPosition2;
- (void)takeLinkWithTitle:(id)aTitle fromContainer:(id)aContainer;
- (void)renameLinkWithTitle:(id)aTitle to:(id)aTo;
- (void)removeLinkWithTitle:(id)aTitle;
- (id)addLinkWithTitle:(id)aTitle;
- (id)linkWithTitle:(id)aTitle;
- (id)allSortedTitles;
- (id)allLinks;
- (id)attributeObservingController;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
@end

