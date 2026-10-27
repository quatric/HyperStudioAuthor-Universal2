#import "HyperStudioPrefix.h"


@interface HSStackCursorsDataSource : NSObject <HSCursorDialogControllerDataSource, NSObject, HSCursorAssistantPaneDataSource>
{
    HSStack *_stack;
    NSMutableArray *_cursors;
}
- (id)cursorAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfCursors;
- (void)stackObjectsDidChange:(id)aChange;
- (void)addCursor:(id)aCursor;
- (id)cursors;
- (void)updateCursors;
- (id)stack;
- (void)setStack:(id)aStack;
- (id)initWithStack:(id)aStack;
- (void)dealloc;
@end

