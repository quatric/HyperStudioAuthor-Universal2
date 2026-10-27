#import "HSPasteboardDataProvider.h"

@implementation HSPasteboardDataProvider
+ (id)mediaInfoPasteboardTypePrefix
{
    return @"HSMediaInfo_";
}
+ (id)mediaInfoPasteboardTypeForUID:(id)aUID
{
    if (!aUID)
        return @"";
    return [[self mediaInfoPasteboardTypePrefix] stringByAppendingString:aUID];
}
// (sic) Only a single text object gives a string.
- (id)arrtibutedStringForObject
{
    if (!_objectAttributedString && [_objects count] == 1) {
        id object = [[HSNode nodeWithDictionary:[_objects objectAtIndex:0]] queryHyperInterface:@protocol(HSObjectAttributes)];
        _objectAttributedString = [[(id<HSStringContentAttributes>)[object queryHyperInterface:@protocol(HSStringContentAttributes)] hyperAttributedStringValue] copy];
        if (!_objectAttributedString && [object respondsToSelector:@selector(serializedText)])
            _objectAttributedString = [[object performSelector:@selector(serializedText)] retain];
    }
    return _objectAttributedString;
}
// The text, or else the name of the first object.
- (id)stringForObject
{
    if (!_objectString) {
        if ([self arrtibutedStringForObject])
            _objectString = [[_objectAttributedString string] retain];
        else if ([_objects count])
            _objectString = [[[[HSNode nodeWithDictionary:[_objects objectAtIndex:0]] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName] retain];
    }
    return _objectString;
}
- (id)imageForObjects
{
    if (!_objectsImage && [_objects count]) {
        NSMutableArray *nodes = nil;
        id support = [HSLimitedConformedToProtocolProxy proxyWithObject:self];
        NSEnumerator *enumerator = [_objects objectEnumerator];
        id dictionary;
        while ((dictionary = [enumerator nextObject])) {
            HSNode *node = [HSNode nodeWithDictionary:dictionary];
            if (!node)
                continue;
            if (!nodes)
                nodes = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
            [node setSupport:support];
            [nodes addObject:node];
            id shadow = [node queryHyperInterface:@protocol(HSMutableShadowAttributes)];
            if (shadow)
                [shadow setHyperShadowEnabled:NO];
        }
        if ([nodes count])
            _objectsImage = [[HSUserObjectInPlayerPreviewView previewImageForObjects:nodes] retain];
        [nodes makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
        [nodes release];
    }
    return _objectsImage;
}
- (id)pathForCurrentObjectsTempImageFile
{
    if (!_tempFilePath) {
        NSData *data = [[self imageForObjects] hyperPNGRepresentation];
        [_tempFilePath release];
        _tempFilePath = [[self nextPathForTempImageFile] retain];
        [data writeToFile:_tempFilePath atomically:NO];
    }
    return _tempFilePath;
}
- (id)nextPathForTempImageFile
{
    return [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[_dragName stringByAppendingPathExtension:@"png"]];
}
- (id)pasteboardTypes
{
    NSMutableArray *types = [NSMutableArray new];
    if (_objects) {
        [types addObject:@"HSObjectsPasteboardType"];
        [types addObject:@"HSEditorPasteboardType"];
        [types addObject:NSFilenamesPboardType];
        if (![self arrtibutedStringForObject])
            [types addObject:NSTIFFPboardType];
        if ([_objects count] == 1) {
            [types addObject:NSStringPboardType];
            if ([self arrtibutedStringForObject])
                [types addObject:NSRTFPboardType];
        }
    }
    if (_cards) {
        [types addObject:@"HSCardPasteboardType"];
        if (_cardImage)
            [types addObject:NSTIFFPboardType];
    }
    NSEnumerator *enumerator = [_mediaUIDs objectEnumerator];
    id uid;
    while ((uid = [enumerator nextObject]))
        [types addObject:[[self class] mediaInfoPasteboardTypeForUID:[uid stringValue]]];
    return [types autorelease];
}
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    if ([aType isEqualToString:NSFilenamesPboardType]) {
        id list = [NSArray arrayWithObject:[self pathForCurrentObjectsTempImageFile]];
        if (list)
            [aPasteboard setPropertyList:list forType:aType];
    } else if ([aType isEqualToString:@"HSObjectsPasteboardType"]) {
        if (_objects)
            [aPasteboard setPropertyList:_objects forType:aType];
    } else if ([aType isEqualToString:@"HSCardPasteboardType"]) {
        id plist = [NSDictionary dictionaryWithObjectsAndKeys:_cards, @"HSSerializedCardsKey", [[_mediaUIDs allObjects] extraPlistRepresentation], @"HSSerializedCardsMediaUIDsKey", [[_groupUIDs allObjects] extraPlistRepresentation], @"HSSerializedGroupObjectsUIDsKey", [[_unrefreshingUIDs allObjects] extraPlistRepresentation], @"HSSerializedUnrefreshingUIDs", nil];
        if (plist)
            [aPasteboard setPropertyList:plist forType:aType];
    } else if ([aType isEqualToString:NSTIFFPboardType]) {
        NSData *data = _objects ? [[self imageForObjects] TIFFRepresentation] : nil;
        if (_cards && _cardImage)
            data = [_cardImage TIFFRepresentation];
        if (data)
            [aPasteboard setData:data forType:aType];
    } else if ([aType isEqualToString:NSStringPboardType]) {
        NSString *string = [self stringForObject];
        if (string)
            [aPasteboard setString:string forType:aType];
    } else if ([aType isEqualToString:NSRTFPboardType]) {
        NSAttributedString *string = [self arrtibutedStringForObject];
        NSData *data = [string RTFFromRange:NSMakeRange(0, [string length]) documentAttributes:@{}];
        if (data)
            [aPasteboard setData:data forType:aType];
    } else if ([aType isEqualToString:@"HSEditorPasteboardType"]) {
        // The editor type only marks the pasteboard.
        [aPasteboard setString:[NSString string] forType:aType];
    } else {
        NSString *prefix = [[self class] mediaInfoPasteboardTypePrefix];
        if (![aType hasPrefix:prefix])
            return;
        NSUInteger prefixLength = [[[self class] mediaInfoPasteboardTypePrefix] length];
        if ([aType length] <= prefixLength)
            return;
        NSString *uid = [aType substringFromIndex:prefixLength];
        if (!uid)
            return;
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[HSUID UIDWithString:uid]];
        if (!media)
            return;
        id plist = [media dictionaryRepresentation];
        if (plist)
            [aPasteboard setPropertyList:plist forType:aType];
    }
}
- (void)removeTypesFromPasteboard:(id)aPasteboard
{
    [aPasteboard declareTypes:[self pasteboardTypes] owner:nil];
}
- (BOOL)declareTypesForPasteboard:(id)aPasteboard
{
    [aPasteboard declareTypes:[self pasteboardTypes] owner:self];
    return YES;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_tempFilePath)
        [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:NULL];
    [_tempFilePath release];
    [_objects release];
    [_cards release];
    [_cardImage release];
    [_mediaUIDs release];
    [_objectsImage release];
    [_objectString release];
    [_objectAttributedString release];
    [_groupUIDs release];
    [_unrefreshingUIDs release];
    [_medias release];
    [_dragName release];
    [super dealloc];
}
- (id)initWithCards:(id)aCards UIDs:(id)aDs groupUIDs:(id)aDs2 unrefreshingUIDs:(id)aDs3 cardImage:(id)aImage
{
    self = [self initWithCards:aCards UIDs:aDs groupUIDs:aDs2 cardImage:aImage];
    if (self)
        _unrefreshingUIDs = [aDs3 retain];
    return self;
}
- (id)initWithCards:(id)aCards UIDs:(id)aDs groupUIDs:(id)aDs2 cardImage:(id)aImage
{
    self = [self initWithCards:aCards UIDs:aDs cardImage:aImage];
    if (self)
        _groupUIDs = [aDs2 retain];
    return self;
}
- (id)initWithCards:(id)aCards UIDs:(id)aDs cardImage:(id)aImage
{
    self = [self initWithMediaUIDs:aDs];
    if (self) {
        _cards = [aCards retain];
        _cardImage = [aImage retain];
    }
    return self;
}
- (id)initWithObjects:(id)aObjects UIDs:(id)aDs groupUIDs:(id)aDs2 unrefreshingUIDs:(id)aDs3 dragName:(id)aName
{
    self = [self initWithObjects:aObjects UIDs:aDs groupUIDs:aDs2 dragName:aName];
    if (self)
        _unrefreshingUIDs = [aDs3 retain];
    return self;
}
- (id)initWithObjects:(id)aObjects UIDs:(id)aDs groupUIDs:(id)aDs2 dragName:(id)aName
{
    self = [self initWithObjects:aObjects UIDs:aDs dragName:aName];
    if (self)
        _groupUIDs = [aDs2 retain];
    return self;
}
// Objects need a drag name (it names the temporary image file).
- (id)initWithObjects:(id)aObjects UIDs:(id)aDs dragName:(id)aName
{
    self = [self initWithMediaUIDs:aDs];
    if (self) {
        _objects = [aObjects copy];
        if (!aName) {
            [self release];
            return nil;
        }
        _dragName = [aName copy];
    }
    return self;
}
- (id)initWithMediaUIDs:(id)aDs
{
    self = [super init];
    if (self) {
        _mediaUIDs = [aDs mutableCopy];
        _medias = [[NSMutableArray alloc] initWithCapacity:[aDs count]];
        NSEnumerator *enumerator = [_mediaUIDs objectEnumerator];
        id uid;
        while ((uid = [enumerator nextObject])) {
            id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
            // The original added unchecked; a missing media would raise.
            if (media)
                [_medias addObject:media];
        }
    }
    return self;
}
@end
