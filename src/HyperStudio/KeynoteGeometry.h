#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteGeometry : KeynoteObject
{
    KeynoteGeometry *_parentGeometry;
}
- (void)setParentGeometry:(id)aGeometry;
- (id)parentGeometry;
- (BOOL)isVerticalFlip;
- (BOOL)isHorizontalFlip;
- (CGFloat)angle;
- (NSPoint)origin;
- (NSSize)naturalSize;
- (NSSize)size;
- (void)dealloc;
@end

