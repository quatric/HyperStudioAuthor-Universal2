#import "HyperStudioPrefix.h"


@interface HSCustomTabView : NSView
{
    HSSegmentedControl *_header;
    HSTintedView *_rightSeparator;
    HSTintedView *_leftSeparator;
    NSView *_contentView;
    NSMutableArray *_content;
    id _delegate;
}
+ (id)defaultCellFont;
+ (id)separatorColor;
- (void)headerSelectionChanged:(id)aChanged;
- (id)tabDescriptionWithTitle:(id)aTitle image:(id)aImage toolTip:(id)aTip accessibilityValues:(id)aValues contentView:(id)aView;
- (id)content;
- (void)mountContentViewForSelectedTab;
- (void)mountContentViewForTabAtIndex:(NSInteger)aIndex;
- (void)updateContentViewSize;
- (void)createContentView;
- (void)updateSeparators;
- (void)createSeparators;
- (void)reloadTabsInHeader;
- (void)updateLayoutOfTabsInHeader;
- (void)updateHeaderSize;
- (NSPoint)headerOrigin;
- (CGFloat)cellSizeOffset;
- (CGFloat)rightSeparatorOffset;
- (NSInteger)headerWidthRemains;
- (void)createHeader;
- (NSSize)frameSizeOfHeader;
- (void)selectHeaderCellAtIndex:(NSInteger)aIndex;
- (id)headerCellAtIndex:(NSInteger)aIndex;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setFont:(id)aFont;
- (id)font;
- (NSSize)tabViewSizeForContentView:(id)aView;
- (NSInteger)indexOfSelectedTab;
- (void)removeTabAtIndex:(NSInteger)aIndex;
- (void)selectTabAtIndex:(NSInteger)aIndex;
- (void)insertTabWithTitle:(id)aTitle image:(id)aImage toolTip:(id)aTip accessibilityValues:(id)aValues contentView:(id)aView atIndex:(NSInteger)aIndex;
- (void)insertTab:(id)aTab atIndex:(NSInteger)aIndex;
- (void)addTabWithTitle:(id)aTitle image:(id)aImage toolTip:(id)aTip accessibilityValues:(id)aValues contentView:(id)aView;
- (void)addTab:(id)aTab;
- (NSInteger)numberOfTabs;
- (void)setFrame:(NSRect)aFrame;
- (void)awakeFromNib;
- (void)setupOnDidLoad;
- (void)dealloc;
- (BOOL)isFlipped;
@end

