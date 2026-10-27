#import "HyperPlayerBasePrefix.h"
#import "HSInfoObjectProvider.h"


@interface HSVectorGraphicsLineEndingInfoObjectProvider : HSInfoObjectProvider <NSXMLParserDelegate, NSObject>
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

@interface HSVectorGraphicsLineEndingInfoObject : HSInfoObject
{
    NSBezierPath *_path;
    BOOL _isFilled;
    NSImage *_image;
}
+ (id)providerKey;
+ (Class)providerClass;
- (id)image;
- (void)setIsFilled:(BOOL)aFilled;
- (BOOL)isFilled;
- (void)setPath:(id)aPath;
- (id)path;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
@end

