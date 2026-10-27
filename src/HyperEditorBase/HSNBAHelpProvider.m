#import "HSNBAHelpProvider.h"

// The help and descriptions of actions (ActionHelp, ActionDescriptions
// RTF files named for the action types); a singleton never released.

static HSNBAHelpProvider *sSharedProvider;

@implementation HSNBAHelpProvider

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedProvider == nil) {
            sSharedProvider = [super allocWithZone:aZone];
            return sSharedProvider;
        }
    }
    return nil;
}

+ (id)sharedNBAHelpProvider
{
    @synchronized(self) {
        if (sSharedProvider == nil)
            [[self alloc] init];
    }
    return sSharedProvider;
}

// The type itself when there's no help file.
- (id)localizedHelpForActionOfType:(id)aType
{
    NSAttributedString *help = [[[NSAttributedString alloc] initWithString:aType] autorelease];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:[self shortDescriptionFileNameForActionType:aType] ofType:@"rtf" inDirectory:@"ActionHelp"];
    if (path == nil)
        path = [bundle pathForResource:[self shortDescriptionFileNameForActionType:aType] ofType:@"rtfd" inDirectory:@"ActionHelp"];
    if (path != nil)
        help = [[[NSAttributedString alloc] initWithPath:path documentAttributes:NULL] autorelease];
    return help;
}

- (id)localizedDescriptionForActionOfType:(id)aType
{
    NSAttributedString *description = [[[NSAttributedString alloc] initWithString:aType] autorelease];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:[self shortDescriptionFileNameForActionType:aType] ofType:@"rtf" inDirectory:@"ActionDescriptions"];
    if (path != nil)
        description = [[[NSAttributedString alloc] initWithPath:path documentAttributes:NULL] autorelease];
    return description;
}

- (id)shortDescriptionFileNameForActionType:(id)aType
{
    NSDictionary *names = [NSDictionary dictionaryWithObjectsAndKeys:@"HSQuitAnotherAppAction", [HSQuitAnotherApplicationAction actionType], nil];
    id name = [names objectForKey:aType];
    return name != nil ? name : aType;
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
