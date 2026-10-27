#import "BTRegionEditingTool.h"
#import "BTSelectionTool.h"
#import "BTCGBitmapLayer.h"
#import "BTCGImageSaver.h"
#import "NSEvent_BTKeyBinding_BTKeyEventsInterpreter.h"

/* The region editing tool: a selection tool selects a region of the work
   image, and once the selection is moved (or copied, pasted, cut) the image
   under it is lifted into an image selection that follows the selection
   path's transform until it is pasted back ("flattened"). While the image
   selection is unpositioned the selection path is only a path; the image
   under it is copied when it is first moved. Cut regions can be restored
   from a restorator as long as the selection hasn't been transformed.
   Copies go to the pasteboard as a BTImageRegion (in process, archived, PDF
   and PNG). */
@implementation BTRegionEditingTool

static NSString *const BTWaitingStage = @"BTWaitingToolStage";
static NSString *const BTCreatingStage = @"BTCreatingSelectionToolStage";
static NSString *const BTWaitingToModifyStage = @"BTWaitingToModifySelectionToolStage";
static NSString *const BTModifyingStage = @"BTModifyingSelectionToolStage";
static NSString *const BTWaitingToPositionStage = @"BTWaitingToPositionSelectionPathToolStage";

/* Whether the current subtool is in aStage. */
static BOOL BTRegionEditingToolIsInStage(BTRegionEditingTool *self, NSString *aStage)
{
    return [[self->_currentSubtool currentStage] isEqualToString:aStage];
}

/* Whether the selection is being (or waiting to be) modified. */
static BOOL BTRegionEditingToolIsModifying(BTRegionEditingTool *self)
{
    id stage = [self->_currentSubtool currentStage];
    return [stage isEqualToString:BTWaitingToModifyStage] || [stage isEqualToString:BTModifyingStage];
}

/* An undo invocation target in the selection category, or nil without an
   undo manager. */
static id BTRegionEditingToolUndo(BTRegionEditingTool *self)
{
    id manager = [self->_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager == nil)
        return nil;
    return [self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self];
}

static id BTRegionEditingToolTransformValue(CGAffineTransform aTransform)
{
    return [NSValue valueWithBytes:&aTransform objCType:@encode(CGAffineTransform)];
}

/* Tells the selection tool's delegate that the image selection is about to
   change in the given steps. */
static void BTRegionEditingToolWill(BTRegionEditingTool *self, NSString *aKey)
{
    [self->_delegate tool:self willUpdateOutputForKey:aKey];
}

static void BTRegionEditingToolDid(BTRegionEditingTool *self, NSString *aKey)
{
    [self->_delegate tool:self didUpdateOutputForKey:aKey];
}

/* The path transformed by aTransform; the caller releases it. */
static CGMutablePathRef BTRegionEditingToolCreateTransformedPath(CGPathRef aPath, CGAffineTransform aTransform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path != NULL)
        CGPathAddPath(path, &aTransform, aPath);
    return path;
}

/* A 32-bit RGB bitmap layer with 16-byte aligned rows. */
+ (id)BTRegionEditingTool_mutableImageOfSize:(CGSize)aSize
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    size_t width = aSize.width > 0 ? lround(ceil(aSize.width)) : 0;
    size_t height = aSize.height > 0 ? lround(ceil(aSize.height)) : 0;
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~(size_t)15, space,
                                                  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (context == NULL)
        return nil;
    id layer = [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
    CGContextRelease(context);
    return layer;
}

- (id)layoutGuidingContextForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate layoutGuidingContextForTool:self] : nil;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate imageViewTransformerForTool:self] : nil;
}

/* Undo names of a positioned selection talk about the image selection, with
   the "Cut and "/"Copy and " prefix of a selection lifted by a move. Removing
   the selection gets no name of its own. */
- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    if (_currentSubtool != aTool)
        return nil;
    NSString *name = aName;
    if ([aName isEqualToString:@"Remove Selection"])
        name = nil;
    else if (_isSelectionPathPositioned) {
        NSRange range = [aName rangeOfString:@"Selection"];
        if (range.location != NSNotFound) {
            NSMutableString *imageName = [NSMutableString stringWithString:aName];
            [imageName insertString:@"Image " atIndex:range.location];
            if (_selectionPathPositioningUndoActionNamePrefix != nil)
                [imageName insertString:_selectionPathPositioningUndoActionNamePrefix atIndex:0];
            name = imageName;
        }
    }
    [_selectionPathPositioningUndoActionNamePrefix release];
    _selectionPathPositioningUndoActionNamePrefix = nil;
    if (name != nil)
        [self setUndoActionName:name];
    return nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
    if (_currentSubtool == aTool)
        [_delegate tool:self willRegisterUndoInManager:aManager category:aCategory];
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return _currentSubtool == aTool ? [_delegate undoManagerForTool:self category:aCategory] : nil;
}

/* The selection tool's stages as seen from outside: an unpositioned
   selection waits to be positioned rather than modified. Moving it the first
   time lifts the image under it (cut, or copied with Option); moving a
   positioned one with Option stamps a copy first. Finishing a positioned
   selection flattens it. */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    [_selectionPathPositioningUndoActionNamePrefix release];
    _selectionPathPositioningUndoActionNamePrefix = nil;
    if (aNextStage == nil) {
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
        [_delegate tool:self didFinalizeOutputForKey:@"imageSelectionBounds"];
        [_delegate tool:self didFinalizeOutputForKey:@"imageSelection"];
        id stage = aStage;
        if (_isSelectionPathPositioned) {
            [self beginUndoAction];
            if (_imageSelection != nil)
                [self BTRegionEditingTool_invalidateImageSelection];
            [self BTRegionEditingTool_paste];
            [self BTRegionEditingTool_disableWorkImageRestoration];
            [self endUndoActionWithName:@"Flatten Image Selection"];
        } else {
            BOOL waitingToModify = [aStage isEqualToString:BTWaitingToModifyStage];
            [self setUndoActionName:@"Remove Selection"];
            if (waitingToModify)
                stage = BTWaitingToPositionStage;
        }
        BOOL result = [_delegate tool:self didFinalizeStage:stage withEvent:aEvent nextStage:nil];
        if (_currentSubtool != nil && _isSelectionPathPositioned)
            [self BTRegionEditingTool_clearImageSelection];
        return result;
    }
    BOOL nextIsWaitingToModify = [aNextStage isEqualToString:BTWaitingToModifyStage];
    if (([aStage isEqualToString:BTWaitingStage] || [aStage isEqualToString:BTCreatingStage])
        && (nextIsWaitingToModify || [aNextStage isEqualToString:BTModifyingStage]))
        return [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent
                     nextStage:nextIsWaitingToModify ? BTWaitingToPositionStage : aNextStage];
    if ([aStage isEqualToString:BTWaitingToModifyStage] && [aNextStage isEqualToString:BTModifyingStage]) {
        BOOL positioned = _isSelectionPathPositioned;
        BOOL result = [_delegate tool:self
                     didFinalizeStage:positioned ? BTWaitingToModifyStage : BTWaitingToPositionStage
                            withEvent:aEvent nextStage:aNextStage];
        BOOL option = ([aEvent modifierFlags] & NSEventModifierFlagOption) != 0;
        if (positioned) {
            if (option) {
                [self BTRegionEditingTool_paste];
                [self BTRegionEditingTool_disableWorkImageRestoration];
            }
            return result;
        }
        [self BTRegionEditingTool_finalizeSelectionWithCopying:YES deletion:!option];
        _selectionPathPositioningUndoActionNamePrefix = [(option ? @"Copy and " : @"Cut and ") retain];
        return result;
    }
    return [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
}

- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionAffineTransform"]) {
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPathTransform"];
        [_delegate tool:self didFinalizeOutputForKey:@"imageSelectionTransform"];
    } else if ([aKey isEqualToString:@"isSelectionFlippedHorizontally"])
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPathFlippedHorizontally"];
    else if ([aKey isEqualToString:@"currentCreateSelectionMode"])
        [_delegate tool:self didFinalizeOutputForKey:@"currentCreateSelectionMode"];
}

/* A transformed positioned selection can't be restored any more: the
   restorator only puts the cut region back where it was. */
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"])
        BTRegionEditingToolDid(self, @"selectionPath");
    else if ([aKey isEqualToString:@"selectionAffineTransform"]) {
        BTRegionEditingToolDid(self, @"selectionPathTransform");
        if (!_isSelectionPathPositioned)
            return;
        BOOL wasCalculated = _isImageSelectionTransformCalculated;
        _isImageSelectionTransformCalculated = 0;
        if (wasCalculated)
            BTRegionEditingToolDid(self, @"imageSelectionTransform");
        if (_imageSelection != nil)
            [self BTRegionEditingTool_invalidateImageSelection];
        if (_workImageRestorator != nil) {
            id value = [_selectionTool selectionAffineTransform];
            if (value == nil)
                _shouldRestoreWorkImage = 1;
            else {
                CGAffineTransform transform = CGAffineTransformIdentity;
                [value getValue:&transform];
                _shouldRestoreWorkImage = CGAffineTransformIsIdentity(transform);
            }
        }
    } else if ([aKey isEqualToString:@"isSelectionFlippedHorizontally"])
        BTRegionEditingToolDid(self, @"selectionPathFlippedHorizontally");
    else if ([aKey isEqualToString:@"currentCreateSelectionMode"])
        BTRegionEditingToolDid(self, @"currentCreateSelectionMode");
}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"])
        BTRegionEditingToolWill(self, @"selectionPath");
    else if ([aKey isEqualToString:@"selectionAffineTransform"]) {
        BTRegionEditingToolWill(self, @"selectionPathTransform");
        if (!_isSelectionPathPositioned)
            return;
        if (_isImageSelectionTransformCalculated)
            BTRegionEditingToolWill(self, @"imageSelectionTransform");
        if (_imageSelection != nil)
            [self BTRegionEditingTool_invalidateImageSelection];
    } else if ([aKey isEqualToString:@"isSelectionFlippedHorizontally"])
        BTRegionEditingToolWill(self, @"selectionPathFlippedHorizontally");
    else if ([aKey isEqualToString:@"currentCreateSelectionMode"])
        BTRegionEditingToolWill(self, @"currentCreateSelectionMode");
}

/* The selection tool doesn't change images. */
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
}

- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
}

- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect
{
}

- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect
{
}

- (void)toolDidEndChangingImageContinuously:(id)aTool
{
}

- (void)toolWillBeginChangingImageContinuously:(id)aTool
{
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentSubtool == aTool)
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

/* The image selection is drawn in its own feedback layer below the selection
   tool's while the selection is modified. */
- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    if (_currentSubtool == nil)
        return NO;
    if ([_currentSubtool isFeedbackLayerActive:aLayer])
        return YES;
    return BTRegionEditingToolIsModifying(self) && [aLayer isEqualToString:@"BTImageRegionFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    if (_currentSubtool == nil)
        return [NSSet set];
    id layers = [_currentSubtool activeFeedbackLayers];
    if (BTRegionEditingToolIsInStage(self, BTWaitingStage) || BTRegionEditingToolIsInStage(self, BTCreatingStage))
        return layers;
    NSMutableSet *all = [NSMutableSet setWithSet:layers];
    [all addObject:@"BTImageRegionFeedbackLayer"];
    return [[all copy] autorelease];
}

- (id)activeFeedbackLayersForDrawing
{
    if (_currentSubtool == nil)
        return [NSArray array];
    id layers = [_currentSubtool activeFeedbackLayersForDrawing];
    if (BTRegionEditingToolIsInStage(self, BTWaitingStage) || BTRegionEditingToolIsInStage(self, BTCreatingStage))
        return layers;
    return [[NSArray arrayWithObject:@"BTImageRegionFeedbackLayer"] arrayByAddingObjectsFromArray:layers];
}

- (void)draw_BTImageRegionFeedbackLayer_Rect:(NSRect)aRect
{
    if ([self imageSelection] == nil)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    CGContextConcatCTM(context, CGAffineTransformConcat([self BTRegionEditingTool_imageSelectionTransform],
                                                        [self imageToViewTransform]));
    [_imageSelection drawInCGContext:context inRect:_imageSelectionBounds];
    CGContextRestoreGState(context);
}

/* Lifts the image under an unpositioned selection (cutting it). */
- (void)finalizeSelection:(id)aSender
{
    if (![self validateAction_finalizeSelection])
        return;
    [_delegate tool:self didFinalizeStage:BTWaitingToPositionStage withEvent:nil nextStage:BTWaitingToModifyStage];
    if (_currentSubtool == nil)
        return;
    [self beginUndoAction];
    [self BTRegionEditingTool_finalizeSelectionWithCopying:YES deletion:YES];
    [self endUndoActionWithName:@"Cut Image Selection"];
}

- (BOOL)validateAction_finalizeSelection
{
    return !_isSelectionPathPositioned && BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage);
}

/* Lifts a copy of the image under the selection; a positioned selection gets
   the image under its transformed path, keeping the path. */
- (void)copyIntoSelection:(id)aSender
{
    if (!BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage) || [self workImage] == nil)
        return;
    if (!_isSelectionPathPositioned) {
        [_delegate tool:self didFinalizeStage:BTWaitingToPositionStage withEvent:nil nextStage:BTWaitingToModifyStage];
        if (_currentSubtool == nil)
            return;
        [self beginUndoAction];
        [self BTRegionEditingTool_finalizeSelectionWithCopying:YES deletion:NO];
        [self endUndoActionWithName:@"Copy Image Selection"];
        return;
    }
    CGPathRef path = (CGPathRef)[_selectionTool selectionPath];
    if (path == NULL)
        return;
    CGAffineTransform pathTransform = [self BTRegionEditingTool_selectionPathTransform];
    CGMutablePathRef transformed = BTRegionEditingToolCreateTransformedPath(path, pathTransform);
    [self beginUndoAction];
    BTRegionEditingToolWill(self, @"imageSelection");
    BTRegionEditingToolWill(self, @"imageSelectionBounds");
    BTRegionEditingToolWill(self, @"imageSelectionTransform");
    _imageSelectionBounds = CGRectIntegral(CGEPathGetPathBoundingBox(transformed));
    CGPathRelease(transformed);
    _selectionImageToPathTransform = CGAffineTransformInvert(pathTransform);
    _imageSelectionTransform = CGAffineTransformIdentity;
    _isImageSelectionTransformCalculated = 1;
    [self BTRegionEditingTool_disableWorkImageRestoration];
    [_imageSelection release];
    _imageSelection = [self BTRegionEditingTool_copyWithClipPath:(struct CGPath *)path createWorkImageRestorator:NO];
    BTRegionEditingToolDid(self, @"imageSelectionTransform");
    BTRegionEditingToolDid(self, @"imageSelectionBounds");
    BTRegionEditingToolDid(self, @"imageSelection");
    [self endUndoActionWithName:@"Copy Image Into Selection"];
    if (_imageSelection != nil)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (BOOL)validateAction_copyIntoSelection
{
    return _isSelectionPathPositioned && BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage)
        && [_selectionTool selectionPath] != nil;
}

/* Pastes a copy of the image selection into the work image. */
- (void)stamp:(id)aSender
{
    if (![self validateAction_stamp])
        return;
    [self beginUndoAction];
    [self BTRegionEditingTool_paste];
    [self BTRegionEditingTool_disableWorkImageRestoration];
    [self endUndoActionWithName:@"Flatten Image Selection"];
}

- (BOOL)validateAction_stamp
{
    return _isSelectionPathPositioned && BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage);
}

/* Removes the image under the selection (or the image selection) along with
   the selection. */
- (void)delete:(id)aSender
{
    if (!BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage))
        return;
    [self beginUndoAction];
    if (!_isSelectionPathPositioned)
        [self BTRegionEditingTool_finalizeSelectionWithCopying:NO deletion:YES];
    [self BTRegionEditingTool_disableWorkImageRestoration];
    [self BTRegionEditingTool_clearImageSelection];
    [_selectionTool setSelectionPath:nil];
    [self endUndoActionWithName:@"Delete Image Selection"];
}

- (BOOL)validateAction_delete
{
    return BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage);
}

/* Replaces the selection with the pasteboard's image region (flattening a
   positioned image selection first). */
- (void)paste:(id)aSender
{
    BOOL waitingToModify = BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage);
    if (!waitingToModify && !BTRegionEditingToolIsInStage(self, BTWaitingStage))
        return;
    id image = nil;
    CGRect bounds = CGRectZero;
    CGAffineTransform imageTransform = CGAffineTransformIdentity;
    struct CGPath *path = NULL;
    CGAffineTransform pathTransform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [self BTRegionEditingTool_pasteboardImage:&image imageBounds:&bounds imageTransform:&imageTransform path:&path
                                pathTransform:&pathTransform flippedHorizontally:&flipped];
    if (image == nil || path == NULL)
        return;
    id stage = waitingToModify && !_isSelectionPathPositioned ? BTWaitingToPositionStage
                                                              : [_currentSubtool currentStage];
    [_delegate tool:self didFinalizeStage:stage withEvent:nil nextStage:BTWaitingToModifyStage];
    if (_currentSubtool == nil)
        return;
    [self beginUndoAction];
    if (_isSelectionPathPositioned) {
        [self BTRegionEditingTool_paste];
        [self BTRegionEditingTool_disableWorkImageRestoration];
        if (_imageSelection != nil)
            [self BTRegionEditingTool_invalidateImageSelection];
    }
    BTRegionEditingToolWill(self, @"selectionPath");
    [_selectionTool setSelectionPath:(id)path];
    BTRegionEditingToolDid(self, @"selectionPath");
    BTRegionEditingToolWill(self, @"selectionPathTransform");
    [_selectionTool setSelectionAffineTransform:BTRegionEditingToolTransformValue(pathTransform)];
    BTRegionEditingToolDid(self, @"selectionPathTransform");
    BTRegionEditingToolWill(self, @"selectionPathFlippedHorizontally");
    [_selectionTool setSelectionFlippedHorizontally:flipped];
    BTRegionEditingToolDid(self, @"selectionPathFlippedHorizontally");
    if (_isSelectionPathPositioned)
        [BTRegionEditingToolUndo(self) BTRegionEditingTool_changeImageSelection:_imageSelection
                                                                         bounds:_imageSelectionBounds
                                                          imageToPathTransform:_selectionImageToPathTransform];
    else {
        _isSelectionPathPositioned = 1;
        [BTRegionEditingToolUndo(self) BTRegionEditingTool_clearImageSelection];
    }
    if (!CGRectEqualToRect(bounds, _imageSelectionBounds)) {
        BTRegionEditingToolWill(self, @"imageSelectionBounds");
        _imageSelectionBounds = bounds;
        BTRegionEditingToolDid(self, @"imageSelectionBounds");
    }
    CGAffineTransform imageToPath = CGAffineTransformConcat(imageTransform, CGAffineTransformInvert(pathTransform));
    if (_isImageSelectionTransformCalculated
        && CGAffineTransformEqualToTransform(imageTransform, _imageSelectionTransform))
        _selectionImageToPathTransform = imageToPath;
    else {
        BOOL wasCalculated = _isImageSelectionTransformCalculated;
        if (wasCalculated)
            BTRegionEditingToolWill(self, @"imageSelectionTransform");
        _selectionImageToPathTransform = imageToPath;
        _imageSelectionTransform = imageTransform;
        _isImageSelectionTransformCalculated = 1;
        if (wasCalculated)
            BTRegionEditingToolDid(self, @"imageSelectionTransform");
    }
    if (image != _imageSelection) {
        BTRegionEditingToolWill(self, @"imageSelection");
        [image retain];
        [_imageSelection release];
        _imageSelection = image;
        BTRegionEditingToolDid(self, @"imageSelection");
    }
    [self endUndoActionWithName:@"Paste Image Selection"];
    if (_imageSelection != nil)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (BOOL)validateAction_paste
{
    NSPasteboard *pasteboard = [self workPasteboard];
    NSArray *types = [NSArray arrayWithObjects:@"BTArchivedImageRegionPboardType",
                      [BTRegionEditingTool_BTImageRegion imageRegionPasteboardType], nil];
    if ([pasteboard availableTypeFromArray:types] != nil)
        return YES;
    return [NSImage canInitWithPasteboard:pasteboard];
}

/* The pasteboard's image region: this process's own (by pointer), an
   archived one, or any image, centred in the visible part of the view. A
   region lying wholly outside the work image is moved back to its edge. */
- (void)BTRegionEditingTool_pasteboardImage:(id *)aImage imageBounds:(CGRect *)aBounds imageTransform:(CGAffineTransform *)aImageTransform path:(struct CGPath **)aPath pathTransform:(CGAffineTransform *)aPathTransform flippedHorizontally:(BOOL *)aFlipped
{
    NSPasteboard *pasteboard = [self workPasteboard];
    BTRegionEditingTool_BTImageRegion *region = nil;
    NSData *data = [pasteboard dataForType:[BTRegionEditingTool_BTImageRegion imageRegionPasteboardType]];
    if (data != nil)
        region = *(BTRegionEditingTool_BTImageRegion *const *)[data bytes];
    else if ((data = [pasteboard dataForType:@"BTArchivedImageRegionPboardType"]) != nil) {
        id unarchiver = [[[BTRegionEditingTool_BTImageRegionUnarchiver alloc] initForReadingWithData:data] autorelease];
        region = [[[BTRegionEditingTool_BTImageRegion alloc] initWithCoder:unarchiver] autorelease];
    }
    if (data != nil) {
        if (region == nil)
            return;
        if (aImage)
            *aImage = [region image];
        if (aBounds)
            *aBounds = [region imageBounds];
        if (aImageTransform || aPathTransform) {
            CGAffineTransform pathTransform = [region pathTransform];
            CGMutablePathRef transformed = BTRegionEditingToolCreateTransformedPath([region path], pathTransform);
            CGRect box = CGEPathGetPathBoundingBox(transformed);
            CGPathRelease(transformed);
            CGSize size = [[self workImage] imageSize];
            CGFloat dx = CGRectGetMinX(box) >= size.width ? size.width - CGRectGetMaxX(box)
                         : CGRectGetMaxX(box) <= 0 ? -CGRectGetMinX(box) : 0;
            CGFloat dy = CGRectGetMinY(box) >= size.height ? size.height - CGRectGetMaxY(box)
                         : CGRectGetMaxY(box) <= 0 ? -CGRectGetMinY(box) : 0;
            CGAffineTransform imageTransform = [region imageTransform];
            imageTransform.tx += dx;
            imageTransform.ty += dy;
            pathTransform.tx += dx;
            pathTransform.ty += dy;
            if (aImageTransform)
                *aImageTransform = imageTransform;
            if (aPathTransform)
                *aPathTransform = pathTransform;
        }
        if (aPath)
            *aPath = [region path];
        if (aFlipped)
            *aFlipped = [region isPathFlippedHorizontally];
        return;
    }
    NSImage *image = [[[NSImage alloc] initWithPasteboard:pasteboard] autorelease];
    if (image == nil)
        return;
    NSSize size = [image size];
    if (aImage) {
        id layer = [[self class] BTRegionEditingTool_mutableImageOfSize:size];
        [layer beginCocoaEditing];
        [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
        [layer endCocoaEditing];
        *aImage = layer;
    }
    if (aPath || aBounds) {
        NSRect visible = [_view visibleRect];
        CGPoint center = [self convertViewPointToImagePoint:NSMakePoint(NSMidX(visible), NSMidY(visible))];
        CGRect rect = CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
        if (aPath) {
            CGPathRef path = CGPathCreateWithRect(rect, NULL);
            *aPath = (struct CGPath *)CFAutorelease(path);
        }
        if (aBounds)
            *aBounds = rect;
    }
    if (aImageTransform)
        *aImageTransform = CGAffineTransformIdentity;
    if (aPathTransform)
        *aPathTransform = CGAffineTransformIdentity;
    if (aFlipped)
        *aFlipped = NO;
}

- (void)copy:(id)aSender
{
    [self BTRegionEditingTool_copyWithDeletion:NO];
}

- (BOOL)validateAction_copy
{
    return [self workPasteboard] != nil && BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage);
}

- (void)cut:(id)aSender
{
    [self BTRegionEditingTool_copyWithDeletion:YES];
}

- (BOOL)validateAction_cut
{
    return [self workPasteboard] != nil && BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage);
}

/* Puts the image selection on the pasteboard (lifting it first), with the
   create selection mode and a rectangular shape prototype for the selection
   tools. The region is the pasteboard owner until it changes owner. */
- (void)BTRegionEditingTool_copyWithDeletion:(BOOL)aDeletion
{
    if (!BTRegionEditingToolIsInStage(self, BTWaitingToModifyStage))
        return;
    if (_isSelectionPathPositioned)
        [self beginUndoAction];
    else {
        [_delegate tool:self didFinalizeStage:BTWaitingToPositionStage withEvent:nil nextStage:BTWaitingToModifyStage];
        if (_currentSubtool == nil)
            return;
        [self beginUndoAction];
        [self BTRegionEditingTool_finalizeSelectionWithCopying:YES deletion:aDeletion];
    }
    NSPasteboard *pasteboard = [self workPasteboard];
    NSString *regionType = [BTRegionEditingTool_BTImageRegion imageRegionPasteboardType];
    if (pasteboard != nil && regionType != nil && _imageSelection != nil) {
        NSString *mode = [self currentCreateSelectionMode];
        CGRect rect = CGRectZero;
        CGPathRef prototype;
        BOOL isRect = [mode isEqualToString:@"BTShapeCreateSelectionMode"]
            && (prototype = (CGPathRef)[self selectionShapePrototypePath]) != NULL && CGPathIsRect(prototype, &rect);
        NSMutableArray *types = [NSMutableArray arrayWithObjects:regionType, @"BTArchivedImageRegionPboardType",
                                 NSPasteboardTypePDF, @"Apple PNG pasteboard type", nil];
        if (mode != nil)
            [types addObject:@"BTCreateSelectionModePboardType"];
        if (isRect)
            [types addObject:@"BTSelectionRectPrototypePboardType"];
        id region = [[BTRegionEditingTool_BTImageRegion alloc]
                       initWithImage:_imageSelection imageBounds:_imageSelectionBounds
                      imageTransform:[self BTRegionEditingTool_imageSelectionTransform]
                                path:(struct CGPath *)[_selectionTool selectionPath]
                       pathTransform:[self BTRegionEditingTool_selectionPathTransform]
                 flippedHorizontally:[_selectionTool isSelectionFlippedHorizontally]];
        [pasteboard declareTypes:types owner:region];
        if (mode != nil)
            [pasteboard setString:mode forType:@"BTCreateSelectionModePboardType"];
        if (isRect) {
            CFSwappedFloat64 values[4] = {
                CFConvertDoubleHostToSwapped(rect.origin.x), CFConvertDoubleHostToSwapped(rect.origin.y),
                CFConvertDoubleHostToSwapped(rect.size.width), CFConvertDoubleHostToSwapped(rect.size.height)};
            [pasteboard setData:[NSMutableData dataWithBytes:values length:sizeof(values)]
                        forType:@"BTSelectionRectPrototypePboardType"];
        }
        if (aDeletion) {
            [self BTRegionEditingTool_disableWorkImageRestoration];
            [self BTRegionEditingTool_clearImageSelection];
            [_selectionTool setSelectionPath:nil];
        }
    }
    [self endUndoActionWithName:aDeletion ? @"Cut Image Selection" : @"Copy Image Selection"];
}

- (id)keyBindings
{
    id bindings = BTRegionEditingToolIsModifying(self) ? [self modifySelectionKeyBindings] : [self generalKeyBindings];
    return [NSEvent BT_mergeKeyBindingDictionary:bindings intoDictionary:[_currentSubtool keyBindings]];
}

- (void)moveSelectionBy:(CGSize)aOffset
{
    [(id)_currentSubtool moveSelectionBy:aOffset];
}

- (void)rotateSelectionAboutCenterBy:(CGFloat)aAngle
{
    [(id)_currentSubtool rotateSelectionAboutCenterBy:aAngle];
}

- (void)scaleSelectionAboutCenterBy:(CGSize)aScale
{
    [(id)_currentSubtool scaleSelectionAboutCenterBy:aScale];
}

- (void)flipSelectionVertically
{
    [(id)_currentSubtool flipSelectionVertically];
}

- (void)flipSelectionHorizontally
{
    [(id)_currentSubtool flipSelectionHorizontally];
}

- (void)posttransformSelectionUsingAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aFlipping
{
    [(id)_currentSubtool posttransformSelectionUsingAffineTransform:aTransform flippingHorizontally:aFlipping];
}

- (void)pretransformSelectionUsingAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aFlipping
{
    [(id)_currentSubtool pretransformSelectionUsingAffineTransform:aTransform flippingHorizontally:aFlipping];
}

- (void)setSelectionAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aFlipping
{
    [(id)_currentSubtool setSelectionAffineTransform:aTransform flippingHorizontally:aFlipping];
}

- (void)setSelectionAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aFlipped
{
    [(id)_currentSubtool setSelectionAffineTransform:aTransform flippedHorizontally:aFlipped];
}

- (void)removeAllUndoActionsFromManager:(id)aManager
{
    [_selectionTool removeAllUndoActionsFromManager:aManager];
    [super removeAllUndoActionsFromManager:aManager];
}

- (void)removeAllUndoActionsFromManager:(id)aManager category:(id)aCategory
{
    [_selectionTool removeAllUndoActionsFromManager:aManager category:aCategory];
    [super removeAllUndoActionsFromManager:aManager category:aCategory];
}

- (id)allUndoCategories
{
    return [NSSet setWithObjects:@"BTToolWorkImageUndoCategory", @"BTSelectionUndoCategory", nil];
}

- (id)currentStage
{
    if (_currentSubtool == nil)
        return BTWaitingStage;
    id stage = [_currentSubtool currentStage];
    if (_isSelectionPathPositioned)
        return stage;
    return [stage isEqualToString:BTWaitingToModifyStage] ? BTWaitingToPositionStage : stage;
}

/* A positioned selection is flattened. */
- (void)performDeactivate
{
    if (BTRegionEditingToolIsModifying(self) && _isSelectionPathPositioned) {
        [self beginUndoAction];
        [self BTRegionEditingTool_paste];
        [self BTRegionEditingTool_disableWorkImageRestoration];
        [self endUndoActionWithName:@"Flatten Image Selection"];
    }
    [_currentSubtool deactivate];
    _currentSubtool = nil;
    [_selectionPathPositioningUndoActionNamePrefix release];
    _selectionPathPositioningUndoActionNamePrefix = nil;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    if ([self BTRegionEditingTool_activateSubtool])
        return YES;
    [super performDeactivate];
    return NO;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    [_selectionTool setViewInvalidationEnabled:aEnabled];
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_selectionTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_selectionTool setWorkPasteboard:aPasteboard];
}

- (void)changeWorkImageTo:(id)aImage
{
    [_workImageRestorator release];
    _workImageRestorator = nil;
    _shouldRestoreWorkImage = 0;
    [super changeWorkImageTo:aImage];
    [_selectionTool setWorkImage:aImage];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"currentCreateSelectionMode", @"imageSelection", @"imageSelectionBounds",
            @"imageSelectionTransform", @"selectionPath", @"selectionPathTransform",
            @"selectionPathFlippedHorizontally", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"modifySelectionKeyBindings",
            @"initialCreateSelectionMode", @"selectionShapePrototypePath", @"backgroundMode", @"backgroundColor",
            @"selectionTolerance", @"alternateProportion", @"proportionalModePrimaryForSides",
            @"proportionalModePrimaryForCorners", @"imageSelection", @"imageSelectionBounds",
            @"imageSelectionTransform", @"selectionPath", @"selectionPathTransform",
            @"selectionPathFlippedHorizontallywillCreateFreeHandSelectionCursor",
            @"doCreateFreeHandSelectionCursor", @"willCreateMagicWandSelectionCursor",
            @"willCreateMagicLassoSelectionCursor", @"doCreateMagicLassoSelectionCursor",
            @"willCreateShapeSelectionCursor", @"doCreateShapeSelectionCursor", @"willMoveSelectionCursor",
            @"doMoveSelectionCursor", @"willResizeBottomLeftSelectionCursor", @"doResizeBottomLeftSelectionCursor",
            @"willResizeCenterLeftSelectionCursor", @"doResizeCenterLeftSelectionCursor",
            @"willResizeTopLeftSelectionCursor", @"doResizeTopLeftSelectionCursor",
            @"willResizeTopCenterSelectionCursor", @"doResizeTopCenterSelectionCursor",
            @"willResizeTopRightSelectionCursor", @"doResizeTopRightSelectionCursor",
            @"willResizeCenterRightSelectionCursor", @"doResizeCenterRightSelectionCursor",
            @"willResizeBottomRightSelectionCursor", @"doResizeBottomRightSelectionCursor",
            @"willResizeBottomCenterSelectionCursor", @"doResizeBottomCenterSelectionCursor",
            @"willRotateBottomLeftSelectionCursor", @"doRotateBottomLeftSelectionCursor",
            @"willRotateCenterLeftSelectionCursor", @"doRotateCenterLeftSelectionCursor",
            @"willRotateTopLeftSelectionCursor", @"doRotateTopLeftSelectionCursor",
            @"willRotateTopCenterSelectionCursor", @"doRotateTopCenterSelectionCursor",
            @"willRotateTopRightSelectionCursor", @"doRotateTopRightSelectionCursor",
            @"willRotateCenterRightSelectionCursor", @"doRotateCenterRightSelectionCursor",
            @"willRotateBottomRightSelectionCursor", @"doRotateBottomRightSelectionCursor",
            @"willRotateBottomCenterSelectionCursor", @"doRotateBottomCenterSelectionCursor", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGImage);
    return protocols;
}

/* Setting the image selection's parts from outside (while active, only while
   the selection is modified) is undoable through the private setters. */
- (void)setImageSelectionTransform:(id)aValue
{
    BOOL active = [self isActive];
    if (active) {
        if (!BTRegionEditingToolIsModifying(self))
            return;
        [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageToPathTransform:_selectionImageToPathTransform];
        if (_isSelectionPathPositioned && _imageSelection != nil)
            [self BTRegionEditingTool_invalidateImageSelection];
    }
    _imageSelectionTransform = CGAffineTransformIdentity;
    [aValue getValue:&_imageSelectionTransform];
    _isImageSelectionTransformCalculated = 1;
    id pathValue = [_selectionTool selectionAffineTransform];
    if (pathValue != nil) {
        CGAffineTransform pathTransform = CGAffineTransformIdentity;
        [pathValue getValue:&pathTransform];
        _selectionImageToPathTransform = CGAffineTransformConcat(_imageSelectionTransform,
                                                                 CGAffineTransformInvert(pathTransform));
    } else
        _selectionImageToPathTransform = _imageSelectionTransform;
    if (active && _isSelectionPathPositioned && _imageSelection != nil)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (void)BTRegionEditingTool_setImageToPathTransform:(CGAffineTransform)aTransform
{
    [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageToPathTransform:_selectionImageToPathTransform];
    if (_isSelectionPathPositioned && CGAffineTransformEqualToTransform(_selectionImageToPathTransform, aTransform))
        return;
    if (_imageSelection != nil && _isSelectionPathPositioned)
        [self BTRegionEditingTool_invalidateImageSelection];
    BOOL wasCalculated = _isImageSelectionTransformCalculated;
    if (wasCalculated)
        BTRegionEditingToolWill(self, @"imageSelectionTransform");
    _selectionImageToPathTransform = aTransform;
    _isImageSelectionTransformCalculated = 0;
    if (wasCalculated)
        BTRegionEditingToolDid(self, @"imageSelectionTransform");
    if (_imageSelection != nil && _isSelectionPathPositioned)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (id)imageSelectionTransform
{
    [self BTRegionEditingTool_imageSelectionTransform];
    return [NSValue valueWithBytes:&_imageSelectionTransform objCType:@encode(CGAffineTransform)];
}

- (void)setImageSelectionBounds:(id)aValue
{
    BOOL active = [self isActive];
    if (active) {
        if (!BTRegionEditingToolIsModifying(self))
            return;
        [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageSelectionBounds:_imageSelectionBounds];
        if (_imageSelection != nil)
            [self BTRegionEditingTool_invalidateImageSelection];
        [self BTRegionEditingTool_disableWorkImageRestoration];
    }
    [aValue getValue:&_imageSelectionBounds];
    _isSelectionPathPositioned = !CGRectIsEmpty(_imageSelectionBounds);
    if (active && _imageSelection != nil)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (void)BTRegionEditingTool_setImageSelectionBounds:(CGRect)aBounds
{
    [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageSelectionBounds:_imageSelectionBounds];
    if (CGRectEqualToRect(_imageSelectionBounds, aBounds))
        return;
    if (_imageSelection != nil && _isSelectionPathPositioned)
        [self BTRegionEditingTool_invalidateImageSelection];
    BTRegionEditingToolWill(self, @"imageSelectionBounds");
    _imageSelectionBounds = aBounds;
    _isSelectionPathPositioned = !CGRectIsEmpty(aBounds);
    BTRegionEditingToolDid(self, @"imageSelectionBounds");
    if (_imageSelection != nil && _isSelectionPathPositioned)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (id)imageSelectionBounds
{
    return [NSValue valueWithBytes:&_imageSelectionBounds objCType:@encode(CGRect)];
}

- (void)setSelectionPathFlippedHorizontally:(BOOL)aFlipped
{
    [_selectionTool setSelectionFlippedHorizontally:aFlipped];
}

- (BOOL)isSelectionPathFlippedHorizontally
{
    return [_selectionTool isSelectionFlippedHorizontally];
}

/* The image selection keeps its own transform: the image to path transform
   follows the new path transform. */
- (void)setSelectionPathTransform:(id)aValue
{
    BOOL invalidate = NO;
    if ([self isActive]) {
        if (!BTRegionEditingToolIsModifying(self))
            return;
        [_selectionTool setSelectionAffineTransform:aValue];
        invalidate = _isSelectionPathPositioned && _imageSelection != nil;
        if (invalidate)
            [self BTRegionEditingTool_invalidateImageSelection];
    } else
        [_selectionTool setSelectionAffineTransform:aValue];
    if (aValue != nil) {
        CGAffineTransform pathTransform = CGAffineTransformIdentity;
        [aValue getValue:&pathTransform];
        _selectionImageToPathTransform = CGAffineTransformConcat([self BTRegionEditingTool_imageSelectionTransform],
                                                                 CGAffineTransformInvert(pathTransform));
    } else
        _selectionImageToPathTransform = [self BTRegionEditingTool_imageSelectionTransform];
    if (invalidate)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (id)selectionPathTransform
{
    return [_selectionTool selectionAffineTransform];
}

- (void)setImageSelection:(id)aImage
{
    if (aImage == _imageSelection)
        return;
    if ([self isActive]) {
        if (!BTRegionEditingToolIsModifying(self))
            return;
        if (_imageSelection != nil)
            [self BTRegionEditingTool_invalidateImageSelection];
        [self BTRegionEditingTool_disableWorkImageRestoration];
        [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageSelection:_imageSelection];
    }
    [aImage retain];
    [_imageSelection release];
    _imageSelection = aImage;
}

- (void)BTRegionEditingTool_setImageSelection:(id)aImage
{
    [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageSelection:_imageSelection];
    BTRegionEditingToolWill(self, @"imageSelection");
    [aImage retain];
    [_imageSelection release];
    _imageSelection = aImage;
    BTRegionEditingToolDid(self, @"imageSelection");
    if (_isSelectionPathPositioned)
        [self BTRegionEditingTool_invalidateImageSelection];
}

- (id)imageSelection
{
    return _imageSelection;
}

- (void)setBackgroundColor:(id)aColor
{
    if ((struct CGColor *)aColor != _backgroundColor) {
        CGColorRelease(_backgroundColor);
        _backgroundColor = (struct CGColor *)CGColorRetain((CGColorRef)aColor);
    }
}

- (id)backgroundColor
{
    return (id)_backgroundColor;
}

- (void)setBackgroundMode:(id)aMode
{
    if (_backgroundMode != aMode) {
        [_backgroundMode release];
        _backgroundMode = [aMode copy];
    }
}

- (id)backgroundMode
{
    return _backgroundMode;
}

- (void)setSelectionTolerance:(CGFloat)aTolerance
{
    [_selectionTool setTolerance:aTolerance];
}

- (CGFloat)selectionTolerance
{
    return [_selectionTool tolerance];
}

- (void)setSelectionPath:(id)aValue
{
    [_selectionTool setSelectionPath:aValue];
}

- (id)selectionPath
{
    return [_selectionTool selectionPath];
}

- (void)setProportionalModePrimaryForSides:(BOOL)aValue
{
    [_selectionTool setProportionalModePrimaryForSides:aValue];
}

- (BOOL)isProportionalModePrimaryForSides
{
    return [_selectionTool isProportionalModePrimaryForSides];
}

- (BOOL)defaultProportionalModePrimaryForSides
{
    return [_selectionTool defaultProportionalModePrimaryForSides];
}

- (void)setProportionalModePrimaryForCorners:(BOOL)aValue
{
    [_selectionTool setProportionalModePrimaryForCorners:aValue];
}

- (BOOL)isProportionalModePrimaryForCorners
{
    return [_selectionTool isProportionalModePrimaryForCorners];
}

- (BOOL)defaultProportionalModePrimaryForCorners
{
    return [_selectionTool defaultProportionalModePrimaryForCorners];
}

- (void)setProportionalModePrimaryForCreation:(BOOL)aValue
{
    [_selectionTool setProportionalModePrimaryForCreation:aValue];
}

- (BOOL)isProportionalModePrimaryForCreation
{
    return [_selectionTool isProportionalModePrimaryForCreation];
}

- (BOOL)defaultProportionalModePrimaryForCreation
{
    return [_selectionTool defaultProportionalModePrimaryForCreation];
}

- (void)setAlternateProportion:(CGFloat)aValue
{
    [_selectionTool setAlternateProportion:aValue];
}

- (CGFloat)alternateProportion
{
    return [_selectionTool alternateProportion];
}

- (CGFloat)defaultAlternateProportion
{
    return [_selectionTool defaultAlternateProportion];
}

- (void)setLassoSwitchingOption:(NSUInteger)aValue
{
    [_selectionTool setLassoSwitchingOption:aValue];
}

- (NSUInteger)lassoSwitchingOption
{
    return [_selectionTool lassoSwitchingOption];
}

- (NSUInteger)defaultLassoSwitchingOption
{
    return [_selectionTool defaultLassoSwitchingOption];
}

- (void)setMagicSwitchingOption:(NSUInteger)aValue
{
    [_selectionTool setMagicSwitchingOption:aValue];
}

- (NSUInteger)magicSwitchingOption
{
    return [_selectionTool magicSwitchingOption];
}

- (NSUInteger)defaultMagicSwitchingOption
{
    return [_selectionTool defaultMagicSwitchingOption];
}

- (void)setSelectionShapePrototypePath:(id)aValue
{
    [_selectionTool setSelectionShapePrototypePath:aValue];
}

- (id)selectionShapePrototypePath
{
    return [_selectionTool selectionShapePrototypePath];
}

- (id)currentCreateSelectionMode
{
    return [_selectionTool currentCreateSelectionMode];
}

- (void)setInitialCreateSelectionMode:(id)aValue
{
    [_selectionTool setInitialCreateSelectionMode:aValue];
}

- (id)initialCreateSelectionMode
{
    return [_selectionTool initialCreateSelectionMode];
}

- (void)setDoRotateBottomCenterSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateBottomCenterSelectionCursor:aValue];
}

- (id)doRotateBottomCenterSelectionCursor
{
    return [_selectionTool doRotateBottomCenterSelectionCursor];
}

- (id)defaultDoRotateBottomCenterSelectionCursor
{
    return [_selectionTool defaultDoRotateBottomCenterSelectionCursor];
}

- (void)setWillRotateBottomCenterSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateBottomCenterSelectionCursor:aValue];
}

- (id)willRotateBottomCenterSelectionCursor
{
    return [_selectionTool willRotateBottomCenterSelectionCursor];
}

- (id)defaultWillRotateBottomCenterSelectionCursor
{
    return [_selectionTool defaultWillRotateBottomCenterSelectionCursor];
}

- (void)setDoRotateBottomRightSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateBottomRightSelectionCursor:aValue];
}

- (id)doRotateBottomRightSelectionCursor
{
    return [_selectionTool doRotateBottomRightSelectionCursor];
}

- (id)defaultDoRotateBottomRightSelectionCursor
{
    return [_selectionTool defaultDoRotateBottomRightSelectionCursor];
}

- (void)setWillRotateBottomRightSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateBottomRightSelectionCursor:aValue];
}

- (id)willRotateBottomRightSelectionCursor
{
    return [_selectionTool willRotateBottomRightSelectionCursor];
}

- (id)defaultWillRotateBottomRightSelectionCursor
{
    return [_selectionTool defaultWillRotateBottomRightSelectionCursor];
}

- (void)setDoRotateCenterRightSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateCenterRightSelectionCursor:aValue];
}

- (id)doRotateCenterRightSelectionCursor
{
    return [_selectionTool doRotateCenterRightSelectionCursor];
}

- (id)defaultDoRotateCenterRightSelectionCursor
{
    return [_selectionTool defaultDoRotateCenterRightSelectionCursor];
}

- (void)setWillRotateCenterRightSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateCenterRightSelectionCursor:aValue];
}

- (id)willRotateCenterRightSelectionCursor
{
    return [_selectionTool willRotateCenterRightSelectionCursor];
}

- (id)defaultWillRotateCenterRightSelectionCursor
{
    return [_selectionTool defaultWillRotateCenterRightSelectionCursor];
}

- (void)setDoRotateTopRightSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateTopRightSelectionCursor:aValue];
}

- (id)doRotateTopRightSelectionCursor
{
    return [_selectionTool doRotateTopRightSelectionCursor];
}

- (id)defaultDoRotateTopRightSelectionCursor
{
    return [_selectionTool defaultDoRotateTopRightSelectionCursor];
}

- (void)setWillRotateTopRightSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateTopRightSelectionCursor:aValue];
}

- (id)willRotateTopRightSelectionCursor
{
    return [_selectionTool willRotateTopRightSelectionCursor];
}

- (id)defaultWillRotateTopRightSelectionCursor
{
    return [_selectionTool defaultWillRotateTopRightSelectionCursor];
}

- (void)setDoRotateTopCenterSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateTopCenterSelectionCursor:aValue];
}

- (id)doRotateTopCenterSelectionCursor
{
    return [_selectionTool doRotateTopCenterSelectionCursor];
}

- (id)defaultDoRotateTopCenterSelectionCursor
{
    return [_selectionTool defaultDoRotateTopCenterSelectionCursor];
}

- (void)setWillRotateTopCenterSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateTopCenterSelectionCursor:aValue];
}

- (id)willRotateTopCenterSelectionCursor
{
    return [_selectionTool willRotateTopCenterSelectionCursor];
}

- (id)defaultWillRotateTopCenterSelectionCursor
{
    return [_selectionTool defaultWillRotateTopCenterSelectionCursor];
}

- (void)setDoRotateTopLeftSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateTopLeftSelectionCursor:aValue];
}

- (id)doRotateTopLeftSelectionCursor
{
    return [_selectionTool doRotateTopLeftSelectionCursor];
}

- (id)defaultDoRotateTopLeftSelectionCursor
{
    return [_selectionTool defaultDoRotateTopLeftSelectionCursor];
}

- (void)setWillRotateTopLeftSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateTopLeftSelectionCursor:aValue];
}

- (id)willRotateTopLeftSelectionCursor
{
    return [_selectionTool willRotateTopLeftSelectionCursor];
}

- (id)defaultWillRotateTopLeftSelectionCursor
{
    return [_selectionTool defaultWillRotateTopLeftSelectionCursor];
}

- (void)setDoRotateCenterLeftSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateCenterLeftSelectionCursor:aValue];
}

- (id)doRotateCenterLeftSelectionCursor
{
    return [_selectionTool doRotateCenterLeftSelectionCursor];
}

- (id)defaultDoRotateCenterLeftSelectionCursor
{
    return [_selectionTool defaultDoRotateCenterLeftSelectionCursor];
}

- (void)setWillRotateCenterLeftSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateCenterLeftSelectionCursor:aValue];
}

- (id)willRotateCenterLeftSelectionCursor
{
    return [_selectionTool willRotateCenterLeftSelectionCursor];
}

- (id)defaultWillRotateCenterLeftSelectionCursor
{
    return [_selectionTool defaultWillRotateCenterLeftSelectionCursor];
}

- (void)setDoRotateBottomLeftSelectionCursor:(id)aValue
{
    [_selectionTool setDoRotateBottomLeftSelectionCursor:aValue];
}

- (id)doRotateBottomLeftSelectionCursor
{
    return [_selectionTool doRotateBottomLeftSelectionCursor];
}

- (id)defaultDoRotateBottomLeftSelectionCursor
{
    return [_selectionTool defaultDoRotateBottomLeftSelectionCursor];
}

- (void)setWillRotateBottomLeftSelectionCursor:(id)aValue
{
    [_selectionTool setWillRotateBottomLeftSelectionCursor:aValue];
}

- (id)willRotateBottomLeftSelectionCursor
{
    return [_selectionTool willRotateBottomLeftSelectionCursor];
}

- (id)defaultWillRotateBottomLeftSelectionCursor
{
    return [_selectionTool defaultWillRotateBottomLeftSelectionCursor];
}

- (void)setDoResizeBottomCenterSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeBottomCenterSelectionCursor:aValue];
}

- (id)doResizeBottomCenterSelectionCursor
{
    return [_selectionTool doResizeBottomCenterSelectionCursor];
}

- (id)defaultDoResizeBottomCenterSelectionCursor
{
    return [_selectionTool defaultDoResizeBottomCenterSelectionCursor];
}

- (void)setWillResizeBottomCenterSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeBottomCenterSelectionCursor:aValue];
}

- (id)willResizeBottomCenterSelectionCursor
{
    return [_selectionTool willResizeBottomCenterSelectionCursor];
}

- (id)defaultWillResizeBottomCenterSelectionCursor
{
    return [_selectionTool defaultWillResizeBottomCenterSelectionCursor];
}

- (void)setDoResizeBottomRightSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeBottomRightSelectionCursor:aValue];
}

- (id)doResizeBottomRightSelectionCursor
{
    return [_selectionTool doResizeBottomRightSelectionCursor];
}

- (id)defaultDoResizeBottomRightSelectionCursor
{
    return [_selectionTool defaultDoResizeBottomRightSelectionCursor];
}

- (void)setWillResizeBottomRightSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeBottomRightSelectionCursor:aValue];
}

- (id)willResizeBottomRightSelectionCursor
{
    return [_selectionTool willResizeBottomRightSelectionCursor];
}

- (id)defaultWillResizeBottomRightSelectionCursor
{
    return [_selectionTool defaultWillResizeBottomRightSelectionCursor];
}

- (void)setDoResizeCenterRightSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeCenterRightSelectionCursor:aValue];
}

- (id)doResizeCenterRightSelectionCursor
{
    return [_selectionTool doResizeCenterRightSelectionCursor];
}

- (id)defaultDoResizeCenterRightSelectionCursor
{
    return [_selectionTool defaultDoResizeCenterRightSelectionCursor];
}

- (void)setWillResizeCenterRightSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeCenterRightSelectionCursor:aValue];
}

- (id)willResizeCenterRightSelectionCursor
{
    return [_selectionTool willResizeCenterRightSelectionCursor];
}

- (id)defaultWillResizeCenterRightSelectionCursor
{
    return [_selectionTool defaultWillResizeCenterRightSelectionCursor];
}

- (void)setDoResizeTopRightSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeTopRightSelectionCursor:aValue];
}

- (id)doResizeTopRightSelectionCursor
{
    return [_selectionTool doResizeTopRightSelectionCursor];
}

- (id)defaultDoResizeTopRightSelectionCursor
{
    return [_selectionTool defaultDoResizeTopRightSelectionCursor];
}

- (void)setWillResizeTopRightSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeTopRightSelectionCursor:aValue];
}

- (id)willResizeTopRightSelectionCursor
{
    return [_selectionTool willResizeTopRightSelectionCursor];
}

- (id)defaultWillResizeTopRightSelectionCursor
{
    return [_selectionTool defaultWillResizeTopRightSelectionCursor];
}

- (void)setDoResizeTopCenterSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeTopCenterSelectionCursor:aValue];
}

- (id)doResizeTopCenterSelectionCursor
{
    return [_selectionTool doResizeTopCenterSelectionCursor];
}

- (id)defaultDoResizeTopCenterSelectionCursor
{
    return [_selectionTool defaultDoResizeTopCenterSelectionCursor];
}

- (void)setWillResizeTopCenterSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeTopCenterSelectionCursor:aValue];
}

- (id)willResizeTopCenterSelectionCursor
{
    return [_selectionTool willResizeTopCenterSelectionCursor];
}

- (id)defaultWillResizeTopCenterSelectionCursor
{
    return [_selectionTool defaultWillResizeTopCenterSelectionCursor];
}

- (void)setDoResizeTopLeftSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeTopLeftSelectionCursor:aValue];
}

- (id)doResizeTopLeftSelectionCursor
{
    return [_selectionTool doResizeTopLeftSelectionCursor];
}

- (id)defaultDoResizeTopLeftSelectionCursor
{
    return [_selectionTool defaultDoResizeTopLeftSelectionCursor];
}

- (void)setWillResizeTopLeftSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeTopLeftSelectionCursor:aValue];
}

- (id)willResizeTopLeftSelectionCursor
{
    return [_selectionTool willResizeTopLeftSelectionCursor];
}

- (id)defaultWillResizeTopLeftSelectionCursor
{
    return [_selectionTool defaultWillResizeTopLeftSelectionCursor];
}

- (void)setDoResizeCenterLeftSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeCenterLeftSelectionCursor:aValue];
}

- (id)doResizeCenterLeftSelectionCursor
{
    return [_selectionTool doResizeCenterLeftSelectionCursor];
}

- (id)defaultDoResizeCenterLeftSelectionCursor
{
    return [_selectionTool defaultDoResizeCenterLeftSelectionCursor];
}

- (void)setWillResizeCenterLeftSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeCenterLeftSelectionCursor:aValue];
}

- (id)willResizeCenterLeftSelectionCursor
{
    return [_selectionTool willResizeCenterLeftSelectionCursor];
}

- (id)defaultWillResizeCenterLeftSelectionCursor
{
    return [_selectionTool defaultWillResizeCenterLeftSelectionCursor];
}

- (void)setDoResizeBottomLeftSelectionCursor:(id)aValue
{
    [_selectionTool setDoResizeBottomLeftSelectionCursor:aValue];
}

- (id)doResizeBottomLeftSelectionCursor
{
    return [_selectionTool doResizeBottomLeftSelectionCursor];
}

- (id)defaultDoResizeBottomLeftSelectionCursor
{
    return [_selectionTool defaultDoResizeBottomLeftSelectionCursor];
}

- (void)setWillResizeBottomLeftSelectionCursor:(id)aValue
{
    [_selectionTool setWillResizeBottomLeftSelectionCursor:aValue];
}

- (id)willResizeBottomLeftSelectionCursor
{
    return [_selectionTool willResizeBottomLeftSelectionCursor];
}

- (id)defaultWillResizeBottomLeftSelectionCursor
{
    return [_selectionTool defaultWillResizeBottomLeftSelectionCursor];
}

- (void)setDoMoveSelectionCursor:(id)aValue
{
    [_selectionTool setDoMoveSelectionCursor:aValue];
}

- (id)doMoveSelectionCursor
{
    return [_selectionTool doMoveSelectionCursor];
}

- (id)defaultDoMoveSelectionCursor
{
    return [_selectionTool defaultDoMoveSelectionCursor];
}

- (void)setWillMoveSelectionCursor:(id)aValue
{
    [_selectionTool setWillMoveSelectionCursor:aValue];
}

- (id)willMoveSelectionCursor
{
    return [_selectionTool willMoveSelectionCursor];
}

- (id)defaultWillMoveSelectionCursor
{
    return [_selectionTool defaultWillMoveSelectionCursor];
}

- (void)setDoCreateShapeSelectionCursor:(id)aValue
{
    [_selectionTool setDoCreateShapeSelectionCursor:aValue];
}

- (id)doCreateShapeSelectionCursor
{
    return [_selectionTool doCreateShapeSelectionCursor];
}

- (id)defaultDoCreateShapeSelectionCursor
{
    return [_selectionTool defaultDoCreateShapeSelectionCursor];
}

- (void)setWillCreateShapeSelectionCursor:(id)aValue
{
    [_selectionTool setWillCreateShapeSelectionCursor:aValue];
}

- (id)willCreateShapeSelectionCursor
{
    return [_selectionTool willCreateShapeSelectionCursor];
}

- (id)defaultWillCreateShapeSelectionCursor
{
    return [_selectionTool defaultWillCreateShapeSelectionCursor];
}

- (void)setDoCreateMagicLassoSelectionCursor:(id)aValue
{
    [_selectionTool setDoCreateMagicLassoSelectionCursor:aValue];
}

- (id)doCreateMagicLassoSelectionCursor
{
    return [_selectionTool doCreateMagicLassoSelectionCursor];
}

- (id)defaultDoCreateMagicLassoSelectionCursor
{
    return [_selectionTool defaultDoCreateMagicLassoSelectionCursor];
}

- (void)setWillCreateMagicLassoSelectionCursor:(id)aValue
{
    [_selectionTool setWillCreateMagicLassoSelectionCursor:aValue];
}

- (id)willCreateMagicLassoSelectionCursor
{
    return [_selectionTool willCreateMagicLassoSelectionCursor];
}

- (id)defaultWillCreateMagicLassoSelectionCursor
{
    return [_selectionTool defaultWillCreateMagicLassoSelectionCursor];
}

- (void)setWillCreateMagicWandSelectionCursor:(id)aValue
{
    [_selectionTool setWillCreateMagicWandSelectionCursor:aValue];
}

- (id)willCreateMagicWandSelectionCursor
{
    return [_selectionTool willCreateMagicWandSelectionCursor];
}

- (id)defaultWillCreateMagicWandSelectionCursor
{
    return [_selectionTool defaultWillCreateMagicWandSelectionCursor];
}

- (void)setDoCreateFreeHandSelectionCursor:(id)aValue
{
    [_selectionTool setDoCreateFreeHandSelectionCursor:aValue];
}

- (id)doCreateFreeHandSelectionCursor
{
    return [_selectionTool doCreateFreeHandSelectionCursor];
}

- (id)defaultDoCreateFreeHandSelectionCursor
{
    return [_selectionTool defaultDoCreateFreeHandSelectionCursor];
}

- (void)setWillCreateFreeHandSelectionCursor:(id)aValue
{
    [_selectionTool setWillCreateFreeHandSelectionCursor:aValue];
}

- (id)willCreateFreeHandSelectionCursor
{
    return [_selectionTool willCreateFreeHandSelectionCursor];
}

- (id)defaultWillCreateFreeHandSelectionCursor
{
    return [_selectionTool defaultWillCreateFreeHandSelectionCursor];
}

- (void)setModifySelectionKeyBindings:(id)aBindings
{
    if (_modifySelectionKeyBindings != aBindings) {
        [_modifySelectionKeyBindings autorelease];
        _modifySelectionKeyBindings = [aBindings copy];
    }
    _areModifySelectionKeyBindingsInitialized = 1;
}

- (id)modifySelectionKeyBindings
{
    if (!_areModifySelectionKeyBindingsInitialized) {
        _modifySelectionKeyBindings = [[self defaultModifySelectionKeyBindings] copy];
        _areModifySelectionKeyBindingsInitialized = 1;
    }
    return _modifySelectionKeyBindings;
}

- (id)defaultModifySelectionKeyBindings
{
    NSString *file = [[NSBundle bundleWithIdentifier:@"com.mackiev.SMKBitmapTools"]
        pathForResource:@"BTRegionEditingTool.MS" ofType:@"dict" inDirectory:@"DefaultKeyBindings"];
    if (file == nil)
        return nil;
    return [NSDictionary dictionaryWithContentsOfFile:file];
}

- (void)BTRegionEditingTool_disableWorkImageRestoration
{
    _shouldRestoreWorkImage = 0;
    [_workImageRestorator release];
    _workImageRestorator = nil;
}

/* Draws the image selection into the work image where it is shown. A cut
   selection that hasn't moved is restored instead. */
- (void)BTRegionEditingTool_paste
{
    if (_shouldRestoreWorkImage) {
        [_workImageRestorator restoreWorkImageForTool:self];
        return;
    }
    if (_imageSelection == nil)
        return;
    id image = [self BTRegionEditingTool_workImageForPaste];
    if (image == nil)
        return;
    CGSize size = [image imageSize];
    CGRect shown = CGRectApplyAffineTransform(_imageSelectionBounds, [self BTRegionEditingTool_imageSelectionTransform]);
    CGRect rect = CGRectIntersection(CGRectMake(0, 0, size.width, size.height),
                                     CGRectIntegral(CGRectInset(shown, -0.05, -0.05)));
    if (CGRectIsEmpty(rect))
        return;
    [self preEditWorkImage:image inRect:rect];
    [image beginCGEditing];
    CGContextRef context = [image imageCGContext];
    if (context != NULL) {
        CGContextConcatCTM(context, _imageSelectionTransform);
        [_imageSelection drawInCGContext:context inRect:_imageSelectionBounds];
    }
    [image endCGEditing];
    [self postEditWorkImageInRect:rect];
}

/* Lifts the image under the selection path into the image selection
   (copying) and/or removes it from the work image (deletion, restorable). */
- (void)BTRegionEditingTool_finalizeSelectionWithCopying:(BOOL)aCopying deletion:(BOOL)aDeletion
{
    id image = [self workImage];
    CGPathRef path = (CGPathRef)[_selectionTool selectionPath];
    if (image == nil || path == NULL)
        return;
    CGSize size = [image imageSize];
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    CGRect bounds;
    CGAffineTransform inverse = CGAffineTransformIdentity;
    CGAffineTransform pathTransform = [self BTRegionEditingTool_selectionPathTransform];
    if (CGAffineTransformIsIdentity(pathTransform)) {
        bounds = CGRectIntersection(imageRect, CGEPathGetPathBoundingBox(path));
        if (CGRectIsEmpty(bounds))
            return;
    } else {
        CGMutablePathRef transformed = BTRegionEditingToolCreateTransformedPath(path, pathTransform);
        // The original kept CGRectNull as the bounds here (in both builds),
        // so a transformed selection lifted nothing; the transformed path's
        // bounds are what was meant.
        bounds = CGRectIntersection(imageRect, CGEPathGetPathBoundingBox(transformed));
        CGPathRelease(transformed);
        if (CGRectIsEmpty(bounds))
            return;
        inverse = CGAffineTransformInvert(pathTransform);
    }
    bounds = CGRectIntegral(bounds);
    if (aCopying) {
        [BTRegionEditingToolUndo(self) BTRegionEditingTool_clearImageSelection];
        BTRegionEditingToolWill(self, @"imageSelectionBounds");
        _imageSelectionBounds = bounds;
        BTRegionEditingToolDid(self, @"imageSelectionBounds");
        BOOL wasCalculated = _isImageSelectionTransformCalculated;
        if (wasCalculated)
            BTRegionEditingToolWill(self, @"imageSelectionTransform");
        _selectionImageToPathTransform = inverse;
        _imageSelectionTransform = CGAffineTransformIdentity;
        _isImageSelectionTransformCalculated = 1;
        if (wasCalculated)
            BTRegionEditingToolDid(self, @"imageSelectionTransform");
        BTRegionEditingToolWill(self, @"imageSelection");
        [_imageSelection release];
        _imageSelection = [self BTRegionEditingTool_copyWithClipPath:(struct CGPath *)path
                                           createWorkImageRestorator:aDeletion];
        BTRegionEditingToolDid(self, @"imageSelection");
        _isSelectionPathPositioned = 1;
    }
    if (aDeletion)
        [self BTRegionEditingTool_deleteInRect:bounds enablingWorkImageRestoration:YES];
}

- (void)BTRegionEditingTool_clearImageSelection
{
    [BTRegionEditingToolUndo(self) BTRegionEditingTool_setImageSelection:_imageSelection bounds:_imageSelectionBounds
                                                    imageToPathTransform:_selectionImageToPathTransform];
    if (!CGRectIsEmpty(_imageSelectionBounds)) {
        BTRegionEditingToolWill(self, @"imageSelectionBounds");
        _imageSelectionBounds = CGRectNull;
        BTRegionEditingToolDid(self, @"imageSelectionBounds");
    }
    if (!CGAffineTransformIsIdentity(_selectionImageToPathTransform)) {
        BOOL wasCalculated = _isImageSelectionTransformCalculated;
        if (wasCalculated)
            BTRegionEditingToolWill(self, @"imageSelectionTransform");
        _selectionImageToPathTransform = CGAffineTransformIdentity;
        _imageSelectionTransform = CGAffineTransformIdentity;
        _isImageSelectionTransformCalculated = 1;
        if (wasCalculated)
            BTRegionEditingToolDid(self, @"imageSelectionTransform");
    }
    if (_imageSelection != nil) {
        BTRegionEditingToolWill(self, @"imageSelection");
        [_imageSelection release];
        _imageSelection = nil;
        BTRegionEditingToolDid(self, @"imageSelection");
    }
    _isSelectionPathPositioned = 0;
}

- (void)BTRegionEditingTool_changeImageSelection:(id)aImage bounds:(CGRect)aBounds imageToPathTransform:(CGAffineTransform)aTransform
{
    [BTRegionEditingToolUndo(self) BTRegionEditingTool_changeImageSelection:_imageSelection
                                                                     bounds:_imageSelectionBounds
                                                      imageToPathTransform:_selectionImageToPathTransform];
    [self BTRegionEditingTool_updateImageSelection:aImage bounds:aBounds imageToPathTransform:aTransform];
}

- (void)BTRegionEditingTool_setImageSelection:(id)aImage bounds:(CGRect)aBounds imageToPathTransform:(CGAffineTransform)aTransform
{
    [BTRegionEditingToolUndo(self) BTRegionEditingTool_clearImageSelection];
    [self BTRegionEditingTool_updateImageSelection:aImage bounds:aBounds imageToPathTransform:aTransform];
    _isSelectionPathPositioned = 1;
}

- (void)BTRegionEditingTool_updateImageSelection:(id)aImage bounds:(CGRect)aBounds imageToPathTransform:(CGAffineTransform)aTransform
{
    if (!CGRectEqualToRect(aBounds, _imageSelectionBounds)) {
        BTRegionEditingToolWill(self, @"imageSelectionBounds");
        _imageSelectionBounds = aBounds;
        BTRegionEditingToolDid(self, @"imageSelectionBounds");
    }
    if (!_isSelectionPathPositioned || !CGAffineTransformEqualToTransform(aTransform, _selectionImageToPathTransform)) {
        BOOL wasCalculated = _isImageSelectionTransformCalculated;
        if (wasCalculated)
            BTRegionEditingToolWill(self, @"imageSelectionTransform");
        _selectionImageToPathTransform = aTransform;
        _isImageSelectionTransformCalculated = 0;
        if (wasCalculated)
            BTRegionEditingToolDid(self, @"imageSelectionTransform");
    }
    if (aImage != _imageSelection) {
        BTRegionEditingToolWill(self, @"imageSelection");
        [aImage retain];
        [_imageSelection release];
        _imageSelection = aImage;
        BTRegionEditingToolDid(self, @"imageSelection");
    }
}

/* Clears the inside of the selection path in aRect of the work image (to the
   background color if there is one). The first deletion keeps a restorator
   of aRect, so that putting an unmoved selection back restores it exactly. */
- (void)BTRegionEditingTool_deleteInRect:(CGRect)aRect enablingWorkImageRestoration:(BOOL)aEnabling
{
    CGPathRef path = (CGPathRef)[_selectionTool selectionPath];
    if (path == NULL)
        return;
    CGAffineTransform pathTransform = CGAffineTransformInvert(_selectionImageToPathTransform);
    CGColorRef color = [self BTRegionEditingTool_backgroundColor];
    id image = [self workImage];
    if (image == nil)
        return;
    if (aEnabling) {
        if (_workImageRestorator == nil)
            _workImageRestorator = [[BTRegionEditingTool_BTImageRestorator alloc] initWithRestorationRect:aRect
                                                                                             inWorkImage:image];
        _shouldRestoreWorkImage = _workImageRestorator != nil;
    }
    if ([image conformsToProtocol:@protocol(BTCGMutableImage)]) {
        id fill = nil;
        if (color != NULL) {
            fill = _workImageRestorator != nil
                ? [_workImageRestorator restorationImage]
                : [[self BTRegionEditingTool_copyWithClipPath:NULL createWorkImageRestorator:NO] autorelease];
            if (fill == nil)
                return;
        }
        [_delegate tool:self willChangeImageInRect:aRect];
        if (_workImageRestorator == nil)
            [self registerWorkImageUndoInRect:aRect];
        else {
            id manager = [_delegate undoManagerForTool:self category:@"BTToolWorkImageUndoCategory"];
            if (manager != nil)
                [[self prepareUndoInManager:manager category:@"BTToolWorkImageUndoCategory" withInvocationTarget:self]
                    BTRegionEditingTool_restoreImageWithRestorator:_workImageRestorator];
        }
        [image beginCGEditing];
        CGContextRef context = [image imageCGContext];
        if (context != NULL) {
            if (color != NULL) {
                // Fill the rect, then draw the old pixels back outside the path.
                CGContextClearRect(context, aRect);
                CGContextSetFillColorWithColor(context, color);
                CGContextFillRect(context, aRect);
                CGMutablePathRef outside = BTRegionEditingToolCreateTransformedPath(path, pathTransform);
                CGPathAddRect(outside, NULL, aRect);
                CGContextBeginPath(context);
                CGContextAddPath(context, outside);
                CGContextEOClip(context);
                CGPathRelease(outside);
                [fill drawInCGContext:context inRect:aRect];
            } else {
                CGContextBeginPath(context);
                CGContextSaveGState(context);
                CGContextConcatCTM(context, pathTransform);
                CGContextAddPath(context, path);
                CGContextRestoreGState(context);
                CGContextEOClip(context);
                CGContextClearRect(context, aRect);
            }
        }
        [image endCGEditing];
        [_delegate tool:self didChangeImageInRect:aRect];
        return;
    }
    // An immutable work image is replaced by a copy without the inside.
    CGSize size = [image imageSize];
    id layer = [BTRegionEditingTool BTRegionEditingTool_mutableImageOfSize:size];
    [self preEditWorkImage:layer inRect:aRect];
    [layer beginCGEditing];
    CGContextRef context = [layer imageCGContext];
    if (context != NULL) {
        if (color != NULL) {
            CGContextSetFillColorWithColor(context, color);
            CGContextFillRect(context, aRect);
        }
        CGMutablePathRef outside = BTRegionEditingToolCreateTransformedPath(path, pathTransform);
        CGPathMoveToPoint(outside, NULL, 0, 0);
        CGPathAddLineToPoint(outside, NULL, 0, size.height);
        CGPathAddLineToPoint(outside, NULL, size.width, size.height);
        CGPathAddLineToPoint(outside, NULL, size.width, 0);
        CGPathCloseSubpath(outside);
        CGContextBeginPath(context);
        CGContextAddPath(context, outside);
        CGContextEOClip(context);
        CGPathRelease(outside);
        [image drawInCGContext:context atPoint:CGPointZero];
    }
    [layer endCGEditing];
    [self postEditWorkImageInRect:aRect];
}

/* The work image's color at a magic selection's start point unless the
   background mode is the external color (the background color, which may
   be NULL to clear). */
- (struct CGColor *)BTRegionEditingTool_backgroundColor
{
    id image = [self workImage];
    if (image == nil)
        return NULL;
    CGPoint point = CGPointMake(-1, -1);
    [[_selectionTool selectionStartPoint] getValue:&point];
    if (![_backgroundMode isEqualToString:@"BTExternalColorBackgroundMode"]) {
        struct CGColor *color = [image colorAtPoint:point];
        if (color != NULL)
            return color;
    }
    return _backgroundColor;
}

/* A copy (+1) of the work image in the image selection bounds, clipped to
   aPath placed by the inverse image to path transform. With a restorator the
   copy is the restorator's image (clipped lazily). */
- (id)BTRegionEditingTool_copyWithClipPath:(struct CGPath *)aPath createWorkImageRestorator:(BOOL)aCreate
{
    id image = [self workImage];
    if (image == nil)
        return nil;
    CGAffineTransform clipTransform = CGAffineTransformInvert(_selectionImageToPathTransform);
    clipTransform.tx -= _imageSelectionBounds.origin.x;
    clipTransform.ty -= _imageSelectionBounds.origin.y;
    if (aCreate) {
        [_workImageRestorator release];
        _workImageRestorator = [[BTRegionEditingTool_BTImageRestorator alloc]
                                  initWithRestorationRect:_imageSelectionBounds inWorkImage:image];
        id restoration = [_workImageRestorator restorationImage];
        if (aPath == NULL)
            return [restoration retain];
        return [[BTRegionEditingTool_BTClippedCGImage alloc] initWithImage:restoration clipPath:aPath
                                                             clipTransform:clipTransform];
    }
    id layer = [BTRegionEditingTool BTRegionEditingTool_mutableImageOfSize:_imageSelectionBounds.size];
    id result = nil;
    [layer beginCGEditing];
    CGContextRef context = [layer imageCGContext];
    if (context != NULL) {
        if (aPath != NULL) {
            CGContextBeginPath(context);
            CGContextSaveGState(context);
            CGContextConcatCTM(context, clipTransform);
            CGContextAddPath(context, aPath);
            CGContextRestoreGState(context);
            CGContextEOClip(context);
        }
        [image drawInCGContext:context
                       atPoint:CGPointMake(-_imageSelectionBounds.origin.x, -_imageSelectionBounds.origin.y)];
        result = [layer retain];
    }
    [layer endCGEditing];
    return result;
}

/* Starts the selection tool; without selection creation the (empty)
   selection counts as positioned. */
- (BOOL)BTRegionEditingTool_activateSubtool
{
    if (![_selectionTool activateWithDelegate:self inView:_view])
        return NO;
    _currentSubtool = _selectionTool;
    if ([_selectionTool currentCreateSelectionMode] == nil) {
        _isSelectionPathPositioned = 1;
        return YES;
    }
    [_imageSelection release];
    _imageSelection = nil;
    _imageSelectionBounds = CGRectNull;
    _selectionImageToPathTransform = CGAffineTransformIdentity;
    _imageSelectionTransform = CGAffineTransformIdentity;
    _isImageSelectionTransformCalculated = 1;
    _isSelectionPathPositioned = 0;
    return YES;
}

- (void)BTRegionEditingTool_invalidateImageSelection
{
    CGAffineTransform transform = CGAffineTransformConcat([self BTRegionEditingTool_imageSelectionTransform],
                                                          [self imageToViewTransform]);
    [_view setNeedsDisplayInRect:NSRectFromCGRect(CGRectApplyAffineTransform(_imageSelectionBounds, transform))];
}

- (void)BTRegionEditingTool_unrestoreImageWithRestorator:(id)aRestorator
{
    [aRestorator unrestoreWorkImageForTool:self];
}

- (void)BTRegionEditingTool_restoreImageWithRestorator:(id)aRestorator
{
    [aRestorator restoreWorkImageForTool:self];
}

/* The work image if it is mutable, else a mutable copy of it. */
- (id)BTRegionEditingTool_workImageForPaste
{
    id image = [self workImage];
    if ([image conformsToProtocol:@protocol(BTCGMutableImage)])
        return image;
    id layer = [BTRegionEditingTool BTRegionEditingTool_mutableImageOfSize:[image imageSize]];
    if (layer == nil)
        return nil;
    [layer beginCGEditing];
    CGContextRef context = [layer imageCGContext];
    if (context != NULL)
        [image drawInCGContext:context atPoint:CGPointZero];
    [layer endCGEditing];
    return context != NULL ? layer : nil;
}

/* The image selection's transform follows the selection path's: it is
   recalculated from the image to path transform after the path moved. */
- (CGAffineTransform)BTRegionEditingTool_imageSelectionTransform
{
    if (!_isImageSelectionTransformCalculated) {
        id value = [_selectionTool selectionAffineTransform];
        if (value != nil) {
            CGAffineTransform pathTransform = CGAffineTransformIdentity;
            [value getValue:&pathTransform];
            _imageSelectionTransform = CGAffineTransformConcat(_selectionImageToPathTransform, pathTransform);
        } else
            _imageSelectionTransform = _selectionImageToPathTransform;
        _isImageSelectionTransformCalculated = 1;
    }
    return _imageSelectionTransform;
}

- (CGAffineTransform)BTRegionEditingTool_selectionPathTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    [[_selectionTool selectionAffineTransform] getValue:&transform];
    return transform;
}

- (void)dealloc
{
    [_selectionTool release];
    [_selectionPathPositioningUndoActionNamePrefix release];
    [_workImageRestorator release];
    [_modifySelectionKeyBindings release];
    [_imageSelection release];
    CGColorRelease(_backgroundColor);
    [_backgroundMode release];
    [super dealloc];
}

- (id)init
{
    if (!(self = [super init]))
        return nil;
    _selectionTool = [[BTSelectionTool alloc] init];
    if (_selectionTool == nil) {
        [self release];
        return nil;
    }
    _backgroundMode = [@"BTClearBackgroundMode" retain];
    _selectionImageToPathTransform = CGAffineTransformIdentity;
    _imageSelectionTransform = CGAffineTransformIdentity;
    _isImageSelectionTransformCalculated = 1;
    return self;
}

@end

/* Keeps the work image of a cut region (and, once restored, the image with
   the region cut) so that the cut can be undone and redone exactly. */
@implementation BTRegionEditingTool_BTImageRestorator

/* A copy of aImage in aRect. */
static id BTImageRestoratorCopy(id aImage, CGRect aRect)
{
    id layer = [BTRegionEditingTool BTRegionEditingTool_mutableImageOfSize:aRect.size];
    if (layer == nil)
        return nil;
    id copy = nil;
    [layer beginCGEditing];
    CGContextRef context = [layer imageCGContext];
    if (context != NULL) {
        [aImage drawInCGContext:context atPoint:CGPointMake(-aRect.origin.x, -aRect.origin.y)];
        copy = [layer retain];
    }
    [layer endCGEditing];
    return copy;
}

/* Draws aImage over the restoration rect of aTool's work image, registering
   the opposite change for undo. */
static void BTImageRestoratorReplace(BTRegionEditingTool_BTImageRestorator *self, id aTool, id aImage, BOOL aRestoring)
{
    id workImage = [aTool workImage];
    id delegate = [aTool delegate];
    CGRect rect = self->_restorationRect;
    [delegate tool:aTool willChangeImageInRect:rect];
    id manager = [delegate undoManagerForTool:aTool category:@"BTToolWorkImageUndoCategory"];
    if (manager != nil) {
        id target = [aTool prepareUndoInManager:manager category:@"BTToolWorkImageUndoCategory" withInvocationTarget:aTool];
        if (aRestoring)
            [target BTRegionEditingTool_unrestoreImageWithRestorator:self];
        else
            [target BTRegionEditingTool_restoreImageWithRestorator:self];
    }
    [workImage beginCGEditing];
    CGContextRef context = [workImage imageCGContext];
    if (context != NULL) {
        CGContextClearRect(context, rect);
        [aImage drawInCGContext:context inRect:rect];
    }
    [workImage endCGEditing];
    [delegate tool:aTool didChangeImageInRect:rect];
}

- (void)unrestoreWorkImageForTool:(id)aTool
{
    BTImageRestoratorReplace(self, aTool, _unrestorationImage, NO);
}

/* The work image as it is now is kept first, for undoing the restoration. */
- (void)restoreWorkImageForTool:(id)aTool
{
    if (_unrestorationImage == nil)
        _unrestorationImage = BTImageRestoratorCopy([aTool workImage], _restorationRect);
    BTImageRestoratorReplace(self, aTool, _restorationImage, YES);
}

- (CGRect)restorationRect
{
    return _restorationRect;
}

- (id)restorationImage
{
    return _restorationImage;
}

- (void)dealloc
{
    [_restorationImage release];
    [_unrestorationImage release];
    [super dealloc];
}

- (id)initWithRestorationRect:(CGRect)aRect inWorkImage:(id)aImage
{
    if (!(self = [super init]))
        return nil;
    _restorationImage = BTImageRestoratorCopy(aImage, aRect);
    if (_restorationImage == nil) {
        [self release];
        return nil;
    }
    _restorationRect = aRect;
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

/* An image drawn clipped to a path (in the image's coordinates scaled to the
   drawing rect). */
@implementation BTRegionEditingTool_BTClippedCGImage

- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] graphicsPort] atPoint:NSPointToCGPoint(aPoint)];
}

- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] graphicsPort] inRect:NSRectToCGRect(aRect)];
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGSize size = [_image imageSize];
    [self drawInCGContext:aContext inRect:CGRectMake(aPoint.x, aPoint.y, size.width, size.height)];
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGContextSaveGState(aContext);
    CGContextBeginPath(aContext);
    CGContextSaveGState(aContext);
    CGSize size = [_image imageSize];
    CGFloat sx = size.width != 0 ? aRect.size.width / size.width : 1;
    CGFloat sy = size.height != 0 ? aRect.size.height / size.height : 1;
    CGAffineTransform toRect = CGAffineTransformMake(sx, 0, 0, sy, aRect.origin.x, aRect.origin.y);
    CGContextConcatCTM(aContext, CGAffineTransformConcat(_clipTransform, toRect));
    CGContextAddPath(aContext, _clipPath);
    CGContextRestoreGState(aContext);
    CGContextEOClip(aContext);
    [_image drawInCGContext:aContext inRect:aRect];
    CGContextRestoreGState(aContext);
}

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    return NULL;
}

- (struct CGImage *)coreGraphicsImage
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return [_image coreGraphicsColorSpace];
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (CGSize)imageSize
{
    return [_image imageSize];
}

- (void)dealloc
{
    [_image release];
    CGPathRelease(_clipPath);
    [super dealloc];
}

- (id)initWithImage:(id)aImage clipPath:(struct CGPath *)aPath clipTransform:(CGAffineTransform)aTransform
{
    if (!(self = [super init]))
        return nil;
    _clipPath = (struct CGPath *)CGPathCreateCopy(aPath);
    if (_clipPath == NULL) {
        [self release];
        return nil;
    }
    _clipTransform = aTransform;
    _image = [aImage retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

/* A copied image selection with its path. On the pasteboard it is this
   process's object (by pointer, the region owns the pasteboard until it
   changes owner), an archive, PDF and PNG data. */
@implementation BTRegionEditingTool_BTImageRegion

/* The main display's RGB color space (generic RGB if the display's profile
   isn't RGB), for images in device RGB or without a color space. The
   original read the default display profile through the old ColorSync
   manager. */
static CGColorSpaceRef BTImageRegionCreateDisplayColorSpace(void)
{
    CGColorSpaceRef space = NULL;
    ColorSyncProfileRef profile = ColorSyncProfileCreateWithDisplayID(CGMainDisplayID());
    if (profile != NULL) {
        space = CGColorSpaceCreateWithPlatformColorSpace(profile);
        CFRelease(profile);
        if (space != NULL && CGColorSpaceGetModel(space) != kCGColorSpaceModelRGB) {
            CGColorSpaceRelease(space);
            space = NULL;
        }
    }
    return space != NULL ? space : CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
}

static BOOL BTImageRegionIsDeviceRGB(CGColorSpaceRef aSpace)
{
    CGColorSpaceRef device = CGColorSpaceCreateDeviceRGB();
    BOOL result = device != NULL && (aSpace == device || CFEqual(aSpace, device));
    CGColorSpaceRelease(device);
    return result;
}

/* A 32-bit bitmap context of aSize in aSpace. */
static CGContextRef BTImageRegionCreateContext(CGSize aSize, CGColorSpaceRef aSpace)
{
    size_t width = aSize.width > 0 ? lround(ceil(aSize.width)) : 0;
    size_t height = aSize.height > 0 ? lround(ceil(aSize.height)) : 0;
    return CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~(size_t)15, aSpace,
                                  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
}

+ (SEL)providingSelectorForType:(id)aType
{
    static NSDictionary *selectors = nil;
    if (selectors == nil)
        selectors = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"provideImageRegionToPasteboard:forType:", [self imageRegionPasteboardType],
            @"provideArchivedImageRegionToPasteboard:forType:", @"BTArchivedImageRegionPboardType",
            @"providePDFDataToPasteboard:forType:", NSPasteboardTypePDF,
            @"provideImageDataToPasteboard:forType:", @"Apple PNG pasteboard type", nil];
    NSString *name = [selectors objectForKey:aType];
    return name != nil ? NSSelectorFromString(name) : NULL;
}

/* Unique to this process, so another process's regions are only read
   archived. */
+ (id)imageRegionPasteboardType
{
    static NSString *type = nil;
    if (type == nil) {
        NSString *unique = [[NSProcessInfo processInfo] globallyUniqueString];
        if (unique != nil)
            type = [[NSString alloc] initWithFormat:@"BTRegionEditingTool_BTImageRegion@%@", unique];
    }
    return type;
}

- (void)pasteboardChangedOwner:(id)aPasteboard
{
    [self release];
}

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    SEL selector = [[self class] providingSelectorForType:aType];
    if (selector != NULL)
        [self performSelector:selector withObject:aPasteboard withObject:aType];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)provideImageDataToPasteboard:(id)aPasteboard forType:(id)aType
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassNSPboardType, (CFStringRef)aType, NULL);
    if (uti == NULL)
        return;
    CFDataRef data = [self BTRegionEditingTool_BTImageRegion_createImageDataForType:(struct __CFString *)uti
                                                             applyingTransformation:YES];
    CFRelease(uti);
    if (data == NULL)
        return;
    [aPasteboard setData:(NSData *)data forType:aType];
    CFRelease(data);
}
#pragma clang diagnostic pop

/* One page the size of the transformed image. Device RGB images go in as
   images in the display's color space. */
- (void)providePDFDataToPasteboard:(id)aPasteboard forType:(id)aType
{
    CGRect box = CGRectApplyAffineTransform(_imageBounds, _imageTransform);
    CGRect mediaBox = CGRectMake(0, 0, box.size.width, box.size.height);
    NSMutableData *data = [NSMutableData data];
    if (data == nil)
        return;
    CGContextRef context = CGEPDFContextCreateWithCFData((CFMutableDataRef)data, &mediaBox, NULL);
    if (context == NULL)
        return;
    CGContextBeginPage(context, &mediaBox);
    CGSize size = [_image imageSize];
    CGImageRef image = NULL;
    if (BTImageRegionIsDeviceRGB([_image coreGraphicsColorSpace])) {
        CGColorSpaceRef space = BTImageRegionCreateDisplayColorSpace();
        if (space != NULL) {
            CGImageRef cgImage = [_image coreGraphicsImage];
            if (cgImage != NULL)
                image = CGImageCreateCopyWithColorSpace(cgImage, space);
            else {
                CGContextRef bitmap = BTImageRegionCreateContext(size, space);
                if (bitmap != NULL) {
                    [_image drawInCGContext:bitmap inRect:CGRectMake(0, 0, size.width, size.height)];
                    image = CGEBitmapContextCreateImageNoCopy(bitmap, NULL, true, kCGRenderingIntentDefault);
                    CGContextRelease(bitmap);
                }
            }
            CGColorSpaceRelease(space);
        }
    }
    CGAffineTransform transform = _imageTransform;
    transform.tx -= box.origin.x;
    transform.ty -= box.origin.y;
    CGContextConcatCTM(context, transform);
    if (image == NULL)
        [_image drawInCGContext:context inRect:_imageBounds];
    else {
        CGFloat sx = size.width != 0 ? _imageBounds.size.width / size.width : 1;
        CGFloat sy = size.height != 0 ? _imageBounds.size.height / size.height : 1;
        CGContextConcatCTM(context, CGAffineTransformMake(sx, 0, 0, sy, _imageBounds.origin.x, _imageBounds.origin.y));
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
        CGImageRelease(image);
    }
    CGContextEndPage(context);
    CGContextRelease(context);
    [aPasteboard setData:data forType:aType];
}

- (void)provideArchivedImageRegionToPasteboard:(id)aPasteboard forType:(id)aType
{
    NSMutableData *data = [NSMutableData data];
    if (data == nil)
        return;
    id archiver = [[BTRegionEditingTool_BTImageRegionArchiver alloc] initForWritingWithMutableData:data];
    if (archiver == nil)
        return;
    [self encodeWithCoder:archiver];
    [archiver release];
    [aPasteboard setData:data forType:aType];
}

- (void)provideImageRegionToPasteboard:(id)aPasteboard forType:(id)aType
{
    id region = self;
    NSData *data = [NSData dataWithBytes:&region length:sizeof(region)];
    if (data != nil)
        [aPasteboard setData:data forType:aType];
}

- (BOOL)isPathFlippedHorizontally
{
    return _isPathFlippedHorizontally;
}

- (CGAffineTransform)pathTransform
{
    return _pathTransform;
}

- (struct CGPath *)path
{
    return _path;
}

- (CGAffineTransform)imageTransform
{
    return _imageTransform;
}

- (CGRect)imageBounds
{
    return _imageBounds;
}

- (id)image
{
    return _image;
}

static void BTImageRegionDecodeDoubles(NSCoder *aCoder, CGFloat *aValues, int aCount)
{
    for (int i = 0; i < aCount; i++) {
        double value = 0;
        [aCoder decodeValueOfObjCType:"d" at:&value];
        aValues[i] = value;
    }
}

/* The archive: bounds, image transform, path transform, the flip, the image
   type and its data, then the path elements (a command byte 1-5 with its
   points) up to a 0 byte. */
- (id)initWithCoder:(id)aCoder
{
    if (!(self = [super init]))
        return nil;
    BTImageRegionDecodeDoubles(aCoder, (CGFloat *)&_imageBounds, 4);
    BTImageRegionDecodeDoubles(aCoder, (CGFloat *)&_imageTransform, 6);
    BTImageRegionDecodeDoubles(aCoder, (CGFloat *)&_pathTransform, 6);
    unsigned char flipped = 0;
    [aCoder decodeValueOfObjCType:"C" at:&flipped];
    _isPathFlippedHorizontally = flipped & 1;
    NSData *typeData = [aCoder decodeDataObject];
    NSString *type = typeData != nil
        ? [(NSString *)CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, (CFDataRef)typeData,
                                                                 kCFStringEncodingUTF8) autorelease]
        : nil;
    NSData *imageData = type != nil ? [aCoder decodeDataObject] : nil;
    CGImageSourceRef source = imageData != nil
        ? CGImageSourceCreateWithData((CFDataRef)imageData,
              (CFDictionaryRef)[NSDictionary dictionaryWithObject:type forKey:(id)kCGImageSourceTypeIdentifierHint])
        : NULL;
    CGImageRef image = NULL;
    if (source != NULL) {
        image = CGImageSourceCreateImageAtIndex(source, 0,
            (CFDictionaryRef)[NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceShouldCache]);
        CFRelease(source);
    }
    if (image != NULL) {
        _image = [[BTCGImage alloc] initWithCGImage:image];
        CGImageRelease(image);
    }
    CGMutablePathRef path = _image != nil ? CGPathCreateMutable() : NULL;
    if (path == NULL) {
        [self release];
        return nil;
    }
    unsigned char command = 0;
    [aCoder decodeValueOfObjCType:"C" at:&command];
    while (command != 0) {
        CGFloat p[6];
        switch (command) {
        case 1:
            BTImageRegionDecodeDoubles(aCoder, p, 2);
            CGPathMoveToPoint(path, NULL, p[0], p[1]);
            break;
        case 2:
            BTImageRegionDecodeDoubles(aCoder, p, 2);
            CGPathAddLineToPoint(path, NULL, p[0], p[1]);
            break;
        case 3:
            BTImageRegionDecodeDoubles(aCoder, p, 4);
            CGPathAddQuadCurveToPoint(path, NULL, p[0], p[1], p[2], p[3]);
            break;
        case 4:
            BTImageRegionDecodeDoubles(aCoder, p, 6);
            CGPathAddCurveToPoint(path, NULL, p[0], p[1], p[2], p[3], p[4], p[5]);
            break;
        case 5:
            CGPathCloseSubpath(path);
            break;
        default:
            NSLog(@"Unknown/invalid path command.");
            break;
        }
        [aCoder decodeValueOfObjCType:"C" at:&command];
    }
    _path = (struct CGPath *)CGPathCreateCopy(path);
    CGPathRelease(path);
    if (_path == NULL) {
        [self release];
        return nil;
    }
    return self;
}

static void BTImageRegionEncodeDoubles(NSCoder *aCoder, const CGFloat *aValues, int aCount)
{
    for (int i = 0; i < aCount; i++) {
        double value = aValues[i];
        [aCoder encodeValueOfObjCType:"d" at:&value];
    }
}

static void BTImageRegionEncodePathElement(void *aCoder, const CGPathElement *aElement)
{
    static const unsigned char commands[] = {1, 2, 3, 4, 5};
    static const int pointCounts[] = {1, 1, 2, 3, 0};
    if (aElement->type > kCGPathElementCloseSubpath) {
        NSLog(@"Unknown/invalid CGPathElementType.");
        return;
    }
    unsigned char command = commands[aElement->type];
    [(NSCoder *)aCoder encodeValueOfObjCType:"C" at:&command];
    for (int i = 0; i < pointCounts[aElement->type]; i++)
        BTImageRegionEncodeDoubles(aCoder, (const CGFloat *)&aElement->points[i], 2);
}

- (void)encodeWithCoder:(id)aCoder
{
    // The type of the image data, kUTTypePNG.
    NSData *type = [(NSData *)CFStringCreateExternalRepresentation(kCFAllocatorDefault, CFSTR("public.png"),
                                                                   kCFStringEncodingUTF8, 0) autorelease];
    if (type == nil)
        return;
    CFDataRef image = [self BTRegionEditingTool_BTImageRegion_createImageDataForType:(struct __CFString *)CFSTR("public.png")
                                                              applyingTransformation:NO];
    if (image == NULL)
        return;
    BTImageRegionEncodeDoubles(aCoder, (const CGFloat *)&_imageBounds, 4);
    BTImageRegionEncodeDoubles(aCoder, (const CGFloat *)&_imageTransform, 6);
    BTImageRegionEncodeDoubles(aCoder, (const CGFloat *)&_pathTransform, 6);
    unsigned char flipped = _isPathFlippedHorizontally;
    [aCoder encodeValueOfObjCType:"C" at:&flipped];
    [aCoder encodeDataObject:type];
    [aCoder encodeDataObject:(NSData *)image];
    CFRelease(image);
    CGPathApply(_path, aCoder, BTImageRegionEncodePathElement);
    unsigned char end = 0;
    [aCoder encodeValueOfObjCType:"C" at:&end];
}

/* The image (transformed, if asked and not the identity) encoded as aType;
   device RGB images are put in the display's color space. The caller
   releases the data. */
- (struct __CFData *)BTRegionEditingTool_BTImageRegion_createImageDataForType:(struct __CFString *)aType applyingTransformation:(BOOL)aApplying
{
    BOOL transforming = aApplying && !CGAffineTransformIsIdentity(_imageTransform);
    CGImageRef image = transforming ? NULL : CGImageRetain([_image coreGraphicsImage]);
    CGColorSpaceRef space = [_image coreGraphicsColorSpace];
    BOOL ownsSpace = NO;
    if (space == NULL || BTImageRegionIsDeviceRGB(space)) {
        space = BTImageRegionCreateDisplayColorSpace();
        ownsSpace = YES;
        if (space != NULL && image != NULL) {
            CGImageRef copy = CGImageCreateCopyWithColorSpace(image, space);
            CGImageRelease(image);
            image = copy;
        }
    }
    if (image == NULL && space != NULL) {
        CGRect rect;
        if (transforming)
            rect = CGRectApplyAffineTransform(_imageBounds, _imageTransform);
        else {
            CGSize size = [_image imageSize];
            rect = CGRectMake(0, 0, size.width, size.height);
        }
        CGContextRef context = BTImageRegionCreateContext(rect.size, space);
        if (context != NULL) {
            if (transforming) {
                CGAffineTransform transform = _imageTransform;
                transform.tx -= rect.origin.x;
                transform.ty -= rect.origin.y;
                CGContextConcatCTM(context, transform);
                [_image drawInCGContext:context inRect:_imageBounds];
            } else
                [_image drawInCGContext:context inRect:rect];
            image = CGEBitmapContextCreateImageNoCopy(context, NULL, true, kCGRenderingIntentDefault);
            CGContextRelease(context);
        }
    }
    if (ownsSpace)
        CGColorSpaceRelease(space);
    if (image == NULL)
        return NULL;
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    if (data != NULL) {
        CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, (CFStringRef)aType, 1, NULL);
        if (destination != NULL) {
            CGImageDestinationAddImage(destination, image, NULL);
            CGImageDestinationFinalize(destination);
            CFRelease(destination);
        } else {
            CFRelease(data);
            data = NULL;
        }
    }
    CGImageRelease(image);
    return (struct __CFData *)data;
}

- (void)dealloc
{
    CGPathRelease(_path);
    [_image release];
    [super dealloc];
}

- (id)initWithImage:(id)aImage imageBounds:(CGRect)aBounds imageTransform:(CGAffineTransform)aImageTransform path:(struct CGPath *)aPath pathTransform:(CGAffineTransform)aPathTransform flippedHorizontally:(BOOL)aFlipped
{
    if (!(self = [super init]))
        return nil;
    _image = [aImage retain];
    _path = (struct CGPath *)CGPathRetain(aPath);
    _imageBounds = aBounds;
    _imageTransform = aImageTransform;
    _pathTransform = aPathTransform;
    _isPathFlippedHorizontally = aFlipped ? 1 : 0;
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

/* Reads the archive written by BTImageRegionArchiver. */
@implementation BTRegionEditingTool_BTImageRegionUnarchiver

static const char BTImageRegionArchiveMagic[] = "BTImageRegionArchive-1.0";

/* A length ("Q") then the bytes. */
- (id)decodeDataObject
{
    unsigned long long length = 0;
    [self decodeValueOfObjCType:"Q" at:&length];
    if (_offset + length > [_data length])
        return nil;
    NSData *data = [NSData dataWithBytes:(const char *)[_data bytes] + _offset length:length];
    _offset += length;
    return data;
}

/* Doubles are big-endian, "Q" native, "C" a byte; other types are skipped.
   Reads past the end leave the value alone. */
- (void)decodeValueOfObjCType:(const char *)aType at:(void *)aValue
{
    const char *bytes = [_data bytes];
    NSUInteger length = [_data length];
    if (strcmp(aType, "d") == 0) {
        if (_offset + 8 > length)
            return;
        CFSwappedFloat64 value;
        memcpy(&value, bytes + _offset, 8);
        *(double *)aValue = CFConvertDoubleSwappedToHost(value);
        _offset += 8;
    } else if (strcmp(aType, "C") == 0) {
        if (_offset + 1 > length)
            return;
        *(unsigned char *)aValue = bytes[_offset];
        _offset += 1;
    } else if (strcmp(aType, "Q") == 0) {
        if (_offset + 8 > length)
            return;
        memcpy(aValue, bytes + _offset, 8);
        _offset += 8;
    }
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

- (id)initForReadingWithData:(id)aData
{
    if (!(self = [super init]))
        return nil;
    if ([aData length] < sizeof(BTImageRegionArchiveMagic)
        || strncmp([aData bytes], BTImageRegionArchiveMagic, sizeof(BTImageRegionArchiveMagic)) != 0) {
        [self release];
        return nil;
    }
    _data = [aData retain];
    _offset = sizeof(BTImageRegionArchiveMagic);
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

/* Writes the magic (with its NUL) and then the values as the unarchiver
   reads them. */
@implementation BTRegionEditingTool_BTImageRegionArchiver

- (void)encodeDataObject:(id)aData
{
    unsigned long long length = [aData length];
    [self encodeValueOfObjCType:"Q" at:&length];
    [_data appendData:aData];
}

- (void)encodeValueOfObjCType:(const char *)aType at:(const void *)aValue
{
    if (strcmp(aType, "d") == 0) {
        CFSwappedFloat64 value = CFConvertDoubleHostToSwapped(*(const double *)aValue);
        [_data appendBytes:&value length:8];
    } else if (strcmp(aType, "C") == 0)
        [_data appendBytes:aValue length:1];
    else if (strcmp(aType, "Q") == 0)
        [_data appendBytes:aValue length:8];
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

- (id)initForWritingWithMutableData:(id)aData
{
    if (!(self = [super init]))
        return nil;
    _data = [aData retain];
    [_data appendBytes:BTImageRegionArchiveMagic length:sizeof(BTImageRegionArchiveMagic)];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
