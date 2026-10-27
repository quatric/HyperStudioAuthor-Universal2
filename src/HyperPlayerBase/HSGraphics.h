#import "HyperPlayerBasePrefix.h"


@interface HSGraphics : NSObject <HSMutableGraphics, HSGraphics, HyperInterface, NSObject, EXKeyValueCoding, NSCopying>
{
    id<HSGraphicsDelegate> _owner;
}
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (id)copyWithZone:(NSZone *)aZone;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)willRemoveFromDocument;
- (void)didAddToDocument;
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)postDidChange;
- (id)hyperMutableCopyWithZone:(NSZone *)aZone;
- (id)undoManager;
- (void)setHyperOwner:(id)aOwner;
- (id)owner;
- (id)initWithOwner:(id)aOwner;
- (id)init;
@end

