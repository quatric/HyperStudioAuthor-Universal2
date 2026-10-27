#import "HyperStudioPrefix.h"


@interface KeynoteParser : NSObject
{
    NSFileWrapper *_fileWrapperRepresentation;
    struct __CFTree *_xmlTree;
    id _delegate;
    id _parentObject;
}
+ (id)xmlTreeNamespace:(struct __CFTree *)aNamespace;
+ (id)xmlTreeName:(struct __CFTree *)aName;
+ (id)xmlName:(id)aName;
+ (id)xmlTreeAttributes:(struct __CFTree *)aAttributes;
+ (struct __CFTree *)xmlTree:(struct __CFTree *)aTree findTreeForPath:(id)aPath;
+ (NSInteger)countXMLTree:(struct __CFTree *)aTree forTag:(id)aTag;
- (id)objectForXMLTree:(struct __CFTree *)aTree parentObject:(id)aObject;
- (id)keynotePresentation;
- (id)namespace;
- (id)name;
- (id)attributes;
- (struct __CFTree *)findTreeForPath:(id)aPath;
- (id)parseXMLTree:(struct __CFTree *)aTree resultAsArray:(id)aArray;
- (id)parseXMLTree:(struct __CFTree *)aTree resultAsDictionary:(id)aDictionary;
- (void)specifyDetailForKeynoteObject:(id)aObject;
- (void)parseXMLTree:(struct __CFTree *)aTree targetClass:(Class)aClass currentObject:(id)aObject;
- (void)parseXMLTree:(struct __CFTree *)aTree;
- (void)parseXML;
- (id)_parseXMLTree:(struct __CFTree *)aTree;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)setXmlTree:(struct __CFTree *)aTree;
- (struct __CFTree *)xmlTree;
- (void)setFileWrapperRepresentation:(id)aRepresentation;
- (id)fileWrapperRepresentation;
- (void)dealloc;
- (id)initWithXMLTree:(struct __CFTree *)aTree context:(id)aContext;
@end

@interface NSObject (KeynoteParserDelegate)
- (void)keynoteParser:(id)aParser didParseChild:(id)aChild forObject:(id)aObject;
- (void)keynoteParser:(id)aParser didParseAttributes:(id)aAttributes forObject:(id)aObject;
- (void)keynoteParser:(id)aParser didParseProperties:(id)aProperties;
- (void)keynoteParser:(id)aParser didParseChild:(struct __CFTree *)aChild;
@end

