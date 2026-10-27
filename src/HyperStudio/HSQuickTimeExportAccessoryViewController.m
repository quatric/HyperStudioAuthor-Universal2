#import "HSQuickTimeExportAccessoryViewController.h"

@implementation HSQuickTimeExportAccessoryViewController

- (void)changeMovieSize:(id)aSize
{
    [_exporter setExportSettingsValue:[NSValue valueWithSize:NSSizeFromString([[[_movieSizePopUpButton selectedItem] representedObject] objectForKey:@"size"])] forKey:HSVideoExportFrameSizeKey];
}

// Lists the card sizes; the exporter's own size is added when it is none of them.
- (void)viewDidLoad
{
    BOOL canExportWithNarration;
    NSEnumerator *enumerator;
    NSDictionary *info;
    NSSize frameSize;
    BOOL isListed;

    [super viewDidLoad];
    canExportWithNarration = [[_exporter exportSettingsValueForKey:HSVideoExportAllowsNarrationKey] boolValue];
    [_exportOptionMatrix selectCellWithTag:canExportWithNarration];
    [_exporter setExportSettingsValue:[NSNumber numberWithInt:canExportWithNarration] forKey:HSVideoExportOptionKey];
    [_exportOptionMatrix setEnabled:canExportWithNarration];
    [_movieSizePopUpButton removeAllItems];
    enumerator = [[self movieSizesInfo] objectEnumerator];
    frameSize = [[_exporter exportSettingsValueForKey:HSVideoExportFrameSizeKey] sizeValue];
    isListed = NSEqualSizes(frameSize, NSZeroSize);
    while ((info = [enumerator nextObject]) != nil) {
        NSSize size = NSSizeFromString([info objectForKey:@"size"]);
        NSString *title = [NSString stringWithFormat:@"%0.0f x %0.0f %@", (double)size.width, (double)size.height, [info objectForKey:@"name"]];

        [_movieSizePopUpButton addItemWithTitle:title];
        [[_movieSizePopUpButton itemWithTitle:title] setRepresentedObject:info];
        if (!isListed && NSEqualSizes(size, frameSize))
            isListed = YES;
    }
    if (!isListed) {
        NSString *title = [NSString stringWithFormat:@"%0.0f x %0.0f %@", (double)frameSize.width, (double)frameSize.height, [[NSBundle mainBundle] localizedStringForKey:@"ExportSheetMovieSize_CurrentCardSize" value:@"" table:@"Export"]];

        info = [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromSize(frameSize), @"size", title, @"name", nil];
        [_movieSizePopUpButton addItemWithTitle:title];
        [[_movieSizePopUpButton itemWithTitle:title] setRepresentedObject:info];
    }
    [_movieSizePopUpButton selectItemAtIndex:0];
}

- (id)movieSizesInfo
{
    if (_movieSizesInfo == nil)
        _movieSizesInfo = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[HSEditorBaseID class]] pathForResource:@"CardSizes" ofType:@"plist"]];
    return _movieSizesInfo;
}

- (void)setExportPanelController:(id)aController
{
    [super setExportPanelController:aController];
    [[self exportPanelController] setRequiredFileType:@"mov"];
}

- (void)dealloc
{
    [_movieSizesInfo release];
    [super dealloc];
}

- (id)init
{
    return [super initWithNibName:@"ExportToDesktopMovieAccessoryView"];
}

@end
