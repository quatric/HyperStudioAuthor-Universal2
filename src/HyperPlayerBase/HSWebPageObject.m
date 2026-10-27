#import "HSWebPageObject.h"
#import "HSCard.h"
#import "HSFunctions.h"
#import "HSProtocolIdentifier.h"
#import "HSWebPageAttributesImplementation.h"
#import "HSWebPageObjectData.h"
#import "HSWebPageObjectVisualization.h"

// The relative tolerance the original uses for its float attributes.
static BOOL HSWebPageFloatsDiffer(float aValue, float aValue2)
{
    float magnitude = aValue != 0.0f ? fabsf(aValue) : 1.0f;
    float magnitude2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    if (magnitude2 <= magnitude)
        magnitude2 = magnitude;
    return magnitude2 * 0.0005f < fabsf(aValue - aValue2);
}

// A card object showing a web page (or a web camera image), optionally
// cropped to a path. The page itself is loaded by the card, which keeps a
// registry of its web page objects.
@implementation HSWebPageObject

+ (Class)nodeDataClass
{
    return [HSWebPageObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSSizeNodeUnit", @"Size Unit", @"HSGeometryNodeUnit", @"Geometry Unit", @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit", @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit", @"HSShowHideTransitionNodeUnit", @"Transition Unit", nil];
}

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    if (!HSWebPageFloatsDiffer((float)[self opacity], (float)aOpacity))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:(float)[self opacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    [self setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}

- (CGFloat)hyperOpacity
{
    return (float)[self opacity];
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
    return YES;
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
    return YES;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
}

- (NSSize)defaultSize
{
    return [self HSWebPageObject_size];
}

// The crop path's bounds when cropped, else the page size.
- (NSSize)HSWebPageObject_size
{
    HSWebPageObjectData *data = [self nodeData];
    NSBezierPath *cropPath = [data pageCropPath];
    if (cropPath == nil)
        return [data pageSize];
    return [cropPath bounds].size;
}

- (id)queryWebObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSWebPageAttributes), aInterface))
        return [[[HSWebPageAttributesImplementation alloc] initWithWebPageObject:self] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSWebPageObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (void)setWebPageImage:(id)aImage
{
    [[self nodeData] setWebPageImage:aImage];
}

- (id)webPageImage
{
    return [[self nodeData] webPageImage];
}

- (void)setOpacity:(CGFloat)aOpacity
{
    [(HSWebPageObjectData *)[self nodeData] setOpacity:aOpacity];
}

- (CGFloat)opacity
{
    return (float)[(HSWebPageObjectData *)[self nodeData] opacity];
}

- (void)setPageCopyright:(id)aCopyright
{
    if ([[self nodeData] pageCopyright] == aCopyright)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Camera Copyright" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageCopyright:[[self nodeData] pageCopyright]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageCopyrightAttribute) withUserInfo:nil];
    [[self nodeData] setPageCopyright:[[aCopyright copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageCopyrightAttribute) withUserInfo:nil];
}

- (id)pageCopyright
{
    return [[self nodeData] pageCopyright];
}

- (void)setPageTimeZone:(id)aZone
{
    if ([[self nodeData] pageTimeZone] == aZone)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Camera Time Zone" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageTimeZone:[[self nodeData] pageTimeZone]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageTimeZoneAttribute) withUserInfo:nil];
    [[self nodeData] setPageTimeZone:[[aZone copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageTimeZoneAttribute) withUserInfo:nil];
}

- (id)pageTimeZone
{
    return [[self nodeData] pageTimeZone];
}

- (void)setPageLocation:(id)aLocation
{
    if ([[self nodeData] pageLocation] == aLocation)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Camera Location" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageLocation:[[self nodeData] pageLocation]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageLocationAttribute) withUserInfo:nil];
    [[self nodeData] setPageLocation:[[aLocation copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageLocationAttribute) withUserInfo:nil];
}

- (id)pageLocation
{
    return [[self nodeData] pageLocation];
}

- (void)setPageCameraID:(id)aID
{
    if ([[self nodeData] pageCameraID] == aID)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Camera Identifier" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageCameraID:[[self nodeData] pageCameraID]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageCameraIDAttribute) withUserInfo:nil];
    [[self nodeData] setPageCameraID:[[aID copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageCameraIDAttribute) withUserInfo:nil];
}

- (id)pageCameraID
{
    return [[self nodeData] pageCameraID];
}

- (void)setPageRefreshRate:(CGFloat)aRate
{
    HSWebPageObjectData *data = [self nodeData];
    if (!HSWebPageFloatsDiffer((float)[data pageRefreshRate], (float)aRate))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Refresh Rate" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageRefreshRate:(float)[[self nodeData] pageRefreshRate]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageRefreshRateAttribute) withUserInfo:nil];
    [[self nodeData] setPageRefreshRate:aRate];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageRefreshRateAttribute) withUserInfo:nil];
}

- (CGFloat)pageRefreshRate
{
    return (float)[[self nodeData] pageRefreshRate];
}

- (void)setPageTitle:(id)aTitle
{
    if ([[self nodeData] pageTitle] == aTitle)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Title" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageTitle:[[self nodeData] pageTitle]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageTitleAttribute) withUserInfo:nil];
    [[self nodeData] setPageTitle:[[aTitle copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageTitleAttribute) withUserInfo:nil];
}

- (id)pageTitle
{
    return [[[[self nodeData] pageTitle] copy] autorelease];
}

- (void)setPageCropPath:(id)aPath
{
    if ([[self nodeData] pageCropPath] == aPath)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Crop" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageCropPath:[[self nodeData] pageCropPath]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageCropPathAttribute) withUserInfo:nil];
    [[self nodeData] setPageCropPath:[[aPath copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageCropPathAttribute) withUserInfo:nil];
}

- (id)pageCropPath
{
    return [[[[self nodeData] pageCropPath] copy] autorelease];
}

- (void)setPageSizeAsString:(id)aString
{
    [[self nodeData] setPageSizeAsString:aString];
}

- (id)pageSizeAsString
{
    return [[self nodeData] pageSizeAsString];
}

// Without a crop path the page size is also the visible area, so the crop
// path attribute changes with it.
- (void)setPageSize:(NSSize)aSize
{
    NSSize size = [[self nodeData] pageSize];
    if (!HSWebPageFloatsDiffer((float)size.width, (float)aSize.width) && !HSWebPageFloatsDiffer((float)size.height, (float)aSize.height))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page Size" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageSize:[[self nodeData] pageSize]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageSizeAttribute) withUserInfo:nil];
    if ([[self nodeData] pageCropPath] == nil)
        [self notifyChange:1 ofAttribute:@protocol(HSWebPageCropPathAttribute) withUserInfo:nil];
    [[self nodeData] setPageSize:aSize];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageSizeAttribute) withUserInfo:nil];
    if ([[self nodeData] pageCropPath] == nil)
        [self notifyChange:2 ofAttribute:@protocol(HSWebPageCropPathAttribute) withUserInfo:nil];
}

- (NSSize)pageSize
{
    return [[self nodeData] pageSize];
}

- (void)setPageURL:(id)aURL
{
    id url = [[self nodeData] pageURL];
    if (url == aURL || (aURL != nil && [url isEqual:aURL]))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Page URL" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPageURL:[[self nodeData] pageURL]];
    [self notifyChange:1 ofAttribute:@protocol(HSWebPageURLAttribute) withUserInfo:nil];
    [[self nodeData] setPageURL:[[aURL copy] autorelease]];
    [self notifyChange:2 ofAttribute:@protocol(HSWebPageURLAttribute) withUserInfo:nil];
}

- (id)pageURL
{
    return [[self nodeData] pageURL];
}

// Web page objects can't be created from the old extra dictionary format.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    // fixed: the original returned nil without releasing the receiver.
    [self release];
    return nil;
}

- (id)attributeToNotificationMapForCodingOperation:(id)aOperation
{
    NSDictionary *map = [super attributeToNotificationMapForCodingOperation:aOperation];
    if (![aOperation isEqualToString:EXDefaultCodingOperation])
        return map;
    NSMutableDictionary *mutableMap = [NSMutableDictionary dictionaryWithDictionary:map];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageURLAttribute)] forKey:@"pageURL"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageSizeAttribute)] forKey:@"pageSizeAsString"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageCropPathAttribute)] forKey:@"pageCropPath"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSOpacityAttribute)] forKey:@"opacity"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageTitleAttribute)] forKey:@"pageTitle"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageRefreshRateAttribute)] forKey:@"pageRefreshRate"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageCameraIDAttribute)] forKey:@"pageCameraID"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageLocationAttribute)] forKey:@"pageLocation"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageTimeZoneAttribute)] forKey:@"pageTimeZone"];
    [mutableMap setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebPageCopyrightAttribute)] forKey:@"pageCopyright"];
    return mutableMap;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"pageURL"];
    [keys addObject:@"pageSizeAsString"];
    [keys addObject:@"pageCropPath"];
    [keys addObject:@"opacity"];
    [keys addObject:@"pageTitle"];
    [keys addObject:@"pageRefreshRate"];
    [keys addObject:@"pageCameraID"];
    [keys addObject:@"pageLocation"];
    [keys addObject:@"pageTimeZone"];
    [keys addObject:@"pageCopyright"];
    return keys;
}

- (void)willDisconnectFromParent
{
    [[[self card] queryHyperInterface:@protocol(HSWebPageObjectRegistry)] removeWebPageObject:self];
    [super willDisconnectFromParent];
}

- (void)didConnectToParent
{
    [super didConnectToParent];
    [[[self card] queryHyperInterface:@protocol(HSWebPageObjectRegistry)] addWebPageObject:self];
}

- (id)init
{
    self = [super init];
    [self linkAttribute:@protocol(HSWebPageContentAttribute) toAttribute:@protocol(HSWebPageURLAttribute)];
    [self linkAttribute:@protocol(HSWebPageContentAttribute) toAttribute:@protocol(HSWebPageSizeAttribute)];
    [self linkAttribute:@protocol(HSSizeAttribute) toAttribute:@protocol(HSWebPageCropPathAttribute)];
    [self linkAttribute:@protocol(HSWebPageImageAttribute) toAttribute:@protocol(HSWebPageURLAttribute)];
    return self;
}

@end

// The card's web page objects load while the card is shown.
@implementation HSCard (HSWebPageObjectsRegistry)

- (void)stopLoadingWebPageObjects
{
    NSEnumerator *enumerator = [_webPageObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [[object queryHyperInterface:@protocol(HSWebPageAttributes)] stopLoading];
}

- (void)startLoadingWebPageObjects
{
    NSEnumerator *enumerator = [_webPageObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [[object queryHyperInterface:@protocol(HSWebPageAttributes)] startLoading];
}

- (void)removeWebPageObject:(id)aObject
{
    [_webPageObjects removeObject:aObject];
}

- (void)addWebPageObject:(id)aObject
{
    if (_webPageObjects == nil)
        _webPageObjects = [NSMutableArray new];
    [_webPageObjects addObject:aObject];
}

@end
