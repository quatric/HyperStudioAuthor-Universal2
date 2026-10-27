#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSBitmapPencilToolWrapper : HSBitmapTool
{
    NSMutableArray *_startPoints;
    NSMutableArray *_endPoints;
    CGRect _bounds;
}
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)settingsIdentifiers;
- (BOOL)activateBitmapTool;
- (void)addPencilStrokeFromPoint:(CGPoint)aFrom toPoint:(CGPoint)aTo;
- (void)deactivateBitmapTool;
- (void)dealloc;
- (void)getStartPoint:(CGPoint *)aStart endtPoint:(CGPoint *)aEnd forPencilStrokeAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfPencilStrokes;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNext;
@end

