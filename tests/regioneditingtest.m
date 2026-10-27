// Exercises BTRegionEditingTool without a view: lifting the image under a
// selection (cut, with undo/redo restoring the pixels), moving and stamping
// the image selection, copy and paste through a pasteboard (in process and
// archived), deletion, the stage names and the key lists.
#import <Cocoa/Cocoa.h>
#import "BTRegionEditingTool.h"
#import "BTSelectionTool.h"

static int failures = 0;

static void check(BOOL aCondition, NSString *aWhat)
{
    if (!aCondition) {
        NSLog(@"FAIL: %@", aWhat);
        failures++;
    }
}

@interface TestDelegate : NSObject
{
@public
    NSUndoManager *undoManager;
    NSMutableArray *stages;
    NSString *actionName;
    int imageChanges;
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
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey {}
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent {}
- (void)tool:(id)aTool willChangeImageInRect:(CGRect)aRect {}
- (void)tool:(id)aTool didChangeImageInRect:(CGRect)aRect { imageChanges++; }
- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(CGRect)aRect {}
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(CGRect)aRect {}
- (void)toolWillBeginChangingImageContinuously:(id)aTool {}
- (void)toolDidEndChangingImageContinuously:(id)aTool {}
@end

static void group(NSUndoManager *aManager, void (^aBlock)(void))
{
    [aManager beginUndoGrouping];
    aBlock();
    [aManager endUndoGrouping];
}

/* The alpha of the pixel at (x, y), y up. */
static int alphaAt(id aImage, int x, int y)
{
    const unsigned char *bytes = [aImage imageBytes];
    NSUInteger rowBytes = [aImage imageBytesPerRow];
    int height = (int)[aImage imageSize].height;
    return bytes[(height - 1 - y) * rowBytes + x * 4];
}

static CGRect rectOf(id aValue)
{
    CGRect rect = CGRectNull;
    [aValue getValue:&rect];
    return rect;
}

static CGAffineTransform transformOf(id aValue)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    [aValue getValue:&transform];
    return transform;
}

int main(void)
{
    @autoreleasepool {
        BTRegionEditingTool *tool = [[BTRegionEditingTool alloc] init];
        check(tool != nil, @"made");
        check([[tool outputKeys] count] == 7, @"output keys");
        NSArray *inputs = [tool inputKeys];
        check([inputs count] == 56 && [[inputs objectAtIndex:0] isEqualToString:@"generalKeyBindings"]
              && [[inputs objectAtIndex:4] isEqualToString:@"backgroundMode"]
              && [[inputs lastObject] isEqualToString:@"doRotateBottomCenterSelectionCursor"], @"input keys");
        check([[tool allUndoCategories] count] == 2, @"undo categories");
        check([[tool backgroundMode] isEqualToString:@"BTClearBackgroundMode"], @"background mode");
        check([tool willMoveSelectionCursor] != nil, @"cursor forwarded");
        [tool setSelectionTolerance:0.5];
        check([tool selectionTolerance] == 0.5, @"tolerance forwarded");

        // A 40x30 opaque work image.
        id image = [BTRegionEditingTool BTRegionEditingTool_mutableImageOfSize:CGSizeMake(40, 30)];
        [image beginCGEditing];
        CGContextSetRGBFillColor([image imageCGContext], 1, 0, 0, 1);
        CGContextFillRect([image imageCGContext], CGRectMake(0, 0, 40, 30));
        [image endCGEditing];
        check(alphaAt(image, 5, 5) == 255, @"opaque work image");
        check([tool setWorkImage:image], @"work image set");
        NSPasteboard *pasteboard = [NSPasteboard pasteboardWithUniqueName];
        [tool setWorkPasteboard:pasteboard];

        TestDelegate *delegate = [[TestDelegate alloc] init];
        delegate->undoManager = [[NSUndoManager alloc] init];
        [delegate->undoManager setGroupsByEvent:NO];
        delegate->stages = [NSMutableArray array];
        NSUndoManager *undo = delegate->undoManager;
        check([tool activateWithDelegate:delegate inView:nil], @"activates");
        check([[tool currentStage] isEqualToString:@"BTWaitingToolStage"], @"waiting");

        // A selection is only a path until it is lifted.
        CGPathRef rect = CGPathCreateWithRect(CGRectMake(10, 10, 10, 10), NULL);
        group(undo, ^{ [tool setSelectionPath:(id)rect]; });
        check([[tool currentStage] isEqualToString:@"BTWaitingToPositionSelectionPathToolStage"], @"waiting to position");
        check([tool imageSelection] == nil && [tool validateAction_finalizeSelection], @"not lifted yet");
        check(![tool validateAction_stamp], @"no stamp before lifting");

        // Lifting cuts the image under the path.
        group(undo, ^{ [tool finalizeSelection:nil]; });
        check([tool imageSelection] != nil, @"image selection lifted");
        check(CGRectEqualToRect(rectOf([tool imageSelectionBounds]), CGRectMake(10, 10, 10, 10)), @"selection bounds");
        check([[tool currentStage] isEqualToString:@"BTWaitingToModifySelectionToolStage"], @"positioned stage");
        check([delegate->actionName isEqualToString:@"Cut Image Selection"], @"cut undo name");
        check(alphaAt(image, 15, 15) == 0 && alphaAt(image, 5, 5) == 255, @"cut cleared the inside only");
        check([[tool activeFeedbackLayers] containsObject:@"BTImageRegionFeedbackLayer"], @"feedback layer");

        [undo undo];
        check(alphaAt(image, 15, 15) == 255, @"undo restores the pixels");
        check([tool imageSelection] == nil
              && [[tool currentStage] isEqualToString:@"BTWaitingToPositionSelectionPathToolStage"], @"undo unlifts");
        [undo redo];
        check(alphaAt(image, 15, 15) == 0 && [tool imageSelection] != nil, @"redo cuts again");

        // Moving the selection moves the image selection; stamping draws it there.
        group(undo, ^{ [tool moveSelectionBy:CGSizeMake(15, 0)]; });
        CGAffineTransform moved = transformOf([tool imageSelectionTransform]);
        check(moved.tx == 15 && moved.ty == 0, @"image selection follows the path");
        check(CGAffineTransformEqualToTransform(transformOf([tool selectionPathTransform]), moved), @"path transform");
        group(undo, ^{ [tool stamp:nil]; });
        check(alphaAt(image, 30, 15) == 255 && alphaAt(image, 15, 15) == 0, @"stamped at the moved place");
        check([delegate->actionName isEqualToString:@"Flatten Image Selection"], @"stamp undo name");
        [undo undo];
        check(alphaAt(image, 30, 15) == 255, @"stamp undone over an opaque area");

        // Copy puts a region on the pasteboard.
        group(undo, ^{ [tool copy:nil]; });
        NSArray *types = [pasteboard types];
        check([types containsObject:@"BTArchivedImageRegionPboardType"]
              && [types containsObject:[BTRegionEditingTool_BTImageRegion imageRegionPasteboardType]]
              && [types containsObject:@"BTCreateSelectionModePboardType"], @"pasteboard types");
        NSData *archived = [pasteboard dataForType:@"BTArchivedImageRegionPboardType"];
        check([archived length] > 25 && strncmp([archived bytes], "BTImageRegionArchive-1.0", 25) == 0, @"archive magic");
        id unarchiver = [[[BTRegionEditingTool_BTImageRegionUnarchiver alloc] initForReadingWithData:archived] autorelease];
        BTRegionEditingTool_BTImageRegion *region =
            [[[BTRegionEditingTool_BTImageRegion alloc] initWithCoder:unarchiver] autorelease];
        check(region != nil, @"archived region decoded");
        CGRect pathRect = CGRectNull;
        check(CGRectEqualToRect([region imageBounds], CGRectMake(10, 10, 10, 10))
              && [region pathTransform].tx == 15 && CGPathIsRect([region path], &pathRect)
              && CGRectEqualToRect(pathRect, CGRectMake(10, 10, 10, 10))
              && CGSizeEqualToSize([[region image] imageSize], CGSizeMake(10, 10)), @"archived region values");
        check([[pasteboard dataForType:NSPasteboardTypePDF] length] > 0, @"pdf provided");

        // Paste replaces the selection with the pasteboard's region.
        group(undo, ^{ [tool delete:nil]; });
        check([tool imageSelection] == nil && [tool selectionPath] == nil, @"deleted");
        check([delegate->actionName isEqualToString:@"Delete Image Selection"], @"delete undo name");
        check([tool validateAction_paste], @"paste valid");
        group(undo, ^{ [tool paste:nil]; });
        check([tool imageSelection] != nil && [tool selectionPath] != nil, @"pasted");
        check(transformOf([tool imageSelectionTransform]).tx == 15, @"pasted where copied");
        check([delegate->actionName isEqualToString:@"Paste Image Selection"], @"paste undo name");
        [undo undo];
        check([tool imageSelection] == nil, @"paste undone");

        [tool deactivate];
        check(![tool isActive], @"deactivated");
        CGPathRelease(rect);
        [tool release];
        [delegate->undoManager release];
        [delegate release];
    }
    if (failures == 0)
        printf("regioneditingtest: all checks passed\n");
    return failures != 0;
}
