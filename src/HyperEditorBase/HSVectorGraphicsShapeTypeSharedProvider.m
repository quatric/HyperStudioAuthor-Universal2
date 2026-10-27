#import "HSVectorGraphicsShapeTypeSharedProvider.h"

// The shape types of the vector graphics: the ones in Shapes.plist, then
// the SVG files of the Shapes folder (in its sortedOrder.txt order).

@implementation HSVectorGraphicsShapeTypeSharedProvider

+ (id)sharedDefaultProvider
{
    static HSVectorGraphicsShapeTypeSharedProvider *sharedDefaultProvider;
    if (sharedDefaultProvider == nil) {
        sharedDefaultProvider = [[self class] new];
        [sharedDefaultProvider addCustomShapes];
    }
    return sharedDefaultProvider;
}

- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName
{
    if ([aElement isEqualToString:@"svg"])
        _isInSVGElement = NO;
}

// Each element in the svg one, as {name: attributes}.
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes
{
    if ([aElement isEqualToString:@"svg"]) {
        _isInSVGElement = YES;
        [_svgAttributes release];
        _svgAttributes = [aAttributes retain];
    } else if (_isInSVGElement) {
        if (_beingBuiltSVGRep == nil)
            _beingBuiltSVGRep = [[NSMutableArray alloc] initWithCapacity:1];
        [_beingBuiltSVGRep addObject:[NSDictionary dictionaryWithObject:aAttributes forKey:aElement]];
    }
}

- (void)parser:(id)aParser parseErrorOccurred:(id)aOccurred
{
    [_beingBuiltSVGRep release];
    _beingBuiltSVGRep = nil;
}

- (void)parserDidStartDocument:(id)aDocument
{
    _isInSVGElement = NO;
}

- (id)hyperShapeDefaults
{
    return _shapeDefaults;
}

- (id)hyperShapeTypes
{
    return _storage;
}

- (void)addCustomShapes
{
    [self addShapesAtPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Shapes"]];
}

- (void)addShapesAtPath:(id)aPath
{
    NSArray *names = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:NULL];
    NSArray *sortedOrder = [NSArray arrayWithContentsOfFile:[aPath stringByAppendingPathComponent:@"sortedOrder.txt"]];
    if (sortedOrder != nil) {
        NSMutableArray *rest = [NSMutableArray arrayWithArray:names];
        [rest removeObjectsInArray:sortedOrder];
        names = [sortedOrder arrayByAddingObjectsFromArray:rest];
    }
    for (NSString *name in names) {
        if ([[name pathExtension] isEqualToString:@"svg"])
            [self addSVGFile:[aPath stringByAppendingPathComponent:name]];
    }
}

// The SVG's elements become the shape's bezier path; its image is in
// the Images folder next to it.
- (void)addSVGFile:(id)aFile
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:aFile]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    if (_beingBuiltSVGRep == nil)
        return;
    NSString *name = [[aFile lastPathComponent] stringByDeletingPathExtension];
    NSString *folder = [aFile stringByDeletingLastPathComponent];
    NSString *localizedName = [[NSBundle bundleForClass:[self class]] localizedStringForKey:name value:@"" table:@"ShapeNames"];
    NSDictionary *type = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:_beingBuiltSVGRep forKey:@"extraSVGRep"] forKey:@"extraBezierPath"];
    HSVectorGraphicsShapeTypeSharedInfo *info = [[HSVectorGraphicsShapeTypeSharedInfo alloc] initShapeTypeInfoWithTypeName:localizedName type:type image:nil atPath:[folder stringByAppendingFormat:@"/Images/%@.tiff", name]];
    [_storage addObject:info];
    [info release];
    [_beingBuiltSVGRep release];
    _beingBuiltSVGRep = nil;
    [_svgAttributes release];
    _svgAttributes = nil;
}

- (void)dealloc
{
    [_storage release];
    [_shapeDefaults release];
    [super dealloc];
}

// The plist's List (name, image and type of each shape) and Defaults.
- (id)initWithContentOfFileAtPath:(id)aPath
{
    if ((self = [super init])) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:aPath];
            NSDictionary *list = [contents objectForKey:@"List"];
            _shapeDefaults = [[contents objectForKey:@"Defaults"] retain];
            NSMutableArray *storage = [[NSMutableArray alloc] initWithCapacity:[list count]];
            for (id key in [list keyEnumerator]) {
                NSDictionary *shape = [list objectForKey:key];
                NSString *name = [bundle localizedStringForKey:[shape objectForKey:@"name"] value:@"" table:@"ShapeNames"];
                NSString *imagePath = [bundle pathForResource:[shape objectForKey:@"image"] ofType:@"tiff"];
                id type = [shape objectForKey:@"type"];
                if (imagePath != nil) {
                    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
                    HSVectorGraphicsShapeTypeSharedInfo *info = [[HSVectorGraphicsShapeTypeSharedInfo alloc] initShapeTypeInfoWithTypeName:name type:type image:image atPath:imagePath];
                    [storage addObject:info];
                    [image release];
                    [info release];
                }
            }
            _storage = storage;
        }
    }
    return self;
}

- (id)init
{
    return [self initWithContentOfFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Shapes" ofType:@"plist"]];
}

@end

// One shape type: its name, attributes (over the defaults) and image.

@implementation HSVectorGraphicsShapeTypeSharedInfo

- (id)imageTitle
{
    return [self hyperShapeName];
}

- (id)imageUID
{
    return [self hyperShapeImagePath];
}

- (id)imageRepresentation
{
    return [self hyperShapeImagePath];
}

- (id)imageRepresentationType
{
    return @"IKImageBrowserPathRepresentationType";
}

- (id)hyperShapeName
{
    return _shapeName;
}

- (id)hyperShapeType
{
    return [self mutableShapeType];
}

- (id)hyperShapeImagePath
{
    return _shapeImagePath;
}

// The image file, else the shape's outline.
- (id)hyperShapeImage
{
    if (_shapeImage == nil) {
        _shapeImage = [[NSImage alloc] initWithContentsOfFile:_shapeImagePath];
        if (_shapeImage == nil)
            _shapeImage = [[self shapePreviewImage] retain];
    }
    return _shapeImage;
}

- (void)setShapeImagePath:(id)aPath
{
    [_shapeImagePath autorelease];
    _shapeImagePath = [aPath retain];
}

- (void)setShapeName:(id)aName
{
    if (_shapeName != aName) {
        [_shapeName autorelease];
        _shapeName = [aName retain];
    }
}

- (id)shapePreviewImage
{
    NSBezierPath *path = [[NSBezierPath alloc] initWithExtraDictionary:[[self hyperShapeType] objectForKey:@"extraBezierPath"]];
    [path extraCanonizeWithScaling:NO appliedTransform:nil];
    NSRect bounds = [path hyperVisualBounds];
    NSImage *image = nil;
    if (!NSIsEmptyRect(bounds)) {
        image = [[[NSImage alloc] initWithSize:bounds.size] autorelease];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:-bounds.origin.x yBy:-bounds.origin.y];
        [image lockFocus];
        [transform concat];
        [path stroke];
        [image unlockFocus];
    }
    [path release];
    return image;
}

- (id)mutableShapeType
{
    if (_mutableShapeType == nil) {
        NSDictionary *defaults = [[HSVectorGraphicsShapeTypeSharedProvider sharedDefaultProvider] hyperShapeDefaults];
        _mutableShapeType = _shapeType != nil ? [_shapeType mutableCopy] : [NSMutableDictionary new];
        [_mutableShapeType extraAppendDictionary:defaults];
    }
    return _mutableShapeType;
}

- (void)dealloc
{
    [_shapeName release];
    [_shapeType release];
    [_shapeImage release];
    [_shapeImagePath release];
    [_mutableShapeType release];
    [super dealloc];
}

- (id)initShapeTypeInfoWithTypeName:(id)aName type:(id)aType image:(id)aImage atPath:(id)aPath
{
    if ((self = [super init])) {
        _shapeImagePath = [aPath retain];
        _shapeImage = [aImage retain];
        _shapeName = [aName retain];
        _shapeType = [aType retain];
    }
    return self;
}

@end
