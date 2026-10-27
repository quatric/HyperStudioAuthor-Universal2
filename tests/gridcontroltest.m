// Exercises what build 217 of SMKControls changed against the Weather Globe
// port's version 211: the grid control's reloading lock (item getters, the
// lock / reload-and-unlock pair, tryLock), the title offset in the cell
// layout, the matrix's text font, text selection style, plain cell border
// offset and locked maximum title height, and the cells' title placement.
#import <Cocoa/Cocoa.h>
#import "SMKControlsUmbrella.h"

static int failures = 0;

static void check(BOOL aCondition, NSString *aWhat)
{
    if (!aCondition) {
        NSLog(@"FAIL: %@", aWhat);
        failures++;
    }
}

@interface TestSource : NSObject
{
@public
    NSMutableArray *titles;
    NSImage *image;
}
@end

@implementation TestSource
- (NSInteger)numberOfItemsInGridControl:(SMKGridControl *)aControl { return [titles count]; }
- (id)gridControl:(SMKGridControl *)aControl titleForItemAt:(NSInteger)aIndex { return [titles objectAtIndex:aIndex]; }
- (id)gridControl:(SMKGridControl *)aControl imageForItemAt:(NSInteger)aIndex { return image; }
- (id)gridControl:(SMKGridControl *)aControl additionalInfoForItemAt:(NSInteger)aIndex { return @"info"; }
@end

int main(void)
{
    @autoreleasepool {
        [NSApplication sharedApplication];
        SMKGridControl *grid = [[SMKGridControl alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
        check(grid != nil, @"made");
        SMKGridMatrix *matrix = [grid gridMatrix];
        check([matrix titleOffset] == 1.0, @"default title offset");
        check([matrix textSelectionStyle] == 0, @"default text selection style");

        // The border offset is returned as set (211 raised it to the shadow blur).
        [matrix setCellBorderOffset:NSMakeSize(2, 2)];
        check(NSEqualSizes([matrix cellBorderOffset], NSMakeSize(2, 2)), @"plain border offset");

        // The text font overrides the control size's system font.
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:20];
        [matrix setTextFont:font];
        check([matrix textFont] == font, @"text font");
        [matrix setControlSize:NSControlSizeSmall];
        check([matrix textFont] == font, @"control size keeps a set font");
        [matrix setTextFont:nil];
        check([[matrix textFont] pointSize] == [NSFont smallSystemFontSize], @"system font again");

        [matrix setTextSelectionStyle:1];
        check([matrix textSelectionStyle] == 1, @"text selection style");
        [matrix setThumbnailMaxTitleHeight:30];
        check([matrix thumbnailMaxTitleHeight] == 30, @"max title height");

        // Thumbnail layout with a title offset.
        [grid setThumbnailSize:NSMakeSize(64, 48) andBorderOffset:NSMakeSize(4, 5) titleOffset:3];
        check([matrix titleOffset] == 3 && NSEqualSizes([matrix cellBorderOffset], NSMakeSize(4, 5)),
              @"offsets set");
        check(NSEqualSizes([grid thumbnailSize], NSMakeSize(64, 48)), @"thumbnail size");
        [grid setThumbnailSize:NSMakeSize(80, 60) andBorderOffset:NSMakeSize(4, 5)];
        check([matrix titleOffset] == 3, @"two-size setter keeps the title offset");

        // Items through the reloading lock.
        TestSource *source = [[TestSource alloc] init];
        source->titles = [NSMutableArray arrayWithObjects:@"One", @"Two", @"Three", nil];
        source->image = [NSImage imageWithSize:NSMakeSize(16, 16) flipped:NO drawingHandler:^BOOL(NSRect r) {
            [[NSColor redColor] set];
            NSRectFill(r);
            return YES;
        }];
        [grid setDataSource:source];
        [grid reloadData];
        check([grid count] == 3, @"three items");
        check([[grid titleForItemAt:1] isEqualToString:@"Two"] && [grid imageForItemAt:0] == source->image,
              @"item getters");
        check([grid titleForItemAt:5] == nil && [grid additionalInfoForItemAt:5] == nil, @"out of range");
        check([[grid additionalInfoForItemAt:2] isEqualToString:@"info"], @"additional info");

        [grid setThreadedPreloadingEnabled:YES];
        check([grid tryLockBeforeReloadingData], @"try lock");
        [source->titles addObject:@"Four"];
        [grid reloadDataAndUnlock];
        check([grid count] == 4, @"reloaded after unlock");
        [grid lockBeforeReloadingData];
        check(![grid tryLockBeforeReloadingData], @"locked against a second writer");
        [source->titles removeLastObject];
        [grid reloadDataAndUnlock];
        check([grid count] == 3 && [[grid titleForItemAt:2] isEqualToString:@"Three"], @"reloaded again");
        [grid setThreadedPreloadingEnabled:NO];

        // Title placement: with a maximum height the title is fitted to it,
        // without one it gets its whole bounding height.
        SMKGridBaseCell *cell = [[matrix cells] objectAtIndex:0];
        NSRect bounds = NSMakeRect(0, 0, 100, 120);
        [cell updateTitleIfNeeded];
        check([[cell title] isEqualToString:@"One"], @"lazy title");
        [cell emptyTitleCache];
        NSRect fitted = [cell textPlacementRectForBounds:bounds];
        check(fitted.size.height > 0 && fitted.size.height <= 30, @"title fitted to the maximum");
        [matrix setThumbnailMaxTitleHeight:0];
        [cell emptyTitleCache];
        NSRect whole = [cell textPlacementRectForBounds:bounds];
        check(whole.size.height > 0 && whole.size.width == 100, @"whole title at its bounding height");
        NSRect graphic = [cell graphicContentPlacementRectForBounds:bounds];
        check(graphic.size.height < bounds.size.height, @"graphic area above the title");

        [grid setDataSource:nil];
        [grid release];
        [source release];
    }
    if (failures == 0)
        printf("gridcontroltest: all checks passed\n");
    return failures != 0;
}
