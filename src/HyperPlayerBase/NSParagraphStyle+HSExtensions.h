#import "HyperPlayerBasePrefix.h"


@interface NSParagraphStyle (HSExtensions)
+ (id)hyperParagraphStyleWithAlignment:(NSUInteger)aAlignment lineBreakMode:(NSUInteger)aMode;
+ (id)hyperParagraphStyleWithCombinedHeadIndent:(CGFloat)aIndent;
+ (id)hyperParagraphStyleWithLineBreakMode:(NSUInteger)aMode;
+ (id)hyperParagraphStyleWithAlignment:(NSUInteger)aAlignment;
- (id)hyperParagraphStyleByChangingMinimumLineHeight:(CGFloat)aHeight;
- (id)hyperParagraphStyleByChangingCombinedHeadIndent:(CGFloat)aIndent;
- (id)hyperParagraphStyleByChangingLineBreakMode:(NSUInteger)aMode;
- (id)hyperParagraphStyleByChangingAlignment:(NSUInteger)aAlignment;
@end

