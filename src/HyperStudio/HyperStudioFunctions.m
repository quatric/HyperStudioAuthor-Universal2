// Plain C functions of the original binary, still to translate.
#import "HyperStudioPrefix.h"

// The C runtime start-up (crt1) and the QuickTime Flash enabler (QFlash*,
// for QuickTime 7's Flash track) are gone; main registers the media
// library's content filters before the application starts.
int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    Class libraryManager = NSClassFromString(@"HSLibraryManager");
    Class contentFilter = NSClassFromString(@"HSLibraryContentFilter");
    [[libraryManager sharedLibraryManager] registerMediaContentFilter:[contentFilter sharedContentFilter]];
    contentFilter = NSClassFromString(@"HSLibraryMoviesContentFilter");
    [[libraryManager sharedLibraryManager] registerMoviesContentFilter:[contentFilter sharedContentFilter]];
    contentFilter = NSClassFromString(@"HSLibrarySoundsContentFilter");
    [[libraryManager sharedLibraryManager] registerSoundsContentFilter:[contentFilter sharedContentFilter]];
    [pool release];
    return NSApplicationMain(argc, argv);
}

// Layout rule helpers shared by HSLayoutSimpleRule and
// HSLayoutGridCornerAlignmentRule. Side numbers: 0 left, 1 bottom, 2 right,
// 3 top, 4 horizontal centre, 5 vertical centre.
NSRect HSLayoutRuleTranslateRect(id aRule, NSRect aRect)
{
    CGFloat x = aRect.origin.x;
    CGFloat y = aRect.origin.y;
    if ([aRule affectsRectSide:0])
        x = [aRule layoutRuleFloatValueForRectSide:0];
    else if ([aRule affectsRectSide:2])
        x = [aRule layoutRuleFloatValueForRectSide:2] - aRect.size.width;
    else if ([aRule affectsRectSide:4])
        x += [aRule layoutRuleFloatValueForRectSide:4] - (aRect.size.width * 0.5 + aRect.origin.x);
    if ([aRule affectsRectSide:1])
        y = [aRule layoutRuleFloatValueForRectSide:1];
    else if ([aRule affectsRectSide:3])
        y = [aRule layoutRuleFloatValueForRectSide:3] - aRect.size.height;
    else if ([aRule affectsRectSide:5])
        y += [aRule layoutRuleFloatValueForRectSide:5] - (aRect.size.height * 0.5 + aRect.origin.y);
    return NSMakeRect(x, y, aRect.size.width, aRect.size.height);
}

NSUInteger HSLayoutRuleHash(id aRule)
{
    if ([aRule affectedRectSidesCount] == 0)
        return 0;
    NSInteger side = [aRule affectedRectSideAtIndex:0];
    float value = [aRule layoutRuleFloatValueForRectSide:side];
    return (unsigned int)(((unsigned int)side << 24) | (unsigned int)value);
}

BOOL HSLayoutRuleIsEqual(id aRule, id anotherRule)
{
    if ([aRule appliesToXAxis] != [anotherRule appliesToXAxis])
        return NO;
    if ([aRule appliesToYAxis] != [anotherRule appliesToYAxis])
        return NO;
    if ([aRule affectedRectSidesCount] != [anotherRule affectedRectSidesCount])
        return NO;
    BOOL equal = YES;
    for (NSUInteger side = 0; side < 8; side++) {
        if ([aRule affectsRectSide:side] != [anotherRule affectsRectSide:side])
            return NO;
        if ([aRule affectsRectSide:side]) {
            float other = [anotherRule layoutRuleFloatValueForRectSide:side];
            float mine = [aRule layoutRuleFloatValueForRectSide:side];
            float a = mine != 0.0f ? fabsf(mine) : 1.0f;
            float b = other != 0.0f ? fabsf(other) : 1.0f;
            if (b <= a)
                b = a;
            equal = fabsf(mine - other) <= b * 0.0005f;
        }
        if (!equal)
            return NO;
    }
    return equal;
}

#if 0

// Not carried over as C functions (block copy/dispose helpers, block and
// comparator bodies inlined into the translated callers, QuickTime 7 track
// copy): see docs/HyperStudioFunctions-untranslated.txt.
