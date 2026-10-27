#import "HSiPadExportContext.h"
// State shared while exporting a stack for the iPad player: media by
// object, UID and path, converted media and group prototypes.
@implementation HSiPadExportContext
- (void)setPrototypeObjectUID:(id)aUID forGroupUID:(id)aUID2
{
    if (_prototypeUIDMap == nil)
        _prototypeUIDMap = [NSMutableDictionary new];
    [_prototypeUIDMap setObject:aUID forKey:aUID2];
}
- (id)prototypeObjectUIDForGroupUID:(id)aUID
{
    return [_prototypeUIDMap objectForKey:aUID];
}
- (void)setConvertedMedia:(id)aMedia forKey:(id)aKey
{
    if (_convertedMediaMap == nil)
        _convertedMediaMap = [NSMutableDictionary new];
    [_convertedMediaMap setObject:aMedia forKey:aKey];
}
- (id)convertedMediaForKey:(id)aKey
{
    return [_convertedMediaMap objectForKey:aKey];
}
// Objects are retained keys of a CF dictionary (not copied).
- (void)setMedia:(id)aMedia forObject:(id)aObject andUID:(id)aUID
{
    if (_uidToObjectsMap == nil)
        _uidToObjectsMap = [NSMutableDictionary new];
    if (_objectToMediaMap == NULL)
        _objectToMediaMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    NSMutableArray *objects = [_uidToObjectsMap objectForKey:aUID];
    if (objects == nil) {
        objects = [NSMutableArray array];
        [_uidToObjectsMap setObject:objects forKey:aUID];
    }
    [objects addObject:aObject];
    CFDictionarySetValue(_objectToMediaMap, aObject, aMedia);
}
- (id)iPadMediaForImageObject:(id)aObject
{
    return (id)CFDictionaryGetValue(_objectToMediaMap, aObject);
}
- (id)imageObjectsForMediaUID:(id)aUID
{
    return [_uidToObjectsMap objectForKey:aUID];
}
- (void)setPathMedia:(id)aMedia forData:(id)aData
{
    if (_pathDataToMediaMap == nil)
        _pathDataToMediaMap = [NSMutableDictionary new];
    [_pathDataToMediaMap setObject:aMedia forKey:aData];
}
- (id)mediaForPathData:(id)aData
{
    return [_pathDataToMediaMap objectForKey:aData];
}
- (void)setShouldTerminateExport:(BOOL)aExport
{
    _shouldTerminateExport = aExport;
}
- (id)mediaArray
{
    return [[_mediaArray copy] autorelease];
}
- (void)addMedia:(id)aMedia
{
    if (_mediaArray == nil)
        _mediaArray = [NSMutableArray new];
    [_mediaArray addObject:aMedia];
}
// Handles the pending events first (so a Cancel button can be pressed).
- (BOOL)shouldTerminateExport
{
    NSEvent *event;
    while ((event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSEventTrackingRunLoopMode dequeue:YES]) != nil)
        [NSApp sendEvent:event];
    return _shouldTerminateExport;
}
- (void)dealloc
{
    [_uidToObjectsMap release];
    if (_objectToMediaMap != NULL)
        CFRelease(_objectToMediaMap);
    [_pathDataToMediaMap release];
    [_convertedMediaMap release];
    [_prototypeUIDMap release];
    [_mediaArray release];
    [super dealloc];
}
- (id)document
{
    return _document;
}
- (id)initWithDocument:(id)aDocument
{
    self = [super init];
    if (self != nil)
        _document = aDocument;
    return self;
}
@end
