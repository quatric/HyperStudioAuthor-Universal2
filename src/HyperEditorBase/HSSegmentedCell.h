#import "HyperEditorBasePrefix.h"


@interface HSSegmentedCell : SMKBackgroundButtonCell <NSCopying, NSCoding>
{
    BOOL _isLeftCap;
    BOOL _isRightCap;
}
+ (BOOL)prefersTrackingUntilMouseUp;
- (id)accessibilityAttributeValue:(id)aValue;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)copyWithZone:(NSZone *)aZone;
- (void)setRightCap:(BOOL)aCap;
- (BOOL)isRightCap;
- (void)setLeftCap:(BOOL)aCap;
- (BOOL)isLeftCap;
@end

@interface SMKBackgroundButtonCell (HSSegmentedCellAdditions)
- (id)hyperPrivateBackgroundRenderer;
@end

