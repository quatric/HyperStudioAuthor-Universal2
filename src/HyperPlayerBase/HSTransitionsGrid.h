#import "HyperPlayerBasePrefix.h"


@interface HSTransitionsGrid : NSMatrix <HSTransitionViewDataSource>
{
    id<HSTransitionsGridDataSource> _dataSource;
    HSTransitionView *_transitionView;
}
- (void)stopPlayingIfNeeded;
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
- (void)HSTransitionsGrid_transitionDidEnd;
- (id)endImageForTransitionView:(id)aView;
- (id)startImageForTransitionView:(id)aView;
- (id)transitionView;
- (void)selectCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (void)mouseDown:(id)aDown;
- (BOOL)canBecomeKeyView;
- (void)drawRect:(NSRect)aRect;
- (id)makeCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (Class)cellClass;
- (void)setSelectedTransitionEffect:(id)aEffect;
- (id)selectedTransitionEffect;
- (void)setTransitionDuration:(double)aDuration;
- (double)transitionDuration;
- (void)setTransitionEndImage:(id)aImage;
- (void)setTransitionStartImage:(id)aImage;
- (void)invalidateTransitionEndImage;
- (void)invalidateTransitionStartImage;
- (void)reloadData;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

