#import "HSOldFormatDocument+HSGraphicsRecreation.h"
// Old-format import: graphic items (rebuilt as image objects), card
// backgrounds and button animations. The graphic being rebuilt is kept in
// the parser's values buffer under "~Graphic"; actions found later look
// themselves up there by the keys these handlers store.

static id HSGraphicsRecreationGraphic(HSOldFormatDocument *aDocument)
{
    return [[aDocument parser] valuesBufferObjectForKey:@"~Graphic"];
}

// Debug builds dump raw item data into aDirectory as <stack>-<offset>.<ext>.
static void HSGraphicsRecreationDump(HSOldFormatDocument *aDocument, NSData *aData, NSDictionary *aParameters, NSString *aDirectory, NSString *aExtension)
{
    id offset = [aParameters objectForKey:@"offsetParameter"];
    NSString *stackName = [[[aDocument parser] path] lastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:aDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
    NSString *path = [[aDirectory stringByAppendingString:@"/"] stringByAppendingFormat:@"%@-%@.%@", stackName, offset, aExtension];
    [aData writeToFile:path atomically:YES];
}

@implementation HSOldFormatDocument (HSGraphicsRecreation)

// An animation ("Sprt" sprite data) attached to a button becomes a play
// animation action of the button. Path animations only: those started by
// trigger kind 1, or without a path or key frames, are dropped.
- (void)processBy_buttonAnimStkItem_buttonItem_ANIM_STK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    uint32_t magic = 0;
    [aValue getBytes:&magic length:4];
    // (The tag is compared as stored, in the host's order.)
    if (magic != 0x74727053)
        return;
    HSOldFormatAnimation *sprite = [HSOldFormatAnimation new];
    [sprite setSpriteData:aValue];
    [sprite setOldFormatDocument:self];
    id actionable = [[self parser] valuesBufferObjectForKey:@"~ActionableObject"];
    id object = [sprite imageObject];
    BOOL isMovie = object == nil;
    if (isMovie)
        object = [sprite movieObject];
    [object moveToHyperBegin];
    short triggerKind = [sprite triggerKind];
    if (triggerKind == 1 || ![sprite bezierPath] || ![[sprite keyFrames] count]) {
        [sprite release];
        return;
    }
    HSAnimation *animation = [[HSAnimation new] autorelease];
    [object setSupport:[self document]];
    [animation setAnimatedObject:object];
    [animation setPath:[sprite bezierPath] keyFrames:[sprite keyFrames]];
    [animation setOldFormatHideMode:[sprite hideMode]];
    [animation setMatchToMovement:[sprite isMatchToMovement]];
    if (isMovie)
        [animation setPlayMovie:YES];
    [animation setUsesTransparentColor:[sprite isHasTransColor]];
    [animation setTransparentColor:[sprite transColor]];
    if ([object implementsHyperInterface:@protocol(HSTransparentColorAttributes)]) {
        [animation setTransparentColorHueTolerance:0];
        [animation setTransparentColorChromaTolerance:0];
        [animation setTransparentColorLightnessTolerance:0];
    }
    [animation setMovieSpeed:lroundf([sprite framesPerSec])];
    [animation setHideOnFirstFrame:![sprite isShowFirstFrame]];
    [animation setHideOnLastFrame:![sprite isShowLastFrame]];
    if ([sprite isNonStop])
        [animation setLoopMode:1];
    else if (triggerKind == 2) {
        [animation setLoopMode:3];
        [animation setLoopSeconds:lroundf([sprite playSeconds])];
    } else if (triggerKind == 4) {
        [animation setLoopMode:4];
        [animation setLoopFrameRepeats:lroundf([sprite playFrameRepeats])];
    } else if (triggerKind == 5) {
        [animation setLoopMode:2];
        [animation setLoopPathRepeats:lroundf([sprite playPathRepeats])];
    }
    [animation setUseClones:[sprite isAllowClones]];
    [animation setPlayBackAndForth:[sprite motionKind] == 3];
    [animation setHorizontalFlipAtStart:[sprite isBegFlipHor]];
    [animation setVerticalFlipAtStart:[sprite isBegFlipVert]];
    [animation setHorizontalFlipAtFinish:[sprite isEndFlipHor]];
    [animation setVerticalFlipAtFinish:[sprite isEndFlipVert]];
    if ([sprite layerKind] == 1)
        [animation setLayer:2];
    else if ([sprite layerKind] == 2)
        [animation setLayer:0];
    [animation setDontEraseGoing:[sprite goingDraw]];
    [animation setDontEraseReturning:[sprite returnDraw]];
    [animation setGoingAbsoluteLayer:[sprite goingOver] != 0];
    [animation setReturningAbsoluteLayer:[sprite returnOver] != 0];
    if ([sprite isStartEnd])
        [animation setPlaybackDirection:1];
    switch ([sprite timerKind]) {
    case 2:
        [animation setSpeedMode:1];
        [animation setClampedDuration:[sprite moveSeconds]];
        break;
    case 1:
        [animation setSpeedMode:0];
        // A multiple of 4 is imported as 3.
        if (lroundf([sprite moveMultiple]) == 4)
            [animation setSpeedMultiplier:3];
        else
            [animation setSpeedMultiplier:[sprite moveMultiple]];
        break;
    case 0:
        [animation setSpeedMode:2];
        [animation setTimesPerSecond:lroundf([sprite moveTimesPerSecond])];
        break;
    }
    HSPlayAnimationAction *action = [HSPlayAnimationAction new];
    [action setAnimation:animation];
    [self addHyperAction:action to:actionable];
    [object setSupport:nil];
    [action release];
    [sprite release];
}

- (void)processBy_animFrame_oneAnimFrameBody_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

// Status flag 0x40: the graphic is linked to a file, whose (classic Mac
// OS) path follows as a Pascal string. Then the graphic gets its rect.
- (void)processBy_itemGraphic_itemGraphicBody_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (([[self parser] intEvaluate:@"itemGraphicHeader.type.itemstatflags"] & 0x40) != 0) {
        id graphic = HSGraphicsRecreationGraphic(self);
        uint8_t length = 0;
        [aValue getBytes:&length length:1];
        NSString *applePath = [NSString hyperStringWithASCIIData:[aValue subdataWithRange:NSMakeRange(1, length)]];
        NSString *path = [self actionObjectPathForApplePath:applePath];
        if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]
            && [[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:NO error:NULL])
            [[graphic hyperImageObject] setMedia:[HSNewMedia mediaWithPath:path]];
    }
    NSRect rect = NSRectFromString([[self parser] valuesBufferObjectForKey:@"itemGraphicHeader.type.rect"]);
    id applier = [[HSGraphicsRecreationGraphic(self) queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier setSize:rect.size withLayoutGuidingContext:nil];
    [applier moveFrameBoundingRectOriginTo:rect.origin withLayoutGuidingContext:nil];
    if ([self debugFlag])
        HSGraphicsRecreationDump(self, aValue, aParameters, @"/tmp/img", @"img");
}

// Stored as a percentage of transparency.
- (void)processBy_itemGraphicHeader_opacity_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [[HSGraphicsRecreationGraphic(self) queryHyperInterface:@protocol(HSMutableOpacityAttributes)] setHyperOpacity:(float)[aValue intValue] / -100.0f + 1.0f];
}

// The color is an index into the stack's palette; a border width of 0
// means no outline.
- (void)processBy_itemGraphicHeader_bordercolor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSInteger width = [[self parser] intEvaluate:@"itemGraphicHeader.type.borderwidth"];
    if (width == 0)
        return;
    id color = [[self graphicsImport] backgroundColorAtIndex:[aValue intValue]];
    id outline = [HSGraphicsRecreationGraphic(self) queryHyperInterface:@protocol(HSMutableOutlineAttributes)];
    [outline setHyperOutlineEnabled:YES];
    [outline setHyperOutlineWidth:(float)width];
    [outline setHyperOutlineColor:color];
}

- (void)processBy_itemGraphicHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self setOldCursorForObject:HSGraphicsRecreationGraphic(self) withOldCursorId:[aValue intValue]];
}

- (void)processBy_itemGraphicHeader_actionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] == 0)
        return;
    id graphic = HSGraphicsRecreationGraphic(self);
    id identifier = [[self parser] valuesBufferObjectForKey:@"itemGraphicHeader.type.id"];
    // (The original passes the item ID once more than the format uses.)
    [[self parser] setValuesBufferObject:graphic forKey:[NSString stringWithFormat:@"~clickingActionObjectByID_%@_%@", identifier, aValue]];
    [[self parser] setValuesBufferObject:graphic forKey:[NSString stringWithFormat:@"~clickingActionObjectOnlyByID_%@", aValue]];
    [[self parser] setValuesBufferObject:graphic forKey:[NSString stringWithFormat:@"~clickingActionObjectOnlyWinByID_%@", identifier]];
}

// Registers the graphic by its old name, so actions can refer to it.
- (void)processBy_itemGraphicHeader_name_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id name = aValue;
    if ([aValue isKindOfClass:[NSData class]])
        name = [self stringForImportedData:aValue];
    id graphic = HSGraphicsRecreationGraphic(self);
    id index = [self uniqueImportedIndexString];
    id itemName = [HSOldFormatDocument recreationItemNameFromString:name];
    [[self parser] setValuesBufferObject:graphic forKey:[NSString stringWithFormat:@"~itemName_%@_type_%@_%@", itemName, @"GRAPHIC", index]];
    NSString *shortNameKey = [NSString stringWithFormat:@"~itemShortName_%@_type_%@", itemName, @"GRAPHIC"];
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    if (![card userInfoForKey:shortNameKey])
        [card setUserInfo:graphic forKey:shortNameKey];
    // (The original also stores the graphic in its own user info.)
    [graphic setUserInfo:graphic forKey:shortNameKey];
    [graphic setUserInfo:itemName forKey:@"~itemNameOld"];
    [graphic setUserInfo:@"GRAPHIC" forKey:@"~itemTypeOld"];
    [graphic setHyperName:name];
}

// Status flag 0x80: a draggable graphic.
- (void)processBy_itemGraphicHeader_itemstatflags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (([aValue unsignedShortValue] & 0x80) == 0)
        return;
    id attributes = [HSGraphicsRecreationGraphic(self) queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    if (attributes)
        [attributes setDraggable:YES];
}

- (void)processBy_itemGraphicHeader_rect_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSRect rect = NSRectFromString(aValue);
    id graphic = HSGraphicsRecreationGraphic(self);
    id applier = [[graphic queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier resizeFrameTo:rect.size aboutRelativePoint:NSZeroPoint followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
    [applier moveFrameBoundingRectOriginTo:rect.origin withLayoutGuidingContext:nil];
    [self processBorderPathForImageObject:graphic];
}

// A graphic with a non-rectangular border is clipped to it. The path is
// in flipped item coordinates.
- (void)processBorderPathForImageObject:(id)aObject
{
    id path = [[self graphicsImport] graphicItemBorderBezierPath];
    if (!path)
        return;
    id<HSGeometryAttributes> geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (!geometry)
        return;
    NSSize size = [geometry size];
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    [[aObject queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] addObjectClipPath:(id)[path hyperCGPath] transform:flip];
}

- (void)processBy_itemGraphic_itemGraphicWhole_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [[self graphicsImport] setGraphicItemData:aValue];
}

// A new graphic item: an image object (empty until the body arrives) is
// added to the card.
- (void)processFirstParentAppearance_itemGraphicHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters
{
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    [[self graphicsImport] setGraphicItemBorderBezierPath:nil];
    id image = [[self graphicsImport] graphicItemImage];
    HSImageObject *graphic;
    if (image)
        graphic = [[HSImageObject alloc] initWithMedia:[HSNewMedia mediaWithImage:image]];
    else
        graphic = [[HSImageObject defaultObject] retain];
    [graphic setShadowEnabled:NO];
    [card addHyperChild:graphic];
    [[self parser] setValuesBufferObject:graphic forKey:@"~Graphic"];
    [graphic setHidden:_isHiddenItem];
    [graphic setLocked:_isLocked];
    if (!_isMasterCardIdExists && _isSharedItem) {
        [graphic setUserInfo:@"YES" forKey:@"~MasterObject"];
        [graphic makeGroupObject];
    }
    [graphic release];
}

// The card's background picture: JPEG data after the palette (pack type
// 3) or a packed bitmap of the card's size. The first background also
// applies the stack's presentation settings: a backdrop from the stack's
// resource fork (PICT 256, mode 1) or a palette color, and no title bar.
- (void)processBy_itemBackground_itemBackgroundBody_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    // (The pack type is evaluated from the value read for it, not by key.)
    NSInteger packType = [[self parser] intEvaluate:[[self parser] valuesBufferObjectForKey:@"itemBackgroundHeader.type.packtype"]];
    [[self graphicsImport] setBackgroundData:aValue];
    id image;
    if (packType == 3) {
        NSInteger offset = [[self parser] intEvaluate:[[self parser] valuesBufferObjectForKey:@"itemBackgroundHeader.type.palsize"]] + 0x56;
        NSData *jpeg = [aValue subdataWithRange:NSMakeRange(offset, [aValue length] - offset)];
        if ([self debugFlag])
            HSGraphicsRecreationDump(self, aValue, aParameters, @"/tmp/stk", @"jpg");
        image = [[[NSImage alloc] initWithData:jpeg] autorelease];
    } else {
        NSInteger height = [[self parser] intEvaluate:@"cardHeader.type.cdHeight"];
        NSInteger width = [[self parser] intEvaluate:@"cardHeader.type.cdWidth"];
        NSInteger depth = [[self parser] intEvaluate:@"cardHeader.type.cdDepth"];
        NSInteger pack = [[self parser] intEvaluate:@"itemBackgroundHeader.type.packtype"];
        NSInteger flags = [[self parser] intEvaluate:@"itemBackgroundHeader.type.flags"];
        image = [[self graphicsImport] backgroundImageWithRect:NSMakeRect(0, 0, width, height) depth:(unsigned short)depth packtype:(unsigned short)pack flags:(unsigned short)flags];
    }
    id card = [[self parser] valuesBufferObjectForKey:@"~Card"];
    if (image)
        [card importBackgroundFromImage:image imageScalingOption:4 eraseBackground:NO];
    if (_isPresModeSet || _presMode == 0x7fffffff)
        return;
    _isPresModeSet = YES;
    [[self stack] setPresentationCoveringDesktopMode:YES];
    if (_presMode == 1) {
        FSRef ref;
        if (CFURLGetFSRef((CFURLRef)[[self document] fileURL], &ref)) {
            ResFileRefNum file = FSOpenResFile(&ref, fsRdPerm);
            if (ResError() == noErr) {
                Handle picture = GetResource('PICT', 0x100);
                if (picture) {
                    // (The original hands the data a handle the resource
                    // map still owns.)
                    DetachResource(picture);
                    NSImage *backdrop = [[[NSImage alloc] initWithData:[NSData hyperDataWithHyperHandleNoCopy:picture]] autorelease];
                    id graphics = [[self stack] queryBackgroundGraphicsInterface:@protocol(HSMutableImage)];
                    if (graphics)
                        [graphics setHyperImage:backdrop];
                }
                // (The original closes the file with FSCloseFork.)
                CloseResFile(file);
            }
        }
    } else if (_presColor != 0) {
        id color = [[self graphicsImport] backgroundColorAtIndex:_presColor];
        [[[self stack] queryBackgroundGraphicsInterface:@protocol(HSMutableColor)] setHyperSolidColor:color];
    }
    if (_presFlags != 1)
        [[self stack] setPresentationPlaysWithoutTitleBar:YES];
}

@end
