#import "HSAFTPServerExporter.h"
#import "HyperStudioUmbrella.h"


@implementation HSAFTPServerExporter

- (void)setWebLocation:(id)aLocation
{
    if (_webLocation != aLocation) {
        [_webLocation release];
        _webLocation = [aLocation copy];
    }
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PublishSheetProgressFTPServerDescription" value:@"" table:@"Publish"];
}

- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    _embeddedCode = [[HSHTML5Exporter embeddedCodeForDocument:aDocument cardWidth:0 cardHeight:0 urlPath:_webLocation] retain];
    [super performExportDocument:aDocument ofType:aType];
}

- (void)dealloc
{
    [_webLocation release];
    [super dealloc];
}

@end
