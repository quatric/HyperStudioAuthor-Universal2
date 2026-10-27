#import "HSGIFMovieObject.h"
// A cel movie made from an animated GIF: one media whose frames are the GIF's
// images, kept by an HSGIFMovieNodeUnit.
@implementation HSGIFMovieObject
+ (Class)nodeDataClass
{
    return [HSConcreteCardObjectData class];
}
+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSGeometryNodeUnit", @"Geometry Unit",
                                                      @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
                                                      @"HSSizeNodeUnit", @"Size Unit",
                                                      @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
                                                      @"HSShowHideTransitionNodeUnit", @"Transition Unit",
                                                      @"HSGIFMovieNodeUnit", @"HSGIFMovieObjectRole",
                                                      @"HSTransparentColorNodeUnit", @"Transparent Color Unit", nil];
}
// An image sequence: each frame exported as a PNG resource.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:@"imageSequence" forKey:@"type"];
    NSMutableArray *frames = [NSMutableArray new];
    id unit = [self unitForRole:@"HSGIFMovieObjectRole"];
    NSArray *framesMedia = [unit framesMedia];
    NSUInteger count = [framesMedia count];
    for (NSUInteger i = 0; i < count; i++) {
        id image = [unit frameImageForMediaUID:[framesMedia objectAtIndex:i]];
        HSNewMedia *media = [[HSNewMedia alloc] initWithData:[image hyperPNGRepresentation] name:@"frame" type:@"png"];
        NSDictionary *frame = [[NSDictionary alloc] initWithObjectsAndKeys:
            [@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]], @"src",
            [NSString stringWithFormat:@"%u", (unsigned int)i], @"index", nil];
        [frames addObject:frame];
        [frame release];
        [aContext addMedia:media];
        [media release];
    }
    [dictionary setObject:frames forKey:@"frames"];
    [frames release];
    [dictionary setObject:[NSString stringWithFormat:@"%.3f", [(HSCelMovieNodeUnit *)unit framesPerSecond]] forKey:@"fps"];
    NSSize size = [(HSSizeNodeUnit *)[self unitForRole:@"Size Unit"] size];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)size.width] forKey:@"xSize"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)size.height] forKey:@"ySize"];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
// The stored frames per second are set as the frame time length (truncated),
// as in the original.
- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id unit = [super unitForRole:@"HSGIFMovieObjectRole"];
    NSString *refId = [[[[aRepresentation elementsForName:@"mediaRef"] extraFirstObject] attributeForName:HSXMLStoringRefIdString] stringValue];
    [unit setFramesMedia:[NSArray arrayWithObject:[HSUID UIDWithString:refId]] precachedSource:NULL];
    [unit setFrameTimeLength:(long long)[[[aRepresentation attributeForName:@"fps"] stringValue] doubleValue]];
    [unit setDefaultFrameSize:NSSizeFromString([[aRepresentation attributeForName:@"defaultFrameSize"] stringValue])];
    [(HSSizeNodeUnit *)[super unitForRole:@"Size Unit"] setSize:NSSizeFromString([[aRepresentation attributeForName:@"frameSize"] stringValue])];
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
// The media is referenced by its UID, and added to the context (converted
// once per context).
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    id unit = [self unitForRole:@"HSGIFMovieObjectRole"];
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"fps" stringValue:[NSString stringWithFormat:@"%.3f", [(HSCelMovieNodeUnit *)unit framesPerSecond]]]];
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"defaultFrameSize" stringValue:NSStringFromSize([unit defaultFrameSize])]];
    id uid = [[unit objectMediaUIDs] anyObject];
    NSString *key = [(id)uid stringValue];
    id media = [aContext convertedMediaForKey:key];
    if (media == nil) {
        media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
        if (media != nil)
            [aContext setConvertedMedia:media forKey:key];
    }
    if (media != nil) {
        [aContext addMedia:media];
        NSXMLElement *mediaRef = [NSXMLElement elementWithName:@"mediaRef"];
        [mediaRef addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[(id)uid stringValue]]];
        [aRepresentation addChild:mediaRef];
    }
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"frameSize" stringValue:NSStringFromSize([(HSSizeNodeUnit *)[self unitForRole:@"Size Unit"] size])]];
}
- (id)XMLElementName
{
    return @"objGIFMovie";
}
- (NSSize)defaultSize
{
    id unit = [super unitForRole:@"HSGIFMovieObjectRole"];
    if (![unit isKindOfClass:[HSGIFMovieNodeUnit class]])
        return NSZeroSize;
    return [unit defaultFrameSize];
}
// Only for GIFs with more than one image; the first image's pixel size is the
// frame size. The error isn't set.
- (id)initWithMedia:(id)aMedia error:(id *)aError
{
    NSData *data = [aMedia mediaData];
    if (data != nil && [data length] != 0) {
        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
        if (source != NULL) {
            CFDictionaryRef properties = CGImageSourceGetCount(source) > 1 ? CGImageSourceCopyPropertiesAtIndex(source, 0, NULL) : NULL;
            if (properties != NULL) {
                long height = 0, width = 0;
                CFTypeRef value = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
                if (value != NULL && CFGetTypeID(value) == CFNumberGetTypeID() && CFNumberGetValue(value, kCFNumberLongType, &height)) {
                    value = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
                    if (value != NULL && CFGetTypeID(value) == CFNumberGetTypeID() && CFNumberGetValue(value, kCFNumberLongType, &width)) {
                        id result = [self initWithFramesMedia:[aMedia mediaUID] croppingPath:nil frameSize:NSMakeSize(width, height) precachedSource:source];
                        CFRelease(properties);
                        CFRelease(source);
                        return result;
                    }
                }
                CFRelease(properties);
            }
            CFRelease(source);
        }
    }
    [self release];
    return nil;
}
- (id)initWithMedia:(id)aMedia
{
    return [self initWithMedia:aMedia error:NULL];
}
- (id)initWithFramesMedia:(id)aMedia croppingPath:(id)aPath frameSize:(NSSize)aSize precachedSource:(struct CGImageSource *)aSource
{
    self = [super init];
    if (self == nil || aMedia == nil) {
        [self release];
        return nil;
    }
    id unit = [super unitForRole:@"HSGIFMovieObjectRole"];
    if ([unit isKindOfClass:[HSGIFMovieNodeUnit class]]) {
        [unit setFramesMedia:[NSArray arrayWithObject:aMedia] precachedSource:aSource];
        [unit setDefaultFrameSize:aSize];
        [unit setCroppingPath:aPath];
    }
    id sizeUnit = [super unitForRole:@"Size Unit"];
    if ([sizeUnit isKindOfClass:[HSSizeNodeUnit class]])
        [(HSSizeNodeUnit *)sizeUnit setSize:aSize];
    return self;
}
@end
