#import "HSImageSequenceExporter.h"

@implementation HSImageSequenceExporter

- (BOOL)isActiveStoryboardMode
{
    return [[self dataSource] isExportDocumentInStoryboardMode];
}

- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    NSIndexSet *indexes = [[self dataSource] exportedCardIndexesForExporter:self onlySelected:[self isExportOnlySelectedCards]];
    double progressStep = [indexes count] == 0 ? 100.0 : (double)(100.0f / (float)[indexes count]);
    _shouldTerminateExport = NO;
    [self notifyExportWillStartWithSlideshowAttributes:nil];
    [self notifyExportDidStart];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    [wrapper setPreferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:@"images"]];
    [self notifyExportProgressDidChangeWithProgress:0.0];
    BOOL succeeded = indexes != nil;
    NSUInteger index = indexes != nil ? [indexes firstIndex] : NSNotFound;
    NSFileWrapper *result = wrapper;
    if (index != NSNotFound && indexes != nil) {
        int number = 1;
        do {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            id image = [[self dataSource] imageForCardAtIndex:index forExporter:self];
            NSData *data = [[NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]] representationUsingType:NSBitmapImageFileTypePNG properties:[NSDictionary dictionary]];
            NSString *name = [[self exportedDocumentName] stringByAppendingFormat:@"%03i.%@", number, @"png"];
            if (data == nil || [wrapper addRegularFileWithContents:data preferredFilename:name] == nil || _shouldTerminateExport) {
                succeeded = NO;
            } else {
                [self notifyExportProgressDidChangeWithProgress:progressStep];
                succeeded = YES;
            }
            index = [indexes indexGreaterThanIndex:index];
            [pool release];
            number++;
        } while (index != NSNotFound && succeeded);
        if (succeeded && number == 2) {
            NSString *name = [[self exportedDocumentName] stringByAppendingFormat:@"%03i.%@", 1, @"png"];
            result = [[wrapper fileWrappers] objectForKey:name];
            if (result == nil || _shouldTerminateExport) {
                succeeded = NO;
                result = wrapper;
            } else {
                [result retain];
                [wrapper release];
                [result setPreferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:@"png"]];
            }
        }
    }
    [_exportRepresentation autorelease];
    if (succeeded) {
        _exportRepresentation = [result retain];
        [result release];
        [self notifyExportDidEnd];
        return;
    }
    _exportRepresentation = nil;
    [result release];
    if (_shouldTerminateExport)
        [self notifyExportDidTerminate];
    else
        [self notifyExportErrorInProgress:[HSError errorWithHSCode:0x5025]];
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ExportSheetProgressImageSequenceDescription" value:@"" table:@"Export"];
}

- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType
{
    if (_exportAccessoryViewController == nil)
        _exportAccessoryViewController = [[HSImageSequenceExportAccessoryViewController alloc] initWithExporter:self publishType:aType];
    return _exportAccessoryViewController;
}

- (void)setExportOnlySelectedCards:(BOOL)aCards
{
    if ((BOOL)_isExportOnlySelectedCards != aCards)
        _isExportOnlySelectedCards = aCards;
}

- (BOOL)isExportOnlySelectedCards
{
    return _isExportOnlySelectedCards;
}

- (BOOL)isExportOnlyOneCard
{
    return [[self dataSource] countExistedCards] == 1;
}

- (NSUInteger)countExportedCards
{
    return [[[self dataSource] exportedCardIndexesForExporter:self onlySelected:[self isExportOnlySelectedCards]] count];
}

- (void)setDataSource:(id)aSource
{
    [super setDataSource:aSource];
}

@end
