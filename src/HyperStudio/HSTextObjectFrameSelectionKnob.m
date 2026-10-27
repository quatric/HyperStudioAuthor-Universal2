#import "HSTextObjectFrameSelectionKnob.h"

@implementation HSTextObjectFrameSelectionKnob

- (Class)trackerClass
{
    return [HSTextObjectFrameResizeSelectionTracker class];
}

@end
