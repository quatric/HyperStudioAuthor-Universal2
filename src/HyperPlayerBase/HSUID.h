#import "HyperPlayerBasePrefix.h"


@interface HSUID : NSObject <EXKeyValueCoding, NSCoding, NSCopying>
{
}
+ (id)UID;
+ (id)UIDWithString:(id)aString;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)copyWithZone:(NSZone *)aZone;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)isEqual:(id)aEqual;
@end

@interface _HSCFUUID : HSUID
{
    struct __CFUUID *_UUID;
}
- (id)copyWithZone:(NSZone *)aZone;
- (id)description;
- (BOOL)isEqual:(id)aEqual;
- (NSUInteger)hash;
- (void)setStringValue:(id)aValue;
- (id)stringValue;
- (void)setUUID:(struct __CFUUID *)aUUID;
- (struct __CFUUID *)UUID;
- (void)dealloc;
- (id)initWithString:(id)aString;
- (id)initWithUUID:(struct __CFUUID *)aUUID;
@end


// Implemented by the concrete _HSCFUUID subclass (HSUID itself has no storage).
@interface HSUID (HSUIDStringValue)
- (id)stringValue;
- (void)setStringValue:(id)aValue;
@end
