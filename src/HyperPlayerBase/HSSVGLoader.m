#import "HSSVGLoader.h"
// Loads the shape in an SVG file as a bezier path: the elements inside <svg>
// are collected as {name: attributes} and handed to NSBezierPath's SVG
// support, then flipped to Cocoa's coordinates.
@implementation HSSVGLoader
- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName
{
    if ([aElement isEqualToString:@"svg"])
        _isInSVGElement = NO;
}
- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes
{
    if ([aElement isEqualToString:@"svg"]) {
        _isInSVGElement = YES;
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
- (id)bezierPath
{
    if (![self isLoaded])
        [self load];
    return _bezierPath;
}
- (void)load
{
    if ([self isLoaded])
        return;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:_url];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    if (_beingBuiltSVGRep != nil) {
        _bezierPath = [[NSBezierPath bezierPath] retain];
        [_bezierPath setExtraSVGRep:_beingBuiltSVGRep];
        [_bezierPath transformUsingAffineTransform:[NSAffineTransform hyperYFlipInRect:[_bezierPath bounds]]];
        [_beingBuiltSVGRep release];
        _beingBuiltSVGRep = nil;
    }
    _loaded = YES;
}
- (BOOL)isLoaded
{
    return _loaded;
}
- (void)dealloc
{
    [_url release];
    [_bezierPath release];
    [super dealloc];
}
- (id)initWithURL:(id)aURL
{
    self = [super init];
    if (self != nil)
        _url = [aURL retain];
    return self;
}
- (id)initWithFile:(id)aFile
{
    self = [super init];
    if (self != nil)
        _url = [[NSURL alloc] initFileURLWithPath:aFile];
    return self;
}
@end
