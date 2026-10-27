#import "HyperPlayerBasePrefix.h"


@interface HSControllerCell : NSActionCell
{
    id<HSMovieControllerCellDelegate> _delegate;
}
- (void)handleMouseDown:(id)aDown inRect:(NSRect)aRect ofView:(id)aView;
- (NSRect)movieFrameForMovieArea:(NSRect)aArea isFlipped:(BOOL)aFlipped;
- (NSRect)movieAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped;
- (NSRect)controllerAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped;
- (CGFloat)controllerHeight;
- (CGFloat)minControllerWidth;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

