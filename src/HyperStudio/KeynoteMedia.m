#import "KeynoteMedia.h"

@implementation KeynoteMedia

// The masking shape path, rotated, scaled to the natural size and moved
// relative to the crop (the Keynote y axis points down).
- (id)maskPath
{
    NSString *pathString = [[[self keynoteObjectForXMLPath:@"./masking-shape-path-source/bezier-path/bezier"] nodeAttributes] objectForKey:@"path"];
    if (!pathString)
        return nil;
    KeynoteGeometry *geometry = [self geometry];
    KeynoteGeometry *crop = [self cropGeometry];
    NSSize natural = [geometry naturalSize];
    NSSize size = [geometry size];
    NSPoint origin = [geometry origin];
    CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
    float midY = CGRectGetMidY(rect);
    float midX = CGRectGetMidX(rect);
    float angle = [geometry angle];
    float s = sinf(-angle);
    float c = cosf(-angle);
    CGAffineTransform rotation = CGAffineTransformMake(c, s, -s, c, s * midY + (1.0f - c) * midX, (1.0f - c) * midY - s * midX);
    CGRect rotated = CGRectApplyAffineTransform(rect, rotation);
    float deltaY = CGRectGetMinY(rotated) - CGRectGetMinY(rect);
    float deltaX = CGRectGetMinX(rotated) - CGRectGetMinX(rect);
    float scaleX = size.width != 0 ? natural.width / size.width : 1.0f;
    float scaleY = size.height != 0 ? natural.height / size.height : 1.0f;
    float movedX = c * deltaX + -s * deltaY + rotation.tx;
    float movedY = deltaX * s + deltaY * c + rotation.ty;
    NSBezierPath *path = [NSBezierPath hyperBezierPathWithString:pathString];
    float cropAngle = [crop angle];
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(cosf(cropAngle), sinf(cropAngle), -sinf(cropAngle), cosf(cropAngle), 0, 0)]];
    NSRect bounds = [path bounds];
    NSPoint cropOrigin = [crop origin];
    float a = c * scaleX + s * 0.0f;
    float cc = -s * scaleX + c * 0.0f;
    float b = c * 0.0f + s * scaleY;
    float d = -s * 0.0f + c * scaleY;
    float cropDeltaX = cropOrigin.x - bounds.origin.x;
    float cropDeltaY = cropOrigin.y - bounds.origin.y;
    float tx = cc * cropDeltaY + cropDeltaX * a + (CGPointZero.x - origin.x * scaleX) + movedX * scaleX + movedY * 0.0f;
    float ty = (CGPointZero.y + CGPointZero.y + natural.height) - (cropDeltaY * d + cropDeltaX * b + (CGPointZero.y - origin.y * scaleY) + movedX * 0.0f + movedY * scaleY);
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(a, -b, cc, -d, tx, ty)]];
    return path;
}

- (id)cropGeometry
{
    return [self keynoteObjectForXMLPath:@"./crop-geometry"];
}

- (id)alphaPath
{
    id pathString = [[[self keynoteObjectForXMLPath:@"./content/image-media/alpha-mask-path"] nodeAttributes] objectForKey:@"path"];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setExtraPathString:pathString];
    float height = [[self geometry] naturalSize].height;
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, height + 0.0f + 0.0f)]];
    return path;
}

- (id)filteredImage
{
    return [self keynoteObjectForXMLPath:@"./content/image-media/filtered-image"];
}

- (double)endTime
{
    KeynoteMovieMedia *movie = [self internalMovieMedia];
    return movie ? [movie endTime] : 3.4028234663852886e+38;
}

- (double)startTime
{
    KeynoteMovieMedia *movie = [self internalMovieMedia];
    return movie ? [movie startTime] : 0.0;
}

- (BOOL)hasPlayRangeSettings
{
    return [(KeynoteMovieMedia *)[self internalMovieMedia] hasPlayRangeSettings];
}

- (NSInteger)playLoopMode
{
    id source = self;
    if (![[self nodeAttributes] objectForKey:@"looping"])
        source = [self internalMovieMedia];
    return [KeynoteTools playLoopModeWithAttributesDictionary:[source nodeAttributes]];
}

- (CGFloat)volume
{
    id volume = [[self nodeAttributes] objectForKey:@"volume"];
    if (volume)
        return [volume floatValue] * 0.00390625f;
    if ([self internalMovieMedia])
        return [(KeynoteMovieMedia *)[self internalMovieMedia] volume];
    return 1.0f;
}

// The movie file path from the embedded movie, the self-contained or external
// movie element (or the referenced cached movie data).
- (id)path
{
    if (!_path)
        _path = [[[self internalMovieMedia] path] retain];
    if (!_path) {
        id movie = [self keynoteObjectForXMLPath:@"./self-contained-movie"];
        id main;
        if (!movie) {
            main = [self keynoteObjectForXMLPath:@"./external-movie/main-movie"];
            if (!main)
                main = [self keynoteObjectForXMLPath:@"./external-movie/main-movie-data"];
            if (!main)
                return _path;
        } else {
            main = [movie keynoteObjectForXMLPath:@"./main-movie"];
            if (!main)
                main = [movie keynoteObjectForXMLPath:@"./main-movie-data"];
            if (!main) {
                id reference = [[[movie keynoteObjectForXMLPath:@"./main-movie-ref"] nodeAttributes] objectForKey:@"IDREF"];
                if (reference)
                    main = [[self cache] objectOfType:@"mediaData" inCacheForId:reference];
            }
        }
        _path = [[KeynoteTools pathWithAttributesDictionary:[main nodeAttributes]] retain];
    }
    return _path;
}

- (BOOL)pathIsRelative
{
    return [[self path] isEqualToString:[[self path] lastPathComponent]];
}

- (id)data
{
    if ([self pathIsRelative])
        return [[[self content] resources] objectForKey:[self path]];
    return [NSData dataWithContentsOfFile:[self path]];
}

- (NSInteger)mediaType
{
    if ([self keynoteObjectForXMLPath:@"content/image-media"])
        return 2;
    id poster = [self posterImage];
    if (!poster)
        poster = [[self internalMovieMedia] posterImage];
    return poster == nil;
}

- (id)posterImage
{
    return [self childForName:@"poster-image"];
}

- (id)internalMovieMedia
{
    return [self keynoteObjectForXMLPath:@"./content/movie-media"];
}

// Reports an importing problem when the media file cannot be found.
- (void)didDetail
{
    [super didDetail];
    BOOL found = [self filteredImage] != nil;
    if (!found) {
        if ([self pathIsRelative])
            found = [[[self content] resources] objectForKey:[self path]] != nil;
        else
            found = [[NSFileManager defaultManager] hyperIsFileReadableAtPath:[self path]];
    }
    if (!found)
        [[self importManager] addImportingProblemForCode:0x4e2c point:@"001" info:[self path]];
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    id main = [self keynoteObjectForXMLPath:@"./self-contained-movie/main-movie"];
    if (main)
        [[self cache] addObject:main type:@"mediaData" inCacheForId:[main nodeId]];
}

- (void)dealloc
{
    [_path release];
    [super dealloc];
}

@end
