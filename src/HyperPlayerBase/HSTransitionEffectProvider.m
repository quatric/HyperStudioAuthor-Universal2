#import "HSTransitionEffectProvider.h"
// The card transition effects: "No Transition" plus the Quartz Composer
// (.qtz) and QuickTime effect (.qfx) files in the Transitions folder of
// the player base bundle, sorted by display name with "No Transition"
// first. Thumbnails of slow effects get a badge.

// Sorts by display name, with "No Transition" first.
static NSInteger HSTransitionEffectProviderCompareNames(id aName1, id aName2, void *aContext)
{
    HSTransitionEffectProvider *provider = aContext;
    NSString *displayName1 = [provider displayNameForTransitionEffectWithName:aName1];
    if (!displayName1)
        return NSOrderedSame;
    NSString *displayName2 = [provider displayNameForTransitionEffectWithName:aName2];
    if (!displayName2)
        return NSOrderedSame;
    NSComparisonResult result = [displayName1 compare:displayName2];
    if (result == NSOrderedSame)
        return result;
    NSString *noTransition = [provider displayNameForTransitionEffectWithName:@"No Transition"];
    if (!noTransition)
        return result;
    if ([displayName1 isEqualToString:noTransition])
        return NSOrderedAscending;
    if ([displayName2 isEqualToString:noTransition])
        return NSOrderedDescending;
    return result;
}

@implementation HSTransitionEffectProvider

// Exported stacks name transitions without spaces; the unsupported ones
// become a fade.
+ (id)exportTransitionNameForTransitionName:(id)aName
{
    if ([[self unsupportedTransitionEffectNames] containsObject:aName])
        return @"Fade";
    NSMutableString *name = [aName mutableCopy];
    [name replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, [name length])];
    return [name autorelease];
}

+ (id)unsupportedTransitionEffectNames
{
    static NSArray *names = nil;
    if (!names)
        names = [[NSArray alloc] initWithObjects:@"Explode", @"Implode Circle", @"Ripple", @"LiquidImage", @"Twirl", nil];
    return names;
}

+ (id)sharedTransitionEffectProvider
{
    static HSTransitionEffectProvider *provider = nil;
    if (!provider)
        provider = [[HSTransitionEffectProvider alloc] init];
    return provider;
}

// A slow effect's thumbnail gets the badge in its lower left corner (the
// thumbnail is drawn unflipped, so at the top).
- (id)thumbnailForTransitionEffectWithName:(id)aName
{
    NSImage *thumbnail = [_transitionEffectThumbnails objectForKey:aName];
    if (thumbnail)
        return thumbnail;
    NSString *path = [[HSPlayerBaseID bundle] pathForResource:aName ofType:@"png" inDirectory:@"TransitionThumbnails"];
    if (!path)
        return nil;
    thumbnail = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
    if (!thumbnail)
        return nil;
    if ([[self HSTransitionEffectProvider_transitionEffectWithName:aName] isSlow] && [self HSTransitionEffectProvider_slowBadgeImage]) {
        [thumbnail lockFocus];
        [_slowBadgeImage drawAtPoint:NSMakePoint(0, [thumbnail size].height - [_slowBadgeImage size].height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1];
        [thumbnail unlockFocus];
    }
    if (!_transitionEffectThumbnails)
        _transitionEffectThumbnails = [[NSMutableDictionary alloc] init];
    [_transitionEffectThumbnails setObject:thumbnail forKey:aName];
    return thumbnail;
}

- (id)HSTransitionEffectProvider_slowBadgeImage
{
    if (!_slowBadgeImage) {
        NSString *path = [[HSPlayerBaseID bundle] pathForResource:@"SlowBage" ofType:@"png" inDirectory:nil];
        if (path)
            _slowBadgeImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return _slowBadgeImage;
}

- (id)displayNameForTransitionEffectWithName:(id)aName
{
    return [[HSPlayerBaseID bundle] localizedStringForKey:aName value:@"" table:@"TransitionNames"];
}

- (id)transitionEffectWithName:(id)aName
{
    return [self HSTransitionEffectProvider_transitionEffectWithName:aName];
}

- (id)HSTransitionEffectProvider_transitionEffectWithName:(id)aName
{
    [self HSTransitionEffectProvider_collectTransitionEffectsIfNeeded];
    return [_transitionEffects objectForKey:aName];
}

- (id)transitionEffectNames
{
    [self HSTransitionEffectProvider_collectTransitionEffectsIfNeeded];
    return _transitionEffectNames;
}

// The swapped names are only needed while collecting.
- (void)HSTransitionEffectProvider_collectTransitionEffectsIfNeeded
{
    if (_transitionEffectNames)
        return;
    // (The original leaks the dictionary of an earlier failed attempt.)
    [_transitionEffects release];
    _transitionEffects = [[NSMutableDictionary alloc] init];
    if (!_transitionEffects)
        return;
    NSMutableArray *names = [NSMutableArray array];
    if (!names)
        return;
    [self HSTransitionEffectProvider_appendNoTransitionEffectNameToArray:names];
    [self HSTransitionEffectProvider_appendBundledTransitionEffectNamesToArray:names];
    _transitionEffectNames = [[names sortedArrayUsingFunction:HSTransitionEffectProviderCompareNames context:self] retain];
    if (!_transitionEffectNames) {
        [_transitionEffects release];
        _transitionEffects = nil;
    } else {
        [_swappedTransitionEffectNames release];
        _swappedTransitionEffectNames = nil;
    }
}

// Top-level files of the Transitions folder only. A file that fails to
// load ends the scan, as in the original.
- (void)HSTransitionEffectProvider_appendBundledTransitionEffectNamesToArray:(id)aArray
{
    NSString *folder = [[HSPlayerBaseID bundle] pathForResource:@"Transitions" ofType:nil];
    if (!folder)
        return;
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:folder];
    NSString *file;
    while ((file = [enumerator nextObject])) {
        [enumerator skipDescendents];
        id effect;
        NSString *name;
        if ([[file pathExtension] isEqualToString:@"qtz"]) {
            name = [file stringByDeletingPathExtension];
            NSString *path = [folder stringByAppendingPathComponent:file];
            if (!name || !path)
                return;
            id composition = [HSQCGraphicComposition compositionWithCompositionFilePath:path];
            if (!composition)
                return;
            effect = [[HSGraphicCompositionTransitionEffect alloc] initWithGraphicComposition:composition];
        } else if ([[file pathExtension] isEqualToString:@"qfx"]) {
            name = [file stringByDeletingPathExtension];
            NSString *path = [folder stringByAppendingPathComponent:file];
            if (!name || !path)
                return;
            BOOL swapped = [[self HSTransitionEffectProvider_swappedTransitionEffectNames] containsObject:name];
            effect = [[HSQTTransitionEffect alloc] initWithEffectFilePath:path swappedInputs:swapped];
        } else
            continue;
        if (!effect)
            return;
        [_transitionEffects setObject:effect forKey:name];
        [effect release];
        [aArray addObject:name];
    }
}

- (void)HSTransitionEffectProvider_appendNoTransitionEffectNameToArray:(id)aArray
{
    HSTransitionEffect *effect = [[HSTransitionEffect alloc] init];
    if (!effect)
        return;
    [_transitionEffects setObject:effect forKey:@"No Transition"];
    [effect release];
    [aArray addObject:@"No Transition"];
}

// QuickTime effects whose two inputs are the other way around.
- (id)HSTransitionEffectProvider_swappedTransitionEffectNames
{
    if (!_swappedTransitionEffectNames) {
        NSString *path = [[HSPlayerBaseID bundle] pathForResource:@"SwappedTransitions" ofType:@"plist"];
        if (path) {
            NSArray *names = [[NSArray alloc] initWithContentsOfFile:path];
            if (names) {
                _swappedTransitionEffectNames = [[NSSet alloc] initWithArray:names];
                [names release];
            }
        }
    }
    return _swappedTransitionEffectNames;
}

- (void)dealloc
{
    [_swappedTransitionEffectNames release];
    [_transitionEffectThumbnails release];
    [_slowBadgeImage release];
    [_transitionEffects release];
    [_transitionEffectNames release];
    [super dealloc];
}

@end
