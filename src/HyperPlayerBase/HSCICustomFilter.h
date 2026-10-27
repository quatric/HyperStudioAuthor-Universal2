#import "HyperPlayerBasePrefix.h"


@interface HSCICustomFilter : CIFilter
{
    CIImage *_inputImage;
    QCRenderer *_renderer;
    NSOpenGLContext *_context;
    NSWindow *_window;
    NSDictionary *_customAttributes;
}
+ (id)customFilterCategories;
+ (id)customFilterDisplayName;
+ (id)customFilterName;
+ (id)customFilterPath;
+ (id)filterWithName:(id)aName;
+ (void)initialize;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (id)valueForKey:(id)aKey;
- (id)customAttributes;
- (id)outputImage;
- (void)setInputImage:(id)aImage;
- (id)inputImage;
- (void)dealloc;
- (id)init;
@end

