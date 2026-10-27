#import "HSSystemSquareButton.h"
#import "HSSystemSquareButtonData.h"
#import "HSValueConstraints.h"
#import "HSNewMediaAccessor.h"

// A square (bevel) system button with an image and an alternate image. The
// image rect depends on the title while there is an image, and on the image
// while there is a title, so those attributes are linked only while both
// exist.
@implementation HSSystemSquareButton

+ (Class)nodeDataClass
{
    return [HSSystemSquareButtonData class];
}

- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    BOOL equal = [super isHyperEqual:aEqual];
    if ([self title] != nil || [aEqual title] != nil)
        equal = equal && [[self title] isEqualToString:[aEqual title]];
    if ([self imageMediaUID] != nil || [aEqual imageMediaUID] != nil)
        equal = equal && [[self imageMediaUID] isEqual:[aEqual imageMediaUID]];
    if ([self alternateImageMediaUID] != nil || [aEqual alternateImageMediaUID] != nil)
        equal = equal && [[self alternateImageMediaUID] isEqual:[aEqual alternateImageMediaUID]];
    return equal && [self imagePosition] == [aEqual imagePosition];
}

- (id)hyperSizeMaxValue
{
    return [[HSValueConstraints sharedConstraints] constraintForKey:@"HSSquareButtonSizeMaxValue"];
}

- (id)hyperSizeMinValue
{
    return [[HSValueConstraints sharedConstraints] constraintForKey:@"HSSquareButtonSizeMinValue"];
}

- (NSUInteger)hyperTitleAlignment
{
    return 2;   // centred
}

// Image position 1 (NSImageOnly) hides the title.
- (BOOL)hasHyperTitle
{
    return [self imagePosition] != NSImageOnly;
}

- (void)setTitle:(id)aTitle
{
    NSUInteger oldLength = [[self title] length];
    NSUInteger newLength = [aTitle length];
    if (oldLength == 0 && newLength != 0) {
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleFontAttribute)];
    }
    [super setTitle:aTitle];
    if (oldLength != 0 && newLength == 0) {
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleStringAttribute)];
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleFontAttribute)];
    }
}

- (BOOL)canResizeVertically
{
    return YES;
}

// Sizes to the button cell, keeping the centre.
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically
{
    id geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    if (geometry == nil)
        return;
    NSSize size = [[[[self nodeData] systemButtonForGetAccessor] cell] cellSize];
    if (!aHorizontally)
        size.width = [(id<HSMutableGeometryAttributes>)geometry width];
    if (!aVertically)
        size.height = [(id<HSMutableGeometryAttributes>)geometry height];
    [geometry setSize:size aboutRelativePoint:NSMakePoint(0.5, 0.5)];
}

- (void)setImagePosition:(NSUInteger)aPosition
{
    if ([self imagePosition] == aPosition)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Move" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setImagePosition:[self imagePosition]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemSquareButtonImagePositionAttribute) withUserInfo:nil];
    [[[self nodeData] systemButtonForSetAccessor] setImagePosition:aPosition];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemSquareButtonImagePositionAttribute) withUserInfo:nil];
}

- (NSUInteger)imagePosition
{
    return [(NSButton *)[[self nodeData] systemButtonForGetAccessor] imagePosition];
}

- (void)setAlternateImage:(id)aImage
{
    [self setAlternateMedia:[HSNewMedia mediaWithImage:aImage]];
}

- (id)alternateImage
{
    return [[self alternateMedia] image];
}

- (void)setImageFromPath:(id)aPath
{
    [self setMedia:[HSNewMedia mediaWithPath:aPath]];
}

- (void)setImage:(id)aImage
{
    [self setMedia:aImage != nil ? [HSNewMedia mediaWithImage:aImage] : nil];
}

- (id)image
{
    return [[self media] image];
}

- (id)mediaUID
{
    return [self imageMediaUID];
}

- (id)nameBaseTemplates
{
    NSMutableArray *templates = [NSMutableArray array];
    id title = [self title];
    if (title != nil)
        [templates addObject:title];
    id name = [[self media] mediaName];
    if (name != nil)
        [templates addObject:name];
    name = [[self alternateMedia] mediaName];
    if (name != nil)
        [templates addObject:name];
    return templates;
}

- (id)mediaUIDs
{
    NSMutableSet *UIDs = [NSMutableSet setWithSet:[super mediaUIDs]];
    if ([self mediaUID] != nil)
        [UIDs addObject:[self imageMediaUID]];
    if ([self alternateImageMediaUID] != nil)
        [UIDs addObject:[self alternateImageMediaUID]];
    return UIDs;
}

- (void)setAlternateMedia:(id)aMedia
{
    if (_alternateMedia == aMedia)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Alternate Icon" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setAlternateImageMediaUID:[self alternateImageMediaUID]];
    [self notifyChange:1 ofAttribute:@protocol(HSVisualSystemSquareButtonAlternateImageAttribute) withUserInfo:nil];
    [_alternateMedia release];
    _alternateMedia = [aMedia retain];
    [self systemButtonSetAlternateImage:[_alternateMedia image]];
    [self notifyChange:2 ofAttribute:@protocol(HSVisualSystemSquareButtonAlternateImageAttribute) withUserInfo:nil];
    [self userObjectNameBaseTemplateDidChange];
}

- (id)alternateMedia
{
    return _alternateMedia;
}

- (void)setAlternateImageMediaUID:(id)aUID
{
    [self setAlternateMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}

- (id)alternateImageMediaUID
{
    return [[self alternateMedia] mediaUID];
}

- (void)setImageMediaUID:(id)aUID
{
    if ([[[self nodeData] imageMediaUID] isEqual:aUID])
        return;
    [[self nodeData] setImageMediaUID:aUID];
    [self setMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}

- (id)imageMediaUID
{
    return [[self nodeData] imageMediaUID];
}

- (void)setMedia:(id)aMedia error:(id *)aError
{
    [self setMedia:aMedia];
}

// A media with another UID goes through setImageMediaUID:, which comes back
// here with the registered media.
- (void)setMedia:(id)aMedia
{
    if (_imageMedia == aMedia)
        return;
    if (![[self imageMediaUID] isEqualTo:[aMedia mediaUID]] && [self imageMediaUID] != [aMedia mediaUID]) {
        [self setImageMediaUID:[aMedia mediaUID]];
        return;
    }
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Icon" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMedia:_imageMedia];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemSquareButtonImageAttribute) withUserInfo:nil];
    [_imageMedia release];
    _imageMedia = [aMedia retain];
    [[self nodeData] setImageMediaUID:[_imageMedia mediaUID]];
    [self systemButtonSetImage:[_imageMedia image]];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemSquareButtonImageAttribute) withUserInfo:nil];
    [self userObjectNameBaseTemplateDidChange];
    [[self nodeData] setImageValid:_imageMedia != nil];
}

- (id)media
{
    if (_imageMedia == nil && [self imageMediaUID] != nil)
        _imageMedia = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[self imageMediaUID]] retain];
    return _imageMedia;
}

- (void)systemButtonSetAlternateImage:(id)aImage
{
    [[[self nodeData] systemButtonForSetAccessor] setAlternateImage:aImage];
}

- (void)systemButtonSetImage:(id)aImage
{
    id oldImage = [self image];
    if (oldImage == nil && aImage != nil) {
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleFontAttribute)];
    }
    [[[self nodeData] systemButtonForSetAccessor] setImage:aImage];
    [[self nodeData] setImageValid:YES];
    if (oldImage != nil && aImage == nil) {
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleStringAttribute)];
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleFontAttribute)];
    }
}

- (void)didCreateSystemView
{
    [super didCreateSystemView];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemButtonBorderAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTransparencyAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemButtonContinuousAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemSquareButtonImageAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSVisualSystemSquareButtonAlternateImageAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemSquareButtonImagePositionAttribute)];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"imageMediaUID"];
    [keys addObject:@"alternateImageMediaUID"];
    [keys addObject:@"imagePosition"];
    return keys;
}

- (void)dealloc
{
    [_imageMedia release];
    [_alternateMedia release];
    [super dealloc];
}

- (id)initWithMedia:(id)aMedia
{
    return [self initWithMedia:aMedia error:NULL];
}

- (id)initWithMedia:(id)aMedia error:(id *)aError
{
    self = [self init];
    if (self == nil || aMedia == nil) {
        [self release];
        return nil;
    }
    [self setMedia:aMedia];
    return self;
}

@end
