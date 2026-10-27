#import "HSImageObjectFrameSelectionKnob.h"

@implementation HSImageObjectFrameSelectionKnob

- (Class)trackerClass
{
    return [HSImageObjectFrameResizeSelectionTracker class];
}

@end
