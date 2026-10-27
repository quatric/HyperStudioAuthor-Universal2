#import "HyperPlayerBasePrefix.h"
#import "HSGraphics.h"


@interface HSDesktopCoverImage : HSGraphics <HSDesktopCoverImage, HSMutableImage, HSImage, HSGraphics, HyperInterface, NSObject, EXKeyValueCoding, NSCopying, HSMutableGraphics>
{
    NSImage *_image;
    int _imageScaling;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedDesktopCoverImage;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)setHyperImageSize:(NSSize)aSize;
- (NSSize)hyperImageSize;
- (void)setHyperImageScaling:(NSInteger)aScaling;
- (NSInteger)hyperImageScaling;
- (void)setHyperImageAlignment:(NSUInteger)aAlignment;
- (NSUInteger)hyperImageAlignment;
- (void)setHyperImage:(id)aImage;
- (id)hyperImage;
- (void)setHyperImageFromPath:(id)aPath;
- (id)desktopCoverImagePath;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

