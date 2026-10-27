#import "NSValue+NSEValue.h"

@implementation NSValue (NSEValue)

// The pixel format with the original's encoding, "{?=Ii}".
+ (id)NSE_valueWithPixelFormat:(struct SMKApplicationKit_anon2)aFormat
{
    return [NSValue valueWithBytes:&aFormat objCType:"{?=Ii}"];
}

- (struct SMKApplicationKit_anon2)NSE_pixelFormatValue
{
    struct SMKApplicationKit_anon2 format = {0, 0};
    [self getValue:&format];
    return format;
}

@end

