#import "HyperStudioPrefix.h"


@interface HSConcreteCardObject (HSEditorInterfaces)
- (Class)runtimeEditorClass;
- (id)querySelectionKnobsProvider;
- (id)queryNewEditorInterface:(id)aInterface;
- (id)queryRuntimeEditor;
@end

