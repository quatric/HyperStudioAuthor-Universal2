#import "HyperPlayerBasePrefix.h"


@interface HSUnarchiver : NSCoder
{
    NSData *_data;
    unsigned int _offset;
}
- (NSInteger)versionForClassName:(id)aName;
- (id)decodeDataObject;
- (void)decodeValueOfObjCType:(char *)aType at:(void *)aAt;
- (void)encodeDataObject:(id)aObject;
- (void)encodeValueOfObjCType:(char *)aType at:(void *)aAt;
- (void)dealloc;
- (id)initForReadingWithData:(id)aData;
@end

@interface HSArchiver : NSCoder
{
    NSMutableData *_data;
}
- (NSInteger)versionForClassName:(id)aName;
- (id)decodeDataObject;
- (void)decodeValueOfObjCType:(char *)aType at:(void *)aAt;
- (void)encodeDataObject:(id)aObject;
- (void)encodeValueOfObjCType:(char *)aType at:(void *)aAt;
- (id)archiverData;
- (void)dealloc;
- (id)initForWritingWithMutableData:(id)aData;
- (id)init;
@end

