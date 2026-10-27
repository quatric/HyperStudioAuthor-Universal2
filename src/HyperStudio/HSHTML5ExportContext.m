#import "HSHTML5ExportContext.h"

@implementation HSHTML5ExportContext

- (id)shapeNameForGroupUID:(id)aUID
{
    id uid = [_groupUIDs objectForKey:aUID];
    return uid ? [_shapeUIDs objectForKey:uid] : nil;
}

// Maps the group to a fresh UID; the name is stored under the group UID itself.
- (void)addGroupUID:(id)aUID withShapeName:(id)aName
{
    id uid = [HSUID UID];
    if (uid) {
        if (!_groupUIDs)
            _groupUIDs = [NSMutableDictionary new];
        [_groupUIDs setObject:uid forKey:aUID];
        if (!_shapeUIDs)
            _shapeUIDs = [NSMutableDictionary new];
        [_shapeUIDs setObject:aName forKey:aUID];
    }
}

- (id)mediaNameForUID:(id)aUID
{
    return [_mediaUIDs objectForKey:aUID];
}

- (void)addUID:(id)aUID withMediaName:(id)aName
{
    if (!_mediaUIDs)
        _mediaUIDs = [NSMutableDictionary new];
    [_mediaUIDs setObject:aName forKey:aUID];
}

- (id)mediaNameForGroupUID:(id)aUID
{
    id uid = [_groupUIDs objectForKey:aUID];
    return uid ? [_mediaUIDs objectForKey:uid] : nil;
}

- (void)addGroupUID:(id)aUID withMediaName:(id)aName
{
    id uid = [HSUID UID];
    if (uid) {
        if (!_groupUIDs)
            _groupUIDs = [NSMutableDictionary new];
        [_groupUIDs setObject:uid forKey:aUID];
        if (!_mediaUIDs)
            _mediaUIDs = [NSMutableDictionary new];
        [_mediaUIDs setObject:aName forKey:uid];
    }
}

- (id)linkedStackURLs
{
    return [_currentLinkedStacks allObjects];
}

- (void)addLinkedStackURL:(id)aURL
{
    if (aURL) {
        if (!_currentLinkedStacks)
            _currentLinkedStacks = [NSMutableSet new];
        [_currentLinkedStacks addObject:aURL];
        [_linkedStacksContext addLinkedStackURL:aURL];
    }
}

- (BOOL)shouldAddLinkedStacks
{
    return [_linkedStacksContext shouldAddLinkedStacks];
}

- (BOOL)isRootStackURL:(id)aURL
{
    return [_linkedStacksContext isRootStackURL:aURL];
}

- (id)nameForLinkedStackURL:(id)aURL
{
    return [_linkedStacksContext nameForLinkedStackURL:aURL];
}

- (void)setShouldTerminateExport:(BOOL)aExport
{
    _shouldTerminateExport = aExport;
}

// Drains the pending events first so the user can cancel from the UI.
- (BOOL)shouldTerminateExport
{
    NSEvent *event;
    while ((event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES]))
        [NSApp sendEvent:event];
    return _shouldTerminateExport;
}

- (id)linkedStacksContext
{
    return _linkedStacksContext;
}

- (id)documentType
{
    return _documentType;
}

- (void)dealloc
{
    [_documentType release];
    [_currentLinkedStacks release];
    [_groupUIDs release];
    [_mediaUIDs release];
    [_shapeUIDs release];
    [_linkedStacksContext release];
    [super dealloc];
}

- (id)initWithDocument:(id)aDocument ofType:(id)aType linkedStacksContext:(id)aContext
{
    self = [super initWithDocument:aDocument];
    if (self) {
        _documentType = [aType copy];
        _linkedStacksContext = [aContext retain];
    }
    return self;
}

@end
