#import "HyperStudioPrefix.h"


@interface HSFolderCursorsDataSource : NSObject <HSCursorAssistantPaneDataSource, NSObject>
{
    NSMutableArray *_cursors;
    NSString *_path;
}
+ (id)defaultPath;
- (id)cursorAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfCursors;
- (void)setPath:(id)aPath;
- (id)path;
- (void)updateCursors;
- (void)dealloc;
@end

