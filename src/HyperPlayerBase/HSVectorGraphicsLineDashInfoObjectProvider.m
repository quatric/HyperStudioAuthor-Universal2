#import "HSVectorGraphicsLineDashInfoObjectProvider.h"
// Provider of line dash styles. Custom styles are SVG files: the elements
// inside the <svg> element become the dash's path (its "extraSVGRep").

@implementation HSVectorGraphicsLineDashInfoObjectProvider

+ (Class)infoObjectClass
{
    return [HSVectorGraphicsLineDashInfoObject class];
}

- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName
{
    if ([aElement isEqualToString:@"svg"])
        _isInSVGElement = NO;
}

- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes
{
    if ([aElement isEqualToString:@"svg"]) {
        _isInSVGElement = YES;
        [_svgAttributes release];
        _svgAttributes = [aAttributes retain];
    } else if (_isInSVGElement) {
        if (!_beingBuiltSVGRep)
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

// Adds an SVG file as a dash named after the file.
- (void)addCustomInfoFile:(id)aFile
{
    if (![[aFile pathExtension] isEqualToString:@"svg"])
        return;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:aFile]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    if (!_beingBuiltSVGRep)
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

@implementation HSVectorGraphicsLineDashInfoObject

+ (id)providerKey
{
    return @"LineDashes";
}

+ (Class)providerClass
{
    return [HSVectorGraphicsLineDashInfoObjectProvider class];
}

- (id)lineDashString
{
    return [[self path] extraLineDashString];
}

- (id)path
{
    if (!_path && [self info])
        _path = [[NSBezierPath alloc] initWithExtraDictionary:[self info]];
    return _path;
}

// 120×12 preview: the dash path stroked 2 points in and halfway up.
// (The original also fetches the path bounds for the offset but then
// uses a zero origin, so the offset is fixed.)
- (id)image
{
    if (_image)
        return _image;
    _image = [[NSImage alloc] initWithSize:NSMakeSize(120, 12)];
    NSBezierPath *path = [self path];
    NSRect bounds = (path && [path elementCount] >= 2) ? [path bounds] : NSZeroRect;
    if (bounds.size.width != 0) {
        [_image setCachedSeparately:YES];
        [_image lockFocus];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:floorf(0) + 2.0 yBy:0 + floorf([_image size].height * 0.5)];
        [transform concat];
        [path stroke];
        [_image unlockFocus];
    }
    return _image;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"title", @"path", nil];
}

- (BOOL)isEqual:(id)aEqual
{
    if ([super isEqual:aEqual])
        return YES;
    if (![aEqual respondsToSelector:@selector(path)])
        return NO;
    NSString *dash = [[self path] extraLineDashString];
    NSString *otherDash = [[aEqual path] extraLineDashString];
    return dash == otherDash || [dash isEqualToString:otherDash];
}

- (void)dealloc
{
    [_path release];
    [_image release];
    [super dealloc];
}

- (id)initWithLineDashString:(id)aString
{
    self = [super init];
    if (self) {
        [[self path] setExtraLineDashString:aString];
        id registered = [self registeredInProvider];
        if (registered != self) {
            [self release];
            self = [registered retain];
        }
    }
    return self;
}

@end
