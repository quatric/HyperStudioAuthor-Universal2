#import "HyperStudioPrefix.h"


@interface HSLimitedLengthStringFormatter : NSFormatter
{
    unsigned int _maximumLengthAllowed;
    NSPredicate *_evalutePredicate;
}
+ (id)formatterWithLengthLimit:(NSUInteger)aLimit;
- (BOOL)isPartialStringValid:(id *)aValid proposedSelectedRange:(NSRange *)aRange originalString:(id)aString originalSelectedRange:(NSRange)aRange2 errorDescription:(id *)aDescription;
- (BOOL)getObjectValue:(id *)aValue forString:(id)aString errorDescription:(id *)aDescription;
- (id)stringForObjectValue:(id)aValue;
- (NSUInteger)maximumLengthAllowed;
- (void)setMaximumLengthAllowed:(NSUInteger)aAllowed;
- (id)evalutePredicate;
@end

