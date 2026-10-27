#import "HSCelMovieObject.h"
#import "HSCelMovieNodeUnit.h"
#import "HSCelMovieObjectVisualization.h"
#import "HSGenericImageRenderLayer.h"
#import "HSHTML5ExporterHelper.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "HSSizeNodeUnit.h"
#import "HSVisualHitTester.h"

// A cel animation: a sequence of frame media played by an HSCelMovieNodeUnit.
@implementation HSCelMovieObject

// aPath names a frame of a numbered image sequence ("name007.png"): the last
// run of digits in the file name is the frame number. The sequence runs over
// the readable files around it; it needs at least two frames. aFormat gets
// the printf format of the frame paths ("%" in the rest of the path escaped).
+ (BOOL)isCelAnimationCanBeCreatedAtPath:(id)aPath frameFormat:(id *)aFormat firstFrame:(int *)aFrame framesCount:(unsigned int *)aCount
{
    NSString *format = nil;
    int firstFrame = -1;
    unsigned int count = 0;
    BOOL canCreate = NO;
    NSString *name = [aPath lastPathComponent];
    NSRange lastDigit = name != nil ? [name rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch] : NSMakeRange(NSNotFound, 0);
    if (lastDigit.location != NSNotFound) {
        NSUInteger digitsStart = lastDigit.location;
        while (digitsStart > 0 && isdigit([name characterAtIndex:digitsStart - 1]))
            digitsStart--;
        NSUInteger digitsCount = lastDigit.location - digitsStart + 1;
        NSUInteger nameStart = [[aPath stringByDeletingLastPathComponent] length] + 1;
        NSUInteger pathDigitsStart = nameStart + digitsStart;
        NSMutableString *prefix = [[aPath substringToIndex:pathDigitsStart] mutableCopy];
        NSMutableString *suffix = [[aPath substringFromIndex:nameStart + lastDigit.location + 1] mutableCopy];
        if (prefix != nil && suffix != nil) {
            [prefix replaceOccurrencesOfString:@"%" withString:@"%%" options:0 range:NSMakeRange(0, [prefix length])];
            [suffix replaceOccurrencesOfString:@"%" withString:@"%%" options:0 range:NSMakeRange(0, [suffix length])];
            format = [NSString stringWithFormat:@"%@%%0%dd%@", prefix, (int)digitsCount, suffix];
        }
        [prefix release];
        [suffix release];
        if (format != nil) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            int number = [[aPath substringWithRange:NSMakeRange(pathDigitsStart, digitsCount)] intValue];
            // back to the first frame of the run
            firstFrame = number;
            while (firstFrame > 0) {
                NSString *path = [[NSString alloc] initWithFormat:format, firstFrame - 1];
                BOOL isDirectory = YES;
                BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory && [fileManager isReadableFileAtPath:path];
                [path release];
                if (!exists)
                    break;
                firstFrame--;
            }
            // and on to the last one
            count = number - firstFrame + 1;
            for (int frame = number + 1; ; frame++) {
                NSString *path = [[NSString alloc] initWithFormat:format, frame];
                BOOL isDirectory = YES;
                BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory && [fileManager isReadableFileAtPath:path];
                [path release];
                if (!exists)
                    break;
                count++;
            }
            canCreate = count > 1;
        }
    }
    if (aFormat != NULL)
        *aFormat = format;
    if (aFrame != NULL)
        *aFrame = firstFrame;
    if (aCount != NULL)
        *aCount = count;
    return canCreate;
}

// New media for each image; the frame media UIDs.
+ (id)framesMediaWithImages:(id)aImages
{
    if (aImages == nil)
        return nil;
    NSMutableArray *framesMedia = [NSMutableArray array];
    for (id image in aImages) {
        id media = [HSNewMedia mediaWithImage:image];
        if (media == nil)
            continue;
        @try {
            [framesMedia addObject:[media mediaUID]];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception was raised while adding media to array. Ignored.");
            NSLog(@"%@", exception);
        }
    }
    return framesMedia;
}

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
                                                      @"HSCelMovieNodeUnit", @"HSCelMovieObjectRole",
                                                      @"HSTransparentColorNodeUnit", @"Transparent Color Unit", nil];
}

// Only for objCelMovie elements (not subclasses); the stored frames per
// second are set as the frame time length (rounded), as in the original.
- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    if (![[self XMLElementName] isEqualToString:@"objCelMovie"])
        return;
    id unit = [super unitForRole:@"HSCelMovieObjectRole"];
    NSMutableArray *framesMedia = [NSMutableArray array];
    for (NSXMLElement *mediaRef in [aRepresentation elementsForName:@"mediaRef"]) {
        NSString *refId = [[mediaRef attributeForName:HSXMLStoringRefIdString] stringValue];
        if (refId != nil && ![refId isEqualToString:@""])
            [framesMedia addObject:[HSUID UIDWithString:refId]];
    }
    [(HSCelMovieNodeUnit *)unit setFramesMedia:framesMedia];
    [unit setFrameTimeLength:llround([[[aRepresentation attributeForName:@"fps"] stringValue] doubleValue])];
    [unit setDefaultFrameSize:NSSizeFromString([[aRepresentation attributeForName:@"defaultFrameSize"] stringValue])];
    [(HSSizeNodeUnit *)[super unitForRole:@"Size Unit"] setSize:NSSizeFromString([[aRepresentation attributeForName:@"frameSize"] stringValue])];
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

// Each frame media is referenced by its UID, and added to the context
// (converted once per context).
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    if (![[self XMLElementName] isEqualToString:@"objCelMovie"])
        return;
    id unit = [self unitForRole:@"HSCelMovieObjectRole"];
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"fps" stringValue:[NSString stringWithFormat:@"%.3f", [(HSCelMovieNodeUnit *)unit framesPerSecond]]]];
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"defaultFrameSize" stringValue:NSStringFromSize([unit defaultFrameSize])]];
    for (id uid in [(HSCelMovieNodeUnit *)unit framesMedia]) {
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
            [mediaRef addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
            [aRepresentation addChild:mediaRef];
        }
    }
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"frameSize" stringValue:NSStringFromSize([(HSSizeNodeUnit *)[self unitForRole:@"Size Unit"] size])]];
}

- (id)XMLElementName
{
    return @"objCelMovie";
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// An image sequence: each frame is a resource (with the transparent colour
// removed into new media when it is enabled); frames whose media can't be
// named are left out.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    id unit = [self unitForRole:@"HSCelMovieObjectRole"];
    if (unit == nil)
        return dictionary;
    [dictionary setObject:@"imageSequence" forKey:@"type"];
    BOOL transparentColorEnabled = [[self queryHyperInterface:@protocol(HSTransparentColorAttributes)] isTransparentColorEnabled];
    NSArray *framesMedia = [(HSCelMovieNodeUnit *)unit framesMedia];
    NSMutableArray *frames = [NSMutableArray new];
    NSUInteger count = [framesMedia count];
    for (NSUInteger i = 0; i < count; i++) {
        id uid = [framesMedia objectAtIndex:i];
        NSString *source = [aContext mediaNameForUID:uid];
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
        if (transparentColorEnabled) {
            media = [HSNewMedia mediaWithImage:[self applyTransparentColorToImageWithMedia:media]];
            uid = [media mediaUID];
            source = nil;
        }
        if (source == nil) {
            NSString *filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media];
            if (filename == nil)
                continue;
            source = [@"Resources" stringByAppendingPathComponent:filename];
            [aContext addUID:uid withMediaName:source];
            [aContext addMedia:media];
        }
        NSDictionary *frame = [[NSDictionary alloc] initWithObjectsAndKeys:source, @"src", [NSString stringWithFormat:@"%i", (int)i], @"index", nil];
        [frames addObject:frame];
        [frame release];
    }
    [dictionary setObject:frames forKey:@"frames"];
    [frames release];
    [dictionary setObject:[NSString stringWithFormat:@"%.3f", [(HSCelMovieNodeUnit *)unit framesPerSecond]] forKey:@"fps"];
    NSSize size = [(HSSizeNodeUnit *)[self unitForRole:@"Size Unit"] size];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)size.width] forKey:@"xSize"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)size.height] forKey:@"ySize"];
    return dictionary;
}

// The media image without the object's transparent colour, or the image
// itself when that fails.
- (id)applyTransparentColorToImageWithMedia:(id)aMedia
{
    id attributes = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
    NSImage *image = [aMedia image];
    NSImage *cleared = HSGenericImageRenderLayerRemovingColorFromCelImage(image, [attributes transparentColor], [attributes hueTolerance], [attributes chromaTolerance], [attributes lightnessTolerance]);
    return cleared != nil ? cleared : image;
}

- (BOOL)canMoveVertically
{
    return YES;
}

- (BOOL)canMoveHorizontally
{
    return YES;
}

- (BOOL)canRotate
{
    return YES;
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return YES;
}

- (BOOL)canFlipHorizontally
{
    return YES;
}

- (BOOL)canScaleVertically
{
    return YES;
}

- (BOOL)canScaleHorizontally
{
    return YES;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
}

- (NSSize)defaultSize
{
    id unit = [super unitForRole:@"HSCelMovieObjectRole"];
    if (![unit isKindOfClass:[HSCelMovieNodeUnit class]])
        return NSZeroSize;
    return [unit defaultFrameSize];
}

- (id)queryImageObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryEditorHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorHitTestingVisualization)] autorelease];
}

- (id)queryInteractiveHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSPlayerHitTestingVisualization)] autorelease];
}

- (id)queryDefaultHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self] autorelease];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface))
        return [[[HSCelMovieObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

// Needs at least two frames and a non-empty frame size.
- (id)initWithFramesMedia:(id)aMedia precachedFrames:(id)aFrames frameTimeLength:(long long)aLength frameSize:(NSSize)aSize
{
    self = [self init];
    if (self == nil || aMedia == nil || [aMedia count] < 2 || aSize.width == 0.0 || aSize.height == 0.0) {
        [self release];
        return nil;
    }
    id unit = [super unitForRole:@"HSCelMovieObjectRole"];
    if ([unit isKindOfClass:[HSCelMovieNodeUnit class]]) {
        [unit setFramesMedia:aMedia precachedFrames:aFrames];
        [unit setFrameTimeLength:aLength];
        [unit setDefaultFrameSize:aSize];
    }
    id sizeUnit = [super unitForRole:@"Size Unit"];
    if ([sizeUnit isKindOfClass:[HSSizeNodeUnit class]])
        [(HSSizeNodeUnit *)sizeUnit setSize:aSize];
    return self;
}

- (id)initWithFramesMedia:(id)aMedia frameTimeLength:(long long)aLength frameSize:(NSSize)aSize
{
    return [self initWithFramesMedia:aMedia frameTimeLength:aLength frameSize:aSize cacheFrames:YES];
}

// Precaching loads every frame image now; frames are only precached when all
// of them load.
- (id)initWithFramesMedia:(id)aMedia frameTimeLength:(long long)aLength frameSize:(NSSize)aSize cacheFrames:(BOOL)aFrames
{
    NSMutableArray *frames = nil;
    if (aFrames) {
        frames = [[NSMutableArray alloc] initWithCapacity:[aMedia count]];
        for (id uid in aMedia) {
            NSData *data = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid] mediaData];
            if ([data length] == 0)
                break;
            NSImage *image = [[NSImage alloc] initWithData:data];
            if (image == nil)
                break;
            [frames addObject:image];
            [image release];
        }
        if ([frames count] != [aMedia count]) {
            [frames release];
            frames = nil;
        }
    }
    id result = [self initWithFramesMedia:aMedia precachedFrames:frames frameTimeLength:aLength frameSize:aSize];
    [frames release];
    return result;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [super linkAttribute:@protocol(HSImageAttribute) toAttribute:@protocol(HSMediaAttribute)];
        [super linkAttribute:@protocol(HSImageRectAttribute) toAttribute:@protocol(HSSizeAttribute)];
    }
    return self;
}

@end
