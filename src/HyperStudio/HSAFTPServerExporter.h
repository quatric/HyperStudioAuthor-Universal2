#import "HyperStudioPrefix.h"
#import "HSHTML5Exporter.h"


@interface HSAFTPServerExporter : HSHTML5Exporter
{
    NSString *_webLocation;
}
- (void)setWebLocation:(id)aLocation;
- (id)progressSheetDescription;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (void)dealloc;
@end
