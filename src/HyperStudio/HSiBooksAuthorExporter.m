#import "HSiBooksAuthorExporter.h"

@implementation HSiBooksAuthorExporter

- (void)finalizeExportForDocument:(id)aDocument
{
    [super finalizeExportForDocument:aDocument];

    NSData *info = [self infoPlistDataForDocument:aDocument];
    if (info != nil)
        [_exportRepresentation addRegularFileWithContents:info preferredFilename:@"Info.plist"];
    NSData *preview = [self stackPreviewForDocument:aDocument];
    if (preview != nil)
        [_exportRepresentation addRegularFileWithContents:preview preferredFilename:@"Default.png"];
    [self removeNeedlessResources];
}

static void HSRemoveChildWrapper(NSFileWrapper *aDirectory, NSString *aName)
{
    NSFileWrapper *child = [[aDirectory fileWrappers] objectForKey:aName];
    if (child != nil)
        [aDirectory removeFileWrapper:child];
}

- (void)removeNeedlessResources
{
    NSFileWrapper *data = [[_exportRepresentation fileWrappers] objectForKey:@"data"];
    if (data == nil)
        return;
    NSFileWrapper *engine = [[data fileWrappers] objectForKey:@"engine"];
    if (engine == nil)
        return;
    HSRemoveChildWrapper(engine, @"chromeFrame.html");
    NSFileWrapper *templates = [[engine fileWrappers] objectForKey:@"templates"];
    if (templates == nil)
        return;
    HSRemoveChildWrapper(templates, @"flash");
    NSFileWrapper *img = [[templates fileWrappers] objectForKey:@"img"];
    if (img == nil)
        return;
    HSRemoveChildWrapper(img, @"empty.cur");
    HSRemoveChildWrapper(img, @"spin.gif");
}

// Objects that cannot play in an HTML5 widget are hidden while the first card is rendered.
- (id)stackPreviewForDocument:(id)aDocument
{
    id card = [[aDocument stack] hyperChildAtIndex:0];
    NSMutableArray *hidden = [NSMutableArray new];

    for (id child in [card hyperChildren]) {
        if (([child implementsHyperInterface:@protocol(HSLiveVideoAttributes)] || [child implementsHyperInterface:@protocol(HSMovieObjectAttributes)])
            && ![child canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"]) {
            [child setHidden:YES];
            [hidden addObject:child];
        }
    }
    id preview = [card previewForHTML5Export];
    for (id child in hidden)
        [child setHidden:NO];
    [hidden release];
    return [preview hyperPNGRepresentation];
}

- (id)infoPlistDataForDocument:(id)aDocument
{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSMutableDictionary *info = nil;
    NSData *data = nil;

    if ([path length] == 0)
        return nil;
    path = [path stringByAppendingPathComponent:@"iBooksAuthor.wdgt"];
    if ([path length] == 0)
        return nil;
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    if (bundle == nil)
        return nil;
    info = [[bundle infoDictionary] mutableCopy];
    if ([info count] == 0)
        goto done;

    NSString *name = [self exportedDocumentName];
    if ([name length] == 0)
        goto done;
    NSString *identifierKey = (NSString *)kCFBundleIdentifierKey;
    NSString *identifier = [info objectForKey:identifierKey];
    if (![identifier isKindOfClass:[NSString class]])
        goto done;
    id stack = [aDocument stack];
    if (stack == nil)
        goto done;
    NSString *uid = [[stack hyperUID] stringValue];
    if (uid == nil)
        goto done;
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    if (uuid == NULL)
        goto done;
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    if (uuidString == NULL)
        goto done;
    identifier = [identifier stringByAppendingFormat:@".%@.%@", uid, (NSString *)uuidString];
    CFRelease(uuidString);
    if ([identifier length] == 0)
        goto done;

    NSNumber *height = [[NSNumber alloc] initWithFloat:_widgetSize.height];
    if (height == nil)
        goto done;
    NSNumber *width = [[NSNumber alloc] initWithFloat:_widgetSize.width];
    if (width == nil) {
        [height release];
        goto done;
    }
    name = [name stringByDeletingPathExtension];
    [info setObject:name forKey:(NSString *)kCFBundleNameKey];
    [info setObject:name forKey:@"CFBundleDisplayName"];
    [info setObject:identifier forKey:identifierKey];
    [info setObject:height forKey:@"Height"];
    [height release];
    [info setObject:width forKey:@"Width"];
    [width release];
    [info removeObjectForKey:@"CFBundleInfoPlistURL"];
    [info removeObjectForKey:@"CFBundleNumericVersion"];
    [info removeObjectForKey:@"NSBundleInitialPath"];
    [info removeObjectForKey:@"NSBundleResolvedPath"];
    data = [NSPropertyListSerialization dataFromPropertyList:info format:NSPropertyListXMLFormat_v1_0 errorDescription:NULL];
done:
    [info release];
    return data;
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ExportSheetProgressiBooksAuthorDescription" value:@"" table:@"Export"];
}

- (id)exportedDocumentName
{
    return [[super exportedDocumentName] stringByAppendingFormat:@".%@", @"wdgt"];
}

- (id)escapeFileNameForExport:(id)aName
{
    return [[[NSURL fileURLWithPath:aName isDirectory:NO] relativeString] extraStringByReplacingURLEscapedSymbolsWithUnderscores];
}

- (id)requiredFileType
{
    return @"wdgt";
}

@end
