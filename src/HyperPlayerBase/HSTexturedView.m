#import "HSTexturedView.h"
// A view drawn by a nine-part texture renderer.
@implementation HSTexturedView
- (void)setShouldTileMiddleParts:(BOOL)aParts
{
    [_renderer setShouldTileMiddleParts:aParts];
}
- (BOOL)shouldTileMiddleParts
{
    return [_renderer shouldTileMiddleParts];
}
- (void)drawRect:(NSRect)aRect
{
    [_renderer drawInRect:[self bounds] invalidRect:aRect inView:self];
}
- (void)setScalesTexturesToFit:(BOOL)aFit
{
    [[self renderer] setScalesImagesToFit:aFit];
}
- (BOOL)scalesTexturesToFit
{
    return [[self renderer] scalesImagesToFit];
}
- (void)setBackgroundColor:(id)aColor
{
    [_renderer setBackgroundColor:aColor];
    [self setNeedsDisplay:YES];
}
- (id)backgroundColor
{
    return [_renderer backgroundColor];
}
- (void)setRenderer:(id)aRenderer
{
    if (_renderer == aRenderer)
        return;
    [_renderer autorelease];
    _renderer = [aRenderer retain];
}
- (id)renderer
{
    return _renderer;
}
- (void)setFraction:(CGFloat)aFraction
{
    if ((float)[_renderer fraction] == (float)aFraction)
        return;
    [_renderer setFraction:aFraction];
    [self setNeedsDisplay:YES];
}
- (CGFloat)fraction
{
    return (float)[_renderer fraction];
}
- (void)setImage:(id)aImage forType:(NSInteger)aType
{
    if ([_renderer imageForType:aType] == aImage)
        return;
    [_renderer setImage:aImage forType:aType];
    [self setNeedsDisplay:YES];
}
- (id)imageForType:(NSInteger)aType
{
    return [_renderer imageForType:aType];
}
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil)
        [self setRenderer:[[[HSControlRectangularBackgroundRenderer alloc] init] autorelease]];
    return self;
}
- (BOOL)isOpaque
{
    return NO;
}
- (void)dealloc
{
    [_renderer release];
    [super dealloc];
}
@end
