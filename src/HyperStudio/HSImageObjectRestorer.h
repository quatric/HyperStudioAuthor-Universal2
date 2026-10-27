#import "HyperStudioPrefix.h"


@interface HSImageObjectRestorer : NSObject
{
}
+ (void)restoreNodeToOriginal:(id)aOriginal;
+ (void)restoreImageGeometry:(id)aGeometry;
+ (void)restoreClippedImage:(id)aImage;
+ (void)restoreEffectedImage:(id)aImage;
+ (BOOL)canRestoreNode:(id)aNode;
+ (BOOL)canRestoreImageGeometry:(id)aGeometry;
+ (BOOL)canRestoreClippedImage:(id)aImage;
+ (BOOL)canRestoreClippedImageRect:(id)aRect;
+ (BOOL)canRestoreEffectedImage:(id)aImage;
@end

