#import "HSAnimationSnapshot.h"
// An animation's state (structure, options, position on the path and
// fixation), to put back later.
@implementation HSAnimationSnapshot
+ (id)snapshotWithStructure:(id)aStructure options:(id)aOptions pathTime:(double)aTime fixation:(id)aFixation
{
    return [[[self alloc] initWithStructure:aStructure options:aOptions pathTime:aTime fixation:aFixation] autorelease];
}
- (id)fixation
{
    return _fixation;
}
- (double)pathTime
{
    return _pathTime;
}
- (id)options
{
    return _options;
}
- (id)structure
{
    return _structure;
}
- (void)dealloc
{
    [_fixation release];
    [_options release];
    [_structure release];
    [super dealloc];
}
- (id)initWithStructure:(id)aStructure options:(id)aOptions pathTime:(double)aTime fixation:(id)aFixation
{
    self = [super init];
    if (self != nil) {
        _structure = [aStructure copyWithZone:NULL];
        _options = [aOptions copyWithZone:NULL];
        _pathTime = aTime;
        _fixation = [aFixation copyWithZone:NULL];
    }
    return self;
}
@end

@implementation HSAnimation (Snapshot)
- (void)replaceWithSnapshot:(id)aSnapshot
{
    [self stop];
    [self setStructure:[(HSAnimationSnapshot *)aSnapshot structure]];
    [self setOptions:[(HSAnimationSnapshot *)aSnapshot options]];
    [self setPathTime:[aSnapshot pathTime]];
    [[self positioning] replaceFixationWith:[aSnapshot fixation]];
    [[self positioning] updateObject];
}
- (id)makeSnapshot
{
    return [HSAnimationSnapshot snapshotWithStructure:[self structure] options:[self options] pathTime:[self pathTime]
                                             fixation:[[self positioning] fixation]];
}
@end
