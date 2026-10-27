#import "HSStackBackgroundImageController.h"

@implementation HSStackBackgroundImageController

// Takes a dropped or pasted file URL or image data as the background image.
- (void)setImageFromPasteboard:(id)aPasteboard
{
    if (![aPasteboard availableTypeFromArray:[NSArray arrayWithObject:NSURLPboardType]]) {
        NSData *data = [aPasteboard dataForType:NSTIFFPboardType];
        NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
        if (!image)
            [_imageFillPreview setImage:[_applier hyperImage]];
        else
            [_applier setHyperImage:image];
    } else {
        NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
        [_applier setHyperImageFromPath:[url path]];
    }
}

- (void)hyperImageView:(id)aView didAcceptedDropWithDraggingInfo:(id)aInfo
{
    if (_imageFillPreview == aView)
        [self setImageFromPasteboard:[aInfo draggingPasteboard]];
}

- (void)hyperImageViewDidPasted:(id)aPasted
{
    [self setImageFromPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)chooseBackgroundImage:(id)aImage
{
    NSString *path = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSImageFileType];
    if (path) {
        [_applier setHyperImageFromPath:path];
        [_imageFillPreview setImage:[_applier hyperImage]];
    }
}

- (void)changeImagePreview:(id)aPreview
{
    if ([aPreview image])
        [_applier setHyperImage:[aPreview image]];
}

- (void)chooseBackgroundFillStyle:(id)aStyle
{
    [_applier setHyperImageScaling:[[aStyle selectedItem] tag]];
}

- (void)setShouldActivateColorWellOnMount:(BOOL)aMount
{
}

- (BOOL)deactivatedColorWellOnUnmount
{
    return NO;
}

- (void)setDelegate:(id)aDelegate
{
}

- (id)delegate
{
    return nil;
}

// The preview stays empty when the selected objects use different images.
- (void)validateUIElements
{
    [_fillImageStylePopUpButton selectItemWithTag:[_applier hyperImageScaling]];
    id image = [_applier hyperImage];
    id media = [[_applier backgroundImageInterface] queryHyperInterface:@protocol(HSMediaAttributes)];
    id path = [[media media] fullPathToMediaFile];
    if ([media isHyperProxy]) {
        NSEnumerator *enumerator = [[media allHyperInterfaces] objectEnumerator];
        id other;
        while ((other = [enumerator nextObject])) {
            if (![[[other media] fullPathToMediaFile] isEqual:path]) {
                [_imageFillPreview setImage:nil];
                return;
            }
        }
    }
    [_imageFillPreview setImage:image];
}

- (void)apply
{
    if (!_didInitOnce) {
        [self validateUIElements];
        _didInitOnce = YES;
    }
    [_applier setHyperImage:[_imageFillPreview image]];
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier)
        _applier = aApplier;
}

- (id)contentView
{
    return _controlledView;
}

- (void)awakeFromNib
{
    if ([_imageFillPreview respondsToSelector:@selector(setAllowsCutCopyPaste:)])
        [_imageFillPreview setAllowsCutCopyPaste:YES];
}

- (void)dealloc
{
    [_controlledView release];
    [super dealloc];
}

@end
