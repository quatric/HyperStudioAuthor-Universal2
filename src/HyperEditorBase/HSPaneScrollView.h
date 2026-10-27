#import "HyperEditorBasePrefix.h"


@interface HSPaneScrollView : NSScrollView
{
}
- (void)viewDidEndLiveResize;
- (void)customizeScrollers;
- (id)initWithCoder:(id)aCoder;
@end

