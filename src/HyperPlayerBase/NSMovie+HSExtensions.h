#import "HyperPlayerBasePrefix.h"


@interface NSMovie (HSExtensions)
+ (id)movieWithHyperMedia:(id)aMedia;
+ (id)movieWithHyperMedia:(id)aMedia error:(id *)aError;
+ (id)movieWithHyperData:(id)aData ofType:(id)aType;
- (void)filterMediaByType:(NSInteger)aType;
- (NSUInteger)maxVideoFrameCount;
- (void)normalizeBox;
- (NSSize)size;
- (id)movieHyperDataRepresentation;
- (id)initWithHyperMedia:(id)aMedia;
- (id)initWithHyperMedia:(id)aMedia error:(id *)aError;
- (id)initWithHyperData:(id)aData ofType:(id)aType;
- (id)initWithHyperURL:(id)aURL byReference:(BOOL)aReference error:(id *)aError;
@end

