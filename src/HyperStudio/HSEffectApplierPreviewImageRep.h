#import "HyperStudioPrefix.h"


@interface HSEffectApplierPreviewImageRep : NSImageRep
{
    NSImage *_image;
}
- (BOOL)draw;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithImage:(id)aImage size:(NSSize)aSize;
@end

@interface HSHyperObjectEffectApplier : NSObject
{
    id _originalObject;
    NSString *_undoActionName;
}
+ (id)effectApplierForHyperObject:(id)aObject;
- (void)setUndoActionName:(id)aName;
- (id)undoActionName;
- (void)applyHyperEffect:(id)aEffect;
- (void)applyEffectWithDelegate:(id)aDelegate userInfo:(void *)aInfo;
- (id)originalObject;
- (id)previewObject;
- (id)previewImageForImage:(id)aImage;
- (id)previewImage;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
- (id)HSHyperObjectEffectApplier_initWithHyperObject:(id)aObject;
@end

@interface HSHyperProxyEffectApplier : HSHyperObjectEffectApplier
{
    id _previewObject;
    NSArray *_allHyperInterfaces;
    HSCIEffect *_coreImageEffect;
    HSQTEffect *_quickTimeEffect;
    CGAffineTransform _preEffectApplyingTransform;
    CGAffineTransform _postEffectApplyingTransform;
}
+ (SEL)delegateSelector;
- (void)applyHyperEffect:(id)aEffect;
- (void)applyEffectWithDelegate:(id)aDelegate userInfo:(void *)aInfo;
- (BOOL)doesObjectHaveEffect;
- (void)collectEffectSettingsForPreviewObject:(id)aObject;
- (id)previewObject;
- (id)previewImageForImage:(id)aImage;
- (id)originalObject;
- (id)previewObjectFromInterfacesArray:(id)aArray;
- (id)allHyperInterfaces;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
@end

@interface HSEditableImageAttributesEffectApplier : HSHyperProxyEffectApplier
{
}
+ (SEL)delegateSelector;
- (id)previewImage;
- (void)applyEffectForHSEditableImageAttributes:(id)aAttributes userInfo:(void *)aInfo;
@end

@interface HSButtonObjectAttributesEffectApplier : HSHyperProxyEffectApplier
{
}
+ (SEL)delegateSelector;
- (id)previewImage;
- (id)previewObjectFromInterfacesArray:(id)aArray;
- (void)applyEffectForHSButtonObjectAttributes:(id)aAttributes userInfo:(void *)aInfo;
@end

@interface HSImageMutableAttributesEffectApplier : HSHyperProxyEffectApplier
{
}
+ (SEL)delegateSelector;
- (id)previewImage;
- (void)applyEffectForHSImageMutableAttributes:(id)aAttributes userInfo:(void *)aInfo;
@end

@interface HSImageObjectAttributesEffectApplier : HSHyperProxyEffectApplier
{
    NSImage *_previewImage;
}
+ (SEL)delegateSelector;
- (id)previewImageForImage:(id)aImage;
- (id)previewImage;
- (void)applyEffectForHSImageObjectAttributes:(id)aAttributes userInfo:(void *)aInfo;
- (void)dealloc;
@end

@interface HSGraphicSelectionToolEffectApplier : HSHyperObjectEffectApplier
{
}
+ (SEL)delegateSelector;
- (void)applyHyperEffect:(id)aEffect;
- (void)applyEffectWithDelegate:(id)aDelegate userInfo:(void *)aInfo;
- (id)previewImageForImage:(id)aImage;
- (id)previewImage;
- (id)initWithHyperObject:(id)aObject;
@end

