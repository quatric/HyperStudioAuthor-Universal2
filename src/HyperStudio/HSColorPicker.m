#import "HSColorPicker.h"

@implementation HSColorPicker

- (void)setIsDisabled:(BOOL)aDisabled
{
    if (_isDisabled != aDisabled)
        _isDisabled = aDisabled;
}

- (BOOL)isDisabled
{
    return _isDisabled;
}

- (void)didLoadNib
{
}

- (void)setColor:(id)aColor
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id)provideNewButtonImage
{
    if (_colorPickerImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:[self imageName] ofType:@"tiff"];
        if (path != nil)
            _colorPickerImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return _colorPickerImage;
}

- (id)buttonToolTip
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)provideNewView:(BOOL)aView
{
    if (aView && _pickerView == nil) {
        [NSBundle loadNibNamed:[self nibName] owner:self];
        [self didLoadNib];
    }
    return _pickerView;
}

- (id)nibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)imageName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSInteger)currentMode
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (BOOL)supportsMode:(NSInteger)aMode
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)dealloc
{
    [_pickerView release];
    [_colorPickerImage release];
    [super dealloc];
}

- (id)initWithPickerMask:(NSUInteger)aMask colorPanel:(id)aPanel
{
    return [super initWithPickerMask:aMask colorPanel:aPanel];
}

@end
