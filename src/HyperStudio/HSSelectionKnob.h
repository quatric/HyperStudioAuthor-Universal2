#import "HyperStudioPrefix.h"


@interface HSSelectionKnob : NSObject <HSCanvasItem, HyperInterface, NSObject, HSCanvasItemActivation>
{
    NSImage *_normalStateImage;
    NSSize _hitTestOffset;
    NSRect _cachedFrame;
    unsigned int _hash;
    struct HyperStudio_anon1 _flags;
}
+ (id)affectingAttributes;
+ (NSSize)hitTestOffset;
+ (id)selectionFrameColor;
+ (id)normalStateImage;
- (void)invalidateParentCanvasLayer;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (BOOL)overridesTrackingLoopCursor;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (NSUInteger)hash;
- (NSUInteger)calculateHash;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)isEqualToKnob:(id)aKnob;
- (id)affectingAttributes;
- (id)affectingAttribute;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (id)querySelectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (BOOL)hitTest:(NSPoint)aTest forOwner:(id)aOwner inView:(id)aView;
- (void)setHitTestOffset:(NSSize)aOffset;
- (NSSize)hitTestOffset;
- (NSRect)frameForOwner:(id)aOwner inView:(id)aView;
- (BOOL)updateCachedFrameWithOwner:(id)aOwner inView:(id)aView;
- (void)invalidateCachedFrame;
- (BOOL)updateCachedFrame:(NSRect)aFrame;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (id)boundingRegionForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (NSRect)boundingRectForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (NSRect)boundingRectForOwner:(id)aOwner inView:(id)aView;
- (NSSize)imageSize;
- (BOOL)canBeLocked;
- (void)setVisible:(BOOL)aVisible;
- (BOOL)isVisible;
- (void)setBeingTracked:(BOOL)aTracked;
- (BOOL)isBeingTracked;
- (void)setActive:(BOOL)aActive;
- (BOOL)isActive;
- (id)image;
- (void)setNormalStateImage:(id)aImage;
- (id)normalStateImage;
- (void)dealloc;
- (id)init;
@end

