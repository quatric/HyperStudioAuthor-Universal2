#import "HSSystemImageViewData.h"

@implementation HSSystemImageViewData
+ (id)nodeDataKeysToNodeKeysMap
{
    NSMutableDictionary *map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"mediaUID" forKey:@"imageMediaUID"];
    return map;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"imageMediaUID"];
    [keys addObject:@"imageAlignment"];
    [keys addObject:@"imageFrameStyle"];
    [keys addObject:@"imageScaling"];
    [keys addObject:@"editable"];
    [keys addObject:@"enabled"];
    return keys;
}
- (void)setEnabled:(BOOL)aValue
{
    [[self systemImageViewForSetAccessor] setEnabled:aValue];
}
- (BOOL)isEnabled
{
    return [[self systemImageViewForGetAccessor] isEnabled];
}
- (void)setEditable:(BOOL)aValue
{
    [[self systemImageViewForSetAccessor] setEditable:aValue];
}
- (BOOL)isEditable
{
    return [[self systemImageViewForGetAccessor] isEditable];
}
- (void)setImageScaling:(NSUInteger)aValue
{
    [[self systemImageViewForSetAccessor] setImageScaling:aValue];
}
- (NSUInteger)imageScaling
{
    return [[self systemImageViewForGetAccessor] imageScaling];
}
- (void)setImageFrameStyle:(NSUInteger)aValue
{
    [[self systemImageViewForSetAccessor] setImageFrameStyle:aValue];
}
- (NSUInteger)imageFrameStyle
{
    return [[self systemImageViewForGetAccessor] imageFrameStyle];
}
- (void)setImageAlignment:(NSUInteger)aValue
{
    [[self systemImageViewForSetAccessor] setImageAlignment:aValue];
}
- (NSUInteger)imageAlignment
{
    return [[self systemImageViewForGetAccessor] imageAlignment];
}
- (void)setImageValid:(BOOL)aValid
{
    _imageValid = aValid;
}
- (BOOL)isImageValid
{
    return _imageValid;
}
// The original leaked the previous media.
- (void)setImageMediaUID:(id)aUID
{
    if (aUID && [aUID isEqualTo:[self imageMediaUID]])
        return;
    id media = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
    [_imageMedia release];
    _imageMedia = media;
}
- (id)imageMediaUID
{
    return [_imageMedia mediaUID];
}
- (id)systemImageViewForSetAccessor
{
    return [self systemViewForSetAccessor];
}
- (id)systemImageViewForGetAccessor
{
    return [self systemViewForGetAccessor];
}
- (void)dealloc
{
    [_imageMedia release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _imageValid = NO;
        [self setDropOffOnly:YES];
    }
    return self;
}
- (id)templateCocoaView
{
    return [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSystemImageView"];
}
@end
