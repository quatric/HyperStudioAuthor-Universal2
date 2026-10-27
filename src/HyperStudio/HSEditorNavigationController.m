#import "HSEditorNavigationController.h"

@implementation HSEditorNavigationController

+ (BOOL)documentCanGoHome:(id)aHome
{
    return ![aHome isInStoryboardMode];
}

@end
