#import "HSGoogleEarthAction.h"
#import "HSActionExecutionContext.h"
#import "HSAlert.h"
#import "HSExecutableResourceProvider.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "HSOpenLocationAction.h"
#import "HSUID.h"
#import "HSZipWrapper.h"

static NSSet *sPlacemarkKeys = nil;

// Opens a Google Earth document (.kml or .kmz, stored as media) in Google
// Earth through an open location action. The HTML5 export reads the
// placemark out of the document.
@implementation HSGoogleEarthAction

+ (id)cantLaunchGoogleEarthAlert
{
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSString *message = [resources localizedStringForKey:@"HSCantLaunchGoogleEarthMessageText" value:@"" table:@"Alerts"];
    NSString *informativeText = [resources localizedStringForKey:@"HSCantLaunchGoogleEarthInformativeText" value:@"" table:@"Alerts"];
    return [HSAlert alertWithMessageText:message defaultButton:[resources localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeText:informativeText];
}

+ (id)cantFindGoogleEarthAlert
{
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSString *message = [resources localizedStringForKey:@"HSCantFindGoogleEarthMessageText" value:@"" table:@"Alerts"];
    NSString *informativeText = [resources localizedStringForKey:@"HSCantFindGoogleEarthInformativeText" value:@"" table:@"Alerts"];
    return [HSAlert alertWithMessageText:message defaultButton:[resources localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeText:informativeText];
}

- (void)parser:(id)aParser foundCharacters:(id)aCharacters
{
    if (_textInProgress != nil)
        [_textInProgress appendString:[aCharacters stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(id)aParser didEndElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName
{
    if ([[self placemarkKeys] containsObject:aElement])
        [_googleEarthExport setObject:_textInProgress forKey:aElement];
    [_textInProgress release];
    _textInProgress = nil;
}

- (void)parser:(id)aParser didStartElement:(id)aElement namespaceURI:(id)aURI qualifiedName:(id)aName attributes:(id)aAttributes
{
    if ([[self placemarkKeys] containsObject:aElement])
        _textInProgress = [NSMutableString new];
}

- (id)placemarkKeys
{
    if (sPlacemarkKeys == nil)
        sPlacemarkKeys = [[NSSet alloc] initWithObjects:@"name", @"longitude", @"latitude", @"altitude", @"range", @"tilt", @"heading", @"altitudeMode", @"gx:altitudeMode", @"coordinates", nil];
    return sPlacemarkKeys;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSMutableSet *features = [NSMutableSet setWithObject:[resources localizedStringForKey:@"HSHTML5UnsupportedFeatureGoogleEarthActionWillBeReplaced" value:@"" table:@"Export"]];
    if ([aType isEqualToString:@"HSiBooksAuthorDocumentType"])
        [features addObject:[resources localizedStringForKey:@"HSHTML5UnsupportedFeatureQuitAfterLaunchGoogleEarth" value:@"" table:@"Export"]];
    if ([self launchInForeground])
        [features addObject:[resources localizedStringForKey:@"HSHTML5UnsupportedFeatureGoogleEarthActionBringToFront" value:@"" table:@"Export"]];
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return YES;
}

// The placemark fields of the document (the first file of a .kmz) go under
// "Placemark".
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSString *path = [[self urlFromMedia] path];
    if (path == nil)
        return nil;
    NSFileWrapper *wrapper;
    if ([[path pathExtension] isEqualToString:@"kmz"]) {
        HSZipWrapper *zipWrapper = [[HSZipWrapper alloc] initWithPath:path];
        wrapper = [[[[zipWrapper fileWrappers] allValues] extraFirstObject] retain];
        [zipWrapper release];
    } else {
        wrapper = [[NSFileWrapper alloc] initWithPath:path];
    }
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[wrapper regularFileContents]];
    [wrapper release];
    [parser setDelegate:(id)self];
    _googleEarthExport = [NSMutableDictionary new];
    [parser parse];
    [parser release];
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:_googleEarthExport forKey:@"Placemark"];
    [dictionary setObject:([self quitAfterLaunch] ? @"1" : @"0") forKey:@"isQuit"];
    [_googleEarthExport release];
    _googleEarthExport = nil;
    return dictionary;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setLaunchInForeground:[[[aRepresentation attributeForName:@"bringGoogleEarthToFront"] stringValue] hyperBoolValue]];
    [self setQuitAfterLaunch:[[[aRepresentation attributeForName:@"quitHyperStudioAfterLaunch"] stringValue] hyperBoolValue]];
    id mediaRef = [[aRepresentation elementsForName:@"googleEarthFileMediaRef"] extraFirstObject];
    [self setMediaUID:[HSUID UIDWithString:[[mediaRef attributeForName:HSXMLStoringRefIdString] stringValue]]];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    if ([self media] == nil)
        return nil;
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [aContext addMedia:[self media]];
    [element addAttribute:[NSXMLNode attributeWithName:@"bringGoogleEarthToFront" stringValue:([self launchInForeground] ? HSXMLStoring1String : HSXMLStoring0String)]];
    [element addAttribute:[NSXMLNode attributeWithName:@"quitHyperStudioAfterLaunch" stringValue:([self quitAfterLaunch] ? HSXMLStoring1String : HSXMLStoring0String)]];
    NSXMLElement *mediaRef = [NSXMLElement elementWithName:@"googleEarthFileMediaRef"];
    [mediaRef addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[self mediaUID] stringValue]]];
    [element addChild:mediaRef];
    return element;
}

- (id)XMLElementName
{
    return @"actGoogleEarth";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (id)media
{
    if (_media != nil)
        return _media;
    return [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[self mediaUID]];
}

- (id)mediaUID
{
    return _mediaUID;
}

- (void)setMediaUID:(id)aUID
{
    if ([_mediaUID isEqual:aUID])
        return;
    [_mediaUID release];
    _mediaUID = [aUID retain];
}

- (void)setURL:(id)aURL
{
    if ([aURL isEqual:[self URL]])
        return;
    [self setDocumentURL:aURL];
    [self updateMediaUID];
}

- (id)URL
{
    return [self documentURL];
}

- (void)setLaunchInForeground:(BOOL)aForeground
{
    [[self openLocationAction] setLaunchInForeground:aForeground];
}

- (BOOL)launchInForeground
{
    return [[self openLocationAction] launchInForeground];
}

- (void)setQuitAfterLaunch:(BOOL)aLaunch
{
    [[self openLocationAction] setQuitAfterLaunch:aLaunch];
}

- (BOOL)quitAfterLaunch
{
    return [[self openLocationAction] quitAfterLaunch];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"openLocationAction", @"mediaUID", @"documentURL", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}

- (void)notifyDidFinish
{
    [super notifyDidFinish];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSHyperActionDidFinish" object:[self openLocationAction]];
}

// Finishes when the open location action does.
- (void)startInContext:(id)aContext
{
    if ([[NSWorkspace sharedWorkspace] fullPathForApplication:@"Google Earth"] == nil) {
        [aContext displayAlert:[HSGoogleEarthAction cantFindGoogleEarthAlert] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        [super notifyDidFinish];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDidFinish) name:@"HSHyperActionDidFinish" object:[self openLocationAction]];
    if ([[aContext document] isWebPlayerDocument])
        [self renameGEDocument];
    [[self openLocationAction] setURL:[self urlFromMedia]];
    [[self openLocationAction] startInContext:aContext];
}

- (id)ownedMediaUIDs
{
    return [[[NSCountedSet alloc] initWithSet:[self mediaUIDs]] autorelease];
}

- (id)mediaUIDs
{
    if ([self mediaUID] == nil)
        return [NSSet set];
    return [NSSet setWithObject:[self mediaUID]];
}

// Gives the media file its original document name, next to it.
- (void)renameGEDocument
{
    [self urlFromMedia];
    NSString *path = [[[_urlFromMedia path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[_documentURL lastPathComponent]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path] && ![manager moveItemAtPath:[_urlFromMedia path] toPath:path error:NULL])
        return;
    [_urlFromMedia release];
    _urlFromMedia = [[NSURL alloc] initFileURLWithPath:path];
}

- (void)updateMediaUID
{
    if (_documentURL == nil)
        return;
    [_media release];
    _media = [[HSNewMedia mediaWithPath:[_documentURL path]] retain];
    [_mediaUID release];
    _mediaUID = [[_media mediaUID] retain];
}

- (void)setDocumentURL:(id)aURL
{
    if ([aURL isEqual:[self URL]])
        return;
    [_documentURL release];
    _documentURL = [aURL retain];
}

- (id)documentURL
{
    return _documentURL;
}

- (void)setOpenLocationAction:(id)aAction
{
    [_openLocationAction release];
    _openLocationAction = [aAction retain];
}

- (id)openLocationAction
{
    if (_openLocationAction == nil) {
        _openLocationAction = [HSOpenLocationAction new];
        [_openLocationAction setOpensDocument:YES];
        [_openLocationAction setOpensApplication:YES];
        [_openLocationAction setApplicationName:@"Google Earth"];
    }
    return _openLocationAction;
}

- (id)urlFromMedia
{
    if (_urlFromMedia == nil)
        _urlFromMedia = [[NSURL fileURLWithPath:[[self media] fullPathToMediaFileCreateIfNeeded:YES] isDirectory:NO] retain];
    return _urlFromMedia;
}

- (void)dealloc
{
    [_openLocationAction release];
    [_media release];
    [_urlFromMedia release];
    [_documentURL release];
    [_mediaUID release];
    [_googleEarthExport release];
    [_textInProgress release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
