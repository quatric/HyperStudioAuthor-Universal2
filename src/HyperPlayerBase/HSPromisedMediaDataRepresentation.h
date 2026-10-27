#import "HyperPlayerBasePrefix.h"
#import "HSMediaRepresentation.h"


@interface HSPromisedMediaDataRepresentation : HSMediaRepresentation
{
    id<HSPromisedMediaDataRepresentationOwner> _owner;
}
- (id)mediaType;
- (id)mediaData;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (id)initWithDataOwner:(id)aOwner;
@end

