#import "HSVectorGraphicsLineEndingInfoObjectProvider.h"
// Line endings (arrowheads…) for vector graphics: SVG files whose elements
// become a path; the custom ones come from the user's folder.
@implementation HSVectorGraphicsLineEndingInfoObjectProvider
+ (Class)infoObjectClass
{
    return [HSVectorGraphicsLineEndingInfoObject class];
}
- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName
{
    if ([aElement isEqualToString:@"svg"])
        _isInSVGElement = NO;
}
// Each element inside <svg> is kept as {name: attributes}.
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes
{
    if ([aElement isEqualToString:@"svg"]) {
        _isInSVGElement = YES;
        [_svgAttributes release];
        _svgAttributes = [aAttributes retain];
        return;
    }
    if (!_isInSVGElement)
        return;
    if (_beingBuiltSVGRep == nil)
        _beingBuiltSVGRep = [[NSMutableArray alloc] initWithCapacity:1];
    [_beingBuiltSVGRep addObject:[NSDictionary dictionaryWithObject:aAttributes forKey:aElement]];
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
// An SVG file becomes a line ending named after the file.
- (void)addCustomInfoFile:(id)aFile
{
    if (![[aFile pathExtension] isEqualToString:@"svg"])
        return;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:aFile]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    if (_beingBuiltSVGRep == nil)
        return;
    NSString *name = [[aFile lastPathComponent] stringByDeletingPathExtension];
    NSDictionary *info = [NSDictionary dictionaryWithObject:_beingBuiltSVGRep forKey:@"extraSVGRep"];
    id object = [[[[self class] infoObjectClass] alloc] initWithTitle:nil info:info];
    [object retainOwnerCount];
    [[self namedObjects] setObject:object forKey:name];
    [[self objects] addObject:object];
    [object release];
    [_beingBuiltSVGRep release];
    _beingBuiltSVGRep = nil;
    [_svgAttributes release];
    _svgAttributes = nil;
}
@end

@implementation HSVectorGraphicsLineEndingInfoObject
+ (id)providerKey
{
    return @"LineEndings";
}
+ (Class)providerClass
{
    return [HSVectorGraphicsLineEndingInfoObjectProvider class];
}
// The menu image: a 60 × 12 line ending in the shape (turned around and
// scaled to 8 points high) at its left.
- (id)image
{
    if (_image != nil)
        return _image;
    _image = [[NSImage alloc] initWithSize:NSMakeSize(60, 12)];
    NSBezierPath *path = [self path];
    NSRect bounds = NSZeroRect;
    if (path != nil && [path elementCount] >= 2)
        bounds = [path bounds];
    float x, y;
    if (bounds.size.width == 0) {
        x = 2;
        y = 6;
    } else {
        float scale = 8.0f / (float)bounds.size.height;
        NSAffineTransform *transform = [NSAffineTransform transform];
        // (The original links the `pi` symbol here.)
        [transform rotateByRadians:(float)M_PI];
        [transform scaleXBy:scale yBy:scale];
        path = [transform transformBezierPath:path];
        bounds = [path bounds];
        x = (float)bounds.size.width + 2;
        y = (float)bounds.size.height * 0.5f + 2;
    }
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:x yBy:y];
    path = [transform transformBezierPath:path];
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(x, 6)];
    [line lineToPoint:NSMakePoint(60, 6)];
    [_image setCachedSeparately:YES];
    [_image lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    [[NSColor blackColor] set];
    if (_isFilled)
        [path fill];
    else
        [path stroke];
    [line stroke];
    [_image unlockFocus];
    return _image;
}
- (void)setIsFilled:(BOOL)aFilled
{
    _isFilled = aFilled;
}
- (BOOL)isFilled
{
    return _isFilled;
}
- (void)setPath:(id)aPath
{
    if (_path == aPath)
        return;
    [_path release];
    _path = [aPath copy];
}
// Built from the SVG elements, 2 points wide, centered vertically on the
// line.
- (id)path
{
    if (_path != nil || [self info] == nil)
        return _path;
    _path = [[NSBezierPath alloc] initWithExtraDictionary:[self info]];
    [_path setLineWidth:2];
    [_path setWindingRule:NSEvenOddWindingRule];
    NSRect bounds = [_path bounds];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0 yBy:(float)bounds.size.height * -0.5f];
    [_path transformUsingAffineTransform:transform];
    BOOL mixed = NO;
    _isFilled = [NSBezierPath isExtraSVGRepFilled:[self info] isMixed:&mixed];
    return _path;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"path", @"isFilled", nil]];
}
- (NSUInteger)hash
{
    return [super hash] + _isFilled;
}
// Also equal: the same fill and path.
- (BOOL)isEqual:(id)aEqual
{
    if ([super isEqual:aEqual])
        return YES;
    if (![aEqual respondsToSelector:@selector(isFilled)] || ![aEqual respondsToSelector:@selector(path)])
        return NO;
    if ([self isFilled] != [aEqual isFilled])
        return NO;
    NSString *string = [[self path] extraPathString];
    NSString *otherString = [[aEqual path] extraPathString];
    return string == otherString || [string isEqualToString:otherString];
}
- (void)dealloc
{
    [_path release];
    [_image release];
    [super dealloc];
}
@end
