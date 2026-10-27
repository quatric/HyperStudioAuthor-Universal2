#import "HyperEditorBasePrefix.h"


@interface HSLayoutGridPreview : NSView <HSGridInterface>
{
    NSSize _gridOffset;
    HSLayoutGrid *_layoutGrid;
    BOOL _isGridVisible;
    BOOL _isSnapToGridEnabled;
    NSColor *_gridColor;
    int _markStyle;
}
+ (NSInteger)defaultMarkStyle;
+ (id)defaultColor;
- (BOOL)isFlipped;
- (void)updateWithObject:(id)aObject;
- (void)layoutGridDidChange:(id)aChange;
- (void)resetToDefaults;
- (BOOL)isSnapToGridEnabled;
- (void)setGridVisible:(BOOL)aVisible;
- (void)setGridOffset:(NSSize)aOffset;
- (void)setIsSnapToGridEnabled:(BOOL)aEnabled;
- (BOOL)isGridVisible;
- (NSSize)gridOffset;
- (void)setLayoutGrid:(id)aGrid;
- (id)layoutGrid;
- (id)gridColor;
- (void)setGridColor:(id)aColor;
- (NSInteger)markStyle;
- (void)setMarkStyle:(NSInteger)aStyle;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (void)drawRect:(NSRect)aRect;
- (id)initWithFrame:(NSRect)aFrame;
@end

