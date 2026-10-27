#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteEvents : KeynoteObject
{
    NSMutableArray *_mediaStartBuilds;
}
- (id)eventTypeForMediaId:(id)aId;
- (id)mediaStartBuilds;
- (id)builds;
- (void)dealloc;
@end

