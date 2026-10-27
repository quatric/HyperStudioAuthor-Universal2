#import "HyperStudioPrefix.h"
#import "HSViewController.h"


@interface HSExportAccessoryViewController : HSViewController
{
    id _exporter;
    NSTextView *_descriptionTextView;
    HSExportPanelController *_exportPanelController;
    int _publishType;
    NSDictionary *_descriptionDictionary;
}
- (BOOL)textView:(id)aView clickedOnLink:(id)aLink atIndex:(NSUInteger)aIndex;
- (id)exportToDiskDescription;
- (id)descriptionForKey:(id)aKey;
- (id)descriptionDictionary;
- (void)detachFromExporter;
- (void)refreshDescriptionForPublishType:(NSInteger)aType;
- (void)setExportPanelController:(id)aController;
- (id)exportPanelController;
- (void)awakeFromNib;
- (void)dealloc;
- (id)initWithExporter:(id)aExporter publishType:(NSInteger)aType;
@end

