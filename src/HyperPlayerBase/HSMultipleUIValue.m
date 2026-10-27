#import "HSMultipleUIValue.h"
// The value shown for a multiple selection with differing values.
@implementation HSMultipleUIValue
+ (id)multipleUIValue
{
    static id value = nil;
    if (value == nil)
        value = [self new];
    return value;
}
- (id)imageValueOfSize:(NSSize)aSize
{
    NSImage *image = [[[NSImage alloc] initWithSize:aSize] autorelease];
    [image lockFocus];
    [(NSAttributedString *)[self attributedStringValue] drawInRect:(NSRect){ NSZeroPoint, aSize }];
    [image unlockFocus];
    return image;
}
// Mixed.
- (NSInteger)stateValue
{
    return -1;
}
- (id)attributedStringValue
{
    return [[[NSAttributedString alloc] initWithString:_stringValue] autorelease];
}
- (id)stringValue
{
    return _stringValue;
}
- (void)dealloc
{
    [_stringValue release];
    [_imageValue release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        _stringValue = [[[NSBundle mainBundle] localizedStringForKey:@"<Multiple selection>" value:@"" table:nil] retain];
        _imageValue = [[NSImage imageNamed:@"MultipleSelection"] retain];
    }
    return self;
}
@end
