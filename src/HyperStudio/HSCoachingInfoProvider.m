#import "HSCoachingInfoProvider.h"

static HSCoachingInfoProvider *sSharedProvider = nil;

@implementation HSCoachingInfoProvider

+ (id)sharedProvider
{
    if (sSharedProvider == nil)
        sSharedProvider = [HSCoachingInfoProvider new];
    return sSharedProvider;
}

- (id)coachingInfoForKey:(id)aKey
{
    return [[self coachingInfo] objectForKey:aKey];
}

- (id)coachingInfoForObject:(id)aObject
{
    return [self coachingInfoForKey:[self coachingKeyForObject:aObject]];
}

// Movies and panoramas use separate coaching when no play-movie action on their parent plays them.
- (id)coachingKeyForObject:(id)aObject
{
    if ([aObject respondsToSelector:@selector(userInfoForKey:)]) {
        NSString *key = [aObject userInfoForKey:@"coachingInfoKey"];
        if (key != nil && [key length] != 0)
            return key;
    }

    id movie = [aObject queryHyperInterface:@protocol(HSMovieObjectAttributes)];
    id image = [aObject queryHyperInterface:@protocol(HSImageObjectAttributes)];

    if (movie != nil) {
        id uid = [aObject hyperUID];
        id action = [[[aObject hyperParent] queryHyperInterface:@protocol(HSActor)] hyperActionOfType:@"HSPlayMovieAction"];
        BOOL played = NO;

        for (id item in [action movies]) {
            if ([[item movieObjectUID] isEqual:uid]) {
                played = YES;
                break;
            }
        }
        if ([movie isHyperQTVR])
            return played ? @"HSQTVRMovieObject" : @"HSQTVRMovieObjectOnObject";
        if ([movie isHyperPanoramaObject])
            return played ? @"HSPanoramaObject" : @"HSPanoramaObjectOnObject";
        if (!played)
            return @"HSMovieObjectOnObject";
    } else if (image != nil) {
        id layout = [[NSUserDefaults standardUserDefaults] objectForKey:HSImportedImageLayoutKey];
        if (layout != nil) {
            int value = [layout intValue];
            if (value == 2)
                return @"HSImageObjectFillCard";
            if (value == 1)
                return @"HSImageObjectFitCard";
        }
        return @"HSImageObject";
    }
    return NSStringFromClass([aObject class]);
}

- (id)coachingInfo
{
    if (_coaching == nil)
        [self setCoachingInfo:[NSDictionary extraDictionaryNamed:@"CoachingInfo.plist"]];
    return _coaching;
}

- (void)setCoachingInfo:(id)aInfo
{
    if (_coaching != aInfo) {
        [_coaching autorelease];
        _coaching = [aInfo retain];
    }
}

- (void)dealloc
{
    [_coaching release];
    [super dealloc];
}

@end
