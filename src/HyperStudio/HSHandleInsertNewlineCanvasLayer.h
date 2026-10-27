#import "HyperStudioPrefix.h"


@interface HSHandleInsertNewlineCanvasLayer : HSSimpleCanvasSublayer
{
    id _owner;
}
- (void)insertNewline:(id)aNewline;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (id)initWithOwner:(id)aOwner;
@end

