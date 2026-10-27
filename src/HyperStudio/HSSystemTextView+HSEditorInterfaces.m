#import "HSSystemTextView+HSEditorInterfaces.h"

@implementation HSSystemTextView (HSEditorInterfaces)

- (Class)runtimeEditorClass
{
    if ([[self queryHyperInterface:@protocol(HSSystemTextViewAttributes)] isRotatableText])
        return [HSRotatableTextObjectEditor class];
    return [HSTextViewEditor class];
}

@end
