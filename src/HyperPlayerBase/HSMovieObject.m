#import "HSMovieObject.h"
#import "CGEImage.h"
#import "HSActionEvent.h"
#import "HSActionMediaPlayer.h"
#import "HSConcreteCardObjectData.h"
#import "HSExecutableResourceProvider.h"
#import "HSFunctions.h"
#import "HSHTML5ExporterHelper.h"
#import "HSHitTestingMovieObjectVisualization.h"
#import "HSInteractiveMovieObject.h"
#import "HSMediaFileWrapper.h"
#import "HSMovie.h"
#import "HSMovieObjectData.h"
#import "HSMovieObjectGeometryBehaviorAdaptor.h"
#import "HSMovieObjectVisualization.h"
#import "HSMoviePixelBufferRenderer.h"
#import "HSMovieWithController.h"
#import "HSNavigationController.h"
#import "HSNewMediaAccessor.h"
#import "HSPlayMovieAction.h"
#import "HSQuickTimeMovieHelper.h"
#import "HSSizeNodeUnit.h"
#import "HSStack.h"
#import "HSThreadInvocationWrapper.h"
#import "HSUID.h"
#import "HSUserObject+FileTypes.h"
#import "HSValueConstraints.h"
#import "HSVisualHitTester.h"
#import "HSiPadExportContext.h"
#import "NSAffineTransform+HSKeyValueCoding.h"
#import "NSEMutableProtocolSet.h"
#import "NSImage+HSImageSize.h"
#import "NSMutableArray+EXMutableArray.h"
#import "NSString+EXMacTypes.h"
#import "NSString+NSStringLinkRecognitionHSExtensions.h"

static NSArray *HSMovieObjectMovieFileTypes = nil;

// The HTML5 export context; its class lives outside this framework.
@protocol HSMovieObjectHTML5ExportContext
- (id)documentType;
- (id)mediaNameForUID:(id)aUID;
- (void)addUID:(id)aUID withMediaName:(id)aName;
- (void)addMedia:(id)aMedia;
@end

static float HSMovieObjectToleranceScale(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

// Different by more than 0.0005 of the larger magnitude.
static BOOL HSMovieObjectFloatsDiffer(float aValue1, float aValue2)
{
    return fabsf(aValue1 - aValue2) > MAX(HSMovieObjectToleranceScale(aValue1), HSMovieObjectToleranceScale(aValue2)) * 0.0005f;
}

static BOOL HSMovieObjectDoublesAreEqual(double aValue1, double aValue2)
{
    double scale1 = aValue1 != 0.0 ? fabs(aValue1) : 1.0;
    double scale2 = aValue2 != 0.0 ? fabs(aValue2) : 1.0;
    return fabs(aValue1 - aValue2) <= MAX(scale1, scale2) * 1e-05;
}

// aValue >= aValue2, within 0.0005 of the larger magnitude.
static BOOL HSMovieObjectIsGreaterOrEqual(float aValue, float aValue2)
{
    return aValue >= aValue2 - MAX(HSMovieObjectToleranceScale(aValue), HSMovieObjectToleranceScale(aValue2)) * 0.0005f;
}

// Greater than zero, beyond the tolerance.
static BOOL HSMovieObjectIsPositive(float aValue)
{
    float scale = HSMovieObjectToleranceScale(aValue);
    return aValue > (scale < 1.0f ? 0.0005f : scale * 0.0005f) + 0.0f;
}

// An angle (in radians) brought into [0, 2pi).
static float HSMovieObjectNormalizedAngle(float aAngle)
{
    double fullTurn = M_PI + M_PI;
    if (HSMovieObjectIsGreaterOrEqual(aAngle, fullTurn))
        return (float)(floorf((float)(aAngle / fullTurn)) * M_PI * -2.0 + aAngle);
    if (aAngle < 0.0f) {
        float angle = (float)((floorf((float)(fabsf(aAngle) / fullTurn)) + 1.0) * fullTurn + aAngle);
        if (HSMovieObjectIsGreaterOrEqual(angle, fullTurn))
            angle = (float)(angle + M_PI * -2.0);
        return angle;
    }
    return aAngle;
}

// The movie frame transform for the object's flips, about aRect.
static CGAffineTransform HSMovieObjectFlipTransform(id aGeometry, NSRect aRect)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    if ([aGeometry isFlippedVertically]) {
        CGFloat offset = aRect.origin.y + aRect.origin.y + aRect.size.height;
        transform.tx += transform.c * offset;
        transform.ty += transform.d * offset;
        transform.c = -transform.c;
        transform.d = -transform.d;
    }
    if ([aGeometry isFlippedHorizontally]) {
        CGFloat offset = aRect.origin.x + aRect.origin.x + aRect.size.width;
        transform.tx += transform.a * offset;
        transform.ty += transform.b * offset;
        transform.a = -transform.a;
        transform.b = -transform.b;
    }
    return transform;
}

// Draws a CVPixelBuffer movie frame into aRect, keying out aColor when set.
static void HSMovieObjectDrawFrame(HSMovieObject *self, id aRenderer, CVPixelBufferRef aFrame, NSRect aRect, id aColor, id aTransparency)
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (aColor == nil) {
        CGImageRef image = CGEImageCreateWithPixelBuffer(aFrame, 1, NULL, false, kCGRenderingIntentPerceptual);
        if (image != NULL) {
            CGContextDrawImage(context, NSRectToCGRect(aRect), image);
            CGImageRelease(image);
        }
        return;
    }
    CGContextSaveGState(context);
    double lightness = [aTransparency lightnessTolerance];
    double chroma = [aTransparency chromaTolerance];
    double hue = [aTransparency hueTolerance];
    [(HSMoviePixelBufferRenderer *)aRenderer drawFramePixelBuffer:aFrame inRect:aRect fromRelativeRect:[self relativeMovieSourceRect] withTransparentColor:aColor hueTolerance:hue chromaTolerance:chroma lightnessTolerance:lightness];
    CGContextRestoreGState(context);
}

// A movie playing object with an optional controller; QTVR and panorama
// movies have their field of view, pan and tilt kept in the node data.
@implementation HSMovieObject

+ (id)movieFileTypes
{
    if (HSMovieObjectMovieFileTypes == nil)
        HSMovieObjectMovieFileTypes = [[HSUserObject typesForUserObjectClassName:@"HSMovieObject"] retain];
    return HSMovieObjectMovieFileTypes;
}

+ (Class)nodeDataClass
{
    return [HSMovieObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSSizeNodeUnit", @"Size Unit", @"HSGeometryNodeUnit", @"Geometry Unit",
        @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit", @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
        @"HSShowHideTransitionNodeUnit", @"Transition Unit", @"HSTransparentColorNodeUnit", @"Transparent Color Unit",
        @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit", nil];
}

// Shrinks the default size, keeping its proportion, when it's larger than the
// card or covers more than 90% of it.
- (void)stretchIfNeededToCardSize:(NSSize)aSize
{
    id <HSMutableSizeAttributes> sizeAttributes = [self queryHyperInterface:@protocol(HSMutableSizeAttributes)];
    if (sizeAttributes == nil)
        return;
    NSSize size = [sizeAttributes defaultSize];
    if (aSize.width < size.width || aSize.height < size.height || aSize.width * aSize.height * 0.9 < size.width * size.height) {
        float proportion = size.width / size.height;
        if (proportion <= aSize.width / aSize.height) {
            size.width = proportion * aSize.height;
            size.height = aSize.height;
        } else {
            size.height = aSize.width / proportion;
            size.width = aSize.width;
        }
    }
    [sizeAttributes setSize:size];
}

- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id mediaRef = [(NSMutableArray *)[aRepresentation elementsForName:@"mediaRef"] extraFirstObject];
    id uid = [HSUID UIDWithString:[[mediaRef attributeForName:HSXMLStoringRefIdString] stringValue]];
    [self setMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid]];
    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id behavior = [(NSMutableArray *)[aRepresentation elementsForName:@"movieBehavior"] extraFirstObject];
    [self setHyperPlayCount:![[[behavior attributeForName:@"looped"] stringValue] hyperBoolValue]];
    [self setHyperHasController:[[[behavior attributeForName:@"visibleController"] stringValue] hyperBoolValue]];
    [self setHyperStartingOnClick:[[[behavior attributeForName:@"startingOnClick"] stringValue] hyperBoolValue]];
    [self setHyperAllowPlayingOtherSounds:[[[behavior attributeForName:@"otherSounds"] stringValue] hyperBoolValue]];
    [self setHyperAllowPlayingOtherMovies:[[[behavior attributeForName:@"otherMovies"] stringValue] hyperBoolValue]];
    [self setHyperPanAngle:[[[behavior attributeForName:@"panoramaAngle"] stringValue] floatValue]];
    [self setHyperTiltAngle:[[[behavior attributeForName:@"tiltAngle"] stringValue] floatValue]];
    [self setHyperFieldOfView:[[[behavior attributeForName:@"fieldOfView"] stringValue] floatValue]];
    [self setHyperVolume:[[[behavior attributeForName:@"volume"] stringValue] floatValue]];
    double startTime = [[[behavior attributeForName:@"startTime"] stringValue] doubleValue];
    // Original quirk kept: "duration" is read as the end of the range, while
    // it's stored as the range's length.
    double duration = [[[behavior attributeForName:@"duration"] stringValue] doubleValue];
    [self setHyperPlayRange:HSMakeTimeRange(startTime, duration - startTime)];
    id transparency = [(NSMutableArray *)[aRepresentation elementsForName:@"transparency"] extraFirstObject];
    if (transparency != nil) {
        id attributes = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
        if (attributes != nil) {
            [attributes setTransparentColorEnabled:[[[transparency attributeForName:@"enabled"] stringValue] hyperBoolValue]];
            [attributes setHueTolerance:[[[transparency attributeForName:@"hueTolerance"] stringValue] doubleValue]];
            [attributes setChromaTolerance:[[[transparency attributeForName:@"chromaTolerance"] stringValue] doubleValue]];
            [attributes setLightnessTolerance:[[[transparency attributeForName:@"lightnessTolerance"] stringValue] doubleValue]];
            NSArray *components = [[[transparency attributeForName:@"color"] stringValue] componentsSeparatedByString:@","];
            if ([components count] > 2) {
                float red = [[components objectAtIndex:0] floatValue];
                float green = [[components objectAtIndex:1] floatValue];
                float blue = [[components objectAtIndex:2] floatValue];
                float alpha = [components count] == 4 ? [[components objectAtIndex:3] floatValue] : 1.0f;
                [attributes setTransparentColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
            }
        }
    }
    [pool release];
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

static void HSMovieObjectAddMediaReference(id aRepresentation, NSString *aName, id aMedia)
{
    NSXMLElement *element = [NSXMLElement elementWithName:aName];
    [element addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[aMedia mediaUID] stringValue]]];
    [aRepresentation addChild:element];
}

static NSString *HSMovieObjectBoolString(BOOL aValue)
{
    return aValue ? HSXMLStoring1String : HSXMLStoring0String;
}

- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeSharedPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    id media = [self media];
    if ([self isHyperQTVR] || [self isHyperPanoramaObject]) {
        if ([aContext shouldTerminateExport])
            return;
        if (media != nil) {
            HSMovieObjectAddMediaReference(aRepresentation, @"originalMediaRef", media);
            [aContext addMedia:media];
        }
    }
    HSMovie *movie = [self hyperMovie];
    media = [media retain];
    if (media != nil) {
        if (![movie isGifMovie] && ![movie isCompatibleWithIPad]) {
            [aContext setConvertedMedia:movie forKey:[[media mediaName] lowercaseString]];
            id firstFrame = [HSNewMedia mediaWithData:[self firstFramePNGRepresentation] name:[[HSUID UID] stringValue] type:@"png"];
            HSMovieObjectAddMediaReference(aRepresentation, @"firstFrameMediaRef", firstFrame);
            [aContext addMedia:firstFrame];
        }
        if ([aContext shouldTerminateExport]) {
            // Fix: the original leaked the media when the export was cancelled.
            [media release];
            return;
        }
        HSMovieObjectAddMediaReference(aRepresentation, @"mediaRef", media);
        [aContext addMedia:media];
        [media release];
    }
    if ([aContext shouldTerminateExport])
        return;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSXMLElement *behavior = [NSXMLElement elementWithName:@"movieBehavior"];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"looped" stringValue:HSMovieObjectBoolString([self hyperPlayCount] != 1)]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"visibleController" stringValue:HSMovieObjectBoolString([self hasController])]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"startingOnClick" stringValue:HSMovieObjectBoolString([self isHyperStartingOnClick])]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"otherSounds" stringValue:HSMovieObjectBoolString([self isHyperAllowPlayingOtherSounds])]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"otherMovies" stringValue:HSMovieObjectBoolString([self isHyperAllowPlayingOtherMovies])]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"rate" stringValue:[NSString stringWithFormat:@"%.0f", [self hyperFramesPerSecond]]]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"panoramaAngle" stringValue:[NSString stringWithFormat:@"%.0f", (double)[self hyperPanAngle]]]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"tiltAngle" stringValue:[NSString stringWithFormat:@"%.0f", (double)[self hyperTiltAngle]]]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"fieldOfView" stringValue:[NSString stringWithFormat:@"%.0f", (double)[self hyperFieldOfView]]]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"volume" stringValue:[NSString stringWithFormat:@"%.8f", (double)[self hyperVolume]]]];
    struct HSTimeRange range = [self hyperPlayRange];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"startTime" stringValue:[NSString stringWithFormat:@"%.2f", range.location]]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"duration" stringValue:[NSString stringWithFormat:@"%.2f", range.length]]];
    [aRepresentation addChild:behavior];
    id attributes = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
    if (attributes != nil && [attributes isTransparentColorEnabled]) {
        NSXMLElement *transparency = [NSXMLElement elementWithName:@"transparency"];
        [transparency addAttribute:[NSXMLNode attributeWithName:@"enabled" stringValue:HSMovieObjectBoolString([attributes isTransparentColorEnabled])]];
        NSColor *color = [[attributes transparentColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        double red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0;
        if (color != nil) {
            red = [color redComponent];
            green = [color greenComponent];
            blue = [color blueComponent];
            alpha = [color alphaComponent];
        }
        [transparency addAttribute:[NSXMLNode attributeWithName:@"color" stringValue:[NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", red, green, blue, alpha]]];
        [transparency addAttribute:[NSXMLNode attributeWithName:@"hueTolerance" stringValue:[NSString stringWithFormat:@"%.2f", (double)[attributes hueTolerance]]]];
        [transparency addAttribute:[NSXMLNode attributeWithName:@"chromaTolerance" stringValue:[NSString stringWithFormat:@"%.2f", (double)[attributes chromaTolerance]]]];
        [transparency addAttribute:[NSXMLNode attributeWithName:@"lightnessTolerance" stringValue:[NSString stringWithFormat:@"%.2f", (double)[attributes lightnessTolerance]]]];
        [aRepresentation addChild:transparency];
    }
    [pool release];
}

- (id)XMLElementName
{
    return @"objMovie";
}

// The movie converted to an iPad movie (cached in the context by media UID),
// retained; nil when there's no movie or the export was cancelled.
- (id)newMovieMediaForExportInContext:(id)aContext
{
    id uid = [self mediaUID];
    id media = [[aContext convertedMediaForKey:uid] retain];
    if (media != nil || [self hyperMovie] == nil)
        return media;
    QTMovie *movie = [QTMovie movieWithQuickTimeMovie:[(HSMovie *)[self hyperMovie] quickTimeMovie] disposeWhenDone:NO error:NULL];
    NSString *path = [NSString extraCreateUniqueFilename:[NSTemporaryDirectory() stringByAppendingPathComponent:@"_iPadTmpMovie"] extension:@"mov"];
    NSSize size = [[movie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
    if ([aContext shouldTerminateExport])
        return nil;
    NSInteger error = [HSQuickTimeMovieHelper convertMovie:movie frameSize:size ofType:'M4V ' toFile:path progressCallback:NULL sender:self];
    if (![aContext shouldTerminateExport] && error == 0) {
        NSString *name = [[[[[self media] mediaName] stringByDeletingPathExtension] stringByAppendingString:@"_iPad"] stringByAppendingPathExtension:@"mov"];
        media = [[HSNewMedia mediaWithPath:path name:name removeWhenDone:YES] retain];
        [aContext setConvertedMedia:media forKey:uid];
    }
    return media;
}

// The renderer to draw movie frames with: the movie's own when it draws pixel
// buffers, otherwise a temporary one (the movie's is detached meanwhile).
static id HSMovieObjectPixelBufferRenderer(id aRenderer, QTMovie *aMovie)
{
    if ([aRenderer isKindOfClass:[HSMoviePixelBufferRenderer class]])
        return aRenderer;
    [aRenderer detachFromMovie];
    return [[HSMoviePixelBufferRenderer alloc] initWithQTMovie:aMovie storage:nil];
}

static void HSMovieObjectReleasePixelBufferRenderer(id aRenderer, id aMovieRenderer)
{
    if (aRenderer != aMovieRenderer) {
        [aRenderer release];
        [aMovieRenderer reattachToMovie];
    }
}

- (id)firstFramePNGRepresentation
{
    if ([self hyperMovie] == nil)
        return nil;
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    QTMovie *movie = [QTMovie movieWithQuickTimeMovie:[(HSMovie *)[self hyperMovie] quickTimeMovie] disposeWhenDone:NO error:NULL];
    id transparency = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
    id color = nil;
    if (![self isHyperQTVR] && ![self isHyperPanoramaObject] && [transparency isTransparentColorEnabled])
        color = [transparency transparentColor];
    if ([(HSMovie *)[self hyperMovie] isAnimatedGifMovie])
        color = [NSColor clearColor];
    id movieRenderer = [self movieRenderer];
    id renderer = HSMovieObjectPixelBufferRenderer(movieRenderer, movie);
    NSRect rect = NSIntegralRect([self movieRect]);
    QTTime time = QTMakeTime(0, 15);
    [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieFrameImageSessionMode];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [self sendEventsToApp];
    NSImage *image = [[NSImage alloc] initWithSize:rect.size];
    [image lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0.0 yBy:rect.size.height - rect.size.height];
    [transform concat];
    // The original runs its frame strip loop (as PNGMapsInContext:) over the
    // single frame at time 0.
    [self sendEventsToApp];
    CGAffineTransform flip = HSMovieObjectFlipTransform(geometry, rect);
    [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:QTMovieFrameImageTypeCVPixelBufferRef forKey:QTMovieFrameImageType];
    CVPixelBufferRef frame = (CVPixelBufferRef)[movie frameImageAtTime:time withAttributes:attributes error:NULL];
    if (frame != NULL) {
        HSMovieObjectDrawFrame(self, renderer, frame, rect, color, transparency);
        flip.tx += flip.c * -rect.size.height;
        flip.ty += flip.d * -rect.size.height;
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
    }
    [image unlockFocus];
    id representation = [[image hyperPNGRepresentation] retain];
    [image release];
    [pool release];
    [movie setAttribute:[NSNumber numberWithBool:NO] forKey:QTMovieFrameImageSessionMode];
    HSMovieObjectReleasePixelBufferRenderer(renderer, movieRenderer);
    return [representation autorelease];
}

// Handles the pending events (in the event tracking mode).
- (void)sendEventsToApp
{
    NSEvent *event;
    while ((event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSEventTrackingRunLoopMode dequeue:YES]) != nil)
        [NSApp sendEvent:event];
}

- (BOOL)hasiPadUnsupportedFunctionality
{
    return [super hasiPadUnsupportedFunctionality] || [self isHyperPanoramaObject] || [self isHyperQTVR];
}

- (id)iPadUnsupportedFunctionalityDescription
{
    NSMutableArray *descriptions = [NSMutableArray array];
    [descriptions addObjectsFromArray:[super iPadUnsupportedFunctionalityDescription]];
    if ([self isHyperPanoramaObject])
        [descriptions addObject:[NSString stringWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSiPadUnsupportedFeaturePanoramaMovie" value:@"" table:@"Export"]]];
    else if ([self isHyperQTVR])
        [descriptions addObject:[NSString stringWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSiPadUnsupportedFeatureQTVR" value:@"" table:@"Export"]]];
    return [descriptions count] != 0 ? [NSArray arrayWithArray:descriptions] : nil;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableArray *features = [[[super HTML5UnsupportedFeaturesForDocumentType:aType] mutableCopy] autorelease];
    if ([[self queryHyperInterface:@protocol(HSTransparentColorAttributes)] isTransparentColorEnabled])
        [features addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureTransparentMovie" value:@"" table:@"Export"]];
    HSMovie *movie = [self hyperMovie];
    if (!HSEqualTimeRanges([movie playRange], [self hyperPlayRange]))
        [features addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureMovieObjectRange" value:@"" table:@"Export"]];
    if ([aType isEqualToString:@"HSiBooksAuthorDocumentType"] && (float)[movie volume] != 1.0f)
        [features addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureMovieObjectVolume" value:@"" table:@"Export"]];
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if ([super hasUnsupportedHTML5FeaturesForDocumentType:aType])
        return YES;
    if ([[self queryHyperInterface:@protocol(HSTransparentColorAttributes)] isTransparentColorEnabled])
        return YES;
    HSMovie *movie = [self hyperMovie];
    if (!HSEqualTimeRanges([movie playRange], [self hyperPlayRange]))
        return YES;
    if ([aType isEqualToString:@"HSiBooksAuthorDocumentType"])
        return (float)[movie volume] != 1.0f;
    return NO;
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    NSString *key = [self isHyperPanoramaObject] ? @"HSHTML5UnsupportedFeaturePanoramaMovie" : @"HSHTML5UnsupportedFeatureQTVR";
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:key value:@"" table:@"Export"];
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![self isHyperPanoramaObject] && ![self isHyperQTVR];
}

static NSString *HSMovieObjectFlagString(BOOL aValue)
{
    return aValue ? @"1" : @"0";
}

// A movie with alpha is exported as PNG frame strips ("maps"), an opaque one
// as a video file with a poster frame.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    HSMovie *movie = [self hyperMovie];
    if (movie == nil)
        return nil;
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    if (![(HSMovie *)[self hyperMovie] isOpaque]) {
        NSArray *maps = [self PNGMapsInContext:aContext];
        if ([maps count] == 0)
            goto done;
        if ([movie hasSound]) {
            id sound = [HSNewMedia mediaWithPath:[(id)movie convertedSoundtrackPath]];
            if (sound == nil)
                goto done;
            NSString *filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:sound];
            if ([filename length] == 0)
                goto done;
            NSString *source = [@"Resources" stringByAppendingPathComponent:filename];
            if ([source length] == 0)
                goto done;
            [dictionary setObject:source forKey:@"src"];
            [aContext addMedia:sound];
        }
        [dictionary setObject:maps forKey:@"mapData"];
        [dictionary setObject:@"1" forKey:@"isPNGMap"];
        [dictionary setObject:[NSString stringWithFormat:@"%d", 15] forKey:@"mapFPS"];
        NSRect rect = NSIntegralRect([self movieRect]);
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)rect.size.width] forKey:@"xSize"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)rect.size.height] forKey:@"ySize"];
    } else {
        id media = [self media];
        id uid = [media mediaUID];
        if (media == nil || uid == nil)
            goto done;
        NSString *source = [aContext mediaNameForUID:uid];
        if (source == nil) {
            id video = [self movieMediaForHTML5ExportWithContext:aContext];
            if (video == nil)
                goto done;
            BOOL iBooks = [[(id <HSMovieObjectHTML5ExportContext>)aContext documentType] isEqualToString:@"HSiBooksAuthorDocumentType"];
            NSString *type = iBooks ? @"mp4" : @"m4v";
            if (![[video mediaType] isEqualToString:type])
                video = [HSNewMedia mediaWithMedia:video type:type];
            NSString *filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:video];
            if ([filename length] == 0)
                goto done;
            source = [@"Resources" stringByAppendingPathComponent:filename];
            [aContext addMedia:video];
            [aContext addUID:uid withMediaName:source];
        }
        [dictionary setObject:@"0" forKey:@"isPNGMap"];
        [dictionary setObject:source forKey:@"src"];
        NSData *poster = [[(HSMovie *)[self hyperMovie] posterImage] hyperPNGRepresentation];
        if (poster != nil) {
            id posterMedia = [HSNewMedia mediaWithData:poster name:@"poster" type:@"png"];
            [aContext addMedia:posterMedia];
            NSString *filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:posterMedia];
            if (filename != nil)
                [dictionary setObject:[@"Resources" stringByAppendingPathComponent:filename] forKey:@"posterFrame"];
        }
    }
    [dictionary setObject:@"video" forKey:@"type"];
    id playable = [self queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)];
    if (playable != nil) {
        [dictionary setObject:HSMovieObjectFlagString([playable isHyperStartingOnClick]) forKey:@"movieClicking"];
        [dictionary setObject:HSMovieObjectFlagString(![playable isHyperAllowPlayingOtherMovies]) forKey:@"stopOtherMovies"];
        [dictionary setObject:HSMovieObjectFlagString(![playable isHyperAllowPlayingOtherSounds]) forKey:@"stopOtherSounds"];
    }
    struct HSTimeRange range = [self hyperPlayRange];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", range.location] forKey:@"startTime"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", range.length] forKey:@"length"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", (double)[self hyperVolume]] forKey:@"volume"];
    [dictionary setObject:HSMovieObjectFlagString([self hasController]) forKey:@"hasController"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", (double)[self hyperOpacity]] forKey:@"opacity"];
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    [dictionary setObject:HSMovieObjectFlagString([geometry isFlippedHorizontally]) forKey:@"isFlippedHorizontally"];
    [dictionary setObject:HSMovieObjectFlagString([geometry isFlippedVertically]) forKey:@"isFlippedVertically"];
done:
    [pool release];
    return dictionary;
}

// The movie at 15 frames per second drawn into PNG sheets of at most
// 1600x1200, frames left to right then top to bottom; one dictionary per sheet
// (its media, size and frame range).
- (id)PNGMapsInContext:(id)aContext
{
    NSMutableArray *maps = [NSMutableArray array];
    if ([self hyperMovie] == nil)
        return maps;
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    QTMovie *movie = [QTMovie movieWithQuickTimeMovie:[(HSMovie *)[self hyperMovie] quickTimeMovie] disposeWhenDone:NO error:NULL];
    id transparency = [self queryHyperInterface:@protocol(HSTransparentColorAttributes)];
    id color = nil;
    if (![self isHyperQTVR] && ![self isHyperPanoramaObject] && [transparency isTransparentColorEnabled])
        color = [transparency transparentColor];
    if ([(HSMovie *)[self hyperMovie] isAnimatedGifMovie])
        color = [NSColor whiteColor];
    id movieRenderer = [self movieRenderer];
    id renderer = HSMovieObjectPixelBufferRenderer(movieRenderer, movie);
    NSRect rect = NSIntegralRect([self movieRect]);
    float width = rect.size.width;
    float height = rect.size.height;
    QTTime duration = [movie duration];
    QTTime time = QTMakeTime(0, 15);
    unsigned int frameCount = (unsigned int)QTMakeTimeScaled(duration, 15).timeValue + 1;
    [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieFrameImageSessionMode];
    // Fix: a movie narrower or shorter than a pixel gets one column or row
    // (the original divided by zero).
    unsigned int columns = 1600 / MAX((unsigned int)(int)width, 1u);
    unsigned int sheetRows = 1200 / MAX((unsigned int)(int)height, 1u);
    columns = MAX(columns, 1u);
    sheetRows = MAX(sheetRows, 1u);
    unsigned int rowsLeft = frameCount / columns + (frameCount % columns != 0);
    float sheetWidth = (float)columns * width;
    NSDictionary *frameAttributes = [NSDictionary dictionaryWithObject:QTMovieFrameImageTypeCVPixelBufferRef forKey:QTMovieFrameImageType];
    NSAutoreleasePool *pool = nil;
    BOOL framesFailed = NO;
    while ((unsigned long long)time.timeValue < frameCount && !framesFailed) {
        [pool release];
        pool = [NSAutoreleasePool new];
        if ([aContext shouldTerminateExport])
            break;
        long long sheetStart = time.timeValue;
        unsigned int rows = MIN(sheetRows, rowsLeft);
        unsigned int sheetEnd = MIN(rows * columns + (unsigned int)time.timeValue, frameCount);
        float sheetHeight = (float)rows * height;
        NSImage *sheet = [[NSImage alloc] initWithSize:NSMakeSize(sheetWidth, sheetHeight)];
        [sheet lockFocus];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0.0 yBy:sheetHeight - height];
        rowsLeft -= rows;
        [transform concat];
        while ((unsigned long long)time.timeValue < sheetEnd) {
            if ([aContext shouldTerminateExport])
                break;
            CGAffineTransform flip = HSMovieObjectFlipTransform(geometry, rect);
            [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
            CVPixelBufferRef frame = (CVPixelBufferRef)[movie frameImageAtTime:time withAttributes:frameAttributes error:NULL];
            if (frame == NULL) {
                // Fix: the original went on with the same frame forever.
                framesFailed = YES;
                break;
            }
            HSMovieObjectDrawFrame(self, renderer, frame, rect, color, transparency);
            // Moves to the next cell: right, or to the start of the next row.
            CGFloat dx, dy;
            if (columns == 1) {
                dx = 0.0;
                dy = -height;
            } else if ((time.timeValue + 2) % columns == 1) {
                dx = width - sheetWidth;
                dy = -height;
            } else {
                dx = width;
                dy = 0.0;
            }
            flip.tx += flip.a * dx + flip.c * dy;
            flip.ty += flip.b * dx + flip.d * dy;
            [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
            time.timeValue++;
        }
        [sheet unlockFocus];
        NSSize size = [sheet size];
        long high = size.height > 0.0 ? lroundf(ceilf(size.height)) : 0;
        long wide = size.width > 0.0 ? lroundf(ceilf(size.width)) : 0;
        id media = [HSNewMedia mediaWithData:[sheet hyperPNGRepresentationWithWide:wide high:high] name:@"frame" type:@"png"];
        [aContext addMedia:media];
        [sheet release];
        NSString *length = [NSString stringWithFormat:@"%qi", time.timeValue - sheetStart];
        NSString *start = [NSString stringWithFormat:@"%qi", sheetStart];
        NSString *ySize = [NSString stringWithFormat:@"%.1f", (double)sheetHeight];
        NSString *xSize = [NSString stringWithFormat:@"%.1f", (double)sheetWidth];
        NSString *source = [@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]];
        [maps addObject:[NSDictionary dictionaryWithObjectsAndKeys:source, @"src", xSize, @"xSize", ySize, @"ySize", start, @"start", length, @"length", nil]];
    }
    // Fix: the maps were made in the pool released here; keep them alive.
    [maps retain];
    [pool release];
    [maps autorelease];
    [movie setAttribute:[NSNumber numberWithBool:NO] forKey:QTMovieFrameImageSessionMode];
    HSMovieObjectReleasePixelBufferRenderer(renderer, movieRenderer);
    return maps;
}

// The media itself when the movie plays on the target (or is QTVR or a
// panorama), otherwise the movie converted to MPEG-4.
- (id)movieMediaForHTML5ExportWithContext:(id)aContext
{
    HSMovie *movie = [self hyperMovie];
    if (movie == nil)
        return nil;
    id media = [self media];
    if ([self isHyperPanoramaObject] || [self isHyperQTVR])
        return media;
    BOOL iBooks = [@"HSiBooksAuthorDocumentType" isEqualToString:[(id <HSMovieObjectHTML5ExportContext>)aContext documentType]];
    if (iBooks ? [movie isCompatibleWithIBooksAuthor] : [movie isCompatibleWithIPad])
        return media;
    NSString *base = [NSTemporaryDirectory() stringByAppendingPathComponent:@"_HTML5TmpMovie"];
    if ([base length] == 0)
        return nil;
    NSString *extension = iBooks ? @"mp4" : @"m4v";
    NSString *path = [NSString extraCreateUniqueFilename:base extension:extension];
    if ([path length] == 0 || [movie quickTimeMovie] == NULL)
        return nil;
    QTMovie *qtMovie = [QTMovie movieWithQuickTimeMovie:[movie quickTimeMovie] disposeWhenDone:NO error:NULL];
    if (qtMovie == nil)
        return nil;
    NSInteger error = [HSQuickTimeMovieHelper convertMovie:qtMovie frameSize:[self movieRect].size ofType:iBooks ? 'M4VH' : 'M4VP' toFile:path progressCallback:(void *)kHSCancelExportMovieProgressProc sender:aContext];
    if (error != 0)
        return nil;
    return [HSNewMedia mediaWithData:[NSData dataWithContentsOfFile:path] name:@"video" type:extension];
}

- (id)mediaUIDsForOptimization
{
    return [NSSet setWithObject:[self mediaUID]];
}

- (BOOL)supportsEffectPerObject
{
    BOOL supports = [super supportsEffectPerObject];
    if ([self isHyperQTVR] || [self isHyperPanoramaObject])
        supports = NO;
    return supports;
}

- (id)recordName
{
    return [[self queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
}

- (id)defaultRecordName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"MyVideoRecord" value:@"" table:nil];
}

- (NSRect)movieControllerRect
{
    NSRect rect = NSZeroRect;
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry != nil && [self hyperHasController] && [self hyperCanUseController]) {
        NSRect movieFrame = [(HSMovieWithController *)[self movieWithController] movieFrameForMovieArea:[geometry boundingRect] isFlipped:YES];
        rect = [(HSMovieWithController *)[self movieWithController] controllerAreaForMovieFrame:movieFrame isFlipped:YES];
    }
    return rect;
}

- (id)movieRenderer
{
    return [(HSMovie *)[self movie] movieRenderer];
}

- (void)setRelativeMovieSourceRect:(NSRect)aRect
{
    NSRect rect = [self relativeMovieSourceRect];
    if (NSEqualRects(aRect, rect))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Relative Movie Source Rect Change" value:@"" table:@"UndoManager"]];
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] setRelativeMovieSourceRect:rect];
    [self notifyChange:1 ofAttribute:@protocol(HSRelativeMovieSourceRectAttribute) withUserInfo:nil];
    [(HSMovieObjectData *)[self nodeData] setRelativeMovieSourceRect:aRect];
    [self notifyChange:2 ofAttribute:@protocol(HSRelativeMovieSourceRectAttribute) withUserInfo:nil];
}

- (NSRect)relativeMovieSourceRect
{
    return [(HSMovieObjectData *)[self nodeData] relativeMovieSourceRect];
}

- (NSRect)movieRect
{
    NSRect rect = NSZeroRect;
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry != nil)
        rect = [geometry boundingRect];
    return rect;
}

// While playing with a controller, redraws the controller every tick that
// had no movie image change.
- (void)HSMovieObject_invalidateMovie
{
    if (_needUpdateController)
        [self notifyChange:2 ofAttribute:@protocol(HSMovieControllerVisualStateAttribute) withUserInfo:nil];
    _needUpdateController = YES;
}

- (void)setPrinting:(BOOL)aPrinting
{
    [(HSMovieObjectData *)[self nodeData] setPrinting:aPrinting];
}

- (void)setNeedsDisplayWithController:(id)aController
{
    [self notifyChange:2 ofAttribute:@protocol(HSMovieControllerVisualStateAttribute) withUserInfo:nil];
}

- (void)stepBackwardWithController:(id)aController
{
    if ([self isHyperPlaying])
        [self hyperStop];
    [self hyperStepBack];
}

- (void)stepForwardWithController:(id)aController
{
    if ([self isHyperPlaying])
        [self hyperStop];
    [self hyperStepForward];
}

- (void)movieWithController:(id)aController setCurrentTime:(double)aTime
{
    [self setHyperCurrentTime:aTime];
}

- (double)currentTimeForMovieWithController:(id)aController
{
    if ([(HSMovieObjectData *)[self nodeData] isPrinting])
        return [self hyperPosterTime];
    return [self hyperCurrentTime];
}

- (void)stopForMovieWithController:(id)aController
{
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopMovie:self];
}

- (void)temporaryStopForMovieWithController:(id)aController
{
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopMovie:self];
}

- (void)playForMovieWithController:(id)aController
{
    [[HSActionMediaPlayer sharedActionMediaPlayer] playMovie:self movieOwner:nil];
}

- (BOOL)isPlayingForMovieWithController:(id)aController
{
    if ([(HSMovieObjectData *)[self nodeData] isPrinting])
        return NO;
    return [self isHyperPlaying];
}

- (struct HSTimeRange)playRangeForMovieWithController:(id)aController
{
    return [self hyperPlayRange];
}

- (double)durationForMovieWithController:(id)aController
{
    return [self hyperDuration];
}

- (BOOL)hasControllerForMovieWithController:(id)aController
{
    return [self hasController];
}

- (BOOL)isEmptyForMovieWithController:(id)aController
{
    return [self isHyperEmpty];
}

- (BOOL)isQTVRMovieForMovieWithController:(id)aController
{
    return [(HSMovie *)[self hyperMovie] isQTVRMovie] || [(HSMovie *)[self hyperMovie] isPanoramaObject];
}

- (void)destroyMovieWithController
{
    [_movieWithController setDelegate:nil];
    [_movieWithController release];
    _movieWithController = nil;
}

- (id)movieWithController
{
    if (_movieWithController == nil) {
        _movieWithController = [HSMovieWithController new];
        [_movieWithController setDelegate:self];
    }
    return _movieWithController;
}

// Cues the movie for the card: at the range of the card's arrival play-movie
// action, or, for a group object shown on the current card's group, where the
// playing copy will be once the card transition is over (wrapped into the
// range).
- (void)performPrimarySetupOnCard:(id)aCard
{
    double time = [self hyperStartTime];
    id actor = [aCard queryHyperInterface:@protocol(HSActor)];
    id action = [actor hyperActionOfType:[HSPlayMovieAction actionType] forEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
    for (id playback in [action movies]) {
        if ([playback movieObjectForCard:aCard] != self)
            continue;
        struct HSTimeRange range = [playback playRange];
        time = range.location;
        if ([self isGroupObject]) {
            id document = [[self stack] document];
            id currentCard = [document currentCard];
            if ([[currentCard cardGroupUID] isEqual:[aCard cardGroupUID]]) {
                id uid = [self sharedNodeDataUID];
                for (id child in [currentCard hyperChildren]) {
                    if (![child isGroupObject] || ![[child sharedNodeDataUID] isEqual:uid] || ![child isHyperPlaying])
                        continue;
                    double transitionDuration = [[document navigationController] transitionDurationForCurrentNavigationOperation];
                    time = [child hyperCurrentTime] + transitionDuration;
                    if (HSMaxTimeRange(range) < time) {
                        double overrun = time - HSMaxTimeRange(range);
                        time = range.location + overrun - range.length * round(overrun / range.length);
                    }
                }
            }
        }
        break;
    }
    [(HSMovie *)[self hyperMovie] setCurrentTime:time];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveMovieObject alloc] initWithNode:self] autorelease];
}

- (NSSize)sizeOfMovieObjectWithController
{
    id <HSGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if ([self hyperHasController])
        return [geometry size];
    id adaptor = [self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)];
    NSSize size = [adaptor adaptResizingTo:[self sizeWithoutControllerForSizeWithController:[geometry size]] maintainAspectRatio:NO byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
    return [self sizeWithControllerForSizeWithoutController:size];
}

- (id)playSelfActionType
{
    return NSStringFromClass([HSPlayMovieAction class]);
}

- (id)hyperFieldOfViewMaxValue
{
    return [NSNumber numberWithFloat:[(HSMovie *)[self movie] maxFieldOfView]];
}

- (id)hyperFieldOfViewMinValue
{
    return [NSNumber numberWithFloat:[(HSMovie *)[self movie] minFieldOfView]];
}

- (CGFloat)hyperFieldOfView
{
    return [(HSMovieObjectData *)[self nodeData] fieldOfView];
}

// The movie may change the pan and tilt along with the field of view.
- (void)setHyperFieldOfView:(CGFloat)aView
{
    if (!HSMovieObjectFloatsDiffer([(HSMovieObjectData *)[self nodeData] fieldOfView], aView))
        return;
    [(HSMovie *)[self movie] setFieldOfView:aView];
    [(HSMovieObjectData *)[self nodeData] setFieldOfView:[(HSMovie *)[self movie] fieldOfView]];
    [(HSMovieObjectData *)[self nodeData] setPanAngle:[(HSMovie *)[self movie] panAngle]];
    [(HSMovieObjectData *)[self nodeData] setTiltAngle:[(HSMovie *)[self movie] tiltAngle]];
}

- (id)hyperPanAngleMaxValue
{
    return [NSNumber numberWithFloat:[(HSMovie *)[self movie] maxPanAngle]];
}

- (id)hyperPanAngleMinValue
{
    return [NSNumber numberWithFloat:[(HSMovie *)[self movie] minPanAngle]];
}

- (CGFloat)hyperPanAngle
{
    return [(HSMovieObjectData *)[self nodeData] panAngle];
}

- (void)setHyperPanAngle:(CGFloat)aAngle
{
    if (!HSMovieObjectFloatsDiffer([(HSMovieObjectData *)[self nodeData] panAngle], aAngle))
        return;
    [(HSMovie *)[self movie] setPanAngle:aAngle];
    [(HSMovieObjectData *)[self nodeData] setPanAngle:[(HSMovie *)[self movie] panAngle]];
}

- (id)hyperTiltAngleMaxValue
{
    return [NSNumber numberWithFloat:[(HSMovie *)[self movie] maxTiltAngle]];
}

- (id)hyperTiltAngleMinValue
{
    return [NSNumber numberWithFloat:[(HSMovie *)[self movie] minTiltAngle]];
}

- (CGFloat)hyperTiltAngle
{
    return [(HSMovieObjectData *)[self nodeData] tiltAngle];
}

- (void)setHyperTiltAngle:(CGFloat)aAngle
{
    if (!HSMovieObjectFloatsDiffer([(HSMovieObjectData *)[self nodeData] tiltAngle], aAngle))
        return;
    [(HSMovie *)[self movie] setTiltAngle:aAngle];
    [(HSMovieObjectData *)[self nodeData] setTiltAngle:[(HSMovie *)[self movie] tiltAngle]];
}

- (BOOL)isHyperPanoramaObject
{
    return [self movie] != nil && _isPanoramaObject;
}

- (BOOL)isHyperQTVR
{
    return [self movie] != nil && _isQTVRMovie;
}

- (void)notifyMovieNeedsRedraw
{
    [self notifyChange:2 ofAttribute:@protocol(HSMovieFrameContentAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSMovieControllerVisualStateAttribute) withUserInfo:nil];
}

- (void)movieDidPlayOnce:(id)aOnce
{
    _frameCount++;
    id starter = [self hyperStarter];
    if (starter != nil && [starter respondsToSelector:@selector(hyperPlayableObjectDidPlayOnce:frameCount:)])
        [starter hyperPlayableObjectDidPlayOnce:self frameCount:_frameCount];
    [super movieDidPlayOnce:aOnce];
}

// Hides the object at the end when it should be erased (in player mode).
- (void)movieDidEnd:(id)aEnd
{
    [_invalidationTimerForController invalidate];
    [_invalidationTimerForController release];
    _invalidationTimerForController = nil;
    [self notifyMovieNeedsRedraw];
    [self endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSMovieFrameContentAttribute), @protocol(HSMovieControllerVisualStateAttribute), nil]];
    [super movieDidEnd:aEnd];
    BOOL playerMode = [[self document] isInPlayerMode];
    if ([(HSMovieObjectData *)[self nodeData] eraseWhenDone] && playerMode)
        [self setHidden:YES];
}

- (void)movieDidChangeImage:(id)aImage
{
    _needUpdateController = NO;
    [self notifyMovieNeedsRedraw];
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
    return ![self isHyperQTVR];
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return ![self isHyperQTVR];
}

- (BOOL)canFlipHorizontally
{
    return ![self isHyperQTVR];
}

- (BOOL)canScaleVertically
{
    return NO;
}

- (BOOL)canScaleHorizontally
{
    return NO;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
}

// Sets the angle, brought into [0, 2pi), on every object sharing the node
// data.
- (void)setMovieRotationAngle:(CGFloat)aAngle
{
    id objects = [[[self nodeData] owner] objectsWithNodeDataUID:[[self nodeData] nodeDataUID]];
    float angle = HSMovieObjectNormalizedAngle(aAngle);
    for (id object in objects)
        [(HSMovieObjectData *)[object nodeData] setMovieRotationAngle:angle];
}

- (CGFloat)movieRotationAngle
{
    return [(HSMovieObjectData *)[self nodeData] movieRotationAngle];
}

- (void)setMovieFlippedVertical:(BOOL)aVertical
{
    [(HSMovieObjectData *)[self nodeData] setMovieFlippedVertical:aVertical];
}

- (BOOL)isMovieFlippedVertical
{
    return [(HSMovieObjectData *)[self nodeData] isMovieFlippedVertical];
}

- (void)setMovieFlippedHorizontal:(BOOL)aHorizontal
{
    [(HSMovieObjectData *)[self nodeData] setMovieFlippedHorizontal:aHorizontal];
}

- (BOOL)isMovieFlippedHorizontal
{
    return [(HSMovieObjectData *)[self nodeData] isMovieFlippedHorizontal];
}

- (void)hyperFlipVertical
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Flip Vertically" value:@"" table:@"UndoManager"]];
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] hyperFlipVertical];
    [self notifyChange:1 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
    [self setMovieFlippedVertical:![self isMovieFlippedVertical]];
    [self notifyChange:2 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
}

- (void)hyperFlipHorizontal
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Flip Horizontally" value:@"" table:@"UndoManager"]];
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] hyperFlipHorizontal];
    [self notifyChange:1 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
    [self setMovieFlippedHorizontal:![self isMovieFlippedHorizontal]];
    [self notifyChange:2 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
}

// After the media changed from none, sizes the object to the new movie.
- (void)resizeForNewMediaIfNeeded
{
    if (!_shouldResizeForNewMedia)
        return;
    HSMovie *movie = [self movie];
    if (movie == nil)
        return;
    id <HSMutableSizeAttributes> sizeAttributes = [self queryHyperInterface:@protocol(HSMutableSizeAttributes)];
    if (sizeAttributes != nil) {
        [sizeAttributes setSize:[movie size]];
        BOOL hasController = [self hasController];
        [self setMovieProportion:[self movieProportionForSize:[sizeAttributes size] hasController:hasController]];
    }
    _shouldResizeForNewMedia = NO;
}

- (id)hyperSizeMaxValue
{
    return [[HSValueConstraints sharedConstraints] constraintForKey:@"HSMovieObjectSizeMaxValue"];
}

- (NSSize)sizeWithControllerForSizeWithoutController:(NSSize)aController
{
    return [(HSMovieWithController *)[self movieWithController] sizeWithControllerForSizeWithoutController:aController];
}

- (NSSize)sizeWithoutControllerForSizeWithController:(NSSize)aController
{
    return [(HSMovieWithController *)[self movieWithController] sizeWithoutControllerForSizeWithController:aController];
}

- (void)updateMovieProportionIfNecessaryFromSize:(NSSize)aSize hasController:(BOOL)aController
{
    if (![[self queryHyperInterface:@protocol(HSResizingBehaviorAttributes)] prefersToMaintainSizeAspectRatio])
        [self setMovieProportion:[self movieProportionForSize:aSize hasController:aController]];
}

// Width over height, or 1 for an empty size.
- (CGFloat)movieProportionForSize:(NSSize)aSize hasController:(BOOL)aController
{
    // Original quirk kept: the size without the controller is worked out but
    // not used.
    if (aController)
        [self sizeWithoutControllerForSizeWithController:aSize];
    if (HSMovieObjectIsPositive(aSize.width) && HSMovieObjectIsPositive(aSize.height))
        return aSize.width / aSize.height;
    return 1.0;
}

- (void)setMovieProportion:(CGFloat)aProportion
{
    [(HSMovieObjectData *)[self nodeData] setMovieProportion:aProportion];
}

- (CGFloat)movieProportion
{
    return [(HSMovieObjectData *)[self nodeData] movieProportion];
}

- (NSSize)defaultSize
{
    if ([self isHyperEmpty])
        return NSMakeSize(320.0, 240.0);
    return [(HSMovie *)[self movie] originalSize];
}

- (void)changeCurrentMediaFrom:(id)aFrom to:(id)aTo error:(id *)aError
{
    [self destroyMovieWithController];
    [super changeCurrentMediaFrom:aFrom to:aTo error:aError];
}

- (void)setMedia:(id)aMedia
{
    [self setMedia:aMedia error:NULL];
}

- (void)setOpacity:(CGFloat)aOpacity
{
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:aOpacity];
}

- (CGFloat)opacity
{
    return [(HSConcreteCardObjectData *)[self nodeData] opacity];
}

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    if (!HSMovieObjectFloatsDiffer(aOpacity, [self opacity]))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:[self opacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    [self setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}

- (CGFloat)hyperOpacity
{
    return [self opacity];
}

- (BOOL)isHidden
{
    return [super isHidden] || [self isHyperEmpty];
}

- (BOOL)canBeHidden
{
    return ![self isHyperEmpty];
}

- (BOOL)canBeDraggable
{
    return YES;
}

- (BOOL)canBeResizable
{
    return YES;
}

- (BOOL)canBeRotatable
{
    return YES;
}

- (double)hyperFramesPerSecond
{
    if ([self movie] == nil)
        return 0.0;
    return (double)(int)[(HSMovie *)[self movie] framesPerSecond];
}

- (id)hyperCurrentFrameImage
{
    return [(HSMovie *)[self movie] currentFrameImage];
}

- (void)checkNewMovieToQTVRAndNotifyIfChanged
{
    BOOL isQTVR = [(HSMovie *)[self movie] isQTVRMovie];
    if (_isQTVRMovie == isQTVR)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSMovieObjectQTVRMovieAttributes) withUserInfo:nil];
    _isQTVRMovie = isQTVR;
    [self notifyChange:2 ofAttribute:@protocol(HSMovieObjectQTVRMovieAttributes) withUserInfo:nil];
}

- (void)checkNewMovieToPanoramaObjectAndNotifyIfChanged
{
    BOOL isPanorama = [(HSMovie *)[self movie] isPanoramaObject];
    if (_isPanoramaObject == isPanorama)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSMovieObjectQTVRMovieAttributes) withUserInfo:nil];
    _isPanoramaObject = isPanorama;
    [self notifyChange:2 ofAttribute:@protocol(HSMovieObjectQTVRMovieAttributes) withUserInfo:nil];
}

- (void)resetHyperFrameCount
{
    _frameCount = 0;
}

- (NSInteger)hyperFrameCount
{
    return _frameCount;
}

- (void)hyperAdjustRateWhilePlaying:(CGFloat)aPlaying
{
    if ([self isHyperPlaying] && aPlaying > 0.0)
        [(HSMovie *)[self movie] setRate:aPlaying];
}

- (void)setHyperEraseWhenDone:(BOOL)aDone
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Toggle Erase When Done" value:@"" table:@"UndoManager"]];
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperEraseWhenDone:[self hyperEraseWhenDone]];
    [self notifyChange:1 ofAttribute:@protocol(HSMovieObjectEraseWhenDoneAttribute) withUserInfo:nil];
    [self setEraseWhenDone:aDone];
    [self notifyChange:2 ofAttribute:@protocol(HSMovieObjectEraseWhenDoneAttribute) withUserInfo:nil];
}

- (BOOL)hyperEraseWhenDone
{
    return [self eraseWhenDone];
}

- (void)setEraseWhenDone:(BOOL)aDone
{
    [(HSMovieObjectData *)[self nodeData] setEraseWhenDone:aDone];
}

- (BOOL)eraseWhenDone
{
    return [(HSMovieObjectData *)[self nodeData] eraseWhenDone];
}

- (double)hyperPosterTime
{
    if ([self movie] == nil)
        return 0.0;
    return [(HSMovie *)[self movie] posterTime];
}

// Hiding the controller stops its redraw timer.
- (void)undoableSetHasController:(BOOL)aController useSuppliedSize:(BOOL)aSize size:(NSSize)aSize2
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Movie Controller Visibility" value:@"" table:@"UndoManager"]];
    // Original quirk kept: the undo flips the use-supplied-size flag, which
    // (like the size) isn't otherwise used.
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] undoableSetHasController:[self hasController] useSuppliedSize:!aSize size:aSize2];
    [self notifyChange:1 ofAttribute:@protocol(HSMovieObjectHasControllerAttribute) withUserInfo:nil];
    [self setHasController:aController];
    if (!aController) {
        [_invalidationTimerForController invalidate];
        [_invalidationTimerForController release];
        _invalidationTimerForController = nil;
    }
    [self notifyChange:2 ofAttribute:@protocol(HSMovieObjectHasControllerAttribute) withUserInfo:nil];
}

- (void)setHasController:(BOOL)aController
{
    [(HSMovieObjectData *)[self nodeData] setHasController:aController];
}

- (BOOL)hasController
{
    return [(HSMovieObjectData *)[self nodeData] hasController];
}

- (void)setHyperHasController:(BOOL)aController
{
    BOOL hasController = [self hasController];
    if ((!aController && hasController) || (aController && !hasController))
        [self undoableSetHasController:aController useSuppliedSize:NO size:[(id <HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size]];
}

- (BOOL)hyperHasController
{
    return [self hasController];
}

- (void)setCanUseMovieController:(BOOL)aController
{
    if ((aController != NO) == (_canUseMovieController != NO))
        return;
    [(HSMovieObject *)[[self undoManager] prepareWithInvocationTarget:self] setCanUseMovieController:_canUseMovieController];
    [self notifyChange:1 ofAttribute:@protocol(HSMovieObjectCanUseControllerAttribute) withUserInfo:nil];
    _canUseMovieController = aController;
    [self notifyChange:2 ofAttribute:@protocol(HSMovieObjectCanUseControllerAttribute) withUserInfo:nil];
}

// The controller is only drawn on an unflipped, unrotated object.
- (BOOL)checkCanUseMovieController
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    float angle = HSMovieObjectNormalizedAngle([geometry rotationAngle]);
    float degrees = ((6.2831855f - angle) / 3.1415927f) * 180.0f;
    float scale = MAX(HSMovieObjectToleranceScale(degrees), 360.0f);
    if (scale * -0.0005f + 360.0f <= degrees)
        degrees -= 360.0f;
    if ([geometry isFlippedVertically])
        return NO;
    return ![geometry isFlippedHorizontally] && fabsf(degrees) <= 0.01f;
}

- (BOOL)hyperCanUseController
{
    if ([self movie] == nil)
        return NO;
    return _canUseMovieController;
}

- (void)hyperStop
{
    [self endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSMovieFrameContentAttribute), @protocol(HSMovieControllerVisualStateAttribute), nil]];
    [_invalidationTimerForController invalidate];
    [_invalidationTimerForController release];
    _invalidationTimerForController = nil;
    [super hyperStop];
}

// Only a normal start (mode 0) starts the movie; with a controller, a timer
// keeps the controller redrawn.
- (void)hyperStart:(id)aStart atRate:(CGFloat)aRate startupMode:(NSInteger)aMode
{
    [self beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSMovieFrameContentAttribute), @protocol(HSMovieControllerVisualStateAttribute), nil]];
    [[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] addCurrentTime:[self hyperCurrentTime] forMovieObject:self];
    if (aMode == 0) {
        _frameCount = 0;
        [super hyperStart:aStart atRate:aRate startupMode:0];
    }
    if ([self hyperHasController]) {
        _needUpdateController = YES;
        // Fix: the original leaked (and left running) a timer from an earlier
        // start.
        [_invalidationTimerForController invalidate];
        [_invalidationTimerForController release];
        _invalidationTimerForController = [[NSThread hyperScheduledThreadTimerWithInterval:0.05 mainThreadTarget:self selector:@selector(HSMovieObject_invalidateMovie) repeats:YES] retain];
    } else
        _needUpdateController = NO;
}

- (BOOL)canUseMedia:(id)aMedia error:(id *)aError
{
    if (aMedia == nil)
        return NO;
    NSString *path = [aMedia fullPathToMediaFileCreateIfNeeded:YES];
    if (path == nil)
        return NO;
    return [HSMovie canInitAsVideoWithURL:[[[NSURL alloc] initFileURLWithPath:path] autorelease] error:aError];
}

- (void)applyAttributesToMovie
{
    [super applyAttributesToMovie];
    [self checkNewMovieToQTVRAndNotifyIfChanged];
    [self checkNewMovieToPanoramaObjectAndNotifyIfChanged];
    _canUseMovieController = [self checkCanUseMovieController];
}

- (void)readAttributesFromMovie
{
    [super readAttributesFromMovie];
    HSMovie *movie = [self movie];
    HSMovieObjectData *data = [self movieObjectNodeData];
    if (movie == nil || data == nil)
        return;
    [data setTiltAngle:[movie tiltAngle]];
    [data setPanAngle:[movie panAngle]];
    [data setFieldOfView:[movie fieldOfView]];
}

- (void)didConnectToSupport
{
    [super didConnectToSupport];
    [self resizeForNewMediaIfNeeded];
}

- (void)currentMediaDidChange
{
    [super currentMediaDidChange];
    [self resizeForNewMediaIfNeeded];
    [self notifyChange:2 ofAttribute:@protocol(HSMovieFrameContentAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSMovieControllerVisualStateAttribute) withUserInfo:nil];
}

// A movie put into an empty object resizes it.
- (void)currentMediaWillChange
{
    [super currentMediaWillChange];
    if ([[self nodeData] mediaUID] == nil)
        _shouldResizeForNewMedia = YES;
    [self notifyChange:1 ofAttribute:@protocol(HSMovieFrameContentAttribute) withUserInfo:nil];
    [self notifyChange:1 ofAttribute:@protocol(HSMovieControllerVisualStateAttribute) withUserInfo:nil];
}

- (void)geometryDidChanged:(id)aChanged
{
    [self setCanUseMovieController:[self checkCanUseMovieController]];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"hasController"];
    [keys addObject:@"eraseWhenDone"];
    [keys addObject:@"opacity"];
    [keys addObject:@"movieFlippedHorizontal"];
    [keys addObject:@"movieFlippedVertical"];
    [keys addObject:@"movieRotationAngle"];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        [keys addObject:@"movieProportion"];
    return keys;
}

- (id)queryMovieObjectHitTester
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
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSMovieObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface))
        return [[[HSHitTestingMovieObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSGeometryBehaviorAdapting), aInterface))
        return [[[HSMovieObjectGeometryBehaviorAdaptor alloc] initWithMovieObject:self] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSFramesPerSecondAttributes), aInterface))
        return [self isHyperQTVR] ? nil : self;
    return [super queryNewHyperInterface:aInterface];
}

- (NSUInteger)hash
{
    return (NSUInteger)[HSMovieObject class];
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]] && ![self isKindOfClass:[aEqual class]])
        return NO;
    if (![[self hyperUID] isEqual:[aEqual hyperUID]])
        return NO;
    return [self isHyperEqual:aEqual];
}

- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]] || ![super isHyperEqual:aEqual])
        return NO;
    if ([self hyperCanUseController] != [aEqual hyperCanUseController]
        || [self hyperHasController] != [aEqual hyperHasController]
        || [self hyperEraseWhenDone] != [aEqual hyperEraseWhenDone]
        || [self isHyperQTVR] != [aEqual isHyperQTVR])
        return NO;
    if (HSMovieObjectFloatsDiffer([self hyperTiltAngle], [aEqual hyperTiltAngle])
        || HSMovieObjectFloatsDiffer([self hyperPanAngle], [aEqual hyperPanAngle])
        || HSMovieObjectFloatsDiffer([self hyperFieldOfView], [aEqual hyperFieldOfView])
        || HSMovieObjectFloatsDiffer([self hyperVolume], [aEqual hyperVolume]))
        return NO;
    if (!HSMovieObjectDoublesAreEqual([self hyperDuration], [aEqual hyperDuration])
        || !HSMovieObjectDoublesAreEqual([self hyperStartTime], [aEqual hyperStartTime])
        || !HSEqualTimeRanges([self hyperPlayRange], [aEqual hyperPlayRange])
        || [self isHyperPlaying] != [aEqual isHyperPlaying])
        return NO;
    return [[[[self movieObjectNodeData] media] mediaUID] isEqual:[[[aEqual movieObjectNodeData] media] mediaUID]];
}

- (void)dealloc
{
    id attributes[] = {@protocol(HSHorizontalFlipAttribute), @protocol(HSVerticalFlipAttribute), @protocol(HSRotationAngleAttribute), nil};
    [super removeObserver:self selector:@selector(geometryDidChanged:) ofChanges:HSActualDidAttributeChanges ofAttributes:attributes];
    [_movieWithController setDelegate:nil];
    [_movieWithController release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    id sizeUnit = [super unitForRole:@"Size Unit"];
    if ([sizeUnit isKindOfClass:[HSSizeNodeUnit class]]) {
        BOOL hasController = [self hasController];
        [self setMovieProportion:[self movieProportionForSize:[(HSSizeNodeUnit *)sizeUnit size] hasController:hasController]];
    }
    [super linkAttribute:@protocol(HSMovieRectAttribute) toAttribute:@protocol(HSSizeAttribute)];
    [super linkAttribute:@protocol(HSMovieControllerRectAttribute) toAttribute:@protocol(HSSizeAttribute)];
    id attributes[] = {@protocol(HSHorizontalFlipAttribute), @protocol(HSVerticalFlipAttribute), @protocol(HSRotationAngleAttribute), nil};
    [super addObserver:self selector:@selector(geometryDidChanged:) ofChanges:HSActualDidAttributeChanges ofAttributes:attributes withPriority:0.75];
    return self;
}

- (id)movieObjectNodeData
{
    return [super nodeData];
}

@end
