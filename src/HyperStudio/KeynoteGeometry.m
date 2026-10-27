#import "KeynoteGeometry.h"

@implementation KeynoteGeometry

- (void)setParentGeometry:(id)aGeometry
{
    [_parentGeometry release];
    _parentGeometry = [aGeometry retain];
}

- (id)parentGeometry
{
    return _parentGeometry;
}

- (BOOL)isVerticalFlip
{
    return [KeynoteTools verticalFlipWithAttributesDictionary:[self nodeAttributes]];
}

- (BOOL)isHorizontalFlip
{
    return [KeynoteTools horizontalFlipWithAttributesDictionary:[self nodeAttributes]];
}

- (CGFloat)angle
{
    return [KeynoteTools angleWithAttributesDictionary:[self nodeAttributes]];
}

- (NSPoint)origin
{
    id position = [self childForName:@"position"];
    NSPoint origin = position != nil ? [KeynoteTools pointWithAttributesDictionary:[position nodeAttributes]] : NSZeroPoint;
    KeynoteGeometry *parent = [self parentGeometry];
    if (parent != nil) {
        NSPoint parentOrigin = [parent origin];
        origin.x += parentOrigin.x;
        origin.y += parentOrigin.y;
    }
    return origin;
}

- (NSSize)naturalSize
{
    return [KeynoteTools sizeWithAttributesDictionary:[[self childForName:@"naturalSize"] nodeAttributes]];
}

- (NSSize)size
{
    return [(KeynoteSize *)[self childForName:@"size"] size];
}

- (void)dealloc
{
    [_parentGeometry release];
    [super dealloc];
}

@end
