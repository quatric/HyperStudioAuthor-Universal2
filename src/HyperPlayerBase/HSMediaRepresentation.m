#import "HSMediaRepresentation.h"
@implementation HSMediaRepresentation
// QuickTime is gone, so there is no graphics importer to ask (nil). The
// original read the importer's metadata user data: 'gp\0\2' latitude and
// 'gp\0\4' longitude (three big-endian rationals each: degrees, minutes,
// seconds), 'gp\0\1' / 'gp\0\3' their "N"/"S" and "E"/"W" refs (S and W
// negate), and returned them as a kCGImagePropertyGPS{Latitude,Longitude}
// (Ref) dictionary.
+ (id)GPSDictionaryFromGraphicsImporter:(struct ComponentInstanceRecord *)aImporter
{
    return nil;
}
- (id)GPSDictionary
{
    return nil;
}
- (BOOL)isValid
{
    return YES;
}
// Abstract: subclasses provide the media.
- (id)mediaType
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (id)mediaData
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (void)storeData
{
    [self doesNotRecognizeSelector:_cmd];
}
@end
