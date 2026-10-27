#import "HyperStudioPrefix.h"
#import "KeynoteImageBase.h"


@interface KeynoteFilteredImage : KeynoteImageBase
{
    KeynoteData *_dataObject;
}
- (NSSize)size;
- (id)dataObject;
- (void)didInitFromParser;
- (void)dealloc;
@end

