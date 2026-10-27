#import "HSYouTubeRatingCell.h"

@implementation HSYouTubeRatingCell

- (id)raitingCell
{
    if (_ratingCell == nil) {
        _ratingCell = [HSRatingCell new];
        [_ratingCell setPointsCount:5];
        [_ratingCell setPointImage:[NSImage imageNamed:@"rating_star"]];
        [_ratingCell setPointDimmedImage:[NSImage imageNamed:@"rating_star_off"]];
    }
    return _ratingCell;
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSYouTubeRatingCell *copy = [[HSYouTubeRatingCell allocWithZone:aZone] init];

    [copy setRepresentedObject:[self representedObject]];
    return copy;
}

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    [self drawInteriorWithFrame:aFrame inView:aView];
}

// Rating stars, view count and movie length, with a separator line on the left.
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    float x = aFrame.origin.x + 12.0f;
    NSMutableString *views = nil;
    id length = nil;
    float rating = 0.0f;
    NSBezierPath *path;

    if ([[self objectValue] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *info = [self objectValue];
        rating = [[info valueForKey:@"HSRatingKey"] floatValue];
        views = [[info valueForKey:@"HSViewsCountKey"] mutableCopy];
        length = [info valueForKey:@"HSMovieLengthKey"];
    }
    [[self raitingCell] setRating:rating];
    [[self raitingCell] drawInteriorWithFrame:NSMakeRect(x, aFrame.origin.y + 25.0f, 55.0, 11.0) inView:aView];
    // Fix: a cell without the info dictionary raised on the nil strings.
    if (views != nil) {
        NSAttributedString *string;

        [views insertString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Views: " value:@"" table:@"Dialogs"] atIndex:0];
        string = [[NSAttributedString alloc] initWithString:views attributes:nil];
        [string drawAtPoint:NSMakePoint(x, aFrame.origin.y + 38.0f)];
        [views release];
        [string release];
    }
    if (length != nil) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:length attributes:[NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:11.0] forKey:NSFontAttributeName]];
        [string drawAtPoint:NSMakePoint(x, aFrame.origin.y + 52.0f)];
        [string release];
    }
    path = [NSBezierPath bezierPath];
    [path setLineWidth:1.0];
    [[NSColor grayColor] set];
    [path moveToPoint:NSMakePoint(aFrame.origin.x + 0.5f, aFrame.origin.y + 9.0f)];
    [path lineToPoint:NSMakePoint(aFrame.origin.x + 0.5f, aFrame.size.height + aFrame.origin.y - 9.0f)];
    [path stroke];
}

- (void)dealloc
{
    [_ratingCell release];
    [super dealloc];
}

@end
