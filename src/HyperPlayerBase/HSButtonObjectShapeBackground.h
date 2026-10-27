#import "HyperPlayerBasePrefix.h"
#import "HSButtonObjectBackground.h"


@interface HSButtonObjectShapeBackground : HSButtonObjectBackground <HSButtonObjectShapeBackgroundAttributes, HSButtonObjectBackgroundAttributes, HSAttributes, HyperInterface, NSObject, HSButtonObjectBackgroundStyleIdentifierAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSMutableBackgroundAttributes, HSBackgroundAttributes, HSBackgroundGraphicsAttribute, HSBackgroundAttribute, HSBackgroundBoundsAttribute, HSButtonObjectBorderAttributes, HSBorderAttributes, HSBorderlessAttribute, HSBorderAttribute, HSBorderColorAttribute, HSBorderWidthAttribute, HSBorderPathAttribute, HSButtonObjectShapeButtonTypeAttribute, HSBorderShowingInPlayerAttribute, HSButtonObjectShapeAlternativeBorderAttribute, HSBackgroundRenderer, HSGraphicsDelegate, HSBackgroundAttributesContainerPrimitives, EXKeyValueCoding, HSGenericSolidColorAttributes, HSGenericSolidColorAttribute, HSMutableOutlineAttributes, HSOutlineAttributes, HSOutlineAvailabilityAttribute, HSOutlineWidthAttribute, HSOutlineColorAttribute>
{
    HSGraphics *_backgroundGraphics;
    BOOL _isBorderless;
    NSBezierPath *_borderPath;
    NSColor *_borderColor;
    BOOL _showsBorderInPlayer;
    BOOL _isAlternativeBorderActive;
    NSImage *_backgroundThumbnail;
    NSString *_shapeButtonType;
}
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (void)setHyperOutlineColor:(id)aColor;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (id)hyperOutlineColor;
- (CGFloat)hyperOutlineWidth;
- (BOOL)isHyperOutlineEnabled;
- (id)queryHyperInterface:(id)aInterface;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)undoManagerForGraphics:(id)aGraphics;
- (void)hyperVisualAttributesChanged:(id)aChanged;
- (void)setHyperDroppedSolidColor:(id)aColor;
- (void)setHyperSolidColor:(id)aColor;
- (id)hyperSolidColor;
- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject;
- (void)_setBackgroundGraphics:(id)aGraphics;
- (NSRect)backgroundBounds;
- (id)backgroundGraphics;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize;
- (id)backgroundThumbnail;
- (id)buttonType;
- (void)setShapeButtonType:(id)aType;
- (id)shapeButtonType;
- (BOOL)isVisible;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (id)backgroundStyle;
- (void)activateAlternativeBorder:(BOOL)aBorder;
- (BOOL)isAlternativeBorderActive;
- (void)setShowsBorderInPlayer:(BOOL)aPlayer;
- (BOOL)showsBorderInPlayer;
- (void)setBorderWidth:(CGFloat)aWidth;
- (CGFloat)borderWidth;
- (void)setBorderColor:(id)aColor;
- (id)borderColor;
- (void)setBorderPath:(id)aPath;
- (id)borderPath;
- (void)setIsBorderless:(BOOL)aBorderless;
- (BOOL)isBorderless;
- (void)dealloc;
- (id)initWithOwner:(id)aOwner;
@end

