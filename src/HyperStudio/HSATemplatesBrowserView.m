#import "HSATemplatesBrowserView.h"

@implementation HSATemplatesBrowserView

- (id)newCellForRepresentedItem:(id)aItem
{
    return [HSATemplateImageBrowserCell new];
}

@end
