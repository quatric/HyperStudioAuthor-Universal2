#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSActionEvent : HSObject <EXKeyValueCoding, NSCopying>
{
    NSString *_eventType;
}
+ (id)actionEventOfType:(id)aType;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)isEqual:(id)aEqual;
- (NSUInteger)hash;
- (id)eventTypeForSave;
- (id)eventType;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithActionEventType:(id)aType;
@end

