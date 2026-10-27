#import "HSAttributeTextField.h"

// A text field that shows a mixed value as a grey placeholder (wrapped in a
// number formatter's prefix and suffix), with its formatter set aside.

@implementation HSAttributeTextField

// The multiple-values string between the positive format's prefix and
// suffix, +1.
- (id)newPlaceholderStringFromNumberFormatter
{
    NSString *format = [(NSNumberFormatter *)_storedFormatter positiveFormat];
    NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"0#,."];
    NSRange first = [format rangeOfCharacterFromSet:digits];
    NSRange last = [format rangeOfCharacterFromSet:digits options:NSBackwardsSearch];
    NSString *multiple = [[HSMultipleUIValue multipleUIValue] stringValue];
    // Fix: the original took ranges out of a format with no digits.
    if (first.location == NSNotFound)
        return [[NSString alloc] initWithString:multiple];
    NSUInteger end = NSMaxRange(last);
    return [[NSString alloc] initWithFormat:@"%@%@%@", [format substringWithRange:NSMakeRange(0, first.location)], multiple,
                                            [format substringWithRange:NSMakeRange(end, [format length] - end)]];
}

- (void)textDidChange:(id)aChange
{
    [super textDidChange:aChange];
    if ([self hasMultipleValues])
        [self setHasMultipleValues:NO];
}

// The untouched placeholder sends nothing.
- (BOOL)sendAction:(SEL)aAction to:(id)aTo
{
    NSString *string = [self stringValue];
    if ([self hasMultipleValues] && [string isEqual:_placeholderString])
        return NO;
    return [super sendAction:aAction to:aTo];
}

- (void)setHasMultipleValues:(BOOL)aValues
{
    if (_hasMultipleValues == aValues)
        return;
    _hasMultipleValues = aValues;
    if (!aValues) {
        if (_storedFormatter != nil) {
            [self setFormatter:_storedFormatter];
            [_storedFormatter release];
            _storedFormatter = nil;
        }
        [self setTextColor:[NSColor blackColor]];
        return;
    }
    _storedFormatter = [[self formatter] retain];
    [self setFormatter:nil];
    if ([_storedFormatter isKindOfClass:[NSNumberFormatter class]]) {
        [_placeholderString release];
        _placeholderString = [self newPlaceholderStringFromNumberFormatter];
    }
    if (_placeholderString == nil)
        _placeholderString = [[NSString alloc] initWithString:[[HSMultipleUIValue multipleUIValue] stringValue]];
    [self setStringValue:_placeholderString];
    [self setTextColor:[NSColor disabledControlTextColor]];
}

- (BOOL)hasMultipleValues
{
    return _hasMultipleValues;
}

- (void)dealloc
{
    [_placeholderString release];
    [_storedFormatter release];
    [super dealloc];
}

@end
