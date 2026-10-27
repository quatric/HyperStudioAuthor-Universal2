#import "HyperPlayerBasePrefix.h"


@interface HSMultipleUIValue : NSObject
{
    NSString *_stringValue;
    NSImage *_imageValue;
}
+ (id)multipleUIValue;
- (id)imageValueOfSize:(NSSize)aSize;
- (NSInteger)stateValue;
- (id)attributedStringValue;
- (id)stringValue;
- (void)dealloc;
- (id)init;
@end

