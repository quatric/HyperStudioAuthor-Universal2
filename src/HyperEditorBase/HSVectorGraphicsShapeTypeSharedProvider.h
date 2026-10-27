#import "HyperEditorBasePrefix.h"


@interface HSVectorGraphicsShapeTypeSharedProvider : NSObject <NSXMLParserDelegate, NSObject, HSVectorGraphicsShapeTypeSharedProvider>
{
    NSMutableArray *_storage;
    NSDictionary *_shapeDefaults;
    NSDictionary *_svgAttributes;
    NSMutableArray *_beingBuiltSVGRep;
    BOOL _isInSVGElement;
}
+ (id)sharedDefaultProvider;
- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName;
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes;
- (void)parser:(id)aParser parseErrorOccurred:(id)aOccurred;
- (void)parserDidStartDocument:(id)aDocument;
- (id)hyperShapeDefaults;
- (id)hyperShapeTypes;
- (void)addCustomShapes;
- (void)addShapesAtPath:(id)aPath;
- (void)addSVGFile:(id)aFile;
- (void)dealloc;
- (id)initWithContentOfFileAtPath:(id)aPath;
- (id)init;
@end

@interface HSVectorGraphicsShapeTypeSharedInfo : NSObject <HSVectorGraphicsShapeTypeSharedInfo>
{
    NSString *_shapeName;
    NSDictionary *_shapeType;
    NSImage *_shapeImage;
    NSString *_shapeImagePath;
    NSMutableDictionary *_mutableShapeType;
}
- (id)imageTitle;
- (id)imageUID;
- (id)imageRepresentation;
- (id)imageRepresentationType;
- (id)hyperShapeName;
- (id)hyperShapeType;
- (id)hyperShapeImagePath;
- (id)hyperShapeImage;
- (void)setShapeImagePath:(id)aPath;
- (void)setShapeName:(id)aName;
- (id)shapePreviewImage;
- (id)mutableShapeType;
- (void)dealloc;
- (id)initShapeTypeInfoWithTypeName:(id)aName type:(id)aType image:(id)aImage atPath:(id)aPath;
@end

