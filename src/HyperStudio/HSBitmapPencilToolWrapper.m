#import "HSBitmapPencilToolWrapper.h"

@implementation HSBitmapPencilToolWrapper

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

- (id)settingsIdentifiers
{
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolEraserColorAttributeKey, nil]];
}

@end
