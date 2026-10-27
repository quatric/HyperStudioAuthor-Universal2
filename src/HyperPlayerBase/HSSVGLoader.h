#import "HyperPlayerBasePrefix.h"


@interface HSSVGLoader : NSObject <NSXMLParserDelegate, NSObject>
{
    NSURL *_url;
    NSBezierPath *_bezierPath;
    BOOL _loaded;
    NSMutableArray *_beingBuiltSVGRep;
    BOOL _isInSVGElement;
}
- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName;
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes;
- (void)parser:(id)aParser parseErrorOccurred:(id)aOccurred;
- (void)parserDidStartDocument:(id)aDocument;
- (id)bezierPath;
- (void)load;
- (BOOL)isLoaded;
- (void)dealloc;
- (id)initWithURL:(id)aURL;
- (id)initWithFile:(id)aFile;
@end

