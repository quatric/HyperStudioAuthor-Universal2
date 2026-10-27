#import "HyperPlayerBasePrefix.h"
#import "HSUserObjectInPlayerPreviewView.h"


@interface HSCardPreviewView : HSUserObjectInPlayerPreviewView
{
}
- (id)hyperBitmapImageRepresentationForRect:(NSRect *)aRect;
- (void)drawRect:(NSRect)aRect;
- (void)setFrameSize:(NSSize)aSize;
- (void)recalculateCentering;
- (void)drawBackgroundInRect:(NSRect)aRect;
- (NSSize)cardSize;
- (id)userObject;
@end

