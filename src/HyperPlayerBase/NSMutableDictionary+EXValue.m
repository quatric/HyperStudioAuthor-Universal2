#import "NSMutableDictionary+EXValue.h"

// Scalar and geometry values stored in extra dictionaries. Geometry is
// written as NSValues or as nested {x,y}/{width,height}/{origin,size}
// dictionaries, and read back from NSValues, arrays or dictionaries.
@implementation NSMutableDictionary (EXValue)

- (id)setExtraFloat:(CGFloat)aFloat forKey:(id)aKey
{
    id value = [NSNumber numberWithFloat:(float)aFloat];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraDouble:(double)aDouble forKey:(id)aKey
{
    id value = [NSNumber numberWithDouble:aDouble];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraBool:(BOOL)aBool forKey:(id)aKey
{
    id value = [NSNumber numberWithBool:aBool];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraInt:(NSInteger)aInt forKey:(id)aKey
{
    id value = [NSNumber numberWithInt:(int)aInt];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraLongLong:(long long)aLong forKey:(id)aKey
{
    id value = [NSNumber numberWithLongLong:aLong];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraRange:(NSRange)aRange forKey:(id)aKey
{
    id value = [NSValue valueWithRange:aRange];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraRect:(NSRect)aRect forKey:(id)aKey
{
    id value = [NSValue valueWithRect:aRect];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraSize:(NSSize)aSize forKey:(id)aKey
{
    id value = [NSValue valueWithSize:aSize];
    [self setObject:value forKey:aKey];
    return value;
}

- (id)setExtraPoint:(NSPoint)aPoint forKey:(id)aKey
{
    id value = [NSValue valueWithPoint:aPoint];
    [self setObject:value forKey:aKey];
    return value;
}

@end

@implementation NSDictionary (EXValue)

+ (id)extraDictionaryWithRect:(NSRect)aRect
{
    id size = [self extraDictionaryWithSize:aRect.size];
    id origin = [self extraDictionaryWithPoint:aRect.origin];
    return [self dictionaryWithObjectsAndKeys:origin, @"origin", size, @"size", nil];
}

+ (id)extraDictionaryWithSize:(NSSize)aSize
{
    return [self dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:(float)aSize.width], @"width",
                                              [NSNumber numberWithFloat:(float)aSize.height], @"height", nil];
}

+ (id)extraDictionaryWithPoint:(NSPoint)aPoint
{
    return [self dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:(float)aPoint.x], @"x",
                                              [NSNumber numberWithFloat:(float)aPoint.y], @"y", nil];
}

@end

@implementation NSArray (EXValue)

// (location, length)
- (NSRange)extraRangeValue
{
    if ([self count] < 2)
        return NSMakeRange(NSNotFound, 0);
    return NSMakeRange([[self objectAtIndex:0] intValue], [[self objectAtIndex:1] intValue]);
}

// (x, y, width, height), or (point, size)
- (NSRect)extraRectValue
{
    NSRect rect = NSZeroRect;
    if ([self count] >= 4) {
        rect.size.height = [[self objectAtIndex:3] floatValue];
        rect.size.width = [[self objectAtIndex:2] floatValue];
        rect.origin.y = [[self objectAtIndex:1] floatValue];
        rect.origin.x = [[self objectAtIndex:0] floatValue];
    } else if ([self count] >= 2) {
        id origin = [self objectAtIndex:0];
        id size = [self objectAtIndex:1];
        if ([origin respondsToSelector:@selector(extraPointValue)])
            rect.origin = [origin extraPointValue];
        if ([size respondsToSelector:@selector(extraSizeValue)])
            rect.size = [size extraSizeValue];
    }
    return rect;
}

- (NSSize)extraSizeValue
{
    if ([self count] < 2)
        return NSZeroSize;
    CGFloat height = [[self objectAtIndex:1] floatValue];
    return NSMakeSize([[self objectAtIndex:0] floatValue], height);
}

- (NSPoint)extraPointValue
{
    if ([self count] < 2)
        return NSZeroPoint;
    CGFloat y = [[self objectAtIndex:1] floatValue];
    return NSMakePoint([[self objectAtIndex:0] floatValue], y);
}

@end

@implementation NSObject (EXValue)

// The scalar getters swallow any NSException raised by key-value coding and
// return zero.
- (CGFloat)extraFloatForKey:(id)aKey
{
    float result = 0.0f;
    @try {
        id value = [self safeExtraValueForKey:aKey];
        if (value != nil)
            result = [value floatValue];
    } @catch (NSException *e) {
    }
    return result;
}

- (double)extraDoubleForKey:(id)aKey
{
    double result = 0.0;
    @try {
        id value = [self safeExtraValueForKey:aKey];
        if (value != nil)
            result = [value doubleValue];
    } @catch (NSException *e) {
    }
    return result;
}

- (BOOL)extraBoolForKey:(id)aKey
{
    BOOL result = NO;
    @try {
        id value = [self safeExtraValueForKey:aKey];
        if (value != nil)
            result = [value boolValue];
    } @catch (NSException *e) {
    }
    return result;
}

- (NSInteger)extraIntForKey:(id)aKey
{
    int result = 0;
    @try {
        id value = [self safeExtraValueForKey:aKey];
        if (value != nil)
            result = [value intValue];
    } @catch (NSException *e) {
    }
    return result;
}

- (long long)extraLongLongForKey:(id)aKey
{
    long long result = 0;
    @try {
        id value = [self safeExtraValueForKey:aKey];
        if (value != nil)
            result = [value longLongValue];
    } @catch (NSException *e) {
    }
    return result;
}

- (NSRange)extraRangeForKey:(id)aKey
{
    return [[self safeExtraValueForKey:aKey] extraRangeValue];
}

- (NSRect)extraRectForKey:(id)aKey
{
    return [[self safeExtraValueForKey:aKey] extraRectValue];
}

- (NSSize)extraSizeForKey:(id)aKey
{
    return [[self safeExtraValueForKey:aKey] extraSizeValue];
}

- (NSPoint)extraPointForKey:(id)aKey
{
    return [[self safeExtraValueForKey:aKey] extraPointValue];
}

- (NSRange)extraRangeValue
{
    if ([self respondsToSelector:@selector(rangeValue)])
        return [(NSValue *)self rangeValue];
    id location = [self safeExtraValueForKey:@"location"];
    id length = [self safeExtraValueForKey:@"length"];
    if (location == nil || length == nil)
        return NSMakeRange(NSNotFound, 0);
    return NSMakeRange([location intValue], [length intValue]);
}

// {origin, size}, or a flat {x, y, width, height} dictionary.
- (NSRect)extraRectValue
{
    if ([self respondsToSelector:@selector(rectValue)])
        return [(NSValue *)self rectValue];
    NSRect rect;
    id origin = [self safeExtraValueForKey:@"origin"];
    id size = [self safeExtraValueForKey:@"size"];
    if (origin == nil || size == nil) {
        rect.origin = [self extraPointValue];
        rect.size = [self extraSizeValue];
    } else {
        rect.origin = [origin extraPointValue];
        rect.size = [size extraSizeValue];
    }
    return rect;
}

- (NSSize)extraSizeValue
{
    if ([self respondsToSelector:@selector(sizeValue)])
        return [(NSValue *)self sizeValue];
    CGFloat height = [self extraFloatForKey:@"height"];
    return NSMakeSize([self extraFloatForKey:@"width"], height);
}

- (NSPoint)extraPointValue
{
    if ([self respondsToSelector:@selector(pointValue)])
        return [(NSValue *)self pointValue];
    CGFloat y = [self extraFloatForKey:@"y"];
    return NSMakePoint([self extraFloatForKey:@"x"], y);
}

@end

@implementation NSValue (EXValue)

- (NSRange)extraRangeValue
{
    return [self rangeValue];
}

- (NSRect)extraRectValue
{
    return [self rectValue];
}

- (NSSize)extraSizeValue
{
    return [self sizeValue];
}

- (NSPoint)extraPointValue
{
    return [self pointValue];
}

@end

@implementation NSObject (HSValueProtected)

// valueForKey: that returns nil instead of raising for unknown keys.
- (id)safeExtraValueForKey:(id)aKey
{
    id result = nil;
    @try {
        result = [self valueForKey:aKey];
    } @catch (NSException *e) {
    }
    return result;
}

@end
