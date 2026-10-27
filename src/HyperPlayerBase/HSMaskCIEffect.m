#import "HSMaskCIEffect.h"
@implementation HSMaskCIEffect
+ (id)effectsDescription
{
    static NSDictionary *sEffectsDescription;
    if (sEffectsDescription == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"CIMaskEffects" ofType:@"plist"];
        if (path != nil)
            sEffectsDescription = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return sEffectsDescription;
}
- (id)compositeOutputCIImage:(id)aImage
{
    if (aImage == nil)
        return nil;
    CIImage *inputImage = [self valueForKey:ciInputImage];
    if (inputImage == nil)
        return aImage;
    CIImage *composited = nil;
    @try {
        if (_compositeFilter == nil)
            _compositeFilter = [[CIFilter filterWithName:@"CISourceOverCompositing"] retain];
        if (_compositeFilter != nil) {
            [_compositeFilter setValue:inputImage forKey:ciInputBackgroundImage];
            [_compositeFilter setValue:aImage forKey:ciInputImage];
            composited = [_compositeFilter valueForKey:ciOutputImage];
        }
    }
    @catch (NSException *exception) {
    }
    if (composited != nil) {
        id cropped = [self cropImage:composited toRect:[inputImage extent]];
        if (cropped != nil)
            aImage = cropped;
    }
    return aImage;
}
- (id)category
{
    return HSMaskCIEffectsCategory;
}
- (void)dealloc
{
    [_compositeFilter release];
    [super dealloc];
}
@end
