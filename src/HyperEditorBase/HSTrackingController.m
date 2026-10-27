#import "HSTrackingController.h"

// Groups value changes made while tracking a control into one continuous
// change of an attribute; subclasses decide when it begins and ends.

@implementation HSTrackingController

- (void)setAttribute:(id)aAttribute
{
    _attribute = aAttribute;
}

- (id)attribute
{
    return _attribute;
}

- (void)setDataInterface:(id)aInterface
{
    if (_dataInterface != aInterface) {
        [_dataInterface release];
        _dataInterface = [aInterface retain];
    }
}

- (id)dataInterface
{
    return _dataInterface;
}

- (void)didSetNewValue:(id)aValue
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)willSetNewValue:(id)aValue
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)setValue:(id)aValue
{
    if (![_value isEqual:aValue]) {
        [self willSetNewValue:aValue];
        [_value release];
        _value = [aValue retain];
        [self didSetNewValue:aValue];
    }
}

- (id)value
{
    return _value;
}

- (void)dealloc
{
    [_value release];
    [_dataInterface release];
    [super dealloc];
}

@end
