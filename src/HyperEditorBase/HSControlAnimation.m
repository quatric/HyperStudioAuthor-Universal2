#import "HSControlAnimation.h"

// Animates key-value properties of controls: each dictionary names a
// target, a key, and start and end values (numbers or colours).

@implementation HSControlAnimation

- (void)finishAnimation
{
    NSEnumerator *enumerator = [_properties objectEnumerator];
    NSDictionary *property;
    while ((property = [enumerator nextObject]))
        [[property objectForKey:@"HSControlAnimatorTargetKey"] setValue:[property objectForKey:@"HSControlAnimatorEndValueKey"]
                                                                  forKey:[property objectForKey:@"HSControlAnimatorPropertyKey"]];
}

- (void)setCurrentProgress:(CGFloat)aProgress
{
    NSEnumerator *enumerator = [_properties objectEnumerator];
    NSDictionary *property;
    while ((property = [enumerator nextObject])) {
        id target = [property objectForKey:@"HSControlAnimatorTargetKey"];
        id start = [property objectForKey:@"HSControlAnimatorStartValueKey"];
        id end = [property objectForKey:@"HSControlAnimatorEndValueKey"];
        id key = [property objectForKey:@"HSControlAnimatorPropertyKey"];
        id value = nil;
        float progress = (float)aProgress;
        if ([start isKindOfClass:[NSNumber class]])
            value = [NSNumber numberWithDouble:([end doubleValue] - [start doubleValue]) * progress + [start doubleValue]];
        else if ([start isKindOfClass:[NSColor class]]) {
            NSColor *from = [start colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
            NSColor *to = [end colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
            value = [NSColor colorWithCalibratedRed:((float)[to redComponent] - (float)[from redComponent]) * progress + (float)[from redComponent]
                                              green:((float)[to greenComponent] - (float)[from greenComponent]) * progress + (float)[from greenComponent]
                                               blue:((float)[to blueComponent] - (float)[from blueComponent]) * progress + (float)[from blueComponent]
                                              alpha:((float)[to alphaComponent] - (float)[from alphaComponent]) * progress + (float)[from alphaComponent]];
        }
        [target setValue:value forKey:key];
    }
}

- (void)dealloc
{
    [_properties release];
    [super dealloc];
}

- (id)initWithAnimationProperties:(id)aProperties
{
    if ((self = [super init])) {
        _properties = [aProperties retain];
        [self setAnimationBlockingMode:NSAnimationNonblocking];
    }
    return self;
}

@end
