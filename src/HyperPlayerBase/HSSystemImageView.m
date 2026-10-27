#import "HSSystemImageView.h"
#import "HSExecutableResourceProvider.h"
#import "HSInteractiveImageViewObject.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "HSSystemImageViewData.h"
#import "HSSystemObjectVisualization.h"
#import "HSValueConstraints.h"

// An image well (NSImageView) showing an image media.
@implementation HSSystemImageView

+ (Class)nodeDataClass
{
    return [HSSystemImageViewData class];
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureImageWell" value:@"" table:@"Export"];
}

- (id)hyperSizeMaxValue
{
    return [[HSValueConstraints sharedConstraints] constraintForKey:@"HSSystemImageViewSizeMaxValue"];
}

// Frame style 2 has its own minimum.
- (id)hyperSizeMinValue
{
    NSUInteger frameStyle = [self hyperImageFrameStyle];
    return [[HSValueConstraints sharedConstraints] constraintForKey:frameStyle == 2 ? @"HSSystemImageViewSizeMinValue" : @"hyperSizeMinValue"];
}

- (NSSize)defaultSize
{
    return NSMakeSize(89, 72);
}

// Quirk kept: the undo action name is the editability one.
- (void)setEnabled:(BOOL)aEnabled
{
    if ([self isEnabled] == aEnabled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Editabling" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setEnabled:[self isEnabled]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemEnabledAttribute) withUserInfo:nil];
    [[self nodeData] setEnabled:aEnabled];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemEnabledAttribute) withUserInfo:nil];
}

- (BOOL)isEnabled
{
    return [[self nodeData] isEnabled];
}

- (void)setEditable:(BOOL)aEditable
{
    if ([self isEditable] == aEditable)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Editabling" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setEditable:[self isEditable]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemEditableAttribute) withUserInfo:nil];
    [[self nodeData] setEditable:aEditable];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemEditableAttribute) withUserInfo:nil];
}

- (BOOL)isEditable
{
    return [[self nodeData] isEditable];
}

- (void)setHyperImageScaling:(NSUInteger)aScaling
{
    if ([self imageScaling] == aScaling)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Image Scaling" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperImageScaling:[self imageScaling]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemImageViewScalingAttribute) withUserInfo:nil];
    [self setImageScaling:aScaling];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemImageViewScalingAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperImageScaling
{
    return [self imageScaling];
}

- (void)setHyperImageFrameStyle:(NSUInteger)aStyle
{
    if ([self imageFrameStyle] == aStyle)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Image Frame Style" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperImageFrameStyle:[self imageFrameStyle]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemImageViewFrameStyleAttribute) withUserInfo:nil];
    [self setImageFrameStyle:aStyle];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemImageViewFrameStyleAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperImageFrameStyle
{
    return [self imageFrameStyle];
}

- (void)setHyperImageAlignment:(NSUInteger)aAlignment
{
    if ([self imageAlignment] == aAlignment)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Image Alignment" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperImageAlignment:[self imageAlignment]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemImageViewAlignmentAttribute) withUserInfo:nil];
    [self setImageAlignment:aAlignment];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemImageViewAlignmentAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperImageAlignment
{
    return [self imageAlignment];
}

- (void)setImageWithPath:(id)aPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:aPath])
        return;
    if ([[NSFileManager defaultManager] hyperIsReadableFileAtPath:aPath showAlert:YES error:NULL])
        [self setMedia:[HSNewMedia mediaWithPath:aPath]];
}

- (void)setImage:(id)aImage
{
    [self setMedia:aImage != nil ? [HSNewMedia mediaWithImage:aImage] : nil];
}

// The cell's image rect, flipped to the object's top-left origin.
- (NSRect)imageRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    NSRect bounds = [geometry boundingRect];
    NSRect rect = [[(NSImageView *)[[self nodeData] systemImageViewForGetAccessor] cell] imageRectForBounds:bounds];
    rect.origin.y = bounds.size.height - (rect.origin.y + rect.size.height);
    return rect;
}

- (BOOL)isImageComposite
{
    return YES;
}

// The view gets the media's image when it has none yet.
- (id)image
{
    if ([(NSImageView *)[[self nodeData] systemImageViewForGetAccessor] image] == nil) {
        NSImage *image = [[self media] image];
        [(NSImageView *)[[self nodeData] systemImageViewForSetAccessor] setImage:image];
        return image;
    }
    return [(NSImageView *)[[self nodeData] systemImageViewForGetAccessor] image];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSSystemObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (void)setImageScaling:(NSUInteger)aScaling
{
    [[self nodeData] setImageScaling:aScaling];
}

- (NSUInteger)imageScaling
{
    return [[self nodeData] imageScaling];
}

- (void)setImageFrameStyle:(NSUInteger)aStyle
{
    [[self nodeData] setImageFrameStyle:aStyle];
}

- (NSUInteger)imageFrameStyle
{
    return [[self nodeData] imageFrameStyle];
}

- (void)setImageAlignment:(NSUInteger)aAlignment
{
    [[self nodeData] setImageAlignment:aAlignment];
}

- (NSUInteger)imageAlignment
{
    return [[self nodeData] imageAlignment];
}

- (id)queryImageWellObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveImageViewObject alloc] initWithNode:self] autorelease];
}

- (id)nameBaseTemplates
{
    return [NSArray array];
}

- (void)setMedia:(id)aMedia
{
    [self setMedia:aMedia error:NULL];
}

- (void)setMedia:(id)aMedia error:(id *)aError
{
    if (_media == aMedia)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Insert Image" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMedia:[self media]];
    if (![[aMedia mediaUID] isEqualTo:[self mediaUID]] && [aMedia mediaUID] != [self mediaUID])
        [[self nodeData] setImageMediaUID:[aMedia mediaUID]];
    [self notifyChange:1 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
    [_media release];
    _media = [aMedia retain];
    [(NSImageView *)[[self nodeData] systemImageViewForSetAccessor] setImage:[_media image]];
    [self notifyChange:2 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
    [self userObjectNameBaseTemplateDidChange];
}

// Loaded from the media UID on first use.
- (id)media
{
    if (_media == nil && [self mediaUID] != nil)
        _media = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[self mediaUID]] retain];
    return _media;
}

- (id)mediaUID
{
    return [[self nodeData] imageMediaUID];
}

- (void)didCreateSystemView
{
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemImageViewAlignmentAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemImageViewFrameStyleAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemImageViewScalingAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSMediaAttribute)];
}

- (id)placeholderSystemView
{
    return nil;
}

- (id)hyperSystemView
{
    id view = [super hyperSystemView];
    if ([view image] == nil)
        [view setImage:[self image]];
    return view;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"editable"];
    [keys addObject:@"enabled"];
    [keys addObject:@"imageAlignment"];
    [keys addObject:@"imageFrameStyle"];
    [keys addObject:@"imageName"];
    [keys addObject:@"imageScaling"];
    return keys;
}

// Added: the original had no dealloc and leaked the media.
- (void)dealloc
{
    [_media release];
    [super dealloc];
}

- (id)initWithMedia:(id)aMedia
{
    return [self initWithMedia:aMedia error:NULL];
}

// Sized to the image, without a frame; nil without an image.
- (id)initWithMedia:(id)aMedia error:(id *)aError
{
    self = [self init];
    NSImage *image = aMedia != nil ? [aMedia image] : nil;
    if (self == nil || image == nil) {
        [self release];
        return nil;
    }
    [(id<HSMutableSizeAttributes>)[self queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:[image size]];
    [self setHyperImageFrameStyle:0];
    [self setMedia:aMedia];
    return self;
}

@end
