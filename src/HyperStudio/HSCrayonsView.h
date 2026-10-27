#import "HyperStudioPrefix.h"


@interface HSCrayonsView : NSControl
{
    NSMutableArray *_items;
    int _numberOfRows;
    int _numberOfColumns;
    BOOL _layoutIsValid;
    BOOL _needsForceLayout;
    NSColor *_color;
    HSCrayonItem *_highlightedItem;
    id _dataSource;
    id _defaultDataSource;
}
+ (Class)defaultDataSourceClass;
+ (void)setDefaultDataSourceClass:(Class)aClass;
+ (Class)cellClass;
- (void)mouseUp:(id)aUp;
- (void)mouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (void)handleMousePoint:(NSPoint)aPoint;
- (void)highlightItem:(id)aItem;
- (void)setFrameSize:(NSSize)aSize;
- (void)drawRect:(NSRect)aRect;
- (void)layout:(BOOL)aLayout;
- (id)defaultDataSource;
- (id)colorForRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (void)setNeedsLayout:(BOOL)aLayout;
- (BOOL)needsLayout;
- (id)items;
- (void)setNeedsForceLayout:(BOOL)aLayout;
- (void)setNumberOfColumns:(NSInteger)aColumns;
- (NSInteger)numberOfColumns;
- (void)setNumberOfRows:(NSInteger)aRows;
- (NSInteger)numberOfRows;
- (id)color;
- (id)dataSource;
- (void)setDataSource:(id)aSource;
- (void)viewDidMoveToWindow;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (BOOL)acceptsFirstResponder;
- (BOOL)isFlipped;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

@interface HSCrayonsView (Accessibility)
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
- (id)accessibilityAttributeNames;
@end

