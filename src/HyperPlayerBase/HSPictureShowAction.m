#import "HSPictureShowAction.h"
#import "HSAlert.h"
#import "HSAttributedStringRenderer.h"
#import "HSExecutableResourceProvider.h"
#import "HSMediaFileWrapper.h"
#import "HSNavigationController.h"
#import "HSPathsProvider.h"
#import "HSPictureshowAttributes.h"
#import "HSPlayerView.h"

// Shows the pictures of a folder as a slideshow in the player view. A
// missing folder can be located again by the user.
@implementation HSPictureShowAction

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id behavior = [[aRepresentation elementsForName:@"behavior"] extraFirstObject];
    if (behavior == nil)
        return;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self setLoopPictureShow:[[[behavior attributeForName:@"loopPictureShow"] stringValue] hyperBoolValue]];
    [self setLeavesLastPictureOnExit:[[[behavior attributeForName:@"leavesLastPictureOnExit"] stringValue] hyperBoolValue]];
    [self setShowsFilenameOnPicture:[[[behavior attributeForName:@"showsFilenameOnPicture"] stringValue] hyperBoolValue]];
    [self setTimeDelay:[[[behavior attributeForName:@"timeDelay"] stringValue] doubleValue]];
    id folderMedia = [[aRepresentation elementsForName:@"pictureShowFolderMedia"] extraFirstObject];
    NSURL *URL = [NSURL URLWithString:[[folderMedia attributeForName:@"url"] stringValue]];
    if (URL != nil)
        [self setURL:URL];
    [pool release];
}

// The pictures themselves are stored too, as PNG media referenced by the
// folder element.
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSXMLElement *behavior = [NSXMLElement elementWithName:@"behavior"];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"loopPictureShow" stringValue:[self loopPictureShow] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"leavesLastPictureOnExit" stringValue:[self leavesLastPictureOnExit] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"showsFilenameOnPicture" stringValue:[self showsFilenameOnPicture] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"timeDelay" stringValue:[NSString stringWithFormat:@"%f", [self timeDelay]]]];
    [element addChild:behavior];
    NSXMLElement *folderMedia = [NSXMLElement elementWithName:@"pictureShowFolderMedia"];
    [folderMedia addAttribute:[NSXMLNode attributeWithName:@"url" stringValue:[[self URL] absoluteString]]];
    for (NSURL *URL in [self URLs]) {
        id data = [[[[NSImage alloc] initWithContentsOfURL:URL] autorelease] hyperPNGRepresentation];
        NSString *name = [NSString stringWithFormat:@"%u_%@.png", (unsigned int)[data hash], [[[URL path] lastPathComponent] stringByDeletingPathExtension]];
        id media = [aContext convertedMediaForKey:name];
        if (media == nil) {
            media = [HSNewMedia mediaWithData:data name:name type:@"png"];
            if (media != nil)
                [aContext setConvertedMedia:media forKey:name];
        }
        if (media == nil)
            continue;
        [aContext addMedia:media];
        NSXMLElement *reference = [NSXMLElement elementWithName:@"mediaItemRef"];
        [reference addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
        [folderMedia addChild:reference];
    }
    [element addChild:folderMedia];
    [pool release];
    return element;
}

- (id)XMLElementName
{
    return @"actPictureShow";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

- (BOOL)isValid
{
    return [[self URLs] count] != 0;
}

- (NSRect)slideshowFrame
{
    return [[[self document] playerView] slideshowFrame];
}

- (NSUInteger)slideshowAutoresizingMask
{
    return [[[self document] playerView] slideshowAutoresizingMask];
}

- (id)slideshowView
{
    return [[[self document] playerView] slideshowView];
}

// The picture centred in an image the size of the slideshow frame, scaled
// down to fit if needed, with the file name at the bottom left if wanted.
- (id)slideshowItemAtIndex:(NSUInteger)aIndex
{
    NSImage *picture = [[NSImage alloc] initByReferencingURL:[[self URLs] objectAtIndex:aIndex]];
    NSRect frame = [self slideshowFrame];
    NSSize size = [picture size];
    NSRect rect;
    if (frame.size.width < size.width || frame.size.height < size.height) {
        CGFloat ratio = size.width / size.height;
        if (ratio <= frame.size.width / frame.size.height)
            rect.size = NSMakeSize(ratio * frame.size.height, frame.size.height);
        else
            rect.size = NSMakeSize(frame.size.width, frame.size.width / ratio);
    } else {
        rect.size = size;
    }
    rect.origin.x = frame.size.width * 0.5 - rect.size.width * 0.5;
    rect.origin.y = frame.size.height * 0.5 - rect.size.height * 0.5;
    NSImage *image = [[[NSImage alloc] initWithSize:frame.size] autorelease];
    [image lockFocus];
    [picture drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    if ([self showsFilenameOnPicture]) {
        NSString *path = [[[self URLs] objectAtIndex:aIndex] path];
        NSString *fileName = [[NSFileManager defaultManager] displayNameAtPath:path];
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowOffset:NSZeroSize];
        [shadow setShadowBlurRadius:3];
        [shadow setShadowColor:[NSColor blackColor]];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, nil];
        [shadow release];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:fileName attributes:attributes];
        HSAttributedStringRenderer *renderer = [HSAttributedStringRenderer sharedRenderer];
        [renderer setContainerWidth:frame.size.width];
        [renderer setHyphenationFactor:1];
        [renderer drawAttributedString:string atPoint:NSZeroPoint];
        [string release];
    }
    [image unlockFocus];
    [picture release];
    return image;
}

- (NSUInteger)numberOfSlideshowItems
{
    return [[self URLs] count];
}

- (void)invalidateURLs
{
    [_URLs release];
    _URLs = nil;
}

// The image files in the folder (found again if it moved), aliases and
// symbolic links resolved.
- (id)URLs
{
    if (_URLs != nil)
        return _URLs;
    NSString *path = [[self URL] path];
    NSString *base = [[self URL] isFileURL] ? [path stringByDeletingLastPathComponent] : path;
    NSString *folder = [HSNavigationController findFile:path base:base];
    NSArray *contents = [[NSFileManager defaultManager] directoryContentsAtPath:folder];
    NSArray *imageTypes = [NSImage imageFileTypes];
    for (NSString *fileName in contents) {
        NSString *filePath = [[folder stringByAppendingPathComponent:fileName] stringByResolvingSymlinksInPath];
        NSString *resolvedPath = [[NSFileManager defaultManager] hyperResolveAliasAtPath:filePath];
        if (resolvedPath != nil && [resolvedPath length] != 0)
            filePath = resolvedPath;
        BOOL isImage = [imageTypes containsObject:[[[filePath lastPathComponent] pathExtension] lowercaseString]];
        if (!isImage)
            isImage = [imageTypes containsObject:[[NSFileManager defaultManager] hyperFileTypeAtPath:filePath]];
        if (!isImage)
            continue;
        NSURL *URL = [NSURL fileURLWithPath:filePath];
        if (URL == nil)
            continue;
        if (_URLs == nil)
            _URLs = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:[contents count]];
        [_URLs addObject:URL];
    }
    return _URLs;
}

- (void)setURL:(id)aURL
{
    if ([[self URL] isEqual:aURL])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Folder to Show" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setURL:[self URL]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [self invalidateURLs];
    [_URL release];
    _URL = [aURL retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)URL
{
    return _URL;
}

- (void)setTimeDelay:(double)aDelay
{
    if ([self timeDelay] == aDelay)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Time Delay" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTimeDelay:[self timeDelay]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTimeDelayAttribute) ofObject:self withUserInfo:nil];
    _timeDelay = aDelay;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTimeDelayAttribute) ofObject:self withUserInfo:nil];
}

- (double)timeDelay
{
    return _timeDelay;
}

- (void)setShowsFilenameOnPicture:(BOOL)aPicture
{
    if ([self showsFilenameOnPicture] == aPicture)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Show Filename on Picture(s)" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setShowsFilenameOnPicture:[self showsFilenameOnPicture]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSShowsFilenameOnPictureAttribute) ofObject:self withUserInfo:nil];
    _showsFilenameOnPicture = aPicture;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSShowsFilenameOnPictureAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)showsFilenameOnPicture
{
    return _showsFilenameOnPicture;
}

- (void)setLeavesLastPictureOnExit:(BOOL)aExit
{
    if ([self leavesLastPictureOnExit] == aExit)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Leave Last Picture on Exit" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setLeavesLastPictureOnExit:[self leavesLastPictureOnExit]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSLeavesLastPictureOnExitAttribute) ofObject:self withUserInfo:nil];
    _leavesLastPictureOnExit = aExit;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSLeavesLastPictureOnExitAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)leavesLastPictureOnExit
{
    return _leavesLastPictureOnExit;
}

- (void)setLoopPictureShow:(BOOL)aShow
{
    if ([self loopPictureShow] == aShow)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Continously Display Files" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setLoopPictureShow:[self loopPictureShow]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSLoopPictureShowAttribute) ofObject:self withUserInfo:nil];
    _loopPictureShow = aShow;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSLoopPictureShowAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)loopPictureShow
{
    return _loopPictureShow;
}

// A chosen folder becomes the new pictures folder and the show starts again
// (the context is the contextInfo).
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != NSModalResponseOK) {
        _isMissingFolder = NO;
        [self notifyDidFinish];
        return;
    }
    NSURL *URL = [[aEnd URLs] extraFirstObject];
    NSString *path = [URL path];
    if ([URL isFileURL])
        path = [path stringByDeletingLastPathComponent];
    [[HSPathsProvider sharedPathsProvider] setPicturesFolder:[HSNavigationController findFile:path base:path]];
    [[self pictureShowActionAttributes] setURL:URL];
    [self performSelector:@selector(startInContext:) withObject:(id)aInfo afterDelay:0];
}

// "Choose Folder..." asks for the folder in a sheet run by the context.
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != NSAlertFirstButtonReturn) {
        _isMissingFolder = NO;
        [self notifyDidFinish];
        return;
    }
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [(id)aInfo showOpenPanel:panel sheetForDirectory:[[HSPathsProvider sharedPathsProvider] picturesFolder] file:nil types:nil modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:aInfo];
    [panel release];
}

- (id)missingFolderAlert
{
    HSAlert *alert = [HSAlert new];
    id provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"Cannot perform PictureShow NBA" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The folder with pictures you have selected may have been deleted, renamed, or moved to another location. If you want to try locating it manually or choose another folder, click Choose Folder." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Choose Folder..." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    return [alert autorelease];
}

- (id)pictureShowActionAttributes
{
    return [self queryHyperInterface:@protocol(HSPictureShowActionAttributes)];
}

// Not during a transition. Without pictures the missing folder alert is
// shown instead.
- (void)startInContext:(id)aContext
{
    if ([aContext isTransitionPlaying]) {
        [self notifyDidFinish];
        return;
    }
    [self invalidateURLs];
    id playerView = [[self document] playerView];
    // Fixed: starting again after choosing the folder added the observer a
    // second time (finishing twice) and leaked the previous context.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSPlayerViewSlideshowDidStopNotification object:playerView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideshowDidStop:) name:HSPlayerViewSlideshowDidStopNotification object:playerView];
    [aContext retain];
    [_context release];
    _context = aContext;
    if ([[self URLs] count] == 0) {
        _isMissingFolder = YES;
        [aContext displayAlert:[self missingFolderAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
        return;
    }
    _isMissingFolder = NO;
    id attributes = [HSPictureshowAttributes defaultPictureshowAttributes];
    [attributes setDurationBetweenSlides:[self timeDelay]];
    [attributes setStartsNextSlideAutomatically:YES];
    [attributes setStopsAfterEnd:![self loopPictureShow]];
    [attributes setUseClickOnExitCard:[self loopPictureShow]];
    [attributes setLeavesLastPictureOnExit:[self leavesLastPictureOnExit]];
    [aContext startSlideshowWithDataSource:self attributes:attributes];
}

- (void)stop:(id)aStop
{
    [_context stopSlideshow];
    [super stop:aStop];
}

// Not while the missing folder alert is up.
- (BOOL)canBeStopped
{
    return !_isMissingFolder;
}

- (void)slideshowDidStop:(id)aStop
{
    [self notifyDidFinish];
}

- (void)notifyDidFinish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSPlayerViewSlideshowDidStopNotification object:[[self document] playerView]];
    [_context release];
    _context = nil;
    [super notifyDidFinish];
}

- (BOOL)canChangeSynchronousFlag
{
    return NO;
}

- (BOOL)isSynchronous
{
    return YES;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    id keys = [super keysForExtraStoringWithCodingContext:aContext];
    return [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"loopPictureShow", @"leavesLastPictureOnExit", @"showsFilenameOnPicture", @"timeDelay", [@"URL" extraKeyForMultiRepresentations], nil]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_URL release];
    [_URLs release];
    [_context release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _timeDelay = 2;
    return self;
}

@end
