#import "HyperStudioPrefix.h"


@interface HSSegmentAttributesView : NSView
{
    HSSegmentView *_segmentView;
    NSMutableArray *_graphicObjects;
    NSMutableArray *_knobs;
}
- (void)rebuildKnobs;
- (NSInteger)updateKnobAtIndex:(NSInteger)aIndex toKeyFrame:(double)aFrame;
- (NSInteger)knobIndexAtPoint:(NSPoint)aPoint;
- (void)mouseDown:(id)aDown;
- (void)drawKnobs:(NSRect)aKnobs;
- (void)drawMidLine:(NSRect)aLine;
- (void)drawBackground:(NSRect)aBackground;
- (id)attributesKnobImage;
- (id)attributesEdgeKnobImage;
- (void)drawRect:(NSRect)aRect;
- (double)duration;
- (double)timeForX:(CGFloat)aX;
- (CGFloat)xForTime:(double)aTime;
- (id)attributes;
- (void)setupBackground;
- (void)refresh;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame segmentView:(id)aView;
@end

@interface HSSegmentAttributesKnob : NSObject
{
    NSString *_name;
    int _index;
    double _keyFrame;
}
- (NSInteger)compareTo:(id)aTo;
- (void)setKeyFrame:(double)aFrame;
- (double)keyFrame;
- (void)setIndex:(NSInteger)aIndex;
- (NSInteger)index;
- (id)name;
- (id)initWithName:(id)aName;
@end

