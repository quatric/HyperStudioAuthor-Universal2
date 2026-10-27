#import "HyperPlayerBasePrefix.h"
#import "HSInfoObjectProvider.h"


@interface HSVectorGraphicsLineDashInfoObjectProvider : HSInfoObjectProvider <NSXMLParserDelegate, NSObject>
{
    NSDictionary *_svgAttributes;
    NSMutableArray *_beingBuiltSVGRep;
    BOOL _isInSVGElement;
}
+ (Class)infoObjectClass;
- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName;
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes;
- (void)parser:(id)aParser parseErrorOccurred:(id)aOccurred;
- (void)parserDidStartDocument:(id)aDocument;
- (void)addCustomInfoFile:(id)aFile;
@end

@interface HSVectorGraphicsLineDashInfoObject : HSInfoObject
{
    NSImage *_image;
    NSBezierPath *_path;
}
+ (id)providerKey;
+ (Class)providerClass;
- (id)lineDashString;
- (id)path;
- (id)image;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
- (id)initWithLineDashString:(id)aString;
@end

