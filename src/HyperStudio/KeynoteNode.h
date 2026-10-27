#import "HyperStudioPrefix.h"


@interface KeynoteNode : NSObject
{
    NSString *_nodeId;
    NSString *_nodeIdRef;
    NSString *_nodeIdent;
    NSString *_nodeParentIdent;
    NSDictionary *_nodeAttributes;
    NSString *_xmlPath;
    KeynoteNode *_rootNode;
    KeynoteNode *_parentNode;
    NSString *_name;
    struct __CFTree *_xmlTree;
    NSMutableArray *_children;
}
- (id)firstKeynoteObjectForXMLPath:(id)aPath;
- (id)keynoteObjectForXMLPath:(id)aPath;
- (void)removeAllChildren;
- (void)removeChild:(id)aChild;
- (void)addChild:(id)aChild;
- (id)childForName:(id)aName;
- (id)childForClass:(Class)aClass;
- (void)setChildren:(id)aChildren;
- (id)children;
- (void)setXmlTree:(struct __CFTree *)aTree;
- (struct __CFTree *)xmlTree;
- (void)setName:(id)aName;
- (id)name;
- (void)setParentNode:(id)aNode;
- (id)parentNode;
- (id)content;
- (id)cache;
- (void)setRootNode:(id)aNode;
- (id)rootNode;
- (void)setXmlPath:(id)aPath;
- (id)xmlPath;
- (void)setNodeAttributes:(id)aAttributes;
- (id)nodeAttributes;
- (void)setNodeParentIdent:(id)aIdent;
- (id)nodeParentIdent;
- (void)setNodeIdent:(id)aIdent;
- (id)nodeIdent;
- (void)setNodeIdRef:(id)aRef;
- (id)nodeIdRef;
- (void)setNodeId:(id)aId;
- (id)nodeId;
- (void)dealloc;
- (id)init;
@end

