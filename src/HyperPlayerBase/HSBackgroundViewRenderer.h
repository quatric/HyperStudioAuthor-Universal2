#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSBackgroundViewRenderer : HSObject <HSAttributeObserving, NSObject, HSBackgroundRenderer, HSBackgroundAttributesContainerPrimitives, HSMutableBackgroundAttributes, HSBackgroundAttributes, HSAttributes, HyperInterface, HSBackgroundGraphicsAttribute, HSBackgroundAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSBackgroundBoundsAttribute, HSGraphicsDelegate, EXKeyValueCoding>
{
    NSImage *_backgroundThumbnail;
    HSGraphics *_backgroundGraphics;
    NSView *_backgroundView;
    id _delegate;
}
- (id)attributesChangedTemporary;
- (id)attributesBeingChangedContinuously;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)endContinuousChangeOfAttributeSet:(id)aSet;
- (void)beginContinuousChangeOfAttributeSet:(id)aSet;
- (void)endContinuousChangeOfAttribute:(id)aAttribute;
- (void)beginContinuousChangeOfAttribute:(id)aAttribute;
- (void)removeAttributeObserver:(id)aObserver;
- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (id)attributeNotificationCenter;
- (id)attributeObservingController;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (NSRect)backgroundBounds;
- (id)undoManagerForGraphics:(id)aGraphics;
- (void)hyperVisualAttributesChanged:(id)aChanged;
- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject;
- (id)backgroundThumbnail;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (id)backgroundGraphics;
- (void)_setBackgroundGraphics:(id)aGraphics;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)backgroundView;
- (void)setBackgroundView:(id)aView;
- (void)dealloc;
- (id)initWithBackgroundView:(id)aView;
- (id)init;
@end

