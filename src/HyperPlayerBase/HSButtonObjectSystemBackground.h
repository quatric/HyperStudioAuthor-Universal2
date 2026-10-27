#import "HyperPlayerBasePrefix.h"
#import "HSButtonObjectBackground.h"


@interface HSButtonObjectSystemBackground : HSButtonObjectBackground <HSButtonObjectSystemStyleBackgroundAttributes, HSButtonObjectBackgroundAttributes, HSAttributes, HyperInterface, NSObject, HSButtonObjectBackgroundStyleIdentifierAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSButtonObjectSystemBackgroundColorAttribute, HSButtonObjectSystemBackgroundAttribute, HSButtonObjectSystemButtonTypeAttribute, HSButtonObjectSystemBackgroundIgnoreTintColorAttribute, EXKeyValueCoding>
{
    NSColor *_tintColor;
    NSString *_systemButtonType;
    BOOL _ignoreTintColor;
    NSSize _size;
}
- (void)updateButtonObjectStyle;
- (BOOL)canButtonStyleBeUpdated;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (CGFloat)additionalHorizontalTitleSpace;
- (BOOL)shouldTileMiddleBackgroundParts;
- (id)backgroundImagePartForType:(NSInteger)aType;
- (BOOL)canResizeVertically;
- (BOOL)isVisible;
- (void)setSizeAsString:(id)aString;
- (id)sizeAsString;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (void)setUsesTintColor:(BOOL)aColor;
- (BOOL)usesTintColor;
- (void)setIgnoreTintColor:(BOOL)aColor;
- (BOOL)ignoreTintColor;
- (id)buttonType;
- (void)setSystemButtonType:(id)aType;
- (id)systemButtonType;
- (BOOL)hasOldstyleButtonType;
- (id)backgroundStyle;
- (void)setTintColor:(id)aColor;
- (id)tintColor;
- (void)dealloc;
@end

