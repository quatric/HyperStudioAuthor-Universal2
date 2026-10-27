#import "HSSOTSLayout.h"

static const float kHSPopUpPadding = 15.0f;
static const float kHSAnchorWidth = 32.0f;
static const float kHSAnchorHeight = 16.0f;

@implementation HSSOTSLayout

// Candidate positions: 1 below the object, 2 above, 3 left, 4 right. Each fit
// is scored by how far the window sits off the object's center, how much of
// the free space it fills and how much it covers the obstacles; the lowest
// score wins. Position 0 falls back to the saved inspector origin.
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout
{
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrames[5], startFrames[5], middleFrames[5], anchorFrames[5];
    float scores[5];
    for (int i = 0; i < 5; i++) {
        windowFrames[i] = startFrames[i] = middleFrames[i] = anchorFrames[i] = NSZeroRect;
        scores[i] = FLT_MAX;
    }
    NSInteger position = [[aLayout objectForKey:HSObjectAssistantLayoutWindowPosition] intValue];
    // An unchanged object keeps its previous position while the window still fits.
    BOOL reuse = position != 0 && aSize2.height >= aSize.height
        && NSEqualRects(aFrame, [[aLayout objectForKey:HSObjectAssistantLayoutObjectFrameKey] rectValue]);
    float objectCenterX = aFrame.origin.x + aFrame.size.width * 0.5f;
    float objectCenterY = aFrame.origin.y + aFrame.size.height * 0.5f;
    for (NSInteger i = reuse ? position : 1; i <= 4 && NSContainsRect(visibleFrame, aFrame); i++) {
        NSRect space;
        float score;
        NSRect window;
        switch (i) {
        case 1:
            startFrames[i] = NSMakeRect(objectCenterX, aFrame.origin.y, 0, 0);
            space = NSMakeRect(0, 0, visibleFrame.size.width, aFrame.origin.y);
            window = windowFrames[i] = [self layoutSize:aSize around:objectCenterX inRect:space horizontally:YES near:NO];
            if (NSEqualRects(window, NSZeroRect))
                goto next;
            middleFrames[i] = NSMakeRect(window.origin.x - kHSPopUpPadding, window.origin.y - kHSPopUpPadding, window.size.width + kHSPopUpPadding * 2, window.size.height + kHSPopUpPadding);
            anchorFrames[i] = NSMakeRect(objectCenterX - window.origin.x - kHSAnchorWidth * 0.5f, window.size.height - kHSAnchorHeight, kHSAnchorWidth, kHSAnchorHeight);
            score = 2.0f * fabsf((float)(window.origin.x + window.size.width * 0.5f) - objectCenterX) / aSize.width + aSize.height / space.size.height;
            break;
        case 2:
            startFrames[i] = NSMakeRect(objectCenterX, NSMaxY(aFrame), 0, 0);
            space = NSMakeRect(0, NSMaxY(aFrame), visibleFrame.size.width, visibleFrame.size.height - NSMaxY(aFrame));
            window = windowFrames[i] = [self layoutSize:aSize around:objectCenterX inRect:space horizontally:YES near:YES];
            if (NSEqualRects(window, NSZeroRect))
                goto next;
            middleFrames[i] = NSMakeRect(window.origin.x - kHSPopUpPadding, window.origin.y, window.size.width + kHSPopUpPadding * 2, window.size.height + kHSPopUpPadding);
            anchorFrames[i] = NSMakeRect(objectCenterX - window.origin.x - kHSAnchorWidth * 0.5f, 0, kHSAnchorWidth, kHSAnchorHeight);
            score = 2.0f * fabsf((float)(window.origin.x + window.size.width * 0.5f) - objectCenterX) / aSize.width + aSize.height / space.size.height + 0.15f;
            break;
        case 3:
            startFrames[i] = NSMakeRect(aFrame.origin.x, objectCenterY, 0, 0);
            space = NSMakeRect(visibleFrame.origin.x, visibleFrame.origin.y, aFrame.origin.x, visibleFrame.size.height);
            window = windowFrames[i] = [self layoutSize:aSize around:objectCenterY inRect:space horizontally:NO near:NO];
            if (NSEqualRects(window, NSZeroRect))
                goto next;
            middleFrames[i] = NSMakeRect(window.origin.x - kHSPopUpPadding, window.origin.y - kHSPopUpPadding, window.size.width + kHSPopUpPadding, window.size.height + kHSPopUpPadding * 2);
            anchorFrames[i] = NSMakeRect(window.size.width - kHSAnchorHeight, objectCenterY - window.origin.y - kHSAnchorWidth * 0.5f, kHSAnchorHeight, kHSAnchorWidth);
            score = 2.0f * fabsf((float)(window.origin.y + window.size.height * 0.5f) - objectCenterY) / aSize.height + aSize.width / space.size.width + 0.15f;
            break;
        default:
            startFrames[i] = NSMakeRect(NSMaxX(aFrame), objectCenterY, 0, 0);
            space = NSMakeRect(NSMaxX(aFrame), visibleFrame.origin.y, visibleFrame.size.width - NSMaxX(aFrame), visibleFrame.size.height);
            window = windowFrames[i] = [self layoutSize:aSize around:objectCenterY inRect:space horizontally:NO near:YES];
            if (NSEqualRects(window, NSZeroRect))
                goto next;
            middleFrames[i] = NSMakeRect(window.origin.x, window.origin.y - kHSPopUpPadding, window.size.width + kHSPopUpPadding, window.size.height + kHSPopUpPadding * 2);
            anchorFrames[i] = NSMakeRect(0, objectCenterY - window.origin.y - kHSAnchorWidth * 0.5f, kHSAnchorHeight, kHSAnchorWidth);
            score = 2.0f * fabsf((float)(window.origin.y + window.size.height * 0.5f) - objectCenterY) / aSize.height + aSize.width / space.size.width + 0.15f;
            break;
        }
        score += [self deltaForObstacleRects:aRects withRect:window] * 5.0f;
        scores[i] = score + [self deltaForObstacleRects:aRects2 withRect:window];
    next:
        if (reuse)
            break;
    }
    if (!reuse)
        position = [self minItemIndex:scores count:5];
    if (position == 0) {
        NSPoint origin = NSPointFromString([[NSUserDefaults standardUserDefaults] objectForKey:HSInspectorOriginKey]);
        NSRect frame = {origin, aSize};
        NSRect middle = NSIntegralRect(NSInsetRect(frame, -kHSPopUpPadding, -kHSPopUpPadding));
        NSRect start = NSMakeRect(NSMidX(frame) - NSZeroRect.size.width * 0.5f, NSMidY(frame) - NSZeroRect.size.height * 0.5f, NSZeroRect.size.width, NSZeroRect.size.height);
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], HSObjectAssistantLayoutWindowPosition,
            [NSValue valueWithRect:frame], HSObjectAssistantLayoutWindowFrame,
            [NSValue valueWithRect:start], HSObjectAssistantLayoutPopUpStartFrame,
            [NSValue valueWithRect:middle], HSObjectAssistantLayoutPopUpMiddleFrame,
            [NSNumber numberWithBool:YES], HSObjectAssistantLayoutShouldNotShowAnchorKey, nil];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)position], HSObjectAssistantLayoutWindowPosition,
        [NSValue valueWithRect:windowFrames[position]], HSObjectAssistantLayoutWindowFrame,
        [NSValue valueWithRect:startFrames[position]], HSObjectAssistantLayoutPopUpStartFrame,
        [NSValue valueWithRect:middleFrames[position]], HSObjectAssistantLayoutPopUpMiddleFrame,
        [NSValue valueWithRect:anchorFrames[position]], HSObjectAssistantLayoutLocalAnchorFrame,
        [NSValue valueWithRect:aFrame], HSObjectAssistantLayoutObjectFrameKey, nil];
}

// The fraction of the rect covered by each obstacle, summed.
- (CGFloat)deltaForObstacleRects:(id)aRects withRect:(NSRect)aRect
{
    float delta = 0.0f;
    NSEnumerator *enumerator = [aRects objectEnumerator];
    NSValue *value;
    while ((value = [enumerator nextObject]) != nil) {
        NSRect intersection = NSIntersectionRect([value rectValue], aRect);
        delta += (float)(intersection.size.width * intersection.size.height) / (float)(aRect.size.width * aRect.size.height);
    }
    return delta;
}

// Centers the size on the coordinate along one axis, 10 points from the
// rect's ends, and puts it at the near or far side on the other axis.
// Original quirk kept: the far limit uses the rect's extent, not its max edge.
- (NSRect)layoutSize:(NSSize)aSize around:(CGFloat)aAround inRect:(NSRect)aRect horizontally:(BOOL)aHorizontally near:(BOOL)aNear
{
    if (!(aRect.size.width > aSize.width) || !(aRect.size.height > aSize.height))
        return NSZeroRect;
    float x, y;
    if (aHorizontally) {
        x = MAX(10.0f, (float)aAround - (float)aSize.width * 0.5f);
        if (x + aSize.width > aRect.size.width - 10.0f)
            x = (float)aRect.size.width - 10.0f - (float)aSize.width;
        y = aNear ? aRect.origin.y : aRect.origin.y + aRect.size.height - aSize.height;
    } else {
        y = MAX((float)aRect.origin.y + 10.0f, (float)aAround - (float)aSize.height * 0.5f);
        if (y + aSize.height > aRect.size.height - 10.0f)
            y = (float)aRect.size.height - 10.0f - (float)aSize.height;
        x = aNear ? aRect.origin.x : aRect.origin.x + aRect.size.width - aSize.width;
    }
    return NSMakeRect(roundf(x), roundf(y), aSize.width, aSize.height);
}

- (NSInteger)minItemIndex:(float *)aIndex count:(NSInteger)aCount
{
    NSInteger index = 0;
    for (NSInteger i = 1; i < aCount; i++) {
        if (aIndex[i] < aIndex[index])
            index = i;
    }
    return index;
}

@end
