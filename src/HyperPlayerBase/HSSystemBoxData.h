#import "HyperPlayerBasePrefix.h"
#import "HSSystemObjectData.h"


@interface HSSystemBoxData : HSSystemObjectData
{
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setBorderType:(NSUInteger)aType;
- (NSUInteger)borderType;
- (void)setBoxTitlePosition:(NSUInteger)aPosition;
- (NSUInteger)boxTitlePosition;
- (void)setTitleFont:(id)aFont;
- (id)titleFont;
- (void)setTitle:(id)aTitle;
- (id)title;
- (id)systemBoxForSetAccessor;
- (id)systemBoxForGetAccessor;
- (id)templateCocoaView;
@end

