#import "HSSegmentedCell.h"

// A button cell drawn as a segment of a segmented control, with caps on
// its ends; the background renderer's class and the caps are archived.

@implementation HSSegmentedCell

+ (BOOL)prefersTrackingUntilMouseUp
{
    return YES;
}

- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityButtonRole;
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute])
        return NSAccessibilityRoleDescription(NSAccessibilityButtonRole, nil);
    if (![SMKBackgroundButtonCell instancesRespondToSelector:@selector(accessibilityAttributeValue:)])
        return nil;
    return [super accessibilityAttributeValue:aValue];
}

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    if (![aCoder respondsToSelector:@selector(allowsKeyedCoding)] || ![aCoder allowsKeyedCoding])
        return;
    if ([self hyperPrivateBackgroundRenderer] != nil) {
        NSString *name = NSStringFromClass([[self hyperPrivateBackgroundRenderer] class]);
        if (name != nil)
            [aCoder encodeObject:name forKey:@"HSBackgroundRendererClassName"];
    }
    [aCoder encodeBool:_isLeftCap forKey:@"HSIsLeftCap"];
    [aCoder encodeBool:_isRightCap forKey:@"HSIsRightCap"];
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]) && [aCoder respondsToSelector:@selector(allowsKeyedCoding)] && [aCoder allowsKeyedCoding]) {
        NSString *name = [aCoder decodeObjectForKey:@"HSBackgroundRendererClassName"];
        Class rendererClass = name != nil ? NSClassFromString(name) : Nil;
        if (rendererClass != Nil && [rendererClass respondsToSelector:@selector(sharedBackgroundRenderer)]
            && [[rendererClass sharedBackgroundRenderer] conformsToProtocol:@protocol(SMKBackgroundRenderer)])
            [self setBackgroundRenderer:[rendererClass sharedBackgroundRenderer]];
        _isLeftCap = [aCoder decodeBoolForKey:@"HSIsLeftCap"];
        _isRightCap = [aCoder decodeBoolForKey:@"HSIsRightCap"];
    }
    return self;
}

// A copy through archiving, with the same renderer and caps.
- (id)copyWithZone:(NSZone *)aZone
{
    HSSegmentedCell *copy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    if (copy != nil) {
        [copy setBackgroundRenderer:[self backgroundRenderer]];
        [copy setLeftCap:_isLeftCap];
        [copy setRightCap:_isRightCap];
    }
    return [copy retain];
}

- (void)setRightCap:(BOOL)aCap
{
    if ([self isRightCap] != (aCap != NO)) {
        _isRightCap = aCap != NO;
        [self _invalidateImageCache];
    }
}

- (BOOL)isRightCap
{
    return _isRightCap;
}

- (void)setLeftCap:(BOOL)aCap
{
    if ([self isLeftCap] != (aCap != NO)) {
        _isLeftCap = aCap != NO;
        [self _invalidateImageCache];
    }
}

- (BOOL)isLeftCap
{
    return _isLeftCap;
}

@end

@implementation SMKBackgroundButtonCell (HSSegmentedCellAdditions)

- (id)hyperPrivateBackgroundRenderer
{
    return _backgroundRenderer;
}

@end
