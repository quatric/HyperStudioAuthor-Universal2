#import "HSCursorSynchronizer.h"
#import "HSMediaFileWrapper.h"
#import "NSMutableDictionary+EXExtensions.h"

static HSCursorSynchronizer *sSharedSynchronizer = nil;
static NSInteger sHideCount = 0;
static HSCursor *sDefaultCursor = nil;
static HSCursor *sTextCursor = nil;
static HSCursor *sActionCursor = nil;
static HSCursor *sDraggableCursor = nil;
static HSCursor *sDraggingCursor = nil;
static HSCursor *sDisappearingCursor = nil;
static HSCursor *sMicrophoneCursor = nil;
static NSMutableDictionary *sRegisteredCursorsByName = nil;
static NSDictionary *sCursorsDescription = nil;

@implementation HSCursorSynchronizer

+ (id)sharedInstance
{
    if (sSharedSynchronizer == nil)
        sSharedSynchronizer = [[self alloc] init];
    return sSharedSynchronizer;
}

- (void)clearCursor
{
    [[NSCursor arrowCursor] set];
}

- (void)resetCursor
{
    [(NSCursor *)[_currentCursor cursor] set];
}

- (void)setCursor:(id)aCursor
{
    if (_currentCursor != aCursor) {
        [_currentCursor autorelease];
        _currentCursor = [aCursor retain];
    }
    if ([_currentCursor cursor] != [NSCursor currentCursor])
        [(NSCursor *)[_currentCursor cursor] set];
}

- (void)dealloc
{
    if (sSharedSynchronizer == self)
        sSharedSynchronizer = nil;
    [_currentCursor release];
    [super dealloc];
}

- (id)init
{
    if (sSharedSynchronizer == nil) {
        sSharedSynchronizer = [super init];
    } else {
        [super dealloc];
    }
    return sSharedSynchronizer;
}

@end

@implementation HSCursor

+ (id)cursorNamed:(id)aNamed
{
    HSCursor *cursor = [[self registeredCursorsByName] objectForKey:aNamed];
    if (cursor == nil) {
        cursor = [self loadedCursorWithName:aNamed];
        if (cursor != nil) {
            [cursor setName:aNamed];
            [[self registeredCursorsByName] setObject:cursor forKey:aNamed];
        }
    }
    return cursor;
}

+ (id)loadedCursorWithName:(id)aName
{
    if ([aName isEqualToString:@"HSDefaultCursor"])
        return [self defaultCursor];
    if ([aName isEqualToString:@"HSIBeamCursor"])
        return [self textCursor];
    if ([aName isEqualToString:@"HSPointingHandCursor"])
        return [self actionCursor];
    NSDictionary *description = [[self cursorsDescription] objectForKey:aName];
    if (description == nil)
        return nil;
    NSPoint hotSpot = NSPointFromString([description objectForKey:@"hotSpot"]);
    NSString *fileName = [description objectForKey:@"CursorImageFileName"];
    if (fileName == nil)
        return nil;
    NSImage *image = [NSImage imageNamed:fileName];
    if (image == nil)
        return nil;
    return [[[HSCursor alloc] initWithImage:image hotSpot:hotSpot] autorelease];
}

+ (id)cursorsDescription
{
    if (sCursorsDescription == nil) {
        sCursorsDescription = [[NSDictionary extraDictionaryNamed:@"CursorTypes.plist"] retain];
        if (sCursorsDescription == nil)
            sCursorsDescription = [NSDictionary new];
    }
    return sCursorsDescription;
}

+ (id)registeredCursorsByName
{
    if (sRegisteredCursorsByName == nil)
        sRegisteredCursorsByName = [NSMutableDictionary new];
    return sRegisteredCursorsByName;
}

static HSCursor *HSCursorWithBundleImage(Class cls, NSString *name, NSPoint hotSpot)
{
    NSString *path = [[NSBundle bundleForClass:[cls class]] pathForResource:name ofType:@"tiff"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
    HSCursor *cursor = [[HSCursor alloc] initWithImage:image hotSpot:hotSpot];
    [cursor setImageMedia:[HSNewMedia mediaWithImage:[cursor image]]];
    [image release];
    return cursor;
}

static HSCursor *HSCursorWithSystemCursor(NSCursor *systemCursor)
{
    HSCursor *cursor = [[HSCursor alloc] initWithCursor:systemCursor];
    [cursor setImageMedia:[HSNewMedia mediaWithImage:[cursor image]]];
    return cursor;
}

+ (id)microphoneCursor
{
    if (sMicrophoneCursor == nil)
        sMicrophoneCursor = HSCursorWithBundleImage(self, @"cur_Microphone", NSMakePoint(7.0, 5.0));
    return sMicrophoneCursor;
}

+ (id)disappearingCursor
{
    if (sDisappearingCursor == nil)
        sDisappearingCursor = HSCursorWithSystemCursor([NSCursor disappearingItemCursor]);
    return sDisappearingCursor;
}

+ (id)draggingCursor
{
    if (sDraggingCursor == nil)
        sDraggingCursor = HSCursorWithSystemCursor([NSCursor closedHandCursor]);
    return sDraggingCursor;
}

+ (id)draggableCursor
{
    if (sDraggableCursor == nil)
        sDraggableCursor = HSCursorWithSystemCursor([NSCursor openHandCursor]);
    return sDraggableCursor;
}

+ (id)actionCursor
{
    if (sActionCursor == nil)
        sActionCursor = HSCursorWithBundleImage(self, @"cur_PointingFinger", NSMakePoint(12.0, 6.0));
    return sActionCursor;
}

+ (id)textCursor
{
    if (sTextCursor == nil)
        sTextCursor = HSCursorWithSystemCursor([NSCursor IBeamCursor]);
    return sTextCursor;
}

+ (id)defaultPlayerCursor
{
    return [HSCursor actionCursor];
}

+ (id)defaultCursor
{
    if (sDefaultCursor == nil)
        sDefaultCursor = HSCursorWithSystemCursor([NSCursor arrowCursor]);
    return sDefaultCursor;
}

// Animated cursors are not supported: only the first frame is used.
+ (id)cursorWithFrames:(id)aFrames changeDelays:(id)aDelays hotSpot:(NSPoint)aSpot
{
    if ([aFrames count] == 0)
        return nil;
    return [[[HSCursor alloc] initWithImage:[aFrames objectAtIndex:0] hotSpot:aSpot] autorelease];
}

+ (BOOL)isHidden
{
    return sHideCount != 0;
}

+ (void)unhideCursorIfNeeded
{
    for (; sHideCount != 0; sHideCount--)
        [NSCursor unhide];
}

+ (void)hideCursorIfNeeded
{
    [NSCursor hide];
    sHideCount++;
}

+ (void)clearCursor
{
    [[HSCursorSynchronizer sharedInstance] clearCursor];
}

+ (void)resetCursor
{
    [[HSCursorSynchronizer sharedInstance] resetCursor];
}

- (void)setCursor:(id)aCursor
{
    if (_cursor != aCursor) {
        [_cursor autorelease];
        _cursor = [aCursor retain];
    }
}

- (id)cursor
{
    return _cursor;
}

- (void)setImageMedia:(id)aMedia
{
    if (![_imageMedia isEqual:aMedia]) {
        [_imageMedia release];
        _imageMedia = [aMedia retain];
    }
}

- (id)imageMedia
{
    return _imageMedia;
}

- (void)setName:(id)aName
{
    [_name autorelease];
    _name = [aName retain];
}

- (id)name
{
    return _name;
}

- (void)set
{
    [[HSCursorSynchronizer sharedInstance] setCursor:self];
}

- (NSPoint)hotSpot
{
    return [[self cursor] hotSpot];
}

- (id)image
{
    return [[self cursor] image];
}

- (void)setImage:(id)aImage hotSpot:(NSPoint)aSpot
{
    if ([[self cursor] image] == aImage && NSEqualPoints([_cursor hotSpot], aSpot))
        return;
    [_cursor release];
    _cursor = [[NSCursor alloc] initWithImage:aImage hotSpot:aSpot];
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[HSCursor class]])
        return NO;
    if (![_cursor isEqual:[aEqual cursor]])
        return NO;
    return [_name isEqualToString:[(HSCursor *)aEqual name]];
}

- (void)dealloc
{
    [_cursor release];
    [_name release];
    [_imageMedia release];
    [super dealloc];
}

- (id)initWithCursor:(id)aCursor
{
    self = [super init];
    if (self != nil)
        _cursor = [aCursor retain];
    return self;
}

- (id)initWithImage:(id)aImage hotSpot:(NSPoint)aSpot
{
    self = [super init];
    if (self != nil)
        _cursor = [[NSCursor alloc] initWithImage:aImage hotSpot:aSpot];
    return self;
}

@end
