#import "HSWebObject.h"

@implementation HSWebObject
+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSSizeNodeUnit", @"Size Unit", @"HSGeometryNodeUnit", @"Geometry Unit", @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit", @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit", @"HSShowHideTransitionNodeUnit", @"Transition Unit", @"HSWebElementNodeUnit", @"Web Element Unit", nil];
}
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
}
- (id)HTML5UnsupportedFunctionalityDescription
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureWebObject" value:@"" table:@"Export"];
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
    return NSMakeSize(320, 240);
}
- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveWebObject alloc] initWithNode:self] autorelease];
}
// Live web views for the card and player, previews for the editor and the
// object list palette.
- (id)queryNewHyperInterface:(id)aInterface
{
    Class visualizationClass;
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface))
        visualizationClass = [HSWebObjectVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        visualizationClass = [HSWebObjectPreviewVisualization class];
    else
        return [super queryNewHyperInterface:aInterface];
    return [[[visualizationClass alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return NO;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id representation = [super HTML5DictionaryRepresentationInContext:aContext];
    id attributes = [self queryHyperInterface:@protocol(HSWebElementAttributes)];
    [representation setObject:@"webObject" forKey:@"type"];
    [representation setObject:[attributes HTMLCode] forKey:@"htmlCode"];
    [representation setObject:[NSString stringWithFormat:@"%.2f", [attributes refreshRate]] forKey:@"refreshRate"];
    return representation;
}

@end
