#import "HSImportProgressDialog.h"
// The progress panel of an old-format stack import, run as a modal session
// that's given time whenever the progress changes.
@implementation HSImportProgressDialog
- (void)cancelImport:(id)aImport
{
    [_importer cancelImport];
}
- (id)importer
{
    return _importer;
}
- (void)setImporter:(id)aImporter
{
    if (_importer != aImporter) {
        [_importer autorelease];
        _importer = [aImporter retain];
    }
}
- (void)stopModalSession:(struct _NSModalSession *)aSession
{
    [NSApp endModalSession:aSession];
    [[self window] orderOut:nil];
}
- (struct _NSModalSession *)runModalSession
{
    _session = [NSApp beginModalSessionForWindow:[self window]];
    [NSApp runModalSession:_session];
    return _session;
}
// The bar never goes back.
- (void)setValue:(double)aValue
{
    if ([_progressBar doubleValue] < aValue)
        [_progressBar setDoubleValue:aValue];
    [_progressBar displayIfNeeded];
    if (_session != NULL)
        [NSApp runModalSession:_session];
}
// Back to the indeterminate "converting" state.
- (void)finishCurrentOperation
{
    [_taskDescription setStringValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OldFileFormatImportCoverting" value:@"" table:@"ImportLocalizable"]];
    [_taskDescription displayIfNeeded];
    [_progressBar setIndeterminate:YES];
    [_progressBar startAnimation:nil];
    [_progressBar displayIfNeeded];
}
- (void)startOperationName:(id)aName minValue:(double)aValue maxValue:(double)aValue2
{
    [_taskDescription setStringValue:aName];
    [_taskDescription displayIfNeeded];
    [_progressBar stopAnimation:nil];
    [_progressBar setIndeterminate:NO];
    [_progressBar setMinValue:aValue];
    [_progressBar setMaxValue:aValue2];
    [_progressBar setDoubleValue:aValue];
    [_progressBar displayIfNeeded];
}
- (void)windowDidLoad
{
    [[self window] setTitle:_title];
    [_taskDescription setStringValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OldFileFormatImportCoverting" value:@"" table:@"ImportLocalizable"]];
    [_progressBar setUsesThreadedAnimation:YES];
    [_progressBar startAnimation:nil];
    [_progressBar displayIfNeeded];
}
- (id)initWithTitle:(id)aTitle
{
    self = [super initWithWindowNibName:@"ImportProgressDialog"];
    if (self != nil)
        _title = [aTitle retain];
    return self;
}
- (void)dealloc
{
    [_title release];
    [_importer release];
    _session = NULL;
    [super dealloc];
}
@end
