#import "HyperStudioPrefix.h"


@interface HSCursorsLibraryDataSource : NSObject <HSCursorDialogControllerDataSource, NSObject>
{
    NSArray *_cursors;
}
+ (id)sharedCursorsLibraryDataSource;
- (id)cursorAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfCursors;
- (id)cursors;
- (void)loadCursors;
- (void)dealloc;
- (id)init;
@end

