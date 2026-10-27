#import "HyperStudioPrefix.h"
#import "HSTextStyleAssistantPane.h"


@interface HSButtonObjectStyleAssistantPane : HSTextStyleAssistantPane
{
    id<HSButtonObjectAttributes> _observedButtonObjectAttributes;
    id<HSButtonObjectSystemStyleBackgroundAttributes> _observedButtonObjectBackgroundAttributes;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)validateUI;
- (void)validateAlignmentMatrixState;
- (void)validateUIWithNotification:(id)aNotification;
- (void)setVerticalAlignment:(id)aAlignment;
- (void)setObservedButtonObjectBackgroundAttributes:(id)aAttributes;
- (void)setObservedButtonObjectAttributes:(id)aAttributes;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (id)init;
@end

