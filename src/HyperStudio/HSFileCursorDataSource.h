#import "HyperStudioPrefix.h"


@interface HSFileCursorDataSource : NSObject <HSCursorDialogControllerDataSource, NSObject>
{
    HSCursor *_cursor;
}
- (void)setCursorFromFileName:(id)aName;
- (void)setCursor:(id)aCursor;
- (id)cursorAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfCursors;
- (void)dealloc;
@end

