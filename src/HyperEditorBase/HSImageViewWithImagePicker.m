#import "HSImageViewWithImagePicker.h"

@implementation HSImageViewWithImagePicker

// A double click picks the image with the picture taker.
- (void)mouseDown:(id)aDown
{
    if ([aDown clickCount] != 2) {
        [super mouseDown:aDown];
        return;
    }
    IKPictureTaker *taker = [NSClassFromString(@"IKPictureTaker") pictureTaker];
    [taker setInputImage:[self image]];
    NSNumber *yes = [NSNumber numberWithBool:YES];
    [taker setValue:yes forKey:IKPictureTakerAllowsVideoCaptureKey];
    [taker setValue:yes forKey:IKPictureTakerAllowsFileChoosingKey];
    [taker setValue:yes forKey:IKPictureTakerShowRecentPictureKey];
    [taker setValue:yes forKey:IKPictureTakerUpdateRecentPictureKey];
    [taker setValue:yes forKey:IKPictureTakerAllowsEditingKey];
    [taker setValue:yes forKey:IKPictureTakerShowEffectsKey];
    if ([taker runModal] != NSModalResponseOK)
        return;
    [self setImage:[taker outputImage]];
    [NSApp sendAction:[self action] to:[self target] from:self];
}

@end
