#import "HSBackgroundPopUpButton.h"

@implementation HSBackgroundPopUpButton

- (NSUInteger)controlSize
{
    return [[self cell] controlSize];
}

- (void)setControlSize:(NSUInteger)aSize
{
    [self synchronizeImagesWithControlSize:aSize];
    [[self cell] setControlSize:aSize];
}

- (void)synchronizeImagesWithControlSize:(NSUInteger)aSize
{
    id image;
    if (aSize == NSControlSizeMini)
        image = [self miniImage];
    else if (aSize == NSControlSizeSmall)
        image = [self smallImage];
    else
        image = [self regularImage];
    [[self cell] setDisplayedImage:image];
}

- (void)setMiniImage:(id)aImage
{
    if (_miniImage != aImage) {
        [_miniImage release];
        _miniImage = [aImage retain];
        [self synchronizeImagesWithControlSize:[self controlSize]];
    }
}

- (id)miniImage
{
    return _miniImage;
}

- (void)setSmallImage:(id)aImage
{
    if (_smallImage != aImage) {
        [_smallImage release];
        _smallImage = [aImage retain];
        [self synchronizeImagesWithControlSize:[self controlSize]];
    }
}

- (id)smallImage
{
    return _smallImage;
}

- (void)setRegularImage:(id)aImage
{
    if (_regularImage != aImage) {
        [_regularImage release];
        _regularImage = [aImage retain];
        [self synchronizeImagesWithControlSize:[self controlSize]];
    }
}

- (id)regularImage
{
    return _regularImage;
}

@end
