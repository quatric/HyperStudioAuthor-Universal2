#import "HSUserObject+MediaSupport.h"
@implementation HSUserObject (MediaSupport)
// Whether this class (or a superclass) is one of the user object classes the
// media type can be set on.
+ (BOOL)isMediaTypeSupported:(id)aSupported
{
    NSArray *classNames = [HSNewMediaAccessor userObjectClassNamesForMediaType:aSupported];
    NSUInteger count = [classNames count];
    for (NSUInteger i = 0; i < count; i++) {
        Class mediaClass = NSClassFromString([classNames objectAtIndex:i]);
        if (mediaClass != Nil && [[self class] isSubclassOfClass:mediaClass])
            return YES;
    }
    return NO;
}
- (void)checkIfCanSetMediaFromPath:(id)aPath
{
}
- (void)checkIfMediaTypeIsSupported:(id)aSupported
{
}
- (BOOL)isMediaTypeSupported:(id)aSupported
{
    return [[self class] isMediaTypeSupported:aSupported];
}
- (BOOL)canSetMediaFromPath:(id)aPath
{
    id fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:aPath];
    return fileType != nil && [self isMediaTypeSupported:fileType];
}
@end
