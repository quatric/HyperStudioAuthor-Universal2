#import "HSAppearanceButtonCell.h"

// A button cell with an alternate image for each control tint.

@implementation HSAppearanceButtonCell

- (void)controlTintDidChange:(id)aChange
{
    [self setAlternateImage:[self isGraphiteTint] ? _graphiteAlternateImage : _aquaAlternateImage];
}

- (void)setGraphiteAlternateImage:(id)aImage
{
    if (_graphiteAlternateImage != aImage) {
        [_graphiteAlternateImage release];
        _graphiteAlternateImage = [aImage retain];
        if ([self isGraphiteTint])
            [self setAlternateImage:_graphiteAlternateImage];
    }
}

- (id)graphiteAlternateImage
{
    return _graphiteAlternateImage;
}

- (void)setAquaAlternateImage:(id)aImage
{
    if (_aquaAlternateImage != aImage) {
        [_aquaAlternateImage release];
        _aquaAlternateImage = [aImage retain];
        if (![self isGraphiteTint])
            [self setAlternateImage:_aquaAlternateImage];
    }
}

- (id)aquaAlternateImage
{
    return _aquaAlternateImage;
}

- (BOOL)isGraphiteTint
{
    return [NSColor currentControlTint] == NSGraphiteControlTint;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_aquaAlternateImage release];
    [_graphiteAlternateImage release];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
    return self;
}

- (id)initImageCell:(id)aCell
{
    if ((self = [super initImageCell:aCell]))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
    return self;
}

- (id)initTextCell:(id)aCell
{
    if ((self = [super initTextCell:aCell]))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
    return self;
}

@end
