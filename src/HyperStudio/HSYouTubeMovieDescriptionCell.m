#import "HSYouTubeMovieDescriptionCell.h"

@implementation HSYouTubeMovieDescriptionCell

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    if ([[self objectValue] isKindOfClass:[NSAttributedString class]])
        [self drawInteriorWithFrame:aFrame inView:aView];
    else
        [super drawWithFrame:aFrame inView:aView];
}

// Original quirk kept: the text is drawn here and then again by super.
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    id text;
    if ([[self objectValue] isKindOfClass:[NSAttributedString class]]) {
        text = [self objectValue];
    } else {
        if ([self stringValue] == nil) {
            [super drawInteriorWithFrame:aFrame inView:aView];
            return;
        }
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[self font] forKey:NSFontAttributeName];
        text = [[[NSAttributedString alloc] initWithString:[self stringValue] attributes:attributes] autorelease];
    }
    if (text != nil) {
        NSTextStorage *storage = [NSAttributedString textStorageFromAttributedString:text fittedToContainerSize:aFrame.size];
        NSLayoutManager *layoutManager = [[storage layoutManagers] objectAtIndex:0];
        NSRange glyphs = [layoutManager glyphRangeForTextContainer:[[layoutManager textContainers] objectAtIndex:0]];
        [layoutManager drawGlyphsForGlyphRange:glyphs atPoint:aFrame.origin];
    }
    [super drawInteriorWithFrame:aFrame inView:aView];
}

@end
