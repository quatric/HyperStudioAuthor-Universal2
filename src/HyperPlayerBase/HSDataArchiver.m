#import "HSDataArchiver.h"
// Compresses data with one of several archivers, keyed by their class's
// methodKey; the simple archiver is there and selected by default.
@implementation HSDataArchiver
- (id)uncompressData:(id)aData
{
    return [[_archivers objectForKey:_currentMethodKey] uncompressData:aData];
}
- (id)compressData:(id)aData
{
    return [[_archivers objectForKey:_currentMethodKey] compressData:aData];
}
- (id)description
{
    return [[_archivers objectForKey:_currentMethodKey] description];
}
- (id)archivingMethod
{
    return [[_archivers objectForKey:_currentMethodKey] archivingMethod];
}
// Only keys of added archivers can be selected.
- (void)selectMethodWithKey:(id)aKey
{
    if (_currentMethodKey == aKey || [_archivers objectForKey:aKey] == nil)
        return;
    [_currentMethodKey release];
    _currentMethodKey = [aKey retain];
}
- (id)currentMethodKey
{
    return _currentMethodKey;
}
// The first archiver for a key stays.
- (void)addArchiver:(id)aArchiver
{
    id key = [[aArchiver class] methodKey];
    if ([_archivers objectForKey:key] == nil)
        [_archivers setObject:aArchiver forKey:key];
}
- (id)methodKeyEnumerator
{
    return [_archivers keyEnumerator];
}
- (id)archivingMethodKeys
{
    return [_archivers allKeys];
}
- (void)dealloc
{
    [_archivers release];
    [_currentMethodKey release];
    [super dealloc];
}
// The original doesn't retain the default method key (it's a constant
// string, so that's harmless); retained here to balance dealloc.
- (id)init
{
    self = [super init];
    if (self != nil) {
        _archivers = [NSMutableDictionary new];
        [_archivers setObject:[[HSSimpleArchiver new] autorelease] forKey:[HSSimpleArchiver methodKey]];
        _currentMethodKey = [[HSSimpleArchiver methodKey] retain];
    }
    return self;
}
@end
