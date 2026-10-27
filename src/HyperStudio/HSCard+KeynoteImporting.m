#import "HSCard+KeynoteImporting.h"

static NSString *HSCardKeynoteColorKey(NSColor *aColor)
{
    return [NSString stringWithFormat:@"%@ %f %f %f %f", [aColor colorSpaceName], [aColor redComponent], [aColor greenComponent], [aColor blueComponent], [aColor alphaComponent]];
}

@implementation HSCard (KeynoteImporting)

- (BOOL)shouldAssignNextCardAction
{
    id container = [[self stack] queryHyperInterface:@protocol(HSNodeContainer)];
    return container == nil || [container hyperCount] > 1;
}

- (void)importKeynoteAngleGradient:(id)aGradient
{
    if (aGradient == nil)
        return;
    HSColor *color = [[HSColor new] autorelease];
    [color setHyperStartColor:[aGradient startColor]];
    [color setHyperEndColor:[aGradient endColor]];
    [color setHyperAngle:-[aGradient angle]];
    [color setHyperKind:0];
    id editable = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editable == nil)
        return;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), nil };
    id image = [editable queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return;
    NSSize size = [image imageSize];
    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
    [editable beginEditImage:image inRect:rect];
    [image beginCocoaEditing];
    [color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
    [image endCocoaEditing];
    [editable endEditImage];
}

- (void)importKeynoteFillColor:(id)aColor fromGraphicStyle:(id)aStyle
{
    if (aColor == nil || [aColor isEqual:[[NSColor whiteColor] colorUsingColorSpace:[aColor colorSpace]]])
        return;
    id media = [self queryHyperInterface:@protocol(HSEditableImageMediaAttributes)];
    if (media != nil) {
        NSString *key = HSCardKeynoteColorKey(aColor);
        id newMedia = [[aStyle cache] objectOfType:@"backgroundMedia" inCacheForId:key];
        if (newMedia == nil) {
            NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
            NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];
            [image lockFocus];
            [(NSColor *)aColor set];
            NSRectFill(NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height));
            [image unlockFocus];
            newMedia = [HSNewMedia mediaWithImage:image];
            [[aStyle cache] addObject:newMedia type:@"backgroundMedia" inCacheForId:key];
        }
        [media setEditableImageMedia:newMedia];
        return;
    }
    id editable = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editable == nil)
        return;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), nil };
    id image = [editable queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return;
    NSSize size = [image imageSize];
    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
    [editable beginEditImage:image inRect:rect];
    [image beginCocoaEditing];
    [(NSColor *)aColor set];
    NSRectFill(rect);
    [image endCocoaEditing];
    [editable endEditImage];
}

- (void)importKeynoteTexturedFill:(id)aFill
{
    id tintedImage;
    if (aFill == nil || (tintedImage = [aFill tintedImage]) == nil)
        return;
    id media = [self queryHyperInterface:@protocol(HSEditableImageMediaAttributes)];
    if (media != nil) {
        NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
        [media setEditableImageMedia:[aFill mediaWithSize:size]];
        return;
    }
    id editable = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editable == nil)
        return;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), nil };
    id image = [editable queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return;
    NSSize size = [image imageSize];
    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
    [editable beginEditImage:image inRect:rect];
    [image beginCocoaEditing];
    [tintedImage hyperDrawInRect:rect ofBounds:rect withAlignment:0 scaling:[aFill scaleType]];
    [image endCocoaEditing];
    [editable endEditImage];
}

- (void)applyKeynoteGraphicStyle:(id)aStyle
{
    [super applyKeynoteGraphicStyle:aStyle];
    if (![self shouldAssignNextCardAction])
        return;
    id keynoteTransition = [aStyle transition];
    HSNextCardAction *action = [[HSNextCardAction new] autorelease];
    id transition = [HSKeynoteAttributesConvert transitionFromKeynoteTransition:keynoteTransition];
    if (transition != nil)
        [action setTransition:transition];
    [[self queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
}

- (void)importFromKeynoteObject:(id)aObject
{
    [self applyKeynoteGraphicStyle:[aObject graphicStyle]];
    NSArray *items = [[aObject items] retain];
    NSInteger count = [items count];
    for (NSInteger i = 0; i < count; i++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [self addDefaultObjectForKeynoteObject:[items objectAtIndex:i] onSlide:aObject];
        [pool release];
    }
    count = [[self hyperChildren] count];
    for (NSInteger i = 0; i < count; i++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id child = [self hyperChildAtIndex:i];
        id keynoteObject = [child userInfoForKey:@"HSKeynoteObjectUserInfoKey"];
        [child importFromKeynoteObject:keynoteObject];
        if ([child hyperParent] == self) {
            id movie = [child queryHyperInterface:@protocol(HSMovieObjectAttributes)];
            if (movie != nil)
                [self addPlayMovieActionToCardForMovieObject:movie eventType:[aObject eventTypeForMediaId:[keynoteObject nodeId]] loopMovie:[keynoteObject playLoopMode]];
        }
        [pool release];
    }
    for (id item in items) {
        if ([[(KeynoteNode *)item name] isEqualToString:@"media"] && [(KeynoteMedia *)item mediaType] == 1)
            [self addSoundFromKeynoteMedia:item];
    }
    [items release];
}

- (void)addPlayMovieActionToCardForMovieObject:(id)aObject eventType:(id)aType loopMovie:(BOOL)aMovie
{
    id actionType = [HSPlayMovieAction actionType];
    id event = [HSActionEvent actionEventOfType:aType];
    id actor = [self queryNewHyperInterface:@protocol(HSActor)];
    id action = [actor hyperActionOfType:actionType forEvent:event];
    if (action == nil)
        action = [actor addHyperActionOfType:actionType forEvent:event];
    [action addPlayableObject:aObject];
    NSEnumerator *enumerator = [[action movies] objectEnumerator];
    id playback;
    while ((playback = [[enumerator nextObject] queryHyperInterface:@protocol(HSMoviePlaybackAttributes)]) != nil) {
        if ([[playback movieObjectForCard:self] queryHyperInterface:@protocol(HSMovieObjectAttributes)] == aObject)
            [playback setPlayCount:!aMovie];
    }
}

- (void)addDefaultObjectForKeynoteObject:(id)aObject onSlide:(id)aSlide
{
    static NSDictionary *defaultObjects = nil;
    if (defaultObjects == nil)
        defaultObjects = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultObjectsForKeynote" ofType:@"plist"]] retain];
    NSString *key = [(KeynoteNode *)aObject name];
    if ([key isEqualToString:@"media"]) {
        NSInteger mediaType = [(KeynoteMedia *)aObject mediaType];
        if (mediaType == 0)
            key = [key stringByAppendingString:@"?movie"];
        else if (mediaType == 2)
            key = [key stringByAppendingString:@"?image"];
    }
    if ([key isEqualToString:@"group"]) {
        for (id item in [aObject items])
            [self addDefaultObjectForKeynoteObject:item onSlide:aSlide];
    }
    NSString *className;
    while ((className = [defaultObjects objectForKey:key]) != nil) {
        Class objectClass = NSClassFromString(className);
        if (objectClass != Nil && [objectClass shouldImportFromKeynoteObject:aObject]) {
            id object = [objectClass defaultObject];
            [self addHyperChild:object];
            [object setUserInfo:aObject forKey:@"HSKeynoteObjectUserInfoKey"];
            if ([[(KeynoteNode *)aObject name] isEqualToString:@"media"])
                [[object queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:NO];
        }
        key = [key stringByAppendingString:@"+"];
    }
}

@end
