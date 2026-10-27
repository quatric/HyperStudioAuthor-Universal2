#import "HyperEditorBasePrefix.h"


@interface HSPreviewDocument : HSPlayerDocument
{
    HSDocument *_originalDocument;
}
- (void)closePlayer;
- (id)initWithOriginal:(id)aOriginal;
- (id)initForExportWithDocument:(id)aDocument;
- (id)init;
- (id)fileName;
- (id)fileURL;
- (id)displayName;
- (void)invalidateOriginal:(id)aOriginal;
- (id)modeSwitcher;
@end

