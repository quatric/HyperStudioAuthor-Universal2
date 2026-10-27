#import "HSUID+HSUIDScriptExtensions.h"
@implementation HSUID (HSUIDScriptExtensions)
+ (id)uidWithScriptValue:(id)aValue
{
    // scripts name a UID "_xxxxxxxx_xxxx_...", with underscores for its dashes
    NSString *name = [[HSJavaScriptNamingStrategy defaultNamingStrategy] objectNameForMechanicName:aValue];
    if (name == nil || ![name hasPrefix:@"_"])
        return nil;
    NSMutableString *string = [NSMutableString stringWithString:[name substringFromIndex:[@"_" length]]];
    [string replaceOccurrencesOfString:@"_" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    HSUID *uid = nil;
    @try {
        uid = [HSUID UIDWithString:string];
    }
    @catch (NSException *exception) {
        uid = nil;
    }
    return uid;
}
- (id)scriptValue
{
    NSMutableString *string = [NSMutableString stringWithString:[self stringValue]];
    [string replaceOccurrencesOfString:@"-" withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    NSString *name = [NSString stringWithFormat:@"%@%@", @"_", string];
    return [[HSJavaScriptNamingStrategy defaultNamingStrategy] mechanicNameForObjectName:name];
}
@end
