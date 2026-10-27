#import "HSPromisedMediaDataRepresentation.h"
@implementation HSPromisedMediaDataRepresentation
- (id)mediaType
{
    return [_owner mediaTypeForPromisedDataRepresentation:self];
}
// Empty data once the owner is gone.
- (id)mediaData
{
    if (_owner != nil)
        return [_owner mediaDataForPromisedDataRepresentation:self];
    return [NSData data];
}
- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}
- (id)owner
{
    return _owner;
}
// The owner isn't retained.
- (id)initWithDataOwner:(id)aOwner
{
    self = [super init];
    if (self != nil)
        _owner = aOwner;
    return self;
}
@end
