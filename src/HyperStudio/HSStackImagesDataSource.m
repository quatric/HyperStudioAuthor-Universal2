#import "HSStackImagesDataSource.h"

@implementation HSStackImagesDataSource

// Media of every button in the stack except textured-background system buttons.
- (id)mediaUIDs
{
    NSMutableSet *uids = [NSMutableSet new];
    NSEnumerator *enumerator = [[self stack] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if ([[[object queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] systemButtonType] isEqualToString:@"HSTexturedBackgroundSystemButtonType"])
            continue;
        id uid = [[[object queryHyperInterface:@protocol(HSButtonObjectAttributes)] media] mediaUID];
        if (uid != nil)
            [uids addObject:uid];
    }
    return [uids autorelease];
}

- (NSInteger)mediaGroup
{
    return 3;
}

@end
