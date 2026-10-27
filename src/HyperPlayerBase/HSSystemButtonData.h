#import "HyperPlayerBasePrefix.h"
#import "HSSystemObjectData.h"


@interface HSSystemButtonData : HSSystemObjectData
{
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setContinuous:(BOOL)aContinuous;
- (BOOL)isContinuous;
- (void)setSelected:(BOOL)aSelected;
- (BOOL)isSelected;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)setTransparent:(BOOL)aTransparent;
- (BOOL)isTransparent;
- (void)setBordered:(BOOL)aBordered;
- (BOOL)isBordered;
- (void)setControlSize:(NSUInteger)aSize;
- (NSUInteger)controlSize;
- (void)setFont:(id)aFont;
- (id)font;
- (void)setTitle:(id)aTitle;
- (id)title;
- (id)systemButtonForSetAccessor;
- (id)systemButtonForGetAccessor;
@end

