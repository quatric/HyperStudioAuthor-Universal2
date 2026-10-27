#import "HyperEditorBasePrefix.h"


@interface HSTrackingController : NSObject
{
    id _value;
    id _dataInterface;
    Protocol *_attribute;
}
- (void)setAttribute:(id)aAttribute;
- (id)attribute;
- (void)setDataInterface:(id)aInterface;
- (id)dataInterface;
- (void)didSetNewValue:(id)aValue;
- (void)willSetNewValue:(id)aValue;
- (void)setValue:(id)aValue;
- (id)value;
- (void)dealloc;
@end

