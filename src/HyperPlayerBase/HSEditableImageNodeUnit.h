#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSEditableImageNodeUnit : HSNodeUnit <BTImageUndoingDelegate>
{
    id<BTImage> _image;
    id<BTImageUndoing> _imageUndoer;
    NSDictionary *_notificationInfo;
    HSNewMedia *_media;
    unsigned int _isImageBeingEdited:1;
    unsigned int _isImageUndoGroupingScheduled:1;
    unsigned int _isImageUndoGroupingBegun:1;
}
+ (struct CGContext *)bitmapLayerForCocoaImage:(id)aImage;
+ (struct CGContext *)bitmapLayerForCGImage:(id)aImage;
- (void)imageUndoer:(id)aUndoer didChangeImageInRect:(CGRect)aRect;
- (void)imageUndoer:(id)aUndoer willChangeImageInRect:(CGRect)aRect;
- (id)prepareUndoForImageUndoer:(id)aUndoer withInvocationTarget:(id)aTarget;
- (void)registerUndoForImageUndoer:(id)aUndoer withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
- (void)setEditableImageMedia:(id)aMedia;
- (id)editableImageMedia;
- (void)endEditImage;
- (void)beginEditImage:(id)aImage inRect:(NSRect)aRect;
- (void)beginEditImage:(id)aImage;
- (void)HSEditableImageNodeUnit_beginEditImage:(id)aImage inRect:(NSRect)aRect;
- (id)HSEditableImageNodeUnit_notificationInfoWithChangedRect:(CGRect)aRect;
- (void)endEditImageContinuously;
- (void)beginEditImageContinuously;
- (id)queryImageWithRequiredProtocols:(id *)aProtocols optionalProtocols:(id *)aProtocols2;
- (id)NSImage;
- (id)image;
- (BOOL)hasImage;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
- (id)attributes;
- (id)mediaUIDs;
- (void)setMediaUID:(id)aUID;
- (id)mediaUID;
- (id)media;
- (void)HSEditableImageNodeUnit_setEditedImage:(id)aImage undoer:(id)aUndoer withWillNotificationInfo:(id)aInfo didNotificationInfo:(id)aInfo2;
- (void)HSEditableImageNodeUnit_releaseMedia;
- (void)dealloc;
@end

