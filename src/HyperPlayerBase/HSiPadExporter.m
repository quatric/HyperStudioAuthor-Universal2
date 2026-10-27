#import "HSiPadExporter.h"
#import "HSApplicationController.h"
#import "HSDocument.h"
#import "HSErrorsAlert.h"
#import "HSExecutableResourceProvider.h"
#import "HSUID.h"
#import "HSUserObject.h"
#import "HSZipDirectoryWrapper.h"
#import "HSZipWrapper.h"
#import "HSiPadExportContext.h"
#import "HSiPadExporterHelper.h"
#import "NSFileWrapper+HSExtensions.h"

// Writes a stack as an iPad stack: a zip with a Contents folder holding
// Info.plist, document.xml, one XML file per card, and the media under
// Resources (listed in media.xml). Cards larger than 1024x768 can be scaled
// down first.
@implementation HSiPadExporter

// Each action that can't run on the iPad, named once.
- (BOOL)containsDocument:(id)aDocument iPadUnsupportedActions:(id *)aActions
{
    NSArray *objects = nil;
    NSArray *actions = [self actionsInDocumentThatCannotBeRun:aDocument forObjects:&objects];
    NSMutableArray *names = [NSMutableArray array];
    if ([actions count] != 0 && [objects count] == [actions count]) {
        for (id action in actions) {
            NSString *name = [NSString stringWithFormat:@"Action %@", action];
            if (![names containsObject:name])
                [names addObject:name];
        }
    }
    if ([names count] == 0)
        return NO;
    *aActions = [NSArray arrayWithArray:names];
    return YES;
}

- (BOOL)containsDocument:(id)aDocument iPadUnsupportedFeatures:(id *)aFeatures
{
    NSMutableArray *features = [NSMutableArray array];
    BOOL found = NO;
    NSEnumerator *enumerator = [[aDocument stack] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if (![[object class] isSubclassOfClass:[HSUserObject class]] || ![object hasiPadUnsupportedFunctionality])
            continue;
        found = YES;
        for (id feature in [object iPadUnsupportedFunctionalityDescription]) {
            if (![features containsObject:feature])
                [features addObject:feature];
        }
    }
    if ([features count] != 0)
        *aFeatures = [NSArray arrayWithArray:features];
    return found;
}

// Quirk kept: true as soon as a card (with its children) has three play
// movie actions, despite the name.
- (BOOL)isStackHasMoreThanThreePlayMovieActionsPerCardInDocument:(id)aDocument
{
    id stack = [aDocument stack];
    for (id card in [stack hyperChildren]) {
        id actor = [card queryHyperInterface:@protocol(HSActor)];
        if (actor == nil)
            continue;
        NSMutableArray *actions = [NSMutableArray arrayWithArray:[actor hyperActions]];
        if ([card implementsHyperInterface:@protocol(HSNodeContainerChildrenAttribute)]) {
            for (id child in [card hyperChildren])
                [actions addObjectsFromArray:[[child queryHyperInterface:@protocol(HSActor)] hyperActions]];
        }
        NSUInteger count = 0;
        for (id action in actions) {
            if ([action implementsHyperInterface:@protocol(HSPlayMovieActionAttributes)])
                count++;
            if (count == 3)
                return YES;
        }
    }
    return NO;
}

// Unsupported features and actions, too many movies per card, and cards too
// big for the iPad each get an alert; any can cancel the export.
- (BOOL)documentCanBeExported:(id)aExported showAlertIfNeeded:(BOOL)aNeeded
{
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSMutableArray *problems = [[NSMutableArray alloc] init];
    NSArray *features = nil;
    if ([self containsDocument:aExported iPadUnsupportedFeatures:&features] && [features count] != 0)
        [problems addObjectsFromArray:features];
    NSArray *actions = nil;
    if ([self containsDocument:aExported iPadUnsupportedActions:&actions])
        [problems addObjectsFromArray:actions];
    BOOL canBeExported = YES;
    if ([problems count] == 0) {
        [problems release];
    } else {
        HSErrorsAlert *alert = [[HSErrorsAlert alloc] init];
        [alert setMessageText:[resources localizedStringForKey:@"HSiPadExportUnsupportedFeaturesMessageText" value:@"" table:@"Export"]];
        [alert setInformativeText:[resources localizedStringForKey:@"HSiPadExportUnsupportedFeaturesInformativeText" value:@"" table:@"Export"]];
        [alert addButtonWithTitle:[resources localizedStringForKey:@"HSiPadExportUnsupportedFeaturesExport" value:@"" table:@"Export"]];
        [alert addButtonWithTitle:[resources localizedStringForKey:@"HSiPadExportUnsupportedFeaturesCancel" value:@"" table:@"Export"]];
        [alert setBottomInformativeText:[resources localizedStringForKey:@"HSiPadExportUnsupportedFeaturesBottomInformativeText" value:@"" table:@"Export"]];
        [alert setScriptErrors:problems isSimpleView:YES];
        NSInteger response = [alert runModal];
        [alert release];
        [problems release];
        canBeExported = response != NSAlertSecondButtonReturn;
    }
    if (canBeExported) {
        if ([self isStackHasMoreThanThreePlayMovieActionsPerCardInDocument:aExported] && aNeeded) {
            NSString *message = [resources localizedStringForKey:@"HSiPadExportMoreThan3PlayMovieActionsPerCardAlertMessageText" value:@"" table:@"Export"];
            NSString *informativeText = [resources localizedStringForKey:@"HSiPadExportMoreThan3PlayMovieActionsPerCardAlertInformativeText" value:@"" table:@"Export"];
            NSString *continueTitle = [resources localizedStringForKey:@"HSiPadExportMoreThan3PlayMovieActionsPerCardContinueButtonTitle" value:@"" table:@"Export"];
            NSString *cancelTitle = [resources localizedStringForKey:@"HSiPadExportMoreThan3PlayMovieActionsPerCardCancelButtonTitle" value:@"" table:@"Export"];
            NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:continueTitle alternateButton:cancelTitle otherButton:nil informativeTextWithFormat:@"%@", informativeText];
            if ([alert runModal] == NSAlertAlternateReturn)
                canBeExported = NO;
        }
    }
    if (canBeExported) {
        NSSize size = NSZeroSize;
        if ([self cardsShouldBeScaledDownBeforeExportDocument:aExported toSize:&size] && aNeeded) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *message = [bundle localizedStringForKey:@"HSiPadExportMaxCardSizeAlertMessageText" value:@"" table:@"Export"];
            NSString *informativeText = [NSString stringWithFormat:[bundle localizedStringForKey:@"HSiPadExportMaxCardSizeAlertInformativeText" value:@"" table:@"Export"], 1024.0, 768.0];
            NSString *scaleDownTitle = [bundle localizedStringForKey:@"HSiPadExportAlertScaleDownButtonTitle" value:@"" table:@"Export"];
            NSString *cancelTitle = [bundle localizedStringForKey:@"HSiPadExportAlertCancelButtonTitle" value:@"" table:@"Export"];
            NSString *asIsTitle = [bundle localizedStringForKey:@"HSiPadExportAlertExportAsIsButtonTitle" value:@"" table:@"Export"];
            NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:scaleDownTitle alternateButton:cancelTitle otherButton:asIsTitle informativeTextWithFormat:@"%@", informativeText];
            NSInteger response = [alert runModal];
            if (response == NSAlertAlternateReturn)
                canBeExported = NO;
            else if (response == NSAlertDefaultReturn)
                [self scaleCardsDownIfNeededForDocument:aExported];
        }
    }
    return canBeExported;
}

- (void)scaleCardsDownIfNeededForDocument:(id)aDocument
{
    NSSize size = NSZeroSize;
    if ([self cardsShouldBeScaledDownBeforeExportDocument:aDocument toSize:&size])
        [[aDocument stack] setHyperCardSize:size];
}

// The size fitting 1024x768, and whether the cards exceed it (by more than
// 0.0005 of the larger magnitude, compared as floats).
- (BOOL)cardsShouldBeScaledDownBeforeExportDocument:(id)aDocument toSize:(NSSize *)aSize
{
    NSSize size = [[aDocument stack] hyperCardSize];
    float width = size.width;
    float height = size.height;
    float scale = fmaxf(width / 1024.0f, height / 768.0f);
    aSize->width = roundf(width / scale);
    aSize->height = roundf(height / scale);
    float magnitude = MAX(width != 0.0f ? fabsf(width) : 1.0f, 1024.0f);
    if (magnitude * 0.0005f + 1024.0f < width)
        return YES;
    magnitude = MAX(height != 0.0f ? fabsf(height) : 1.0f, 768.0f);
    return magnitude * 0.0005f + 768.0f < height;
}

- (id)mediaXMLElementUID
{
    if (_mediaXMLElementUID == nil)
        _mediaXMLElementUID = [[HSUID UID] retain];
    return _mediaXMLElementUID;
}

// The export for previewing, after an alert listing what won't work on the
// iPad. Cards are scaled down for the export only.
- (id)previewFileWrapperForDocument:(id)aDocument
{
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSMutableArray *problems = [[NSMutableArray alloc] init];
    if ([self shouldVerifyDocumentActions] && [self doesDocumentContainActionsThatCannotBeRun:aDocument]) {
        NSArray *actions = nil;
        if ([self containsDocument:aDocument iPadUnsupportedActions:&actions])
            [problems addObjectsFromArray:actions];
    }
    NSArray *features = nil;
    if ([self containsDocument:aDocument iPadUnsupportedFeatures:&features] && [features count] != 0)
        [problems addObjectsFromArray:features];
    NSSize size = NSZeroSize;
    if ([self cardsShouldBeScaledDownBeforeExportDocument:aDocument toSize:&size]) {
        NSString *text = [NSString stringWithFormat:[resources localizedStringForKey:@"HSPreviewiPadStackWithTooBigCardsInformativeText" value:@"" table:@"Alerts"], 1024.0, 768.0, (double)size.width, (double)size.height];
        [problems addObject:[NSString stringWithFormat:@"%@\n", text]];
    }
    if ([problems count] != 0) {
        HSErrorsAlert *alert = [[HSErrorsAlert alloc] init];
        [alert setMessageText:[resources localizedStringForKey:@"HSPreviewiPadExportUnsupportedFeaturesMessageText" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[resources localizedStringForKey:@"HSPreviewiPadStackWithUnsupportedFeaturesInformativeText" value:@"" table:@"Alerts"]];
        [alert setBottomInformativeText:[resources localizedStringForKey:@"HSPreviewiPadExportUnsupportedFeaturesBottomInformativeText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[resources localizedStringForKey:@"HSPreviewiPadExportUnsupportedFeaturesPreview" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[resources localizedStringForKey:@"HSPreviewiPadExportUnsupportedFeaturesCancel" value:@"" table:@"Alerts"]];
        [alert setScriptErrors:problems isSimpleView:YES];
        NSInteger response = [alert runModal];
        [alert release];
        if (response == NSAlertSecondButtonReturn) {
            [problems release];
            return nil;
        }
    }
    [problems release];
    NSUndoManager *undoManager = [[aDocument stack] undoManager];
    [undoManager disableUndoRegistration];
    NSSize cardSize = [[aDocument stack] hyperCardSize];
    [self scaleCardsDownIfNeededForDocument:aDocument];
    id wrapper = [self fileWrapperForDocument:aDocument];
    [[aDocument stack] setHyperCardSize:cardSize];
    [undoManager enableUndoRegistration];
    return wrapper;
}

- (void)terminateExport
{
    [_context setShouldTerminateExport:YES];
}

- (id)fileWrapperForDocument:(id)aDocument
{
    NSMutableDictionary *wrappers = [[NSMutableDictionary alloc] init];
    [_mediaXMLElementUID release];
    _mediaXMLElementUID = nil;
    id contents = [self contentsWrapperForDocument:aDocument withResFolder:nil];
    if (contents == nil) {
        [wrappers release];
        return nil;
    }
    [wrappers setObject:contents forKey:@"Contents"];
    HSZipWrapper *wrapper = [[HSZipWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    [wrappers release];
    return [wrapper autorelease];
}

- (id)contentsWrapperForDocument:(id)aDocument withResFolder:(id)aFolder
{
    NSMutableDictionary *wrappers = [[NSMutableDictionary alloc] init];
    [_context release];   // the original leaked the previous context
    _context = [[HSiPadExportContext alloc] initWithDocument:aDocument];
    [wrappers addEntriesFromDictionary:[self cardWrappersWithContext:_context]];
    [wrappers setObject:[self documentWrapperWithContext:_context] forKey:@"document.xml"];
    NSDictionary *resources = [self resourcesWrappersWithContext:_context withResFolder:aFolder];
    if (resources != nil)
        [wrappers addEntriesFromDictionary:resources];
    [wrappers setObject:[self infoPlistWrapper] forKey:@"Info.plist"];
    HSZipDirectoryWrapper *wrapper = [[HSZipDirectoryWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    [wrappers release];
    return [wrapper autorelease];
}

// The media files go into Resources, named after the media; a resources
// folder from an earlier export keeps its file names (read from the media
// accessor plists) and those files aren't added again. Video that hasn't been
// converted is marked "/Compatible".
- (id)resourcesWrappersWithContext:(id)aContext withResFolder:(id)aFolder
{
    NSMutableDictionary *wrappers = [[NSMutableDictionary alloc] init];
    NSXMLElement *root = [NSXMLElement elementWithName:@"resource"];
    [root addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[[self mediaXMLElementUID] stringValue]]];
    HSZipDirectoryWrapper *resources = [[HSZipDirectoryWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    NSMutableSet *addedUIDs = [NSMutableSet new];
    NSMutableDictionary *existingNames = [NSMutableDictionary dictionary];
    NSDictionary *existingWrappers = nil;
    if (aFolder != nil) {
        existingWrappers = [aFolder fileWrappers];
        NSDictionary *accessorWrappers = [[existingWrappers objectForKey:@"MediaAccessor"] fileWrappers];
        if (accessorWrappers != nil) {
            for (NSString *key in [existingWrappers allKeys]) {
                if ([[[existingWrappers objectForKey:key] preferredFilename] isEqualToString:key])
                    continue;
                NSFileWrapper *plistWrapper = [accessorWrappers objectForKey:[key stringByAppendingPathExtension:@"plist"]];
                if (plistWrapper == nil)
                    continue;
                id plist = [NSPropertyListSerialization propertyListFromData:[plistWrapper regularFileContents] mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
                if (plist != nil)
                    [existingNames setObject:key forKey:[[plist objectForKey:@"uid"] objectForKey:@"stringValue"]];
            }
        }
    }
    for (id media in [aContext mediaArray]) {
        if ([addedUIDs containsObject:[media mediaUID]])
            continue;
        NSFileWrapper *fileWrapper = [media fileWrapper];
        if (fileWrapper == nil)
            continue;
        [addedUIDs addObject:[media mediaUID]];
        NSString *name = [existingNames objectForKey:[[media mediaUID] stringValue]];
        if (name == nil)
            name = [[media mediaName] lowercaseString];
        NSString *filename = name;
        if ([name length] == 0) {
            NSString *type = [media mediaType];
            filename = type != nil ? [@"media" stringByAppendingPathExtension:type] : @"media";
        } else if ([[name pathExtension] length] == 0 && [[media mediaType] length] != 0) {
            filename = [name stringByAppendingPathExtension:[media mediaType]];
        }
        id existingWrapper = [existingWrappers objectForKey:filename];
        if (existingWrapper == nil) {
            [fileWrapper setPreferredFilename:filename];
            filename = [resources addFileWrapper:fileWrapper];
        }
        NSXMLElement *item = [NSXMLElement elementWithName:@"mediaItem"];
        [item addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[[media mediaUID] stringValue]]];
        NSString *MIMEType = [HSiPadExporterHelper MIMETypeForExtension:[media mediaType]];
        if ([MIMEType rangeOfString:@"video"].length != 0 && [aContext convertedMediaForKey:[name lowercaseString]] == nil)
            MIMEType = [MIMEType stringByAppendingString:@"/Compatible"];
        [item addAttribute:[NSXMLNode attributeWithName:@"mimetype" stringValue:([MIMEType length] != 0 ? MIMEType : @"")]];
        NSString *target = [@"Resources" stringByAppendingPathComponent:filename];
        if (existingWrapper == nil)
            target = [@"iPadStack" stringByAppendingPathComponent:target];
        [item addAttribute:[NSXMLNode attributeWithName:@"target" stringValue:target]];
        [root addChild:item];
    }
    [addedUIDs release];
    [wrappers setObject:resources forKey:@"Resources"];
    [resources release];
    NSXMLDocument *document = [NSXMLDocument documentWithRootElement:root];
    [document setVersion:@"1.0"];
    [document setCharacterEncoding:@"UTF-8"];
    NSFileWrapper *mediaWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[document XMLDataWithOptions:NSXMLNodePrettyPrint | NSXMLNodeCompactEmptyElement]];
    [wrappers setObject:mediaWrapper forKey:@"media.xml"];
    [mediaWrapper release];
    return [wrappers autorelease];
}

- (id)infoPlistWrapper
{
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"5.1", @"CompatibilityVersionNumber",
                          [HSDocument currentDocumentVersion], @"HSDocumentVersion",
                          [HSDocument currentDocumentCompatibilityVersion], @"HSDocumentCompatibilityVersion",
                          [HSApplicationController buildVersionString], @"HSDocumentCreatorVersion", nil];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithHyperDictionary:info];
    [info release];
    return [wrapper autorelease];
}

- (id)documentWrapperWithContext:(id)aContext
{
    id stack = [[aContext document] stack];
    NSXMLElement *root = [NSXMLElement elementWithName:@"document"];
    [root addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[[HSUID UID] stringValue]]];
    [root addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"5.1"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"revision" stringValue:@"0"]];
    [root addChild:[stack XMLElementRepresentationInContext:aContext]];
    NSXMLElement *resourceRef = [NSXMLElement elementWithName:@"resourceref"];
    [resourceRef addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[self mediaXMLElementUID] stringValue]]];
    [resourceRef addAttribute:[NSXMLNode attributeWithName:@"target" stringValue:@"media.xml"]];
    [root addChild:resourceRef];
    NSXMLDocument *document = [NSXMLDocument documentWithRootElement:root];
    [document setVersion:@"1.0"];
    [document setCharacterEncoding:@"UTF-8"];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[document XMLDataWithOptions:NSXMLNodePrettyPrint | NSXMLNodeCompactEmptyElement]];
    return [wrapper autorelease];
}

- (id)cardWrappersWithContext:(id)aContext
{
    NSMutableDictionary *wrappers = [NSMutableDictionary dictionary];
    id stack = [[aContext document] stack];
    for (id card in [stack hyperChildren]) {
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:[card XMLElementRepresentationInContext:aContext]];
        [document setVersion:@"1.0"];
        [document setCharacterEncoding:@"UTF-8"];
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[document XMLDataWithOptions:NSXMLNodePrettyPrint | NSXMLNodeCompactEmptyElement]];
        [document release];
        [wrappers setObject:wrapper forKey:[HSiPadExporterHelper filenameForCard:card]];
        [wrapper release];
    }
    return wrappers;
}

// The actions of every object and of its hypertext links.
- (BOOL)doesDocumentContainActionsThatCannotBeRun:(id)aRun
{
    NSEnumerator *enumerator = [[aRun stack] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        NSArray *links = [[object queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
        NSArray *actors = links != nil ? [links arrayByAddingObject:object] : [NSArray arrayWithObject:object];
        for (id actor in actors) {
            for (id action in [[actor queryHyperInterface:@protocol(HSActor)] hyperActions]) {
                id attributes = [action queryHyperInterface:@protocol(HSActionAttributes)];
                if (attributes != nil && ![self canRunAction:attributes])
                    return YES;
            }
        }
    }
    return NO;
}

// The names of the actions that can't run, and for each a description of
// its object (a card, the stack, or an object on a card).
- (id)actionsInDocumentThatCannotBeRun:(id)aRun forObjects:(id *)aObjects
{
    NSMutableArray *actionNames = [NSMutableArray array];
    NSMutableArray *objectNames = [NSMutableArray array];
    id stack = [aRun stack];
    for (id object in [stack hyperDeepEnumerator]) {
        NSArray *links = [[object queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
        NSArray *actors = links != nil ? [links arrayByAddingObject:object] : [NSArray arrayWithObject:object];
        for (id actor in actors) {
            for (id action in [[actor queryHyperInterface:@protocol(HSActor)] hyperActions]) {
                id attributes = [action queryHyperInterface:@protocol(HSActionAttributes)];
                if (attributes == nil || [self canRunAction:attributes])
                    continue;
                [actionNames addObject:[NSString stringWithFormat:@"\"%@\"", [attributes localizedName]]];
                id objectAttributes = [[action hyperObject] queryHyperInterface:@protocol(HSObjectAttributes)];
                id name = objectAttributes != nil ? [objectAttributes hyperName] : @"";
                NSString *description;
                if ([[action hyperObject] implementsHyperInterface:@protocol(HSCardAttributes)]) {
                    description = [NSString stringWithFormat:@"%@ %d \"%@\"", [[action hyperObject] hyperKindDisplayName], (int)[[action hyperObject] hyperIndex] + 1, name];
                } else if ([[action hyperObject] implementsHyperInterface:@protocol(HSStackAttributes)]) {
                    id stackAttributes = [[action hyperObject] queryHyperInterface:@protocol(HSStackAttributes)];
                    if (stackAttributes != nil)
                        name = [[stackAttributes document] displayName];
                    description = [NSString stringWithFormat:@"%@ \"%@\"", [objectAttributes hyperKindDisplayName], name];
                } else {
                    id card = [[action hyperObject] card];
                    description = [NSString stringWithFormat:@"%@ \"%@\" at %@ %d", [objectAttributes hyperKindDisplayName], name, [card hyperKindDisplayName], (int)[card hyperIndex] + 1];
                }
                [objectNames addObject:description];
            }
        }
    }
    if (aObjects != NULL)
        *aObjects = [NSArray arrayWithArray:objectNames];
    return [NSArray arrayWithArray:actionNames];
}

- (BOOL)canRunAction:(id)aAction
{
    return [aAction supportedInIPad];
}

- (BOOL)shouldVerifyDocumentActions
{
    return YES;
}

- (void)dealloc
{
    [_mediaXMLElementUID release];
    [_context release];
    [super dealloc];
}

@end
