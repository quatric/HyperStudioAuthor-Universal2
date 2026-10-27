#import "HyperPlayerBasePrefix.h"
#import "HSView.h"


@interface HSUserObjectPreviewView : HSView
{
    NSMutableArray *_userObjects;
    NSMutableArray *_renderers;
    NSColor *_backgroundColor;
    id _presentationContext;
    BOOL _isOpaque;
    BOOL _scaleToFit;
    BOOL _shouldPreserveOrigins;
    BOOL _shouldBeCentered;
}
+ (id)retrieveRendererFromObject:(id)aObject;
+ (id)thumbnailPreviewImageWithMaxSize:(NSSize)aSize forObject:(id)aObject;
+ (id)thumbnailPreviewImageOfSize:(NSSize)aSize forObject:(id)aObject borderInset:(NSSize)aInset;
+ (id)dragPreviewImageForSortedObjects:(id)aObjects;
+ (id)previewImageForObjects:(id)aObjects renderingOrigin:(NSPoint *)aOrigin;
+ (id)previewImageForSortedObjects:(id)aObjects;
+ (id)previewImageForObjects:(id)aObjects;
+ (id)previewImageForObject:(id)aObject;
+ (id)previewImageForObjects:(id)aObjects objectsAreAlreadySorted:(BOOL)aSorted needBitmapRep:(BOOL)aRep renderingOrigin:(NSPoint *)aOrigin;
+ (id)previewImageWithView:(id)aView forObjects:(id)aObjects objectsAreAlreadySorted:(BOOL)aSorted needBitmapRep:(BOOL)aRep renderingOrigin:(NSPoint *)aOrigin;
+ (id)objectEnumeratorForSortedObjectsInArray:(id)aArray;
+ (NSSize)sizeOfPreviewImageForObject:(id)aObject;
+ (NSSize)sizeOfPreviewImageForObject:(id)aObject offsetFromObjectBounds:(NSPoint *)aBounds;
- (void)setOpaque:(BOOL)aOpaque;
- (BOOL)isOpaque;
- (void)hyperUpdateVisualObjectCount;
- (id)renderers;
- (id)mutableUserObjects;
- (void)drawHyperRenderersInRect:(NSRect)aRect;
- (void)drawRect:(NSRect)aRect;
- (id)backgroundColor;
- (void)setBackgroundColor:(id)aColor;
- (id)offsetsFromPoint:(NSPoint)aPoint;
- (NSRect)renderersBoundingRect;
- (void)visualAttributeDidChange:(id)aChange;
- (void)removeAllUserObjects;
- (void)addUserObject:(id)aObject;
- (id)userObjects;
- (void)setShouldBeCentered:(BOOL)aCentered;
- (BOOL)shouldBeCentered;
- (void)setShouldPreserveOrigins:(BOOL)aOrigins;
- (BOOL)shouldPreserveOrigins;
- (void)setScaleToFit:(BOOL)aFit;
- (BOOL)isScaleToFit;
- (BOOL)isFlipped;
- (void)dealloc;
@end

