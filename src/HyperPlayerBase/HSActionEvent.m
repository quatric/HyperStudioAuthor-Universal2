#import "HSActionEvent.h"
// What starts an action: shared per type. The default type stands for
// every type but arriving and leaving.
@implementation HSActionEvent
+ (id)actionEventOfType:(id)aType
{
    static NSMutableDictionary *events = nil;
    HSActionEvent *event = [events objectForKey:aType];
    if (event == nil) {
        if (events == nil)
            events = [NSMutableDictionary new];
        event = [[self alloc] initWithActionEventType:aType];
        [events setObject:event forKey:aType];
        [event release];
    }
    return event;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"eventType", nil];
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    NSString *other = [aEqual eventType];
    if ([_eventType isEqual:other])
        return YES;
    if (![_eventType isEqual:@"HSDefaultActionEventType"] && ![other isEqual:@"HSDefaultActionEventType"])
        return NO;
    if ([_eventType isEqual:@"HSArriveActionEventType"] || [_eventType isEqual:@"HSLeaveActionEventType"])
        return NO;
    return ![other isEqual:@"HSArriveActionEventType"] && ![other isEqual:@"HSLeaveActionEventType"];
}
- (NSUInteger)hash
{
    return [_eventType hash];
}
- (id)eventTypeForSave
{
    if ([_eventType isEqualToString:@"HSArriveActionEventType"] || [_eventType isEqualToString:@"HSLeaveActionEventType"])
        return _eventType;
    return @"HSDefaultActionEventType";
}
- (id)eventType
{
    return _eventType;
}
- (id)copyWithZone:(NSZone *)aZone
{
    if (aZone == NULL || [self zone] == aZone)
        return [self retain];
    return [[[self class] allocWithZone:aZone] initWithActionEventType:_eventType];
}
- (void)dealloc
{
    [_eventType release];
    [super dealloc];
}
- (id)initWithActionEventType:(id)aType
{
    self = [super init];
    if (self != nil)
        _eventType = [aType copy];
    return self;
}
@end
