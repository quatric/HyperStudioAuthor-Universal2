#import "HSSystemSquareButtonData.h"
// A square system button ("VisualSquareButton" nib) with an image and an
// alternate image, stored by media UID, and the image position.
@implementation HSSystemSquareButtonData
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"imageMediaUID"];
    [keys addObject:@"alternateImageMediaUID"];
    [keys addObject:@"imagePosition"];
    return keys;
}
- (void)setImagePosition:(NSUInteger)aPosition
{
    [(NSButton *)[self systemButtonForSetAccessor] setImagePosition:aPosition];
}
- (NSUInteger)imagePosition
{
    return [(NSButton *)[self systemButtonForGetAccessor] imagePosition];
}
- (void)setAlternateImageValid:(BOOL)aValid
{
    _alternateImageValid = aValid;
}
- (BOOL)isAlternateImageValid
{
    return _alternateImageValid;
}
// (The original leaked the previous media.)
- (void)setAlternateImageMediaUID:(id)aUID
{
    if (aUID != nil && [aUID isEqualTo:[self alternateImageMediaUID]])
        return;
    id media = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
    [_alternateImageMedia release];
    _alternateImageMedia = media;
}
- (id)alternateImageMediaUID
{
    return [_alternateImageMedia mediaUID];
}
- (void)setImageValid:(BOOL)aValid
{
    _imageValid = aValid;
}
- (BOOL)isImageValid
{
    return _imageValid;
}
// (The original leaked the previous media.)
- (void)setImageMediaUID:(id)aUID
{
    if (aUID != nil && [aUID isEqualTo:[self imageMediaUID]])
        return;
    id media = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
    [_imageMedia release];
    _imageMedia = media;
}
- (id)imageMediaUID
{
    return [_imageMedia mediaUID];
}
- (void)dealloc
{
    [_alternateImageMedia release];
    [_imageMedia release];
    [super dealloc];
}
- (id)templateCocoaView
{
    return [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSquareButton"];
}
@end
