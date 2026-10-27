#import "HSYouTubeObject.h"
#import "HSExecutableResourceProvider.h"
#import "HSHTML5ExporterHelper.h"
#import "HSInteractiveYouTubeObject.h"
#import "HSMediaFileWrapper.h"
#import "HSFunctions.h"
#import "HSYouTubeObjectData.h"
#import "HSYouTubeObjectVisualization.h"
#import "HSYouTubeRenderer.h"

// A card object playing a YouTube video. The renderer is created lazily from
// the movie ID and keeps a still image of the video for drawing.
@implementation HSYouTubeObject

+ (Class)nodeDataClass
{
    return [HSYouTubeObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSSizeNodeUnit", @"Size Unit", @"HSGeometryNodeUnit", @"Geometry Unit", @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit", @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit", @"HSShowHideTransitionNodeUnit", @"Transition Unit", nil];
}

// The video is exported with its still image as poster frame, positioned at
// the object's transformed origin.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *representation = [super HTML5DictionaryRepresentationInContext:aContext];
    NSURL *watchURL = [self youTubeMovieWatchURL];
    if (watchURL == nil)
        return representation;
    id media = [HSNewMedia mediaWithImage:[self youTubeMovieImage] name:[self youTubeMovieTitle]];
    if (media == nil)
        return representation;
    NSString *fileName = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media];
    if ([fileName length] == 0)
        return representation;
    NSString *path = [@"Resources" stringByAppendingPathComponent:fileName];
    if ([path length] == 0)
        return representation;
    [aContext addMedia:media];
    [representation setObject:[watchURL absoluteString] forKey:@"url"];
    [representation setObject:path forKey:@"posterFrame"];
    [representation setObject:@"youtube" forKey:@"type"];
    id<HSGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    CGAffineTransform transform = [geometry affineTransform];
    float width = (float)[geometry width];
    float horizontalScale = (float)[geometry horizontalScale];
    float height = (float)[geometry height];
    float verticalScale = (float)[geometry verticalScale];
    NSPoint origin = NSZeroPoint;
    [representation setObject:[NSString stringWithFormat:@"%.1f", (double)(float)(transform.a * origin.x + transform.c * origin.y + transform.tx)] forKey:@"xCoord"];
    [representation setObject:[NSString stringWithFormat:@"%.1f", (double)(float)(transform.b * origin.x + transform.d * origin.y + transform.ty)] forKey:@"yCoord"];
    [representation setObject:[NSString stringWithFormat:@"%.1f", (double)(width * horizontalScale)] forKey:@"xSize"];
    [representation setObject:[NSString stringWithFormat:@"%.1f", (double)(height * verticalScale)] forKey:@"ySize"];
    return representation;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return [super hasUnsupportedHTML5FeaturesForDocumentType:aType];
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureYouTube" value:@"" table:@"Export"];
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (void)newImageAvailableInRenderer:(id)aRenderer
{
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeFrameContentAttribute) withUserInfo:nil];
    [self setYouTubeMovieImage:[_youTubeRenderer updateYouTubeImage]];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeFrameContentAttribute) withUserInfo:nil];
}

- (void)stopObservingFromRenderer:(id)aRenderer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSYouTubeRendererDidUpdateFrameImageNotification" object:aRenderer];
}

- (void)startObservingFromRenderer:(id)aRenderer
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageAvailableInRenderer:) name:@"HSYouTubeRendererDidUpdateFrameImageNotification" object:aRenderer];
}

- (void)destroyRenderer
{
    if (_youTubeRenderer == nil)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeFrameContentAttribute) withUserInfo:nil];
    [self stopObservingFromRenderer:_youTubeRenderer];
    [_youTubeRenderer release];
    _youTubeRenderer = nil;
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeFrameContentAttribute) withUserInfo:nil];
}

- (void)setYouTubeMovieImage:(id)aImage
{
    [[self nodeData] setYouTubeMovieImage:aImage];
}

- (id)youTubeMovieImage
{
    return [[self nodeData] youTubeMovieImage];
}

- (void)setYouTubeMovieSizeAsString:(id)aString
{
    [self setYouTubeMovieSize:NSSizeFromString(aString)];
}

- (id)youTubeMovieSizeAsString
{
    return NSStringFromSize([self youTubeMovieSize]);
}

- (void)setYouTubeMovieSize:(NSSize)aSize
{
    if (NSEqualSizes([[self nodeData] youTubeMovieSize], aSize))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Size" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieSize:[[self nodeData] youTubeMovieSize]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieSizeAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieSize:aSize];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieSizeAttribute) withUserInfo:nil];
}

- (NSSize)youTubeMovieSize
{
    return [[self nodeData] youTubeMovieSize];
}

- (void)setYouTubeMovieDuration:(double)aDuration
{
    if ([[self nodeData] youTubeMovieDuration] == aDuration)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Duration" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieDuration:[[self nodeData] youTubeMovieDuration]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieDurationAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieDuration:aDuration];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieDurationAttribute) withUserInfo:nil];
}

- (double)youTubeMovieDuration
{
    return [[self nodeData] youTubeMovieDuration];
}

// The author URL shares the author attribute.
- (void)setYouTubeMovieAuthorURL:(id)aURL
{
    if ([[self nodeData] youTubeMovieAuthorURL] == aURL)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Author URL" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieAuthorURL:[[self nodeData] youTubeMovieAuthorURL]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieAuthorAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieAuthorURL:[[aURL copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieAuthorAttribute) withUserInfo:nil];
}

- (id)youTubeMovieAuthorURL
{
    return [[self nodeData] youTubeMovieAuthorURL];
}

- (void)setYouTubeMovieAuthor:(id)aAuthor
{
    if ([[self nodeData] youTubeMovieAuthor] == aAuthor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Author" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieAuthor:[[self nodeData] youTubeMovieAuthor]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieAuthorAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieAuthor:[[aAuthor copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieAuthorAttribute) withUserInfo:nil];
}

- (id)youTubeMovieAuthor
{
    return [[self nodeData] youTubeMovieAuthor];
}

// The title is the base of the object's default name.
- (void)setYouTubeMovieTitle:(id)aTitle
{
    if ([[self nodeData] youTubeMovieTitle] == aTitle)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Name" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieTitle:[[self nodeData] youTubeMovieTitle]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieTitleAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieTitle:[[aTitle copy] autorelease]];
    [self userObjectNameBaseTemplateDidChange];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieTitleAttribute) withUserInfo:nil];
}

- (id)youTubeMovieTitle
{
    return [[self nodeData] youTubeMovieTitle];
}

// The watch URL shares the movie URL attribute.
- (void)setYouTubeMovieWatchURL:(id)aURL
{
    if ([[self nodeData] youTubeMovieWatchURL] == aURL)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Player URL" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieWatchURL:[[self nodeData] youTubeMovieWatchURL]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieURLAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieWatchURL:[[aURL copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieURLAttribute) withUserInfo:nil];
}

- (id)youTubeMovieWatchURL
{
    return [[self nodeData] youTubeMovieWatchURL];
}

- (void)setYouTubeMovieURL:(id)aURL
{
    if ([[self nodeData] youTubeMovieURL] == aURL)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video URL" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setYouTubeMovieURL:[[self nodeData] youTubeMovieURL]];
    [self notifyChange:1 ofAttribute:@protocol(HSYouTubeMovieURLAttribute) withUserInfo:nil];
    [[self nodeData] setYouTubeMovieURL:aURL];
    [self notifyChange:2 ofAttribute:@protocol(HSYouTubeMovieURLAttribute) withUserInfo:nil];
}

- (id)youTubeMovieURL
{
    return [[self nodeData] youTubeMovieURL];
}

// A new movie needs a new renderer; the ID change also changes the URL.
- (void)setYouTubeMovieID:(id)aID
{
    if ([[self nodeData] youTubeMovieID] == aID)
        return;
    [self destroyRenderer];
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video Identifier" value:@"" table:@"UndoManager"]];
        [[undoManager prepareWithInvocationTarget:self] setYouTubeMovieID:[[self nodeData] youTubeMovieID]];
    }
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSYouTubeMovieIDAttribute), @protocol(HSYouTubeMovieURLAttribute), nil];
    if (attributes == nil) {
        [[self nodeData] setYouTubeMovieID:aID];
        return;
    }
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [[self nodeData] setYouTubeMovieID:aID];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (id)youTubeMovieID
{
    return [[self nodeData] youTubeMovieID];
}

// Without a movie size the renderer uses YouTube's default 425x355 player.
- (id)youTubeRenderer
{
    if (_youTubeRenderer != nil)
        return _youTubeRenderer;
    NSSize size = [[self nodeData] youTubeMovieSize];
    if ((float)size.width <= 0.0f || (float)size.height <= 0.0f)
        size = NSMakeSize(425.0, 355.0);
    id movieID = [self youTubeMovieID];
    if (movieID == nil)
        return nil;
    NSString *string = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", movieID];
    if (string == nil)
        return nil;
    NSURL *url = [[NSURL alloc] initWithString:string];
    if (url == nil)
        return nil;
    _youTubeRenderer = [[HSYouTubeRenderer alloc] initWithURL:url movieSize:size];
    // fixed: the original leaked the URL.
    [url release];
    if (_youTubeRenderer != nil) {
        [_youTubeRenderer setYouTubeImage:[self youTubeMovieImage]];
        [self startObservingFromRenderer:_youTubeRenderer];
    }
    return _youTubeRenderer;
}

- (NSRect)youTubeRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    return [geometry boundingRect];
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
    return NO;
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return NO;
}

- (BOOL)canFlipHorizontally
{
    return NO;
}

- (BOOL)canScaleVertically
{
    return YES;
}

- (BOOL)canScaleHorizontally
{
    return YES;
}

- (BOOL)prefersResizingToScaling
{
    return NO;
}

- (BOOL)canResizeVertically
{
    return NO;
}

- (BOOL)canResizeHorizontally
{
    return NO;
}

- (BOOL)canBreakSizeAspectRatio
{
    return NO;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}

- (NSSize)defaultSize
{
    NSSize size = [[self nodeData] youTubeMovieSize];
    if (NSEqualSizes(size, NSZeroSize))
        return NSMakeSize(425.0, 355.0);
    return size;
}

- (BOOL)canBeDraggable
{
    return NO;
}

- (BOOL)canBeResizable
{
    return NO;
}

- (BOOL)canBeRotatable
{
    return NO;
}

- (void)reattachRenderer
{
    [[self youTubeRenderer] reattach];
}

- (void)detachRenderer
{
    [[self youTubeRenderer] detach];
}

- (id)youTubeInteractiveView
{
    return [[self youTubeRenderer] interactiveView];
}

- (id)nameBaseTemplates
{
    NSString *title = [self youTubeMovieTitle];
    if ([title length] == 0)
        return [NSArray array];
    return [NSArray arrayWithObject:title];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveYouTubeObject alloc] initWithNode:self] autorelease];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSYouTubeObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (void)dealloc
{
    [self stopObservingFromRenderer:_youTubeRenderer];
    [_youTubeRenderer release];
    [super dealloc];
}

@end
