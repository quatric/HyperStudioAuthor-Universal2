#import "HSKeynoteAttributesConvert.h"

@implementation HSKeynoteAttributesConvert

// A direction-specific mapping wins over the plain transition type.
+ (id)transitionFromKeynoteTransition:(id)aTransition
{
    NSString *type = [(KeynoteTransition *)aTransition type];
    if ([type isEqualToString:@"none"])
        return nil;
    NSString *direction = [aTransition directionCodeString];
    id name = nil;
    if ([direction length] != 0)
        name = [[self transitionsForKeynote] objectForKey:[type stringByAppendingString:direction]];
    if (name == nil)
        name = [[self transitionsForKeynote] objectForKey:type];
    if (name == nil)
        return nil;
    HSTransition *transition = [HSTransition transitionWithName:name];
    [transition setDuration:[self transitionDurationFromKeynoteDuration:[(KeynoteTransition *)aTransition duration]]];
    return transition;
}

+ (double)transitionDurationFromKeynoteDuration:(double)aDuration
{
    if (aDuration > HSMaxTransitionDuration)
        return HSMaxTransitionDuration;
    if (aDuration < HSMinTransitionDuration)
        return HSMinTransitionDuration;
    return aDuration;
}

+ (id)transitionsForKeynote
{
    static NSDictionary *transitions = nil;
    if (transitions == nil)
        transitions = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TransitionsForKeynote" ofType:@"plist"]] retain];
    return transitions;
}

@end
