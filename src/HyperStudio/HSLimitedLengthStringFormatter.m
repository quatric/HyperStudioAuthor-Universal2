#import "HSLimitedLengthStringFormatter.h"

@implementation HSLimitedLengthStringFormatter

+ (id)formatterWithLengthLimit:(NSUInteger)aLimit
{
    id formatter = [[[self class] new] autorelease];

    [formatter setMaximumLengthAllowed:aLimit];
    return formatter;
}

// Original quirk kept: the error description is not passed on to super.
- (BOOL)isPartialStringValid:(id *)aValid proposedSelectedRange:(NSRange *)aRange originalString:(id)aString originalSelectedRange:(NSRange)aRange2 errorDescription:(id *)aDescription
{
    BOOL valid = [super isPartialStringValid:aValid proposedSelectedRange:aRange originalString:aString originalSelectedRange:aRange2 errorDescription:NULL];

    if (valid && [self maximumLengthAllowed] != 0 && [*aValid length] > [self maximumLengthAllowed]) {
        NSBeep();
        return NO;
    }
    if (![[self evalutePredicate] evaluateWithObject:*aValid]) {
        NSBeep();
        return NO;
    }
    return valid;
}

- (BOOL)getObjectValue:(id *)aValue forString:(id)aString errorDescription:(id *)aDescription
{
    if (aValue != NULL)
        *aValue = aString;
    return aString != nil;
}

- (id)stringForObjectValue:(id)aValue
{
    id string = aValue;

    if (![aValue isKindOfClass:[NSString class]])
        string = [aValue respondsToSelector:@selector(string)] ? [aValue string] : nil;
    if ([aValue respondsToSelector:@selector(stringValue)])
        string = [aValue stringValue];
    return string != nil ? string : @"";
}

- (NSUInteger)maximumLengthAllowed
{
    return _maximumLengthAllowed;
}

- (void)setMaximumLengthAllowed:(NSUInteger)aAllowed
{
    _maximumLengthAllowed = (unsigned int)aAllowed;
}

- (id)evalutePredicate
{
    if (_evalutePredicate == nil)
        _evalutePredicate = [[NSPredicate predicateWithFormat:@"SELF MATCHES '[\\\\w \\\\s ! # $ % & \\' ( ) \\\\\\\\  * + , \\\\- . \\/ : ; < = > ? @ \\\\[ \\\\] \\^ _ ` { } | ~ ±]*'"] retain];
    return _evalutePredicate;
}

- (void)dealloc
{
    [_evalutePredicate release];
    [super dealloc];
}

@end
