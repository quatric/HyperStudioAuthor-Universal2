#import "HSCustomButtonsSharedProvider.h"
#import "HSButtonObject.h"
#import "HSGenericNodeSupport.h"
#import "HSMediaFileRepresentation.h"
#import "HSMediaFileWrapper.h"
#import "HSUID.h"

// Buttons in the ordered list come first, in its order; the rest follow by
// name.
static NSInteger HSCustomButtonsSort(id aButton1, id aButton2, void *aOrderedList)
{
    NSArray *orderedList = (NSArray *)aOrderedList;
    NSUInteger index1 = [orderedList indexOfObject:[aButton1 hyperCustomButtonName]];
    NSUInteger index2 = [orderedList indexOfObject:[aButton2 hyperCustomButtonName]];
    if (index1 == NSNotFound && index2 == NSNotFound)
        return [aButton1 compareIncrease:aButton2];
    if (index1 == NSNotFound)
        return NSOrderedDescending;
    if (index2 == NSNotFound)
        return NSOrderedAscending;
    if (index1 == index2)
        return NSOrderedSame;
    return index1 < index2 ? NSOrderedAscending : NSOrderedDescending;
}

// The custom button images in the bundle's resources, with their settings
// and textured backgrounds (three or nine parts).
@implementation HSCustomButtonsSharedProvider

+ (id)customButtonsFolderName
{
    return @"CustomButtons";
}

+ (id)resourcesPath
{
    return [[NSBundle bundleForClass:[self class]] resourcePath];
}

+ (id)sharedCustomButtonsProvider
{
    static id sharedProvider = nil;
    if (sharedProvider == nil)
        sharedProvider = [[self class] new];
    return sharedProvider;
}

// The nine-part image first, then the three-part one.
- (id)texturedBackgroundImageForType:(NSInteger)aType prefix:(id)aPrefix atPath:(id)aPath
{
    id image = nil;
    for (int attempt = 1; image == nil && attempt <= 2; attempt++) {
        id suffix = [self texturedBackgroundImageSuffixForType:aType nineParts:attempt == 1];
        if (suffix != nil) {
            NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", aPrefix, suffix];
            image = [NSImage hyperImageWithContentsOfFile:[aPath stringByAppendingPathComponent:fileName]];
        }
    }
    return image;
}

// Types 0-8 are the nine parts row by row from the top; three-part images
// only have 3-5 (the middle row).
- (id)texturedBackgroundImageSuffixForType:(NSInteger)aType nineParts:(BOOL)aParts
{
    if (aParts) {
        switch (aType) {
            case 0: return @"left_top";
            case 1: return @"middle_top";
            case 2: return @"right_top";
            case 3: return @"left_middle";
            case 4: return @"middle";
            case 5: return @"right_middle";
            case 6: return @"left_bottom";
            case 7: return @"middle_bottom";
            case 8: return @"right_bottom";
            default: return nil;
        }
    }
    switch (aType) {
        case 3: return @"left";
        case 4: return @"middle";
        case 5: return @"right";
        default: return nil;
    }
}

// 129 points wide and as tall as the middle column's parts together.
- (NSSize)sizeForCustomButtonWithTexturedBackground:(id)aBackground
{
    id imageParts = [[self backgroundSettingsForButtonWithMediaUID:[[aBackground media] mediaUID]] objectForKey:@"imageParts"];
    id parts[3];
    parts[0] = [imageParts objectForKey:[NSNumber numberWithInt:1]];
    parts[1] = [imageParts objectForKey:[NSNumber numberWithInt:4]];
    parts[2] = [imageParts objectForKey:[NSNumber numberWithInt:7]];
    float height = 0;
    for (int i = 0; i < 3; i++)
        if (parts[i] != nil)
            height += [(NSImage *)parts[i] size].height;
    float magnitude = height != 0 ? fabsf(height) : 1;
    float tolerance = magnitude >= 1 ? magnitude * 0.0005f : 0.0005f;
    if (fabsf(height) <= tolerance)
        return NSZeroSize;
    return NSMakeSize(129, height);
}

- (id)backgroundSettingsForButtonWithMediaUID:(id)aUID
{
    return [[self backgroundSettings] objectForKey:[aUID stringValue]];
}

// Built once, keyed by the button media UIDs: the image parts found, whether
// the middle parts tile, and the extra horizontal title space (12 by default).
- (id)backgroundSettings
{
    if (_backgroundSettings != nil)
        return _backgroundSettings;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    id buttonsSettings = [self customButtonsSettingsDictionary];
    NSString *backgroundsPath = [[[self class] resourcesPath] stringByAppendingPathComponent:@"TexturedButtonBackgrounds"];
    for (id button in [self hyperCustomButtons]) {
        id backgroundSettings = [[buttonsSettings objectForKey:[button hyperCustomButtonName]] objectForKey:@"BackgroundSettings"];
        if (backgroundSettings == nil)
            continue;
        id prefix = [backgroundSettings objectForKey:@"texturedBackgroundPartsPrefix"];
        if (prefix == nil)
            continue;
        NSString *partsPath = [backgroundsPath stringByAppendingPathComponent:prefix];
        NSMutableDictionary *imageParts = [NSMutableDictionary dictionaryWithCapacity:9];
        for (int type = 0; type < 9; type++) {
            id image = [self texturedBackgroundImageForType:type prefix:prefix atPath:partsPath];
            if (image != nil)
                [imageParts setObject:image forKey:[NSNumber numberWithInt:type]];
        }
        if ([imageParts count] == 0)
            continue;
        id shouldTile = [backgroundSettings objectForKey:@"shouldTileMiddleBackgroundParts"];
        if (shouldTile == nil)
            shouldTile = [NSNumber numberWithBool:NO];
        id titleSpace = [backgroundSettings objectForKey:@"additionalHorizontalTitleSpace"];
        if (titleSpace == nil)
            titleSpace = [NSNumber numberWithFloat:12];
        NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:shouldTile, @"shouldTileMiddleBackgroundParts", [[imageParts copy] autorelease], @"imageParts", titleSpace, @"additionalHorizontalTitleSpace", nil];
        [settings setObject:entry forKey:[[[button media] mediaUID] stringValue]];
    }
    _backgroundSettings = [settings copy];
    return _backgroundSettings;
}

- (id)buttonSizeAttributeKey
{
    return @"sizeAsString";
}

- (id)titleAttributeKey
{
    return @"title";
}

- (id)imagePositionAttributeKey
{
    return @"imagePosition";
}

- (id)borderedAttributeKey
{
    return @"bordered";
}

- (CGFloat)additionalHorizontalTitleSpaceForButtonWithMediaUID:(id)aUID
{
    return [[[self backgroundSettingsForButtonWithMediaUID:aUID] objectForKey:@"additionalHorizontalTitleSpace"] floatValue];
}

- (BOOL)shouldTileMiddleBackgroundPartsForButtonWithMediaUID:(id)aUID
{
    return [[[self backgroundSettingsForButtonWithMediaUID:aUID] objectForKey:@"shouldTileMiddleBackgroundParts"] boolValue];
}

// Three-part backgrounds have a fixed height.
- (BOOL)canResizeVerticallyBackgroundForButtonWithMediaUID:(id)aUID
{
    return [[[self backgroundSettingsForButtonWithMediaUID:aUID] objectForKey:@"imageParts"] count] != 3;
}

- (id)backgroundImagePartForButtonWithMediaUID:(id)aUID partType:(NSInteger)aType
{
    return [[[self backgroundSettingsForButtonWithMediaUID:aUID] objectForKey:@"imageParts"] objectForKey:[NSNumber numberWithInt:(int)aType]];
}

// The extra dictionary of a button object set up for the custom button: an
// invisible shape button the size of the image, or a textured system button.
- (id)hyperCustomButtonDescriptionForName:(id)aName
{
    HSButtonObject *buttonObject = [HSButtonObject defaultObject];
    [[HSGenericNodeSupport sharedNodeSupport] addNode:buttonObject];
    id button = [self hyperCustomButtonForName:aName];
    [buttonObject setTitle:[button hyperCustomButtonTitle]];
    [buttonObject setTitleVisible:NO];
    [buttonObject setHasHighlight:YES];
    [buttonObject setMedia:[button media]];
    if ([self backgroundSettingsForButtonWithMediaUID:[[button media] mediaUID]] == nil) {
        [buttonObject setBackgroundStyle:@"HSButtonObjectShapeBackgroundStyle"];
        [buttonObject setIconVisible:YES];
        id background = [[buttonObject background] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
        [background setShapeButtonType:@"HSInvisibleShapeButtonType"];
        NSRect rect = NSZeroRect;
        rect.size = [(NSImage *)[button hyperCustomButtonImage] size];
        [background setBorderPath:[NSBezierPath bezierPathWithRect:rect]];
    } else {
        NSSize size = [self sizeForCustomButtonWithTexturedBackground:button];
        if (!NSEqualSizes(size, NSZeroSize))
            [buttonObject setSize:size];
        [buttonObject setBackgroundStyle:@"HSButtonObjectSystemBackgroundStyle"];
        [buttonObject setIconVisible:NO];
        id background = [[buttonObject background] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
        [background setSystemButtonType:@"HSTexturedBackgroundSystemButtonType"];
        [background setIgnoreTintColor:YES];
    }
    NSMutableDictionary *description = [NSMutableDictionary dictionaryWithDictionary:[buttonObject extraDictionaryRepresentation]];
    [[HSGenericNodeSupport sharedNodeSupport] removeNode:buttonObject];
    return description;
}

- (id)hyperCustomButtonImageForName:(id)aName
{
    return [[self hyperCustomButtonForName:aName] hyperCustomButtonImage];
}

- (id)hyperCustomButtonForName:(id)aName
{
    for (id button in [self hyperCustomButtons])
        if ([[button hyperCustomButtonName] isEqualToString:aName])
            return button;
    return nil;
}

// Every regular file in the folder, named after its settings entry and
// sorted by the ordered list.
- (id)hyperCustomButtons
{
    if (_customButtons != nil)
        return _customButtons;
    _customButtons = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self folderPath]];
    NSString *fileName;
    while ((fileName = [enumerator nextObject]) != nil) {
        NSString *path = [[self folderPath] stringByAppendingPathComponent:fileName];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
        if (![[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular])
            continue;
        NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
        id buttonSettings = [[self customButtonsSettingsDictionary] objectForKey:name];
        NSString *title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:[buttonSettings objectForKey:@"customButtonName"] value:@"" table:@"CustomButtonNames"];
        id UID = [HSUID UIDWithString:[buttonSettings objectForKey:@"customButtonUID"]];
        id representation = [[HSMediaFileRepresentation alloc] initWithPath:path];
        id media = [[HSNewMedia alloc] initWithMediaUID:UID representation:representation name:title];
        id button = [[HSCustomButton allocWithZone:[self zone]] initWithMedia:media name:name];
        if (button != nil)
            [_customButtons addObject:button];
        [button release];
        [media release];
        [representation release];
    }
    [_customButtons sortUsingFunction:HSCustomButtonsSort context:[self customButtonsOrderedList]];
    return _customButtons;
}

- (id)customButtonsOrderedList
{
    if (_customButtonsOrderedList == nil) {
        NSString *path = [[[self class] resourcesPath] stringByAppendingPathComponent:@"CustomButtonsOrderedList.plist"];
        _customButtonsOrderedList = [[NSArray alloc] initWithContentsOfFile:path];
    }
    return _customButtonsOrderedList;
}

- (id)customButtonsSettingsDictionary
{
    if (_customButtonsSettingsDictionary == nil) {
        NSString *path = [[[self class] resourcesPath] stringByAppendingPathComponent:@"CustomButtonsSettings.plist"];
        _customButtonsSettingsDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return _customButtonsSettingsDictionary;
}

- (id)folderPath
{
    return [[[self class] resourcesPath] stringByAppendingPathComponent:[[self class] customButtonsFolderName]];
}

- (void)dealloc
{
    [_customButtons release];
    [_customButtonsSettingsDictionary release];
    [_customButtonsOrderedList release];
    [_backgroundSettings release];
    [super dealloc];
}

@end

// One custom button: its image media and its file name.
@implementation HSCustomButton

- (id)imageUID
{
    return [self hyperCustomButtonPathName];
}

- (id)imageRepresentation
{
    return [self hyperCustomButtonPathName];
}

- (id)imageRepresentationType
{
    return @"IKImageBrowserPathRepresentationType";
}

- (NSInteger)compareDecrease:(id)aDecrease
{
    return [aDecrease compareIncrease:self];
}

- (NSInteger)compareIncrease:(id)aIncrease
{
    return [[self hyperCustomButtonName] compare:[aIncrease hyperCustomButtonName]];
}

- (id)hyperCustomButtonPathName
{
    return [[self media] fullPathToMediaFile];
}

- (id)hyperCustomButtonName
{
    return _name;
}

- (id)hyperCustomButtonTitle
{
    return [[self media] mediaName];
}

- (id)hyperCustomButtonImage
{
    return [[self media] image];
}

- (void)dealloc
{
    [_media release];
    [_name release];
    [super dealloc];
}

- (id)media
{
    return _media;
}

- (id)initWithMedia:(id)aMedia name:(id)aName
{
    self = [self initWithMedia:aMedia];
    if (self != nil)
        _name = [aName retain];
    return self;
}

- (id)initWithMedia:(id)aMedia error:(id *)aError
{
    self = [super init];
    if (self != nil)
        _media = [aMedia retain];
    return self;
}

- (id)initWithMedia:(id)aMedia
{
    return [self initWithMedia:aMedia error:NULL];
}

@end
