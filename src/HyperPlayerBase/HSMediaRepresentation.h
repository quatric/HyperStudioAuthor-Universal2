#import "HyperPlayerBasePrefix.h"


@interface HSMediaRepresentation : NSObject
{
}
+ (id)GPSDictionaryFromGraphicsImporter:(struct ComponentInstanceRecord *)aImporter;
- (id)GPSDictionary;
- (BOOL)isValid;
- (id)mediaType;
- (id)mediaData;
- (void)storeData;
@end

