#import "HyperStudioPrefix.h"
#import "KeynoteItem.h"


@interface KeynoteImageBase : KeynoteItem <KeynoteImageContainer, NSObject>
{
    HSNewMedia *_media;
}
- (id)media;
- (id)path;
- (id)data;
- (id)image;
- (NSSize)size;
- (id)dataObject;
- (void)didDetail;
- (void)dealloc;
@end

