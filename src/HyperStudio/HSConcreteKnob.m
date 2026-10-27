#import "HSConcreteKnob.h"

@implementation HSConcreteKnob

+ (id)beingTrackedActiveStateImage
{
    return nil;
}

+ (id)activeStateImage
{
    return nil;
}

+ (id)beingTrackedStateImage
{
    return nil;
}

- (id)image
{
    BOOL isActive = [self isActive];
    BOOL isBeingTracked = [self isBeingTracked];
    if (isActive)
        return isBeingTracked ? [self beingTrackedActiveStateImage] : [self activeStateImage];
    if (isBeingTracked)
        return [self beingTrackedStateImage];
    return [super image];
}

- (void)setBeingTrackedActiveStateImage:(id)aImage
{
    if (_beingTrackedActiveStateImage != aImage) {
        [_beingTrackedActiveStateImage release];
        _beingTrackedActiveStateImage = [aImage retain];
    }
    _cflags.isBeingTrackedActiveStateImageSet = 1;
}

- (id)beingTrackedActiveStateImage
{
    id image;
    if (_cflags.isBeingTrackedActiveStateImageSet == 0) {
        image = _beingTrackedActiveStateImage = [[[self class] beingTrackedActiveStateImage] retain];
        _cflags.isBeingTrackedActiveStateImageSet = 1;
    } else {
        image = _beingTrackedActiveStateImage;
    }
    if (image == nil) {
        image = [self beingTrackedStateImage];
        if (image == [self normalStateImage])
            image = [self activeStateImage];
    }
    return image;
}

- (void)setBeingTrackedStateImage:(id)aImage
{
    if (_beingTrackedStateImage != aImage) {
        [_beingTrackedStateImage release];
        _beingTrackedStateImage = [aImage retain];
    }
    _cflags.isBeingTrackedStateImageSet = 1;
}

- (id)beingTrackedStateImage
{
    id image;
    if (_cflags.isBeingTrackedStateImageSet == 0) {
        image = _beingTrackedStateImage = [[[self class] beingTrackedStateImage] retain];
        _cflags.isBeingTrackedStateImageSet = 1;
    } else {
        image = _beingTrackedStateImage;
    }
    if (image == nil)
        image = [self normalStateImage];
    return image;
}

- (void)setActiveStateImage:(id)aImage
{
    if (_activeStateImage != aImage) {
        [_activeStateImage release];
        _activeStateImage = [aImage retain];
    }
    _cflags.isActiveStateImageSet = 1;
}

- (id)activeStateImage
{
    id image;
    if (_cflags.isActiveStateImageSet == 0) {
        image = _activeStateImage = [[[self class] activeStateImage] retain];
        _cflags.isActiveStateImageSet = 1;
    } else {
        image = _activeStateImage;
    }
    if (image == nil)
        image = [self normalStateImage];
    return image;
}

- (void)dealloc
{
    [_activeStateImage release];
    [_beingTrackedStateImage release];
    [_beingTrackedActiveStateImage release];
    [super dealloc];
}

@end
