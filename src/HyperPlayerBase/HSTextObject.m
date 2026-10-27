#import "HSTextObject.h"
#import "HSCardGroupController.h"
#import "HSCoreText.h"
#import "HSDocument.h"
#import "EXCodingContext.h"
#import "HSFunctions.h"
#import "HSHitTestingTextObjectVisualization.h"
#import "HSProtocolIdentifier.h"
#import "HSSystemTextView.h"
#import "HSTextObjectAttributesImplementation.h"
#import "HSTextObjectData.h"
#import "HSTextObjectGeometryBehaviorAdaptor.h"
#import "HSTextObjectVisualization.h"
#import "HSUID.h"
#import "HSValueConstraints.h"
#import "HSVisualHitTester.h"

static NSSet *HSTextObjectImplementationInterfaces = nil;

// Within 0.0005 of the larger magnitude, zero counting as 1.
static BOOL HSTextObjectFloatsAreEqual(float aValue, float aValue2)
{
    float magnitude = (aValue != 0.0f) ? fabsf(aValue) : 1.0f;
    float magnitude2 = (aValue2 != 0.0f) ? fabsf(aValue2) : 1.0f;
    if (magnitude2 <= magnitude)
        magnitude2 = magnitude;
    return fabsf(aValue - aValue2) <= magnitude2 * 0.0005f;
}

@implementation HSTextObject

/* i386 ivar offsets: _isInited=0x82, _rectSide=0x84 */

+ (CGFloat)widthOfTextContainerForTextObjectWithSize:(NSSize)aSize
{
    return ceilf(aSize.width);
}

+ (id)textImplementationInterfaces
{
    if (HSTextObjectImplementationInterfaces == nil)
        HSTextObjectImplementationInterfaces = [[NSSet alloc] initWithObjects:
            [HSProtocolIdentifier identifierForProtocol:@protocol(HSTextObjectAttributes)],
            [HSProtocolIdentifier identifierForProtocol:@protocol(HSGenericFontAttributes)],
            [HSProtocolIdentifier identifierForProtocol:@protocol(HSGenericSolidColorAttributes)], nil];
    return HSTextObjectImplementationInterfaces;
}

+ (Class)nodeDataClass
{
    return [HSTextObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        @"HSSizeNodeUnit", @"Size Unit",
        @"HSGeometryNodeUnit", @"Geometry Unit",
        @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
        @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
        @"HSShowHideTransitionNodeUnit", @"Transition Unit",
        @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit", nil];
}

- (id)valuesForMDAttribute:(id)aAttribute
{
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent]) {
        NSString *string = [self objectString];
        if (string != nil)
            return [[super valuesForMDAttribute:aAttribute] arrayByAddingObject:string];
    }
    return [super valuesForMDAttribute:aAttribute];
}

- (id)supportedMDAttributes
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super supportedMDAttributes]];
    if (![attributes containsObject:(NSString *)kMDItemTextContent])
        [attributes addObject:(NSString *)kMDItemTextContent];
    return attributes;
}

// Ranges are replaced front to back without adjusting the later ones
// (original).
- (void)setObjectString:(id)aString
{
    [self setHyperStringValue:aString];
}

- (id)objectString
{
    return [self hyperStringValue];
}

- (void)setHyperAttributedStringValue:(id)aValue
{
    [[self queryHyperInterface:@protocol(HSTextObjectAttributes)] hyperReplaceText:aValue];
}

- (id)hyperAttributedStringValue
{
    return [self cocoaTextStorage];
}

- (void)setHyperStringValue:(id)aValue
{
    [[self queryHyperInterface:@protocol(HSTextObjectAttributes)] hyperReplaceTextWithString:aValue];
}

- (id)hyperStringValue
{
    return [[self cocoaTextStorage] string];
}

- (id)hyperSizeMinValue
{
    return [[HSValueConstraints sharedConstraints] constraintForKey:@"HSTextObjectSizeMinValue"];
}

- (id)queryTextObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryEditorHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorHitTestingVisualization)] autorelease];
}

- (id)queryInteractiveHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSPlayerHitTestingVisualization)] autorelease];
}

- (id)queryDefaultHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self] autorelease];
}

- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName
{
}

- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName
{
    if (aSize)
        [self hyperAutoSizeToFitTextWithUndoActionName:aName];
}

- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName
{
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [self userObjectNameBaseTemplateDidChange];
    [self hyperAutoSizeToFitTextWithUndoActionName:aName];
}

- (void)textDidChangeAttributes:(id)aAttributes
{
    [self notifyChange:2 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
}

- (void)textWillChangeAttributes:(id)aAttributes
{
    [self notifyChange:1 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
}

- (void)textDidChangeText:(id)aText
{
    [self notifyChange:2 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
}

- (void)textWillChangeText:(id)aText
{
    [self notifyChange:1 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
}

- (id)undoManager
{
    return [super undoManager];
}

// Resizes about the sticky side: left by default, the middle for centered
// and the right for right-aligned text. The side is taken once, on the
// first autosize (original).
- (void)hyperAutoSizeToFitTextWithUndoActionName:(id)aName
{
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil)
        return;
    NSSize size = [(id<HSSizeAttributes>)[applier mutableGeometryAttributes] size];
    NSPoint point = NSZeroPoint;
    if (!_isInited) {
        _rectSide = [self stickyHorizontalSideForAutoresizing];
        _isInited = 1;
    }
    if (_rectSide == 4)
        point.x = 0.5;
    else if (_rectSide == 2)
        point.x = 1.0;
    NSSize newSize = [HSCoreText hyperSizeForText:[self text] withOptions:[self hyperAutoresizingOptions]];
    if (HSTextObjectFloatsAreEqual(size.width, newSize.width) && HSTextObjectFloatsAreEqual(size.height, newSize.height))
        return;
    [[self nodeData] setAutosizing:YES];
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [applier resizeFrameTo:newSize aboutRelativePoint:point withLayoutGuidingContext:nil];
    [[self nodeData] setAutosizing:NO];
}

// The card size of the outermost stack above the object.
- (NSSize)hyperParentSize
{
    NSSize size = NSZeroSize;
    id parent = [self hyperParent];
    while (parent != nil) {
        id stack = [parent queryHyperInterface:@protocol(HSStackAttributes)];
        if (stack != nil)
            size = [stack hyperCardSize];
        id child = [parent queryHyperInterface:@protocol(HSNodeChild)];
        if (child == nil)
            break;
        parent = [child hyperParent];
    }
    return size;
}

- (id)cocoaTextStorage
{
    return [[self text] textStorage];
}

- (NSInteger)stickyHorizontalSideForAutoresizing
{
    unsigned int alignment = 0;
    BOOL multipleValues = NO;
    [[self text] getHyperTextAlignment:&alignment multipleValues:&multipleValues];
    if (multipleValues)
        return 0;
    if (alignment == 1)
        return 2;
    if (alignment == 2)
        return 4;
    return 0;
}

// A dimension the user set is kept; the others may grow up to the card size.
- (struct HSTextObjectAutoresizingOptions)hyperAutoresizingOptions
{
    struct HSTextObjectAutoresizingOptions options;
    BOOL widthSetByUser = [[self nodeData] widthSetByUser];
    BOOL heightSetByUser = [[self nodeData] heightSetByUser];
    NSSize parentSize = NSZeroSize;
    if (!widthSetByUser || !heightSetByUser)
        parentSize = [self hyperParentSize];
    NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    options.f0 = widthSetByUser ? [HSTextObject widthOfTextContainerForTextObjectWithSize:size] : parentSize.width;
    options.f1 = heightSetByUser ? size.height : parentSize.height;
    options.f2 = widthSetByUser;
    options.f3 = heightSetByUser;
    return options;
}

- (void)hyperAutoSizeToFitText
{
    [self hyperAutoSizeToFitTextWithUndoActionName:nil];
}

- (NSInteger)hyperAutoresizingMode
{
    if ([[self nodeData] widthSetByUser])
        return 1;
    return [[self nodeData] heightSetByUser] ? 2 : 0;
}

- (void)setTextBlockVerticalAlignment:(NSInteger)aAlignment
{
    if ([[self nodeData] verticalAlignment] == aAlignment)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Vertical Alignment" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextBlockVerticalAlignment:[[self nodeData] verticalAlignment]];
    [self notifyChange:1 ofAttribute:@protocol(HSTextObjectVerticalAlignmentAttribute) withUserInfo:nil];
    [[self nodeData] setVerticalAlignment:aAlignment];
    [self notifyChange:2 ofAttribute:@protocol(HSTextObjectVerticalAlignmentAttribute) withUserInfo:nil];
}

- (NSInteger)textBlockVerticalAlignment
{
    return [[self nodeData] verticalAlignment];
}

- (NSRect)maximumVisibleBoundsForText
{
    NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSRect bounds;
    bounds.origin = NSZeroPoint;
    bounds.size.width = [[self class] widthOfTextContainerForTextObjectWithSize:size];
    bounds.size.height = size.height;
    return bounds;
}

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    float opacity = [(HSTextObjectData *)[self nodeData] opacity];
    if (HSTextObjectFloatsAreEqual(opacity, aOpacity))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:[(HSTextObjectData *)[self nodeData] opacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    [(HSTextObjectData *)[self nodeData] setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}

- (CGFloat)hyperOpacity
{
    return [(HSTextObjectData *)[self nodeData] opacity];
}

- (void)setOpacity:(CGFloat)aOpacity
{
    [(HSTextObjectData *)[self nodeData] setOpacity:aOpacity];
}

- (CGFloat)opacity
{
    return [(HSTextObjectData *)[self nodeData] opacity];
}

- (void)setFontFamily:(id)aFamily
{
    [[self text] setHyperFontFamily:aFamily undoActionName:nil];
}

- (id)fontFamily
{
    return [[self text] hyperFontFamily];
}

// Text objects are loaded as system text views unless class substitution is
// disabled. When the first open document remapped UIDs, the shared node data
// UID of the dictionary is remapped first; the new text view still gets the
// shared UID read before the remap (original). Group objects move their node
// data from the groups over to the text view.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    NSMutableDictionary *uidsMap = nil;
    HSUID *sharedUID = nil;
    id dictionary = aDictionary;
    NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
    if ([documents count] != 0) {
        uidsMap = [[[documents objectAtIndex:0] cardGroupController] oldUIDsToNewUIDsMap];
        if (uidsMap != nil && [uidsMap count] != 0) {
            id newUIDString = [uidsMap objectForKey:[[aDictionary objectForKey:@"sharedNodeDataUID"] objectForKey:@"stringValue"]];
            if (newUIDString != nil) {
                NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
                id uidDictionary = [mutableDictionary objectForKey:@"sharedNodeDataUID"];
                sharedUID = [HSUID objectWithExtraDictionary:uidDictionary];
                // The original set the new string in the loaded dictionary itself.
                NSMutableDictionary *newUIDDictionary = [NSMutableDictionary dictionaryWithDictionary:uidDictionary];
                [newUIDDictionary setObject:newUIDString forKey:@"stringValue"];
                [mutableDictionary setObject:[NSDictionary dictionaryWithDictionary:newUIDDictionary] forKey:@"sharedNodeDataUID"];
                dictionary = [NSDictionary dictionaryWithDictionary:mutableDictionary];
            }
        }
    }
    self = [super initWithExtraDictionary:dictionary codingContext:aContext];
    if (self == nil)
        return nil;
    if ([[[(EXCodingContext *)aContext options] objectForKey:HSDisableClassSubstitutionCodingKey] boolValue])
        return self;

    HSSystemTextView *textView = [HSSystemTextView defaultObject];
    [textView setUID:[self hyperUID]];
    if (sharedUID != nil) {
        [textView setSharedNodeDataUID:sharedUID];
        [textView setExplicitNodeDataProvider:[self nodeDataProvider]];
        [textView setLocalNodeData:nil];
        NSEnumerator *roles = [self unitRoleEnumerator];
        id role;
        while ((role = [roles nextObject]) != nil)
            [textView injectUnit:[self unitForRole:role] forRole:role];
    } else {
        id applier = [[textView queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        id sizeAttributes = [self queryHyperInterface:@protocol(HSSizeAttributes)];
        id geometryAttributes = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (sizeAttributes != nil && geometryAttributes != nil) {
            BOOL flipped = [geometryAttributes isFlippedHorizontally];
            [applier setSize:[(id<HSSizeAttributes>)sizeAttributes size] affineTransform:[geometryAttributes affineTransform] flippedHorizontally:flipped withLayoutGuidingContext:nil];
        } else if (geometryAttributes != nil) {
            [applier setAffineTransform:[geometryAttributes affineTransform] withLayoutGuidingContext:nil];
        }
        id cardAttributes = [self queryHyperInterface:@protocol(HSCardObjectAttributes)];
        if (cardAttributes != nil) {
            [textView setHidden:[cardAttributes isHidden]];
            [textView setDraggable:[cardAttributes isDraggable]];
            [textView setLocked:[cardAttributes isLocked]];
            [textView setResizable:[cardAttributes isResizable]];
            [textView setRotatable:[cardAttributes isRotatable]];
            if ([cardAttributes isGroupObject] && [self sharedNodeDataUID] != nil) {
                [[textView localNodeData] setGroupObjectFlag:YES];
                id localUID = [[[textView localNodeData] nodeDataUID] retain];
                [[textView localNodeData] setNodeDataUID:[self sharedNodeDataUID]];
                [[self nodeData] setNodeDataUID:localUID];
                [localUID release];
                NSEnumerator *groups = [[[self nodeDataProvider] groups] objectEnumerator];
                id group;
                while ((group = [groups nextObject]) != nil) {
                    id data = [group nodeDataWithUID:[[self nodeData] nodeDataUID]];
                    if (data == nil)
                        continue;
                    [[group nodeDataForOldVersionsSupport] addObject:data];
                    [group removeData:data];
                    [group addData:[textView nodeData]];
                    [textView setSharedNodeDataUID:[self sharedNodeDataUID]];
                    [textView setExplicitNodeDataProvider:[self nodeDataProvider]];
                    [textView setLocalNodeData:nil];
                    [uidsMap setObject:[[textView sharedNodeDataUID] stringValue] forKey:[[data nodeDataUID] stringValue]];
                    NSEnumerator *roles = [self unitRoleEnumerator];
                    id role;
                    while ((role = [roles nextObject]) != nil)
                        [textView injectUnit:[self unitForRole:role] forRole:role];
                    break;
                }
            }
        }
    }

    [textView setHyperText:[[[self queryHyperInterface:@protocol(HSTextObjectAttributes)] coreTextInterface] hyperText]];
    id shadowAttributes = [self queryHyperInterface:@protocol(HSShadowAttributes)];
    id fontTraits = [textView queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    if ([shadowAttributes isHyperShadowEnabled]) {
        [fontTraits setHyperShadowEnabled:YES];
        [fontTraits setHyperShadowAngle:[shadowAttributes hyperShadowAngle]];
        [fontTraits setHyperShadowDistance:[shadowAttributes hyperShadowDistance]];
        [fontTraits setHyperShadowBlurRadius:[shadowAttributes hyperShadowBlurRadius]];
    }
    [fontTraits setHyperSpaceBetweenCharacters:[[self queryHyperInterface:@protocol(HSTextObjectAttributes)] hyperSpaceBetweenCharacters]];
    [self release];
    return (id)[textView retain];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:HSTextFontFamilySerializationKey];
    [keys addObject:@"text"];
    [keys addObject:@"opacity"];
    [keys addObject:@"widthSetByUser"];
    [keys addObject:@"heightSetByUser"];
    [keys addObject:@"verticalAlignment"];
    [keys addObject:@"serializedText"];
    [keys addObject:@"textStorageContainsDummyString"];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    id keys = [super keysForExtraStoringWithCodingContext:aContext];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        keys = [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"textStyleAttributes", nil]];
    return keys;
}

- (void)setVerticalAlignment:(NSInteger)aAlignment
{
    [[self nodeData] setVerticalAlignment:aAlignment];
}

- (NSInteger)verticalAlignment
{
    return [[self nodeData] verticalAlignment];
}

- (void)setHeightSetByUser:(BOOL)aUser
{
    [[self nodeData] setHeightSetByUser:aUser];
}

- (BOOL)heightSetByUser
{
    return [[self nodeData] heightSetByUser];
}

- (void)setWidthSetByUser:(BOOL)aUser
{
    [[self nodeData] setWidthSetByUser:aUser];
}

- (BOOL)widthSetByUser
{
    return [[self nodeData] widthSetByUser];
}

- (void)setTextStorageContainsDummyString:(BOOL)aString
{
    [[self nodeData] setTextStorageContainsDummyString:aString];
}

- (BOOL)textStorageContainsDummyString
{
    return [[self nodeData] textStorageContainsDummyString];
}

- (void)setTextStyleAttributes:(id)aAttributes
{
    [[self text] applyHyperTextAttributes:aAttributes undoActionName:nil];
}

- (id)textStyleAttributes
{
    return [[self text] hyperTextAttributesDictionary];
}

- (void)setSerializedText:(id)aText
{
    [[self nodeData] setDeserializedText:aText];
    if ([[self nodeData] text] != nil)
        [self setText:nil];
}

- (id)serializedText
{
    return [[[NSAttributedString alloc] initWithAttributedString:[[self text] textStorage]] autorelease];
}

- (BOOL)canMoveVertically
{
    return YES;
}

- (BOOL)canMoveHorizontally
{
    return YES;
}

- (BOOL)canRotate
{
    return YES;
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return YES;
}

- (BOOL)canFlipHorizontally
{
    return YES;
}

- (BOOL)canScaleVertically
{
    return NO;
}

- (BOOL)canScaleHorizontally
{
    return NO;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
}

- (NSSize)defaultSize
{
    return NSMakeSize(87.0, 40.0);
}

// Setting the height also marks the width as set.
- (void)setHyperHeightSetByUser:(BOOL)aUser
{
    [self setPrimitiveHeightSetByUser:aUser];
    if (aUser && ![[self nodeData] widthSetByUser])
        [self setHyperWidthSetByUser:YES];
}

- (void)setPrimitiveHeightSetByUser:(BOOL)aUser
{
    if ((BOOL)[[self nodeData] heightSetByUser] == (aUser != NO))
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setPrimitiveHeightSetByUser:[[self nodeData] heightSetByUser]];
    [[self nodeData] setHeightSetByUser:aUser != NO];
}

- (void)setHyperWidthSetByUser:(BOOL)aUser
{
    if ((BOOL)[[self nodeData] widthSetByUser] == (aUser != NO))
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperWidthSetByUser:[[self nodeData] widthSetByUser]];
    [[self nodeData] setWidthSetByUser:aUser != NO];
}

- (BOOL)hyperHeightSetByUser
{
    return [[self nodeData] heightSetByUser];
}

- (BOOL)hyperWidthSetByUser
{
    return [[self nodeData] widthSetByUser];
}

- (id)nameBaseTemplates
{
    return [NSArray arrayWithObjects:[[self text] hyperString], nil];
}

- (BOOL)isEmpty
{
    return [[self text] isHyperEmpty];
}

- (id)coreTextInterface
{
    return [self text];
}

- (id)text
{
    return [[self nodeData] text];
}

- (void)setText:(id)aText
{
    if ([[self nodeData] text] != aText)
        [[self nodeData] setText:aText];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSTextObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface))
        return [[[HSHitTestingTextObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSGeometryBehaviorAdapting), aInterface))
        return [[[HSTextObjectGeometryBehaviorAdaptor alloc] initWithTextObject:self] autorelease];
    if ([[HSTextObject textImplementationInterfaces] containsObject:[HSProtocolIdentifier identifierForProtocol:aInterface]])
        return [[[HSTextObjectAttributesImplementation alloc] initWithHyperObject:self interfaces:[HSTextObject textImplementationInterfaces]] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (id)init
{
    self = [super init];
    [self linkAttribute:@protocol(HSTextMaximumVisibleBoundsAttribute) toAttribute:@protocol(HSSizeAttribute)];
    return self;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

@end
