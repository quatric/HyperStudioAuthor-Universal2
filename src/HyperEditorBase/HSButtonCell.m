#import "HSButtonCell.h"

// A button cell drawing its own images (normal, pushed and disabled of
// each), and its focus ring around the image only.

@implementation HSButtonCell

- (void)loadDefaultImages
{
}

- (void)applyDefaultSettings
{
    [self loadDefaultImages];
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    if (![self showsFirstResponder]) {
        [super drawInteriorWithFrame:aFrame inView:aView];
        return;
    }
    [NSGraphicsContext saveGraphicsState];
    [self setFocusRingType:NSFocusRingTypeNone];
    [super drawInteriorWithFrame:aFrame inView:aView];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawImage:(id)aImage withFrame:(NSRect)aFrame inView:(id)aView
{
    BOOL focus = [self showsFirstResponder];
    if (focus) {
        [NSGraphicsContext saveGraphicsState];
        [self setFocusRingType:NSFocusRingTypeDefault];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSSetFocusRingStyle(NSFocusRingOnly);
#pragma clang diagnostic pop
    }
    NSImage *image;
    BOOL on = [self state] == NSControlStateValueOn;
    BOOL off = [self state] == NSControlStateValueOff;
    if ([self isEnabled])
        image = on && _pushedButtonImage != nil ? _pushedButtonImage : off ? _buttonImage : nil;
    else
        image = on && _disabledPushedButtonImage != nil ? _disabledPushedButtonImage : off ? _disabledButtonImage : nil;
    if (image != nil)
        [super drawImage:image withFrame:aFrame inView:aView];
    if (focus)
        [NSGraphicsContext restoreGraphicsState];
}

- (void)setDisabledPushedButtonImage:(id)aImage
{
    if (_disabledPushedButtonImage != aImage) {
        [_disabledPushedButtonImage release];
        _disabledPushedButtonImage = [aImage retain];
    }
}

- (id)disabledPushedButtonImage
{
    return _disabledPushedButtonImage;
}

- (void)setDisabledButtonImage:(id)aImage
{
    if (_disabledButtonImage != aImage) {
        [_disabledButtonImage release];
        _disabledButtonImage = [aImage retain];
    }
}

- (id)disabledButtonImage
{
    return _disabledButtonImage;
}

- (void)setPushedButtonImage:(id)aImage
{
    if (_pushedButtonImage != aImage) {
        [_pushedButtonImage release];
        _pushedButtonImage = [aImage retain];
    }
}

- (id)pushedButtonImage
{
    return _pushedButtonImage;
}

- (void)setButtonImage:(id)aImage
{
    if (_buttonImage != aImage) {
        [_buttonImage release];
        _buttonImage = [aImage retain];
    }
}

- (id)buttonImage
{
    return _buttonImage;
}

// Fix: the disabled images were neither retained by copies nor released.
- (id)copyWithZone:(NSZone *)aZone
{
    HSButtonCell *copy = [super copyWithZone:aZone];
    [copy->_buttonImage retain];
    [copy->_pushedButtonImage retain];
    [copy->_disabledButtonImage retain];
    [copy->_disabledPushedButtonImage retain];
    return copy;
}

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    if ([aCoder allowsKeyedCoding]) {
        if (_buttonImage != nil)
            [aCoder encodeObject:_buttonImage forKey:buttonImageKey];
        if (_pushedButtonImage != nil)
            [aCoder encodeObject:_pushedButtonImage forKey:pushedButtonImageKey];
    } else {
        if (_buttonImage != nil)
            [aCoder encodeObject:_buttonImage];
        if (_pushedButtonImage != nil)
            [aCoder encodeObject:_pushedButtonImage];
    }
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder])) {
        if ([aCoder allowsKeyedCoding]) {
            _buttonImage = [[aCoder decodeObjectForKey:buttonImageKey] retain];
            _pushedButtonImage = [[aCoder decodeObjectForKey:pushedButtonImageKey] retain];
        } else {
            _buttonImage = [[aCoder decodeObject] retain];
            _pushedButtonImage = [[aCoder decodeObject] retain];
        }
        if (_buttonImage == nil || _pushedButtonImage == nil)
            [self applyDefaultSettings];
    }
    // Fix: the original returned nil.
    return self;
}

- (void)dealloc
{
    [_buttonImage release];
    [_pushedButtonImage release];
    [_disabledButtonImage release];
    [_disabledPushedButtonImage release];
    [super dealloc];
}

@end
