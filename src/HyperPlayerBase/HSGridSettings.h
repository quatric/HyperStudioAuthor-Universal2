#import "HyperPlayerBasePrefix.h"


@interface HSGridSettings : NSObject <HSGridInterface, EXKeyValueCoding>
{
    NSSize _gridOffset;
    HSLayoutGrid *_layoutGrid;
    BOOL _isGridVisible;
    BOOL _isSnapToGridEnabled;
    NSColor *_gridColor;
    int _markStyle;
    NSUndoManager *_undoManager;
}
+ (NSInteger)defaultMarkStyle;
+ (id)defaultColor;
- (void)layoutGridDidChange:(id)aChange;
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
- (void)resetToDefaults;
- (void)saveToUserDefaults;
- (void)notifyAboutChanges;
- (void)setUndoManager:(id)aManager;
- (id)undoManager;
- (void)dealloc;
- (id)init;
@end

