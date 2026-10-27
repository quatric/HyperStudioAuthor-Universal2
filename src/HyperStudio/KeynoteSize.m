#import "KeynoteSize.h"

@implementation KeynoteSize

- (NSSize)size
{
    return [KeynoteTools sizeWithAttributesDictionary:[self nodeAttributes]];
}

@end
