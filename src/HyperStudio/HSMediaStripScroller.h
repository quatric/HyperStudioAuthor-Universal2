#import "HyperStudioPrefix.h"


@interface HSMediaStripScroller : NSScroller
{
    NSRect _partRects[3];
    SEL _partActions[3];
    BOOL _partsEnabled[3];
    int _trackingPart;
    NSSize _sizeForCachedGeometry;
    BOOL _showsStopButton;
    BOOL _geometryValid;
    id _rendererCell;
    id _trackingCell;
}
+ (id)alternateImageForMediaStripScrollerPart:(NSInteger)aPart;
+ (id)imageForMediaStripScrollerPart:(NSInteger)aPart;
+ (id)mediaStripStopAlternateImage;
+ (id)mediaStripStopImage;
+ (id)mediaStripUpAlternateImage;
+ (id)mediaStripUpImage;
+ (id)mediaStripDownAlternateImage;
+ (id)mediaStripDownImage;
+ (CGFloat)scrollerWidthForControlSize:(NSUInteger)aSize;
+ (CGFloat)scrollerWidth;
- (void)updateCell:(id)aCell;
- (void)mouseDown:(id)aDown;
- (void)drawRect:(NSRect)aRect;
- (void)drawPart:(NSInteger)aPart clipRect:(NSRect)aRect;
- (NSUInteger)testPart:(NSPoint)aPart;
- (NSRect)rectForPart:(NSUInteger)aPart;
- (NSUInteger)usableParts;
- (NSInteger)hitTestPart:(NSPoint)aPart;
- (void)ensureGeometryIsValid;
- (id)trackingCell;
- (id)rendererCell;
- (BOOL)isEnabledForPart:(NSInteger)aPart;
- (void)setEnabled:(BOOL)aEnabled forPart:(NSInteger)aPart;
- (SEL)actionForPart:(NSInteger)aPart;
- (void)setAction:(SEL)aAction forPart:(NSInteger)aPart;
- (void)setShowsStopButton:(BOOL)aButton;
- (BOOL)showsStopButton;
- (BOOL)isOpaque;
- (void)dealloc;
@end

