#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObject.h"


@interface HSShadowedObject : HSConcreteCardObject <HSMutableShadowAttributes, HSShadowAttributes, HSAttributes, HyperInterface, NSObject, HSShadowOffsetAttribute, HSShadowAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSShadowEnabledAttribute, HSShadowBlurRadiusAttribute, HSShadowOpacityAttribute>
{
}
+ (NSRect)shadowRectFor:(NSRect)aFor withOffset:(NSSize)aOffset andBlurRadius:(CGFloat)aRadius isFlipped:(BOOL)aFlipped;
+ (Class)nodeDataClass;
- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)hyperShadow;
- (void)setHyperShadowOpacity:(CGFloat)aOpacity;
- (void)setHyperShadowEnabled:(BOOL)aEnabled;
- (void)setHyperShadowBlurRadius:(CGFloat)aRadius;
- (void)setHyperShadowDistance:(CGFloat)aDistance;
- (void)setHyperShadowAngle:(CGFloat)aAngle;
- (void)setHyperVerticalShadowOffset:(CGFloat)aOffset;
- (void)setHyperHorizontalShadowOffset:(CGFloat)aOffset;
- (void)setHyperShadowOffset:(NSSize)aOffset;
- (CGFloat)hyperShadowOpacity;
- (BOOL)isHyperShadowEnabled;
- (BOOL)hasMultipleShadowStyles;
- (CGFloat)hyperShadowBlurRadius;
- (CGFloat)hyperShadowDistance;
- (CGFloat)hyperShadowAngle;
- (CGFloat)hyperVerticalShadowOffset;
- (CGFloat)hyperHorizontalShadowOffset;
- (NSSize)hyperShadowOffset;
- (id)attributeToNotificationMapForCodingOperation:(id)aOperation;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)setShadowEnabled:(BOOL)aEnabled;
- (BOOL)isShadowEnabled;
- (void)setShadow:(id)aShadow;
- (id)shadow;
- (void)dealloc;
@end

