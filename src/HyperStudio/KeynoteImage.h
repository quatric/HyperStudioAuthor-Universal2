#import "HyperStudioPrefix.h"
#import "KeynoteImageBase.h"


@interface KeynoteImage : KeynoteImageBase
{
}
- (NSSize)size;
- (id)dataObject;
- (NSRect)croppedImageFrame;
- (id)maskPath;
- (id)alphaPath;
- (void)didInitFromParser;
@end

