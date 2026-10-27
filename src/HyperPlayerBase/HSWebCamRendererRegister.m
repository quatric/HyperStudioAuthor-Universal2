#import "HSWebCamRendererRegister.h"
#import "HSErrorManager.h"
#import "HSExecutableResourceProvider.h"
#import "HSWebCamDataProvider.h"
#import "HSWebPageRenderer.h"

// Service error codes that are not worth reporting to the user.
#define HSWebCamLastSilentErrorCode 0x900ca
#define HSWebCamClipNotFoundErrorCode 0x900cd

static HSWebCamRendererRegister *HSSharedWebCamRendererRegister = nil;

// Renderer users are stored by address. The original stored them with
// numberWithInt:, which truncates pointers on 64-bit.
static NSNumber *HSWebCamRendererUserNumber(id aUser)
{
    return [NSNumber numberWithUnsignedLong:(uintptr_t)aUser];
}

static id HSWebCamRendererUserFromNumber(NSNumber *aNumber)
{
    return (id)(uintptr_t)[aNumber unsignedLongValue];
}

@implementation HSWebCamRendererRegister

+ (id)sharedWebCamRendererRegister
{
    if (HSSharedWebCamRendererRegister == nil)
        [[self class] new];
    return HSSharedWebCamRendererRegister;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSInteger count = [_unregisterTimers count];
    NSInteger index;
    for (index = 0; index < count; index++)
        [[_unregisterTimers objectAtIndex:index] invalidate];
    [_unregisterTimers release];
    [_renderersInfo release];
    [super dealloc];
}

- (void)dereferenceObject:(id)aObject
{
    NSInteger rendererCount = [_renderersInfo count];
    NSInteger rendererIndex;
    for (rendererIndex = 0; rendererIndex < rendererCount; rendererIndex++) {
        NSMutableArray *users = [[[_renderersInfo allValues] objectAtIndex:rendererIndex] objectForKey:@"HSRegisteredRendererUsers"];
        NSInteger userCount = [users count];
        NSInteger userIndex;
        for (userIndex = 0; userIndex < userCount; userIndex++) {
            NSDictionary *userInfo = [users objectAtIndex:userIndex];
            if (HSWebCamRendererUserFromNumber([userInfo objectForKey:@"HSRendererUser"]) == aObject) {
                [[userInfo objectForKey:@"HSRendererUserRefreshRateTimer"] invalidate];
                [users removeObjectAtIndex:userIndex];
                userCount--;
                break;
            }
        }
        if (userCount == 0)
            [self scheduleRemovalOfWebPageRendererForCamID:[[_renderersInfo allKeys] objectAtIndex:rendererIndex]];
    }
}

- (NSRect)clipRectForWebCamWithID:(id)aID
{
    NSRect rect = NSZeroRect;
    if ([aID length] != 0) {
        NSValue *value = [[_renderersInfo objectForKey:aID] objectForKey:WCDPClipRectKey];
        if (value != nil)
            rect = [value rectValue];
    }
    return rect;
}

- (NSSize)pageSizeForWebCamWithID:(id)aID
{
    NSSize size = NSZeroSize;
    if ([aID length] != 0) {
        NSValue *value = [[_renderersInfo objectForKey:aID] objectForKey:WCDPPageSizeKey];
        if (value != nil)
            size = [value sizeValue];
    }
    return size;
}

- (void)reportError:(id)aError
{
    [[HSErrorManager sharedErrorManager] presentError:aError];
}

- (void)webCamClipInfoValidatingFailed:(id)aFailed
{
    id camID = [aFailed object];
    NSMutableDictionary *info = [_renderersInfo objectForKey:camID];
    if (info == nil)
        [_renderersInfo setObject:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"HSWebCamValidityState"] forKey:camID];
    else
        [info setObject:[NSNumber numberWithBool:NO] forKey:@"HSWebCamValidityState"];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"HSWebCamValidityStateDidChangeNotification" object:camID userInfo:nil deliverImmediately:NO];

    NSData *errorData = [[aFailed userInfo] objectForKey:WCDPErrorDataKey];
    if (errorData != nil) {
        NSError *error = [NSKeyedUnarchiver unarchiveObjectWithData:errorData];
        if (error != nil && [error code] != HSWebCamClipNotFoundErrorCode && [error code] > HSWebCamLastSilentErrorCode)
            [self reportError:error];
    }
}

- (void)webCamClipInfoValidatingComplete:(id)aComplete
{
    id camID = [aComplete object];
    NSDictionary *userInfo = [aComplete userInfo];
    NSSize pageSize = NSSizeFromString([userInfo objectForKey:WCDPPageSizeKey]);
    NSRect clipRect = NSRectFromString([userInfo objectForKey:WCDPClipRectKey]);
    NSDictionary *state;
    if (pageSize.width != 0.0 && pageSize.height != 0.0 && !NSIsEmptyRect(clipRect)) {
        // The service reports the clip rect with a top-left origin.
        clipRect.origin.y = pageSize.height - clipRect.origin.y - clipRect.size.height;
        state = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], @"HSWebCamValidityState",
            [NSValue valueWithSize:pageSize], WCDPPageSizeKey,
            [NSValue valueWithRect:clipRect], WCDPClipRectKey,
            nil];
    } else {
        state = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"HSWebCamValidityState", nil];
    }

    NSMutableDictionary *info = [_renderersInfo objectForKey:camID];
    if (info != nil)
        [info addEntriesFromDictionary:state];
    else
        [_renderersInfo setObject:[NSMutableDictionary dictionaryWithDictionary:state] forKey:camID];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"HSWebCamValidityStateDidChangeNotification" object:camID userInfo:nil deliverImmediately:NO];
}

- (void)validateWebCamWithID:(id)aID pageSize:(NSSize)aSize clipRect:(NSRect)aRect
{
    BOOL skipValidation = [[[HSExecutableResourceProvider sharedInstance] objectForInfoDictionaryKey:@"HSWebCamRendererSkipValidation"] boolValue];
    if (!skipValidation || aSize.width == 0.0 || aSize.height == 0.0 || NSIsEmptyRect(aRect)) {
        if ([aID length] == 0)
            return;
        [[_renderersInfo objectForKey:aID] removeObjectForKey:@"HSWebCamValidityState"];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"HSWebCamValidityStateDidChangeNotification" object:aID userInfo:nil deliverImmediately:NO];
        [[HSWebCamDataProvider sharedWebCamDataProvider] validateClipForWebCam:aID];
        return;
    }

    NSDictionary *state = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], @"HSWebCamValidityState",
        [NSValue valueWithSize:aSize], WCDPPageSizeKey,
        [NSValue valueWithRect:aRect], WCDPClipRectKey,
        nil];
    NSMutableDictionary *info = [_renderersInfo objectForKey:aID];
    if (info != nil)
        [info addEntriesFromDictionary:state];
    else
        [_renderersInfo setObject:[NSMutableDictionary dictionaryWithDictionary:state] forKey:aID];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"HSWebCamValidityStateDidChangeNotification" object:aID userInfo:nil deliverImmediately:NO];
}

- (NSInteger)validityStateForWebCamWithID:(id)aID
{
    if ([aID length] != 0) {
        NSNumber *state = [[_renderersInfo objectForKey:aID] objectForKey:@"HSWebCamValidityState"];
        if (state != nil)
            return [state boolValue] ? 1 : 2;
    }
    return 0;
}

- (void)rendererDidLiveEnough:(id)aEnough
{
    [[[_renderersInfo objectForKey:[aEnough userInfo]] objectForKey:@"HSRegisteredRenderer"] stopLoading];
    NSInteger count = [_unregisterTimers count];
    NSInteger index;
    for (index = 0; index < count; index++) {
        NSTimer *timer = [_unregisterTimers objectAtIndex:index];
        if (timer == aEnough) {
            [[timer retain] autorelease];
            [_unregisterTimers removeObjectAtIndex:index];
            return;
        }
    }
}

- (void)cancelScheduledRemovalOfWebPageRendererForCamID:(id)aID
{
    NSInteger count = [_unregisterTimers count];
    NSInteger index;
    for (index = 0; index < count; index++) {
        NSTimer *timer = [_unregisterTimers objectAtIndex:index];
        if ([[timer userInfo] isEqualToString:aID]) {
            [timer invalidate];
            [_unregisterTimers removeObjectAtIndex:index];
            return;
        }
    }
}

- (void)scheduleRemovalOfWebPageRendererForCamID:(id)aID
{
    NSInteger count = [_unregisterTimers count];
    NSInteger index;
    for (index = 0; index < count; index++) {
        if ([[[_unregisterTimers objectAtIndex:index] userInfo] isEqualToString:aID])
            break;
    }
    if (index == count) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(rendererDidLiveEnough:) userInfo:aID repeats:NO];
        if (timer != nil)
            [_unregisterTimers addObject:timer];
    }
}

- (void)unregisterWebPageRenderer:(id)aRenderer user:(id)aUser
{
    if (aRenderer == nil)
        return;

    NSInteger rendererCount = [_renderersInfo count];
    NSInteger rendererIndex;
    for (rendererIndex = 0; rendererIndex < rendererCount; rendererIndex++) {
        NSDictionary *info = [[_renderersInfo allValues] objectAtIndex:rendererIndex];
        if ([info objectForKey:@"HSRegisteredRenderer"] != aRenderer)
            continue;

        NSMutableArray *users = [info objectForKey:@"HSRegisteredRendererUsers"];
        NSInteger userCount = [users count];
        NSInteger userIndex;
        for (userIndex = 0; userIndex < userCount; userIndex++) {
            NSDictionary *userInfo = [users objectAtIndex:userIndex];
            NSNumber *user = [userInfo objectForKey:@"HSRendererUser"];
            if (user != nil && HSWebCamRendererUserFromNumber(user) == aUser) {
                [[userInfo objectForKey:@"HSRendererUserRefreshRateTimer"] invalidate];
                [users removeObjectAtIndex:userIndex];
                [aUser unregisterWeakReferencer:self];
                userCount--;
                userIndex--;
            }
        }
        if (userCount == 0)
            [self scheduleRemovalOfWebPageRendererForCamID:[[_renderersInfo allKeys] objectAtIndex:rendererIndex]];
        return;
    }
}

- (void)rendererDidUpdate:(id)aUpdate
{
    id renderer = [aUpdate object];
    NSEnumerator *enumerator = [_renderersInfo objectEnumerator];
    NSMutableDictionary *info;
    while ((info = [enumerator nextObject]) != nil) {
        if ([info objectForKey:@"HSRegisteredRenderer"] == renderer) {
            [info setObject:[NSDate date] forKey:@"HSRendererLastUpdateDate"];
            return;
        }
    }
}

- (void)refreshOnTimer:(id)aTimer
{
    NSDictionary *userInfo = [aTimer userInfo];
    id user = HSWebCamRendererUserFromNumber([userInfo objectForKey:@"HSRendererUser"]);
    id camID = [userInfo objectForKey:@"WebCamID"];
    NSDate *lastUpdateDate = [[_renderersInfo objectForKey:camID] objectForKey:@"HSRendererLastUpdateDate"];
    NSTimeInterval lastUpdate = [lastUpdateDate timeIntervalSince1970];
    NSTimeInterval fireDate = [[aTimer fireDate] timeIntervalSince1970];
    NSTimeInterval interval = [aTimer timeInterval];

    if (lastUpdateDate == nil) {
        // Not loaded yet: check again shortly.
        [aTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
    } else if (lastUpdate > fireDate - interval) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSWebCamDidRefreshNotification" object:user userInfo:[NSDictionary dictionaryWithObject:camID forKey:@"WebCamID"]];
    }
}

- (void)reloadWebCamWithID:(id)aID
{
    if ([aID length] == 0)
        return;

    NSMutableDictionary *info = [_renderersInfo objectForKey:aID];
    HSWebPageRenderer *renderer = [info objectForKey:@"HSRegisteredRenderer"];
    [renderer reload];
    [info removeObjectForKey:@"HSRendererLastUpdateDate"];
    if (renderer != nil) {
        NSArray *users = [info objectForKey:@"HSRegisteredRendererUsers"];
        NSInteger count = [users count];
        NSInteger index;
        for (index = 0; index < count; index++)
            [[[users objectAtIndex:index] objectForKey:@"HSRendererUserRefreshRateTimer"] setFireDate:[NSDate date]];
    }
}

- (void)setNewRefreshRate:(CGFloat)aRate user:(id)aUser webPageRendererWithCamID:(id)aID
{
    if (aUser == nil || [aID length] == 0 || !(aRate > 0.0))
        return;

    NSDictionary *info = [_renderersInfo objectForKey:aID];
    HSWebPageRenderer *renderer = [info objectForKey:@"HSRegisteredRenderer"];
    if (renderer == nil)
        return;

    CGFloat currentRate = [renderer refreshRate];
    NSArray *users = [info objectForKey:@"HSRegisteredRendererUsers"];
    NSInteger count = [users count];
    NSInteger index;
    float minimumRate = 0.0f;
    for (index = 0; index < count; index++) {
        NSMutableDictionary *userInfo = [users objectAtIndex:index];
        NSTimer *timer = [userInfo objectForKey:@"HSRendererUserRefreshRateTimer"];
        NSNumber *user = [userInfo objectForKey:@"HSRendererUser"];
        if (user == nil)
            continue;
        if (HSWebCamRendererUserFromNumber(user) == aUser) {
            [timer invalidate];
            NSDictionary *timerInfo = [NSDictionary dictionaryWithObjectsAndKeys:aID, @"WebCamID", user, @"HSRendererUser", nil];
            timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:aRate target:self selector:@selector(refreshOnTimer:) userInfo:timerInfo repeats:YES];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
            [runLoop addTimer:timer forMode:NSModalPanelRunLoopMode];
            [userInfo setObject:[timer autorelease] forKey:@"HSRendererUserRefreshRateTimer"];
        }
        NSTimeInterval interval = [timer timeInterval];
        if (minimumRate == 0.0f || interval < minimumRate)
            minimumRate = interval;
    }
    if (minimumRate != (float)currentRate)
        [renderer setRefreshRate:minimumRate];
}

- (id)registeredWebPageRendererForCamID:(id)aID pageURL:(id)aURL pageSize:(NSSize)aSize refreshRate:(CGFloat)aRate user:(id)aUser
{
    if ([aID length] == 0 || aUser == nil)
        return nil;

    NSMutableDictionary *info = [_renderersInfo objectForKey:aID];
    HSWebPageRenderer *renderer = [info objectForKey:@"HSRegisteredRenderer"];
    if (info == nil) {
        info = [NSMutableDictionary dictionary];
        [_renderersInfo setObject:info forKey:aID];
    }

    if (renderer == nil) {
        NSURLRequest *request = aURL != nil ? [NSURLRequest requestWithURL:aURL] : nil;
        if (request != nil) {
            renderer = [[[HSWebPageRenderer alloc] initWithURLRequest:request pageSize:aSize refreshRate:aRate] autorelease];
            if (renderer != nil) {
                [renderer startLoading];
                [info setObject:renderer forKey:@"HSRegisteredRenderer"];
                [aUser registerWeakReferencer:self];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:HSWebCamRendererUserNumber(aUser) forKey:@"HSRendererUser"];
                [info setObject:[NSMutableArray arrayWithObject:userInfo] forKey:@"HSRegisteredRendererUsers"];
            }
        }
    } else {
        NSMutableArray *users = [info objectForKey:@"HSRegisteredRendererUsers"];
        if ([users count] == 0)
            [self cancelScheduledRemovalOfWebPageRendererForCamID:aID];
        [aUser registerWeakReferencer:self];
        [users addObject:[NSMutableDictionary dictionaryWithObject:HSWebCamRendererUserNumber(aUser) forKey:@"HSRendererUser"]];
        if ([renderer loadState] == 0)
            [renderer startLoading];
    }

    [self setNewRefreshRate:aRate user:aUser webPageRendererWithCamID:aID];
    return renderer;
}

- (id)init
{
    // Singleton: a second instance is thrown away in favor of the shared one.
    if (HSSharedWebCamRendererRegister != nil) {
        [self dealloc];
        return HSSharedWebCamRendererRegister;
    }

    self = [super init];
    HSSharedWebCamRendererRegister = self;
    if (self != nil) {
        _renderersInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        _unregisterTimers = [[NSMutableArray alloc] initWithCapacity:0];
        NSDistributedNotificationCenter *distributedCenter = [NSDistributedNotificationCenter defaultCenter];
        [distributedCenter addObserver:self selector:@selector(webCamClipInfoValidatingComplete:) name:@"WCDPWebCamIsValidNotification" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorHold];
        [distributedCenter addObserver:self selector:@selector(webCamClipInfoValidatingFailed:) name:@"WCDPWebCamIsInvalidNotification" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorHold];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rendererDidUpdate:) name:@"HSWebPageDidUpdateNotification" object:nil];
    }
    return self;
}

@end
