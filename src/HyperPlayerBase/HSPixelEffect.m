#import "HSPixelEffect.h"
// Base of the effects computed on bitmaps (not Core Image): inputs are
// described in the class's plist (PixelEffect.plist unless overridden) and
// stored in the attributes dictionary unless the subclass has a setter.
@implementation HSPixelEffect
+ (id)effectDescriptionPlistName
{
    return @"PixelEffect";
}
+ (id)effectsDescription
{
    NSString *path = [[NSBundle bundleForClass:self] pathForResource:[self effectDescriptionPlistName] ofType:@"plist"];
    if (path == nil)
        return nil;
    return [NSDictionary dictionaryWithContentsOfFile:path];
}
- (void)updateInputImageRelatedInfo
{
}
// Draws the image over the whole (cleared) bitmap.
- (void)copyCocoaImage:(id)aImage toCGBitmapContext:(struct CGContext *)aContext
{
    if (aImage == nil)
        return;
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:aContext flipped:NO];
    if (context == nil)
        return;
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    CGRect bounds = CGRectMake(CGPointZero.x, CGPointZero.y, (float)CGBitmapContextGetWidth(aContext), (float)CGBitmapContextGetHeight(aContext));
    CGContextClearRect(aContext, bounds);
    [[aImage bestRepresentationForDevice:nil] drawInRect:NSRectFromCGRect(bounds)];
    [NSGraphicsContext restoreGraphicsState];
}
// An image from the class's bundle, sized in pixels.
- (id)loadImageWithName:(id)aName extension:(id)aExtension
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:aName ofType:aExtension];
    if (path == nil)
        return nil;
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[NSData dataWithContentsOfMappedFile:path]];
    if (rep == nil)
        return nil;
    float height = (float)[rep pixelsHigh];
    float width = (float)[rep pixelsWide];
    if (width == 0 || height == 0)
        return nil;
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [image addRepresentation:rep];
    if ([image isValid])
        return [image autorelease];
    [image release];
    return nil;
}
- (void)setAttribute:(id)aAttribute forKey:(id)aKey
{
    [[self effectAttributes] setObject:aAttribute forKey:aKey];
}
- (id)effectAttributes
{
    if (_effectAttributes == nil)
        _effectAttributes = [NSMutableDictionary new];
    return _effectAttributes;
}
// A getter of the key's name if the effect has one, else the attribute.
- (id)valueForKey:(id)aKey
{
    if (aKey == nil)
        return nil;
    SEL getter = NSSelectorFromString(aKey);
    if ([self respondsToSelector:getter])
        return [self performSelector:getter];
    return [[self effectAttributes] objectForKey:aKey];
}
- (void)setValue:(id)aValue forKey:(id)aKey
{
    if (aKey == nil)
        return;
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", aKey]);
    if ([self respondsToSelector:setter])
        [self performSelector:setter withObject:aValue];
    else
        [self setAttribute:aValue forKey:aKey];
}
- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"outputImage", @"outputCGImage", nil];
}
- (id)inputKeys
{
    return [[self attributes] objectForKey:HSInputsAttribute];
}
- (void)setInputImage:(id)aImage
{
    if (_inputImage == aImage)
        return;
    [_inputImage release];
    _inputImage = [aImage retain];
    [_outputImage release];
    _outputImage = nil;
    [self updateInputImageRelatedInfo];
}
- (void)setDefaults
{
    NSEnumerator *enumerator = [[[self attributes] objectForKey:HSInputsAttribute] objectEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil)
        [self setValue:[[[self attributes] objectForKey:key] objectForKey:HSAttributeDefault] forKey:key];
}
- (id)displayName
{
    return [[self attributes] objectForKey:HSAttributeEffectDisplayName];
}
- (id)name
{
    return [[self attributes] objectForKey:HSAttributeEffectName];
}
- (struct CGImage *)outputCGImage
{
    return [[self outputImage] hyperQuartzImage];
}
- (void)dealloc
{
    [_inputImage release];
    [_outputImage release];
    [_effectAttributes release];
    [_previewImage release];
    [super dealloc];
}
@end
