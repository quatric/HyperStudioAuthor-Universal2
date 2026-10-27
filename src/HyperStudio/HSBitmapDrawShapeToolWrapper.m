#import "HSBitmapDrawShapeToolWrapper.h"

@implementation HSBitmapDrawShapeToolWrapper

- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform
{
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)canProvideSelectedShape
{
    return NO;
}

// Solid RGB stroke colors are copied back to the shared tool settings.
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    BOOL alternate = [aKey isEqualToString:@"alternateStrokeColor"];
    if (alternate || [aKey isEqualToString:@"strokeColor"]) {
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

// The 3D box tool has no fill color.
- (id)settingsIdentifiers
{
    NSArray *identifiers;
    if ([[self toolIdentifier] isEqualToString:@"HS3DBoxMakerTool"])
        identifiers = [NSArray arrayWithObjects:HSToolStrokeWidthAttributeKey, HSToolDrawColorAttributeKey, HSToolEraserColorAttributeKey, nil];
    else
        identifiers = [NSArray arrayWithObjects:HSToolStrokeWidthAttributeKey, HSToolDrawColorAttributeKey, HSToolEraserColorAttributeKey, HSToolFillColorAttributeKey, nil];
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:identifiers];
}

@end
