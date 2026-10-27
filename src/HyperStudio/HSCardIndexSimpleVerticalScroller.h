#import "HyperStudioPrefix.h"


@interface HSCardIndexVerticalScroller : NSScroller
{
    NSMutableDictionary *_imagesHighlighted;
    NSMutableDictionary *_imagesSimple;
}
- (id)imageNameForExtraPart:(NSInteger)aPart;
- (id)imagesSimple;
- (id)imagesHighlighted;
- (id)imageNamed:(id)aNamed highlighted:(BOOL)aHighlighted;
- (BOOL)shouldDrawPart:(NSInteger)aPart;
- (BOOL)isPartHighlighted:(NSInteger)aHighlighted;
- (void)drawExtraPart:(NSInteger)aPart highlighted:(BOOL)aHighlighted;
- (BOOL)arrowsTogether;
- (id)simpleSubfolder;
- (id)highlightedSubfolder;
- (NSRect)rectForExtraPart:(NSInteger)aPart;
- (void)drawRect:(NSRect)aRect;
- (BOOL)isOpaque;
- (id)initWithScrollView:(id)aView;
- (id)init;
- (void)invalidateColors;
- (void)dealloc;
@end

@interface HSCardIndexSimpleVerticalScroller : HSCardIndexVerticalScroller
{
}
- (NSRect)rectForExtraPart:(NSInteger)aPart;
@end

@interface HSCardIndexHorizontalScroller : HSCardIndexVerticalScroller
{
}
- (BOOL)arrowsTogether;
- (NSRect)rectForExtraPart:(NSInteger)aPart;
- (id)simpleSubfolder;
- (id)highlightedSubfolder;
- (id)initWithScrollView:(id)aView;
@end

