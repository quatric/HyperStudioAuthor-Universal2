#import "HSBitmapBrushToolWrapper.h"

@implementation HSBitmapBrushToolWrapper

+ (Class)settingsSerializationClass
{
    return [BTBrushToolSettingsSerialization class];
}

// Solid RGB colors are copied back to the shared tool settings.
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    BOOL alternate = [aKey isEqualToString:@"alternateColor"];
    if (alternate || [aKey isEqualToString:@"color"]) {
        CGEColorRef color = [[aTool valueForOutputKey:aKey] pointer];
        if (CGEColorIsSolid(color)) {
            CGColorRef cgColor = CGEColorGetCGColor(color);
            CGColorSpaceRef rgb = cgColor != NULL ? CGColorSpaceCreateDeviceRGB() : NULL;
            if (rgb != NULL) {
                if (CGColorGetNumberOfComponents(cgColor) == 4 && CFEqual(CGColorGetColorSpace(cgColor), rgb)) {
                    NSColor *nsColor = [NSColor colorWithColorSpace:[NSColorSpace deviceRGBColorSpace] components:CGColorGetComponents(cgColor) count:4];
                    if (nsColor != nil) {
                        id settings = [[HSToolManager sharedToolManager] toolSettings];
                        if (alternate)
                            [settings setEraserColor:nsColor];
                        else
                            [settings setDrawColor:nsColor];
                    }
                }
                CGColorSpaceRelease(rgb);
            }
        }
    }
    [super tool:aTool didUpdateOutputForKey:aKey];
}

- (id)settingsIdentifiers
{
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolEraserColorAttributeKey, HSToolSizeRatioAttributeKey, kToolPaddingKey, HSToolCursorContourAttributeKey, nil]];
}

- (id)bitmapTool
{
    return [super bitmapTool];
}

- (void)dealloc
{
    [_touchStorage setDelegate:nil];
    [_touchStorage release];
    [super dealloc];
}

- (void)deactivateBitmapTool
{
    [[self bitmapTool] stopRecordTouchesWithConsumer:_touchStorage];
    [_touchStorage setDelegate:nil];
    [_touchStorage release];
    _touchStorage = nil;
    [super deactivateBitmapTool];
}

- (BOOL)activateBitmapTool
{
    BOOL activated = [super activateBitmapTool];
    if (activated && _touchStorage == nil) {
        _touchStorage = [HSBrushTouchesStorage new];
        [_touchStorage setDelegate:self];
        [[self bitmapTool] startRecordTouchesWithConsumer:_touchStorage];
    }
    return activated;
}

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    id bitmapTool = [self bitmapTool];
    if (bitmapTool == aTool && aNextStage == nil && [_touchStorage numberOfTouches] != 0) {
        [bitmapTool stopRecordTouchesWithConsumer:_touchStorage];
        // A gradient brush is drawn once over the whole stroke when the stage ends.
        if ([bitmapTool image] == nil && CGEColorIsGradient([[bitmapTool color] pointer])) {
            id workImage = [bitmapTool workImage];
            CGSize imageSize = workImage != nil ? [workImage imageSize] : CGSizeZero;
            CGRect dirtyRect = CGRectIntersection(_brushBounds, CGRectMake(CGPointZero.x, CGPointZero.y, imageSize.width, imageSize.height));
            if (!CGRectIsEmpty(dirtyRect)) {
                [bitmapTool preEditWorkImage:workImage inRect:dirtyRect];
                [workImage beginCGEditing];
                CGContextRef context = [workImage imageCGContext];
                if (context != NULL)
                    [_touchStorage drawWithTouchProvider:_touchStorage inContext:context withBounds:dirtyRect];
                [workImage endCGEditing];
                [bitmapTool postEditWorkImageInRect:dirtyRect];
            }
        }
        [_touchStorage setDelegate:nil];
        [_touchStorage release];
        _touchStorage = [HSBrushTouchesStorage new];
        [_touchStorage setDelegate:self];
        [bitmapTool startRecordTouchesWithConsumer:_touchStorage];
        _brushBounds = CGRectZero;
    }
    return [super tool:aTool didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
}

@end
