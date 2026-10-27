#import "HSHeadlineTool.h"

@implementation HSHeadlineTool

+ (id)allowedEditorInterfaces
{
    static NSSet *sInterfaces = nil;

    if (sInterfaces == nil) {
        NSMutableSet *interfaces = [NSMutableSet set];
        [interfaces unionSet:[super allowedEditorInterfaces]];
        [interfaces unionSet:[self allowedPrototypeInterfaces]];
        sInterfaces = [interfaces copy];
    }
    return sInterfaces;
}

+ (id)allowedPrototypeInterfaces
{
    static NSSet *sInterfaces = nil;

    if (sInterfaces == nil) {
        NSMutableSet *interfaces = [NSMutableSet set];
        [interfaces unionSet:[super allowedPrototypeInterfaces]];
        [interfaces addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableBackgroundAttributes)]];
        [interfaces addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSBackgroundAttributes)]];
        [interfaces addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSOutlineAttributes)]];
        [interfaces addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableOutlineAttributes)]];
        sInterfaces = [interfaces copy];
    }
    return sInterfaces;
}

+ (Class)userObjectClass
{
    return [HSHeadlineObject class];
}

- (void)setTextColor:(id)aColor
{
    [[[self prototypeObject] queryHyperInterface:@protocol(HSMutableOutlineAttributes)] setHyperOutlineColor:aColor];
}

- (id)defaultToolCursorName
{
    return HSIBeamCursor;
}

@end
