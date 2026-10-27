#import "HSPictureshowAttributes.h"
@implementation HSPictureshowAttributes
+ (id)defaultPictureshowAttributes
{
    return [self objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSPictureshowAttributesKeyString"]];
}
- (BOOL)useClickOnNextSlide
{
    return YES;
}
- (BOOL)useKeystrokeOnNextSlide
{
    return YES;
}
- (BOOL)useKeystrokeOnExitCard:(id)aCard
{
    // Only Escape may leave a picture show.
    if (aCard != nil && [(NSEvent *)aCard type] == NSEventTypeKeyDown && [(NSEvent *)aCard keyCode] == 0x35)
        return [super useKeystrokeOnExitCard:aCard];
    return NO;
}
@end
