#import "HSToolbarPopUpButton.h"

@implementation HSToolbarPopUpButton

- (void)dealloc
{
    [_regularImage release];
    [_smallImage release];
    [super dealloc];
}

- (void)setControlSize:(NSControlSize)aSize
{
    [[self itemAtIndex:0] setImage:(aSize == NSRegularControlSize) ? _regularImage : _smallImage];
    [[self cell] setControlSize:aSize];
}

- (NSControlSize)controlSize
{
    return [[self cell] controlSize];
}

- (void)setRegularImage:(NSImage *)aImage
{
    if (_regularImage != aImage) {
        [_regularImage release];
        _regularImage = [aImage retain];
    }
}

- (void)setSmallImage:(NSImage *)aImage
{
    if (_smallImage != aImage) {
        [_smallImage release];
        _smallImage = [aImage retain];
    }
}

@end
