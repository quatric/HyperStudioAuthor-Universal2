#import "HyperStudioPrefix.h"


@interface HSExportContext : NSObject
{
    HSDocument *_document;
    NSMutableArray *_mediaArray;
}
- (id)mediaArray;
- (void)addMedia:(id)aMedia;
- (id)document;
- (void)dealloc;
- (id)init;
- (id)initWithDocument:(id)aDocument;
@end

