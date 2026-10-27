#import "HSBackgroundView.h"
// A view showing a background (from its attributes).
@implementation HSBackgroundView
- (void)drawRect:(NSRect)aRect
{
    [[self backgroundRenderer] hyperDrawBackgroundInROI:aRect ofBounds:[self bounds]];
}
- (id)backgroundAttributes
{
    return [[self backgroundRenderer] extraDictionaryRepresentation];
}
- (void)setBackgroundAttributes:(id)aAttributes
{
    if (_backgroundAttributes != aAttributes) {
        [_backgroundAttributes autorelease];
        _backgroundAttributes = [[NSDictionary alloc] initWithDictionary:aAttributes];
        [self setBackgroundRenderer:nil];
    }
}
// Made from the attributes when needed.
- (id)backgroundRenderer
{
    if (_backgroundRenderer == nil) {
        id renderer;
        if (_backgroundAttributes != nil)
            renderer = [HSBackgroundViewRenderer objectWithExtraDictionary:_backgroundAttributes];
        else
            renderer = [[[HSBackgroundViewRenderer alloc] initWithBackgroundView:self] autorelease];
        [self setBackgroundRenderer:renderer];
    }
    return _backgroundRenderer;
}
- (void)setBackgroundRenderer:(id)aRenderer
{
    if (_backgroundRenderer != aRenderer) {
        [_backgroundRenderer setBackgroundView:nil];
        [_backgroundRenderer autorelease];
        id previous = _backgroundRenderer;
        _backgroundRenderer = [aRenderer retain];
        [_backgroundRenderer setBackgroundView:self];
        [self setNeedsDisplay:YES];
        // (A nil renderer ends the user info early, as in the original.)
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:_backgroundRenderer, @"HSBackgroundRendererKey",
                              previous, @"HSPreviousBackgroundRendererKey", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSBackgroundViewRendererDidChangeNotification" object:self userInfo:info];
    }
}
- (void)dealloc
{
    [_backgroundRenderer setBackgroundView:nil];
    [_backgroundRenderer autorelease];
    [_backgroundAttributes autorelease];
    [super dealloc];
}
- (id)initWithFrame:(NSRect)aFrame
{
    return [self initWithFrame:aFrame backgroundAttributes:nil];
}
- (id)initWithFrame:(NSRect)aFrame backgroundAttributes:(id)aAttributes
{
    self = [super initWithFrame:aFrame];
    if (self != nil)
        _backgroundAttributes = [[NSDictionary alloc] initWithDictionary:aAttributes];
    return self;
}
@end
