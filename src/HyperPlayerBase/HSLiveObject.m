#import "HSLiveObject.h"
#import "HSExecutableResourceProvider.h"
#import "HSFunctions.h"
#import "HSInteractiveLiveObject.h"
#import "HSLiveObjectData.h"
#import "HSLiveVideoObjectVisualization.h"
#import "HSLiveVideoStreamAttributesImplementation.h"
#import "HSPlayMovieAction.h"
#import "HSSystem.h"

// Relative comparison: values within 0.05% of the larger magnitude (zero
// counting as 1) are equal.
static BOOL HSOpacityValuesDiffer(float a, float b)
{
    float magnitudeA = a != 0.0f ? fabsf(a) : 1.0f;
    float magnitudeB = b != 0.0f ? fabsf(b) : 1.0f;
    float magnitude = magnitudeB <= magnitudeA ? magnitudeA : magnitudeB;
    return magnitude * 0.0005f < fabsf(a - b);
}

// A live camera view. Playing only marks the object as started; the video
// itself comes from the live video stream attributes implementation, which
// needs capture support (without it the object answers the stream protocols
// itself: never playing, no frames).
@implementation HSLiveObject

+ (Class)nodeDataClass
{
    return [HSLiveObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        @"HSSizeNodeUnit", @"Size Unit",
        @"HSGeometryNodeUnit", @"Geometry Unit",
        @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
        @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
        @"HSShowHideTransitionNodeUnit", @"Transition Unit",
        nil];
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureLiveVideo" value:@"" table:@"Export"];
}

- (id)XMLElementName
{
    return @"objLiveVideo";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (void)hyperStepForward
{
}

- (void)hyperStepBack
{
}

- (void)setHyperCurrentTime:(double)aTime
{
}

- (double)hyperCurrentTime
{
    return 0.0;
}

- (void)hyperStop
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayableObjectWillStopNotification" object:self];
    [self notifyChange:4 ofAttribute:@protocol(HSPlayingVideoStateAttribute) withUserInfo:nil];
    id starter = _starter;
    _starter = nil;
    if ([starter respondsToSelector:@selector(hyperPlayableObjectDidStop:)])
        [starter hyperPlayableObjectDidStop:self];
    [starter release];
    [self notifyChange:8 ofAttribute:@protocol(HSPlayingVideoStateAttribute) withUserInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayableObjectDidStopNotification" object:self];
}

- (void)hyperStart:(id)aStart
{
    if (_starter == aStart)
        return;
    [self notifyChange:4 ofAttribute:@protocol(HSPlayingVideoStateAttribute) withUserInfo:nil];
    [_starter release];
    _starter = [aStart retain];
    [self notifyChange:8 ofAttribute:@protocol(HSPlayingVideoStateAttribute) withUserInfo:nil];
}

- (id)hyperStarter
{
    return _starter;
}

- (BOOL)isHyperPlaying
{
    return _starter != nil;
}

- (id)playSelfActionType
{
    return NSStringFromClass([HSPlayMovieAction class]);
}

- (void)setHyperPlayRange:(struct HSTimeRange)aRange
{
}

- (struct HSTimeRange)hyperPlayRange
{
    struct HSTimeRange range;
    range.location = 0.0;
    range.length = [self hyperDuration];
    return range;
}

- (void)setHyperStartTime:(double)aTime
{
}

- (double)hyperStartTime
{
    return 0.0;
}

- (double)hyperDuration
{
    return 0.0;
}

- (id)hyperPlayableObjectName
{
    return [[self queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
}

- (id)hyperPlayableObjectUID
{
    return [self hyperUID];
}

- (void)setHyperDeviceIndex:(NSUInteger)aIndex
{
    if ([(HSLiveObjectData *)[self nodeData] deviceIndex] == aIndex)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Camera Index" value:@"" table:@"UndoManager"]];
    [(HSLiveObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperDeviceIndex:[(HSLiveObjectData *)[self nodeData] deviceIndex]];
    [self notifyChange:1 ofAttribute:@protocol(HSLiveObjectDeviceIndexAttribute) withUserInfo:nil];
    [self setDeviceIndex:aIndex];
    [self notifyChange:2 ofAttribute:@protocol(HSLiveObjectDeviceIndexAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperDeviceIndex
{
    return [self deviceIndex];
}

- (void)setDeviceIndex:(NSUInteger)aIndex
{
    [(HSLiveObjectData *)[self nodeData] setDeviceIndex:aIndex];
}

- (NSUInteger)deviceIndex
{
    return [(HSLiveObjectData *)[self nodeData] deviceIndex];
}

- (id)liveVideoDevice
{
    return nil;
}

- (id)videoFrameForVideoFrameProcessorClass:(Class)aClass
{
    return nil;
}

- (void)removeVideoFrameProcessorClass:(Class)aClass
{
}

- (void)addVideoFrameProcessorClass:(Class)aClass
{
}

- (BOOL)isPlayingVideo
{
    return [self isHyperPlaying];
}

- (NSRect)videoRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    return [geometry boundingRect];
}

- (NSSize)defaultSize
{
    return NSMakeSize(320.0, 240.0);
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

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    float opacity = [(HSLiveObjectData *)[self nodeData] opacity];
    if (!HSOpacityValuesDiffer(opacity, aOpacity))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
    [(HSLiveObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:(float)[(HSLiveObjectData *)[self nodeData] opacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    [(HSLiveObjectData *)[self nodeData] setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}

- (CGFloat)hyperOpacity
{
    return (float)[(HSLiveObjectData *)[self nodeData] opacity];
}

- (void)setOpacity:(CGFloat)aOpacity
{
    [(HSLiveObjectData *)[self nodeData] setOpacity:aOpacity];
}

- (CGFloat)opacity
{
    return (float)[(HSLiveObjectData *)[self nodeData] opacity];
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

- (id)queryCameraObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveLiveObject alloc] initWithNode:self] autorelease];
}

- (void)willDisconnectFromDocument
{
    if ([self isHyperPlaying])
        [self hyperStop];
    [super willDisconnectFromDocument];
}

// The stream protocols decoded from the disassembly: without capture
// support the object itself is returned.
- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSLiveVideoObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSVideoStreamAttributes))
        || HSProtocolsAreEqual(aInterface, @protocol(HSLiveVideoAttributes))) {
        if (![[HSSystem sharedSystem] isQTKitCapturingAvailable])
            return self;
        return [[[HSLiveVideoStreamAttributesImplementation alloc] initWithLiveVideoObject:self] autorelease];
    }
    return [super queryNewHyperInterface:aInterface];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"opacity"];
    [keys addObject:@"deviceIndex"];
    return keys;
}

- (void)dealloc
{
    // fixed: the original leaked a starter still set here
    [_starter release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        [self linkAttribute:@protocol(HSVideoRectAttribute) toAttribute:@protocol(HSSizeAttribute)];
    return self;
}

@end
