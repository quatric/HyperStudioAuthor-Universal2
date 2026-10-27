// Exercises BTSelectionTool without a view: the create/modify subtool
// switching when a selection is set, finished or removed (with undo), the
// stage names, the selection outputs, disabling creation, the forwards to the
// subtools and the key lists.
#import <Cocoa/Cocoa.h>
#import "BTSelectionTool.h"
#import "BTCreateSelectionTool.h"
#import "BTModifySelectionTool.h"

static int failures = 0;

static void check(BOOL aCondition, NSString *aWhat)
{
    if (!aCondition) {
        NSLog(@"FAIL: %@", aWhat);
        failures++;
    }
}

/* Exposes the subtools. */
@interface TestSelectionTool : BTSelectionTool
@end

@implementation TestSelectionTool
- (id)subtool { return _currentSubtool; }
- (id)createTool { return _createSelectionTool; }
- (id)modifyTool { return _modifySelectionTool; }
@end

@interface TestDelegate : NSObject
{
@public
    NSUndoManager *undoManager;
    NSMutableArray *stages;
    NSMutableArray *updates;
    NSString *actionName;
}
@end

@implementation TestDelegate
- (id)layoutGuidingContextForTool:(id)aTool { return nil; }
- (id)mouseTrackingDelegateForTool:(id)aTool { return nil; }
- (id)imageViewTransformerForTool:(id)aTool { return nil; }
- (id)tool:(id)aTool willSetUndoActionName:(id)aName { actionName = aName; return nil; }
- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory {}
- (id)undoManagerForTool:(id)aTool category:(id)aCategory { return undoManager; }
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNext
{
    [stages addObject:[NSString stringWithFormat:@"%@>%@", aStage, aNext]];
    return YES;
}
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey {}
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey {}
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey { [updates addObject:aKey]; }
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent {}
@end

static void group(NSUndoManager *aManager, void (^aBlock)(void))
{
    [aManager beginUndoGrouping];
    aBlock();
    [aManager endUndoGrouping];
}

static CGAffineTransform transformOf(id aTool)
{
    CGAffineTransform t = CGAffineTransformIdentity;
    [[aTool selectionAffineTransform] getValue:&t];
    return t;
}

static BOOL samePath(id aPath, CGPathRef aOther)
{
    return aPath != nil && CGPathEqualToPath((CGPathRef)aPath, aOther);
}

int main(void)
{
    @autoreleasepool {
        TestSelectionTool *tool = [[TestSelectionTool alloc] init];
        id create = [tool createTool], modify = [tool modifyTool];
        check(create != nil && modify != nil, @"subtools made");
        check([[tool outputKeys] count] == 5, @"output keys");
        NSArray *inputs = [tool inputKeys];
        check([inputs count] == 52 && [[inputs objectAtIndex:0] isEqualToString:@"generalKeyBindings"]
              && [[inputs objectAtIndex:11] isEqualToString:@"willCreateFreeHandSelectionCursor"]
              && [[inputs lastObject] isEqualToString:@"doRotateBottomCenterSelectionCursor"], @"input keys");
        check([[tool allUndoCategories] isEqual:[NSSet setWithObject:@"BTSelectionUndoCategory"]], @"undo categories");
        check([[tool currentStage] isEqualToString:@"BTWaitingToolStage"], @"inactive stage");

        // Forwards to the subtools.
        check([tool willMoveSelectionCursor] == [modify willMoveSelectionCursor], @"move cursor from modify");
        check([tool willCreateShapeSelectionCursor] == [create willCreateShapeSelectionCursor], @"shape cursor from create");
        [tool setDoRotateTopLeftSelectionCursor:[NSCursor IBeamCursor]];
        check([modify doRotateTopLeftSelectionCursor] == [NSCursor IBeamCursor], @"cursor set on modify");
        [tool setTolerance:0.25];
        check([tool tolerance] == 0.25 && [create tolerance] == 0.25, @"tolerance");
        [tool setProportionalModePrimaryForSides:YES];
        check([modify isProportionalModePrimaryForSides], @"sides on modify");
        [tool setAlternateProportion:2.0];
        check([create alternateProportion] == 2.0, @"proportion on create");

        TestDelegate *delegate = [[TestDelegate alloc] init];
        delegate->undoManager = [[NSUndoManager alloc] init];
        [delegate->undoManager setGroupsByEvent:NO];
        delegate->stages = [NSMutableArray array];
        delegate->updates = [NSMutableArray array];
        NSUndoManager *undo = delegate->undoManager;

        check([tool activateWithDelegate:delegate inView:nil], @"activates");
        check([tool subtool] == create, @"creating first");
        check([[tool currentStage] isEqualToString:[create currentStage]], @"create stage");
        check([tool currentCreateSelectionMode] != nil, @"creation enabled");
        check([tool selectionAffineTransform] == nil && ![tool isSelectionFlippedHorizontally], @"no transform while creating");

        // Setting a selection hands it to the modify tool, as one undo action.
        CGPathRef rect = CGPathCreateWithRect(CGRectMake(10, 20, 40, 30), NULL);
        group(undo, ^{ [tool setSelectionPath:(id)rect]; });
        check([tool subtool] == modify && [modify isActive], @"modify after set");
        check([[tool currentStage] isEqualToString:@"BTWaitingToModifySelectionToolStage"], @"waiting to modify");
        check(samePath([tool selectionPath], rect), @"selection path");
        check([delegate->actionName isEqualToString:@"Set Selection"], @"set undo name");
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"untransformed");

        [undo undo];
        check([tool subtool] == create, @"undo goes back to creating");
        [undo redo];
        check([tool subtool] == modify && samePath([tool selectionPath], rect), @"redo sets it again");

        // Transforms go to the modify tool.
        group(undo, ^{ [tool moveSelectionBy:CGSizeMake(5, -3)]; });
        CGAffineTransform t = transformOf(tool);
        check(t.tx == 5 && t.ty == -3, @"moved through the tool");
        [undo undo];
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"move undone");

        // The modify tool finishing removes the selection and goes back to creating.
        [delegate->stages removeAllObjects];
        group(undo, ^{
            [tool tool:modify didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
        });
        check([delegate->stages count] == 1
              && [[delegate->stages objectAtIndex:0] isEqualToString:@"BTWaitingToModifySelectionToolStage>(null)"],
              [NSString stringWithFormat:@"finish reported as waiting to modify: %@", delegate->stages]);
        check([tool subtool] == create && ![modify isActive], @"back to creating");
        check([delegate->actionName isEqualToString:@"Remove Selection"], @"remove undo name");
        [delegate->updates removeAllObjects];
        [undo undo];
        check([tool subtool] == modify && [modify isActive] && samePath([tool selectionPath], rect),
              @"undo restores the selection to the modify tool");
        check([delegate->updates containsObject:@"selectionPath"]
              && [delegate->updates containsObject:@"selectionAffineTransform"]
              && [delegate->updates containsObject:@"isSelectionFlippedHorizontally"], @"restored outputs reported");

        // A stage change of the modify tool is renamed both ways.
        [delegate->stages removeAllObjects];
        [tool tool:modify didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:@"BTWaitingToolStage"];
        check([[delegate->stages lastObject] isEqualToString:@"BTWaitingToModifySelectionToolStage>BTWaitingToModifySelectionToolStage"],
              @"stage names");
        check([tool subtool] == modify, @"stage change keeps the selection");

        // Removing the selection through the selection path.
        group(undo, ^{ [tool setSelectionPath:nil]; });
        check([tool subtool] == create, @"nil path removes the selection");
        check([delegate->actionName isEqualToString:@"Remove Selection"], @"nil path undo name");
        [undo undo];
        check([tool subtool] == modify && samePath([tool selectionPath], rect), @"removal undone");

        // Without creation the modify tool stays current.
        [tool setInitialCreateSelectionMode:nil];
        check([tool currentCreateSelectionMode] == nil && [tool initialCreateSelectionMode] == nil, @"creation disabled");
        group(undo, ^{ [tool setSelectionPath:nil]; });
        check([tool subtool] == modify && [tool selectionPath] == nil, @"empty selection kept on modify");
        [tool selectAllArea:nil];
        check(![tool validateAction_selectAllArea] && [tool subtool] == modify, @"no select all without creation");
        [tool setInitialCreateSelectionMode:@"BTShapeCreateSelectionMode"];
        check([tool currentCreateSelectionMode] != nil && [create isActive] && [tool subtool] == modify, @"creation enabled again");

        [tool deactivate];
        check([tool subtool] == nil && ![create isActive] && ![modify isActive], @"deactivated");
        CGPathRelease(rect);
        [tool release];
        [delegate->undoManager release];
        [delegate release];
    }
    if (failures == 0)
        printf("selectiontest: all checks passed\n");
    return failures != 0;
}
